import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/features/planning/data/js_values.dart';
import 'package:maleva/features/planning/bloc/plan_cubit_base.dart';
import 'package:maleva/features/planning/bloc/plan_row_ops.dart';
import 'package:maleva/features/planning/bloc/plan_rti_ops.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/data/planning_repository.dart';
import 'package:maleva/features/planning/data/planning_rules.dart';
import 'package:maleva/features/planning/data/planning_save_payload.dart';
import 'package:maleva/features/planning/models/fleet_options.dart';
import 'package:maleva/features/planning/models/plan_header.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/rti/data/rti_from_planning.dart';

/// The plan screen (the web's `usePlanningListPage`): access, the plan's form and rows, search,
/// load, save, delete and the row and RTI actions (in [PlanRowOps] and [PlanRtiOps]).
class PlanCubit extends Cubit<PlanState> with PlanCubitBase, PlanRowOps, PlanRtiOps {
  PlanCubit({required this.repo, required this.rtiFromPlanning, DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        super(PlanState(header: PlanHeader.fresh((clock ?? DateTime.now)())));

  @override
  final PlanningRepository repo;
  @override
  final RtiFromPlanning rtiFromPlanning;
  final DateTime Function() _clock;

  /// Only the newest plan load may touch the screen (`planLoadSeqRef`).
  int _loadSeq = 0;

  DateTime get today {
    final n = _clock();
    return DateTime(n.year, n.month, n.day);
  }

  /// Opens the screen: the role's actions (VIEW only on failure), the pickers, then the plan
  /// [planId] or a new plan's number.
  Future<void> start({int? planId}) async {
    emit(state.copyWith(phase: PlanPhase.loading));
    Set<String> actions;
    try {
      actions = await repo.access();
    } catch (_) {
      actions = const {'VIEW'};
    }
    final lookups = await Future.wait<Object>([repo.ports(), repo.trucks(), repo.drivers()]);
    if (isClosed) return;
    emit(state.copyWith(
      actions: actions,
      ports: lookups[0] as List<String>,
      trucks: lookups[1] as List<TruckOption>,
      drivers: lookups[2] as List<DriverOption>,
    ));
    try {
      final employees = await repo.employees();
      if (isClosed) return;
      emit(state.copyWith(employees: employees, phase: PlanPhase.ready));
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(phase: PlanPhase.employeesFailed));
      if ((planId ?? 0) <= 0) notify('Failed to load employees. Please refresh.', NoticeKind.error);
      return;
    }
    if ((planId ?? 0) > 0) {
      await loadPlan(id: planId);
    } else {
      await _loadNextNumber();
    }
  }

  Future<void> _loadNextNumber() async {
    try {
      final no = await repo.nextNumber();
      if (!isClosed) emit(state.copyWith(header: state.header.copyWith(planningNo: no)));
    } catch (_) {
      // a preview only; the number is taken on save
    }
  }

  /// A form change. [counts] marks it unsaved (plan date, remarks, employee); the search
  /// fields do not.
  void updateHeader(PlanHeader Function(PlanHeader) change, {bool counts = false}) =>
      emit(state.copyWith(header: change(state.header), headerChanged: counts ? true : null, searchError: () => null));

  /// PORT "Add": the port joins the search text.
  void appendPort() {
    final next = PlanningRules.appendPort(state.header);
    if (next != null) updateHeader((h) => h.copyWith(searchText: next));
  }

  /// Today / Tomorrow / This week (to Sunday) for FROM and TO.
  void setQuickRange(String which) {
    final t = today;
    final (from, to) = switch (which) {
      'tomorrow' => (t.add(const Duration(days: 1)), t.add(const Duration(days: 1))),
      'week' => (t, t.add(Duration(days: DateTime.sunday - t.weekday))),
      _ => (t, t),
    };
    updateHeader((h) => h.copyWith(pickupFromDate: PlanHeader.ymd(from), pickupToDate: PlanHeader.ymd(to)));
  }

  /// Search (`handleSearch`): the refusals, then `POST /api/planing/search`. A new plan takes the
  /// jobs found; a saved plan merges them. A failure clears the grid, as on the web.
  Future<void> search() async {
    if (state.searching) return;
    final refusal = PlanningRules.searchRefusal(state.header);
    if (refusal != null) {
      emit(state.copyWith(searchError: () => refusal));
      notify(refusal, NoticeKind.error);
      return;
    }
    emit(state.copyWith(searching: true, searchError: () => null));
    try {
      final found = await repo.search(PlanningRules.searchPayload(repo.companyId, state.header));
      if (isClosed) return;
      final saved = state.editId > 0;
      final merge = PlanningRules.mergeSearch(savedPlan: saved, current: state.rows, found: found);
      emit(state.copyWith(rows: merge.rows, searching: false, structureChanged: merge.rows.isNotEmpty ? true : null));
      notify(saved ? 'Planning data loaded successfully (${merge.added} added · ${merge.refreshed} refreshed)' : 'Planning data loaded successfully');
      await syncRtiStatuses();
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(rows: const [], searching: false));
      notify(errorText(e, 'Search failed'), NoticeKind.error);
    }
  }

  /// PLAN NO: digits only; an empty or unusable value does nothing.
  Future<void> openPlanNumber(String typed) async {
    final no = PlanningRules.parsePlanningNo(typed);
    if (no == null) return;
    await loadPlan(planningNo: no);
  }

  /// Loads a saved plan (`loadPlanningForEdit`). Reading the plan already open keeps the rows
  /// with unsaved edits; another plan replaces everything.
  Future<void> loadPlan({int? id, int? planningNo}) async {
    final seq = ++_loadSeq;
    emit(state.copyWith(fetchingPlan: true));
    try {
      final loaded = await repo.load(id: id, planningNo: planningNo);
      if (seq != _loadSeq || isClosed) return;
      if (loaded == null) throw StateError('Planning data not found');
      final samePlan = loaded.editId > 0 && loaded.editId == state.editId;
      final h = loaded.header;
      final header = state.header.copyWith(
        planningNo: h['planningNo'],
        planningDate: h['planningDate'],
        pickupFromDate: h['pickupFromDate'],
        pickupToDate: h['pickupToDate'],
        port: h['port'],
        employee: h['employee'],
        remarks: h['remarks'],
        searchText: h['searchText'],
      );
      List<PlanLine> rows = loaded.lines;
      if (samePlan && state.dirtyJobIds.isNotEmpty && state.rows.isNotEmpty) {
        rows = [
          for (final incoming in loaded.lines)
            state.dirtyJobIds.contains(incoming.saleOrderMasterRefId)
                ? state.rows.where((r) => r.saleOrderMasterRefId == incoming.saleOrderMasterRefId).firstOrNull ?? incoming
                : incoming,
        ];
      }
      final keptUids = {for (final r in rows) r.uid};
      emit(state.copyWith(
        editId: loaded.editId,
        header: header,
        rows: rows,
        fetchingPlan: false,
        dirtyJobIds: samePlan ? null : const {},
        changedUids: samePlan ? state.changedUids.intersection(keptUids) : const {},
        structureChanged: samePlan ? null : false,
        headerChanged: false,
        selectedUid: samePlan ? null : () => null,
        rtiKey: '',
      ));
      await syncRtiStatuses();
    } catch (e) {
      if (seq != _loadSeq || isClosed) return;
      emit(state.copyWith(fetchingPlan: false));
      notify(errorText(e, 'Failed to load planning'), NoticeKind.error);
    }
  }

  /// Save (`savePlanning` + `handleSave`): the checks, one request, one success message, then the
  /// plan is read again in place (Q-TOAST: the message is shown once).
  Future<bool> save() async {
    if (state.saving) return false;
    if (!guardWrite()) return false;
    final request = PlanningSavePayload.build(
      companyId: repo.companyId,
      editId: state.editId,
      header: state.header,
      rows: state.rows,
      userId: repo.userId,
      employeeId: repo.employeeId,
    );
    final refusal = PlanningSavePayload.refusal(request);
    if (refusal != null) {
      notify(refusal, NoticeKind.error);
      return false;
    }
    emit(state.copyWith(saving: true));
    try {
      final result = await repo.save(request);
      if (isClosed) return true;
      final existing = state.editId > 0;
      final serverMessage = (result['message'] ?? '').toString().trim();
      final message = serverMessage.isNotEmpty ? serverMessage : (existing ? 'Planning updated successfully' : 'Planning saved successfully');
      final newId = int.tryParse('${result['id'] ?? result['Id'] ?? ''}') ?? 0;
      final id = existing ? state.editId : newId;
      emit(state.copyWith(saving: false, dirtyJobIds: const {}, changedUids: const {}, structureChanged: false, headerChanged: false));
      notify(message);
      if (id > 0) {
        await loadPlan(id: id);
      } else {
        _reset();
        await _loadNextNumber();
      }
      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(saving: false));
      notify(errorText(e, 'Error saving planning'), NoticeKind.error);
      return false;
    }
  }

  /// Delete before its confirm: false after the web's refusal.
  bool canDelete() {
    final a = state.access;
    if (!a.canDelete) {
      notify(a.deleteDeniedReason, NoticeKind.error);
      return false;
    }
    if (state.editId <= 0) {
      notify('No planning selected to delete', NoticeKind.error);
      return false;
    }
    return true;
  }

  /// Delete, after "Delete Planning": the screen then holds a new plan.
  Future<void> delete() async {
    if (state.deleting || !canDelete()) return;
    emit(state.copyWith(deleting: true));
    try {
      await repo.delete(state.editId);
      if (isClosed) return;
      _reset();
      emit(state.copyWith(deleting: false));
      notify('Planning deleted successfully');
      await _loadNextNumber();
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(deleting: false));
      notify(errorText(e, 'Error deleting planning'), NoticeKind.error);
    }
  }

  /// Clear / New plan (`handleClear`).
  Future<void> newPlan() async {
    _loadSeq++;
    _reset();
    notify('Form cleared');
    await _loadNextNumber();
  }

  /// Refresh (the web reloads the page): the pickers and the plan again; edited rows are kept.
  Future<void> refresh() async {
    final lookups = await Future.wait<Object>([repo.ports(), repo.trucks(), repo.drivers()]);
    if (isClosed) return;
    emit(state.copyWith(
        ports: lookups[0] as List<String>, trucks: lookups[1] as List<TruckOption>, drivers: lookups[2] as List<DriverOption>, rtiKey: ''));
    if (state.editId > 0) {
      await loadPlan(id: state.editId);
    } else {
      await syncRtiStatuses();
    }
  }

  void _reset() => emit(state.copyWith(
        editId: 0,
        header: PlanHeader.fresh(today),
        rows: const [],
        dirtyJobIds: const {},
        changedUids: const {},
        structureChanged: false,
        headerChanged: false,
        selectedUid: () => null,
        searchError: () => null,
        rtiKey: '',
        fetchingPlan: false,
      ));
}
