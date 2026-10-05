import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/rti/bloc/rti_entry_event.dart';
import 'package:maleva/features/rti/bloc/rti_entry_state.dart';
import 'package:maleva/features/rti/data/rti_entry_repository.dart';
import 'package:maleva/features/rti/data/rti_grid_rules.dart';
import 'package:maleva/features/rti/data/rti_mapper.dart';
import 'package:maleva/features/rti/data/rti_save_payload.dart';
import 'package:maleva/features/rti/models/fleet_expiry.dart';
import 'package:maleva/features/rti/models/rti_dates.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/models/rti_job_row.dart';
import 'package:maleva/features/rti/models/rti_rules.dart';
import 'package:maleva/core/widgets/ui/picker_sheet.dart' show PickSeverity;

export 'rti_entry_event.dart';
export 'rti_entry_state.dart';

/// The RTI entry (`R/pages/RTIPage.tsx` with `useRTIState` and `useRTIOperations`): the form,
/// the job grid and the route activities, their save, delete and revise. State lives here so
/// it survives rotation and the phone / tablet switch.
class RtiEntryBloc extends Bloc<RtiEntryEvent, RtiEntryState> {
  RtiEntryBloc({required RtiEntryRepository repository, RtiForm Function()? initialForm})
      : _repo = repository,
        _initial = initialForm ?? RtiForm.initial,
        super(RtiEntryState(form: (initialForm ?? RtiForm.initial)())) {
    on<RtiEntryStarted>(_onStarted);
    on<RtiReferencesRetried>((e, emit) => _loadReferences(emit));
    on<RtiFormChanged>(_onFormChanged);
    on<RtiDriverPicked>(_onDriverPicked);
    on<RtiTruckPicked>(_onTruckPicked);
    on<RtiJobCellEdited>((e, emit) => _setGrid(emit, [
          for (var i = 0; i < state.grid.length; i++) i == e.row ? state.grid[i].withCell(e.column, e.value) : state.grid[i],
        ]));
    on<RtiJobLookupRequested>(_onLookup);
    on<RtiJobRowAdded>((e, emit) => _setGrid(emit, [...state.grid, const RtiJobRow()]));
    on<RtiJobRowDeleted>((e, emit) => _setGrid(emit, RtiGridRules.deleteRow(state.grid, e.row)));
    on<RtiJobCellsPasted>((e, emit) => _setGrid(emit, RtiGridRules.paste(state.grid, e.row, e.column, e.text)));
    on<RtiStopAdded>((e, emit) => emit(state.copyWith(stops: RtiGridRules.addStop(state.stops, state.form.destination))));
    on<RtiStopEdited>((e, emit) => emit(state.copyWith(stops: RtiGridRules.editStop(state.stops, e.index, e.change))));
    on<RtiStopAgentPicked>((e, emit) => emit(state.copyWith(
        stops: RtiGridRules.editStop(state.stops, e.index, (s) => RtiGridRules.pickAgent(s, employee: e.employee, typed: e.typed)))));
    on<RtiStopDeleted>((e, emit) => emit(state.copyWith(stops: [
          for (var i = 0; i < state.stops.length; i++)
            if (i != e.index) state.stops[i],
        ])));
    on<RtiSaveRequested>(_onSave);
    on<RtiDeleteRequested>(_onDelete);
    on<RtiReviseRequested>(_onRevise);
    on<RtiClearRequested>(_onClear);
    on<RtiStepChanged>((e, emit) => emit(state.copyWith(step: e.step.clamp(0, 4))));
    on<RtiNoticeRaised>((e, emit) => _notice(emit, e.text, e.error ? RtiNoticeKind.error : RtiNoticeKind.success));
  }

  final RtiEntryRepository _repo;
  final RtiForm Function() _initial;
  int _seq = 0;

  /// The signed-in employee (0 for a driver login).
  int get employeeId => _repo.employeeId;

  void _notice(Emitter<RtiEntryState> emit, String text, RtiNoticeKind kind, {bool long = false}) =>
      emit(state.copyWith(notice: RtiNotice(text, kind, ++_seq, long: long)));

  void _setGrid(Emitter<RtiEntryState> emit, List<RtiJobRow> grid) =>
      emit(state.copyWith(grid: grid, errors: state.errors.isEmpty ? const [] : RtiRules.validate(state.form, grid)));

  Future<void> _onStarted(RtiEntryStarted e, Emitter<RtiEntryState> emit) async {
    final refs = _loadReferences(emit);
    final id = e.rtiId ?? 0;
    if (id > 0) {
      await _load(emit, id);
    } else if (e.fromPlanning.isNotEmpty) {
      final n = e.fromPlanning.length;
      emit(state.copyWith(
        status: RtiLoadStatus.ready,
        form: RtiMapper.planningForm(e.fromPlanning),
        grid: RtiGridRules.nonEmpty([for (final i in e.fromPlanning) RtiMapper.fromPlanning(i)]),
        stops: const [],
      ));
      _notice(emit, 'Loaded $n planning ${n == 1 ? 'order' : 'orders'} into RTI', RtiNoticeKind.success);
      await _nextNumber(emit);
    } else {
      emit(state.copyWith(status: RtiLoadStatus.ready));
      await _nextNumber(emit);
    }
    await refs;
  }

  Future<void> _loadReferences(Emitter<RtiEntryState> emit) async {
    emit(state.copyWith(refsLoading: true, refsError: null));
    try {
      final refs = await _repo.references();
      emit(state.copyWith(refs: refs, refsLoading: false));
    } catch (err) {
      emit(state.copyWith(refsLoading: false, refsError: '$err'));
    }
  }

  Future<void> _nextNumber(Emitter<RtiEntryState> emit) async {
    try {
      final no = await _repo.nextNumber();
      if (state.form.editId == 0 && state.form.rtiNo.isEmpty) emit(state.copyWith(form: state.form.copyWith(rtiNo: no)));
    } catch (_) {
      // a preview only: the server assigns the number on save
    }
  }

  Future<bool> _load(Emitter<RtiEntryState> emit, int id) async {
    try {
      final r = await _repo.load(id);
      emit(state.copyWith(
        status: RtiLoadStatus.ready,
        loadError: null,
        form: r.form,
        grid: RtiGridRules.nonEmpty(r.grid),
        stops: r.stops ?? const [],
        errors: const [],
        licenceWarning: null,
        reviseChanges: const {},
        inRevise: false,
      ));
      return true;
    } catch (err) {
      if (state.status == RtiLoadStatus.loading) emit(state.copyWith(status: RtiLoadStatus.failed, loadError: '$err'));
      return false;
    }
  }

  void _onFormChanged(RtiFormChanged e, Emitter<RtiEntryState> emit) {
    final before = state.form;
    var next = e.change(before);
    if (next.pickup == 'NO' && before.pickup != 'NO') next = next.copyWith(pickupCount: '');
    if (next.addDrop == 'NO' && before.addDrop != 'NO') next = next.copyWith(dropCount: '');
    final stops = next.destination != before.destination ? RtiGridRules.withDestination(state.stops, next.destination) : state.stops;
    emit(state.copyWith(form: next, stops: stops, errors: state.errors.isEmpty ? const [] : RtiRules.validate(next, state.grid)));
  }

  void _onDriverPicked(RtiDriverPicked e, Emitter<RtiEntryState> emit) {
    _onFormChanged(RtiFormChanged((f) => f.copyWith(driverRefId: e.driverId)), emit);
    if (e.driverId.isEmpty) return;
    final warnings = FleetExpiry.driver(state.driverRow(e.driverId));
    if (warnings.isEmpty) return;
    final critical = FleetExpiry.severityOf(warnings) == PickSeverity.critical;
    _notice(emit, warnings.map((w) => w.message).join('\n'), critical ? RtiNoticeKind.error : RtiNoticeKind.info, long: true);
  }

  Future<void> _onTruckPicked(RtiTruckPicked e, Emitter<RtiEntryState> emit) async {
    _onFormChanged(RtiFormChanged((f) => f.copyWith(truckRefId: e.truckId)), emit);
    emit(state.copyWith(licenceWarning: null));
    if (e.truckId.isEmpty) return;
    final warnings = FleetExpiry.truck(state.truckRow(e.truckId));
    if (warnings.isNotEmpty) {
      final critical = FleetExpiry.severityOf(warnings) == PickSeverity.critical;
      _notice(emit, warnings.map((w) => w.message).join('\n'), critical ? RtiNoticeKind.error : RtiNoticeKind.info, long: true);
    }
    if (state.form.isEdit) return;
    final id = int.tryParse(e.truckId) ?? 0;
    if (id == 0 || _repo.companyId == 0) return;
    final message = RtiRules.truckLicenseMessage(await _repo.truck(id));
    if (message == null || state.form.truckRefId != e.truckId) return;
    emit(state.copyWith(licenceWarning: message));
    _notice(emit, message, RtiNoticeKind.warning);
  }

  Future<void> _onLookup(RtiJobLookupRequested e, Emitter<RtiEntryState> emit) async {
    if (e.jobNo.isEmpty) return;
    var row = e.row;
    var grid = state.grid;
    if (row < 0) {
      row = grid.indexWhere((r) => r.isBlank);
      if (row < 0) {
        grid = [...grid, const RtiJobRow()];
        row = grid.length - 1;
      }
    }
    if (RtiGridRules.alreadyLoaded(grid, row, e.jobNo)) return;
    grid = [for (var i = 0; i < grid.length; i++) i == row ? grid[i].withCell(RtiJobColumns.jobNo, e.jobNo) : grid[i]];
    emit(state.copyWith(grid: grid, busy: state.isBusy ? state.busy : RtiBusy.lookingUp, lookupRow: row));
    try {
      final matches = await _repo.lookupJob(e.jobNo);
      if (matches == null || matches.isEmpty) {
        emit(state.copyWith(busy: _afterLookup(), lookupRow: null));
        _notice(emit, 'Job not found.', RtiNoticeKind.warning);
        return;
      }
      final next = RtiGridRules.applyLookup(state.grid, row, e.jobNo, matches);
      emit(state.copyWith(
        grid: next,
        busy: _afterLookup(),
        lookupRow: null,
        errors: state.errors.isEmpty ? const [] : RtiRules.validate(state.form, next),
      ));
    } catch (err) {
      emit(state.copyWith(busy: _afterLookup(), lookupRow: null));
      _notice(emit, '$err', RtiNoticeKind.error);
    }
  }

  RtiBusy _afterLookup() => state.busy == RtiBusy.lookingUp ? RtiBusy.none : state.busy;

  Future<void> _onSave(RtiSaveRequested e, Emitter<RtiEntryState> emit) async {
    if (state.busy == RtiBusy.saving || state.busy == RtiBusy.deleting || state.busy == RtiBusy.revising) return;
    if (_repo.companyId == 0) return _notice(emit, 'Company is missing. Please refresh and try again.', RtiNoticeKind.error);
    if (_repo.employeeId == 0) return _notice(emit, 'Employee login is required before saving RTI.', RtiNoticeKind.error);
    final errors = RtiRules.validate(state.form, state.grid);
    if (errors.isNotEmpty) {
      emit(state.copyWith(errors: errors, step: 4));
      return _notice(emit, errors.join('\n'), RtiNoticeKind.error);
    }
    final revised = state.inRevise;
    final isEdit = state.form.isEdit;
    final payload = RtiSavePayloadBuilder.build(state.form, state.grid, state.stops,
        companyId: _repo.companyId, employeeRefId: _repo.employeeId);
    emit(state.copyWith(busy: RtiBusy.saving, errors: const []));
    try {
      ({int id, String rtiNo}) saved;
      var attempt = 0;
      while (true) {
        try {
          saved = await _repo.save(payload);
          break;
        } catch (_) {
          // the web retries an edit up to twice (useRTIOperations.ts:96-100)
          if (!isEdit || ++attempt > 2) rethrow;
        }
      }
      await _load(emit, saved.id);
      emit(state.copyWith(busy: RtiBusy.none, step: isEdit ? state.step : 0));
      _notice(emit, revised ? 'RTI revised successfully' : (isEdit ? 'RTI updated successfully' : 'RTI saved successfully'),
          RtiNoticeKind.success);
    } catch (err) {
      emit(state.copyWith(busy: RtiBusy.none));
      _notice(emit, '$err', RtiNoticeKind.error);
    }
  }

  Future<void> _onDelete(RtiDeleteRequested e, Emitter<RtiEntryState> emit) async {
    if (state.isBusy) return;
    if (!state.form.isEdit) return _notice(emit, 'No RTI selected for delete.', RtiNoticeKind.warning);
    emit(state.copyWith(busy: RtiBusy.deleting));
    try {
      await _repo.delete(state.form.editId);
      emit(state.copyWith(busy: RtiBusy.none));
      _notice(emit, 'RTI deleted successfully', RtiNoticeKind.success);
      await _onClear(const RtiClearRequested(), emit);
    } catch (err) {
      emit(state.copyWith(busy: RtiBusy.none));
      _notice(emit, '$err', RtiNoticeKind.error);
    }
  }

  Future<void> _onRevise(RtiReviseRequested e, Emitter<RtiEntryState> emit) async {
    if (state.isBusy) return;
    if (!state.form.isEdit) return _notice(emit, 'No RTI selected to revise.', RtiNoticeKind.warning);
    emit(state.copyWith(busy: RtiBusy.revising));
    try {
      final r = await _repo.revise(state.form.editId);
      final changes = reviseChanges(state.grid, r.grid);
      final count = changes.values.fold<int>(0, (n, l) => n + l.length);
      emit(state.copyWith(
        busy: RtiBusy.none,
        form: r.form.copyWith(editId: state.form.editId, rtiNo: r.form.rtiNo.isEmpty ? state.form.rtiNo : null),
        grid: RtiGridRules.nonEmpty(r.grid),
        stops: r.stops ?? state.stops,
        reviseChanges: changes,
        inRevise: true,
        errors: const [],
      ));
      _notice(emit, 'Revised from the sales orders: $count ${count == 1 ? 'change' : 'changes'} in ${changes.length} '
          '${changes.length == 1 ? 'job' : 'jobs'}. Check them, edit if needed, then save.', RtiNoticeKind.info, long: true);
    } catch (err) {
      emit(state.copyWith(busy: RtiBusy.none));
      final text = '$err';
      _notice(emit, text.trim().isEmpty ? 'Failed to load revise data.' : text, RtiNoticeKind.error);
    }
  }

  Future<void> _onClear(RtiClearRequested e, Emitter<RtiEntryState> emit) async {
    if (state.busy == RtiBusy.saving) return;
    emit(state.copyWith(
      status: RtiLoadStatus.ready,
      loadError: null,
      form: _initial(),
      grid: const [RtiJobRow()],
      stops: const [],
      errors: const [],
      licenceWarning: null,
      reviseChanges: const {},
      inRevise: false,
      step: 0,
    ));
    await _nextNumber(emit);
  }

  /// The job values the revise changed, per sale order: was → now.
  static Map<int, List<RtiReviseChange>> reviseChanges(List<RtiJobRow> before, List<RtiJobRow> after) {
    final out = <int, List<RtiReviseChange>>{};
    for (final now in after) {
      final was = before.where((b) => (now.id > 0 && b.id == now.id) || (b.saleOrderMasterRefId == now.saleOrderMasterRefId && now.saleOrderMasterRefId > 0)).firstOrNull;
      if (was == null) continue;
      final list = <RtiReviseChange>[
        for (final (label, a, b) in [
          ('Job No', was.jobNo, now.jobNo),
          ('Customer', was.customerName, now.customerName),
          ('Job date', RtiDates.short(was.jobDate), RtiDates.short(now.jobDate)),
          ('Origin', was.originD, now.originD),
          ('Destination', was.destinationD, now.destinationD),
          ('Pickup', RtiDates.short(was.pickupDateD), RtiDates.short(now.pickupDateD)),
          ('Delivery', RtiDates.short(was.deliveryDateD), RtiDates.short(now.deliveryDateD)),
        ])
          if (a != b) RtiReviseChange(label, a, b),
      ];
      if (list.isNotEmpty) out[now.saleOrderMasterRefId] = list;
    }
    return out;
  }
}
