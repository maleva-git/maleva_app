import 'package:maleva/core/fleet/truck_api.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';


import 'licenseupdate_event.dart';
import 'licenseupdate_state.dart';
import 'package:maleva/core/models/shared/get_truck_model.dart';



class LicenseUpdateBloc
    extends Bloc<LicenseUpdateEvent, LicenseUpdateState> {
  LicenseUpdateBloc() : super(LicenseUpdateInitial()) {
    on<LicenseUpdateStarted>(_onStarted);
    on<LicenseUpdateTruckSelected>(_onTruckSelected);
    on<LicenseUpdateTruckCleared>(_onTruckCleared);
    on<LicenseUpdateTextChanged>(_onTextChanged);
    on<LicenseUpdateDateChanged>(_onDateChanged);
    on<LicenseUpdateCheckboxChanged>(_onCheckboxChanged);
    on<LicenseUpdateSaveRequested>(_onSaveRequested);
    on<LicenseUpdateClearRequested>(_onClearRequested);
  }

  // ── Startup ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      LicenseUpdateStarted event,
      Emitter<LicenseUpdateState> emit) async {
    emit(LicenseUpdateLoading());
    try {
      AppGlobals.TruckDetailsList = [];
      // A driver never edits trucks (the server refuses a driver's truck save); an
      // employee edits any. "No truck assigned" used to make a driver an admin.
      final isAdmin = AppGlobals.DriverLogin != 1;

      if (!isAdmin && AppGlobals.DriverTruckRefId != 0) {
        // Driver login: auto-load truck
        final loaded = await _fetchAndBuild(
            AppGlobals.DriverTruckRefId, admin: false);
        emit(loaded);
      } else {
        emit(LicenseUpdateLoaded.empty(admin: true));
      }
    } catch (e) {
      emit(LicenseUpdateError(e.toString()));
    }
  }

  // ── Truck selected ───────────────────────────────────────────────────────────
  Future<void> _onTruckSelected(
      LicenseUpdateTruckSelected event,
      Emitter<LicenseUpdateState> emit) async {
    if (state is! LicenseUpdateLoaded) return;
    final s = state as LicenseUpdateLoaded;
    emit(LicenseUpdateLoading());
    try {
      final loaded = await _fetchAndBuild(event.truckId, admin: s.admin);
      emit(loaded.copyWith(truckName: event.truckName));
    } catch (e) {
      emit(LicenseUpdateError(e.toString()));
    }
  }

  // ── Truck cleared ────────────────────────────────────────────────────────────
  void _onTruckCleared(
      LicenseUpdateTruckCleared event,
      Emitter<LicenseUpdateState> emit) {
    if (state is! LicenseUpdateLoaded) return;
    final s = state as LicenseUpdateLoaded;
    AppGlobals.TruckDetailsList = [];
    AppGlobals.SelectTruckList  = GetTruckModel.Empty();
    emit(LicenseUpdateLoaded.empty(admin: s.admin));
  }

  // ── Generic text field ───────────────────────────────────────────────────────
  void _onTextChanged(
      LicenseUpdateTextChanged event,
      Emitter<LicenseUpdateState> emit) {
    if (state is! LicenseUpdateLoaded) return;
    final s = state as LicenseUpdateLoaded;
    switch (event.field) {
      case 'truckNo':        emit(s.copyWith(truckNo:        event.value)); break;
      case 'truckNo2':       emit(s.copyWith(truckNo2:       event.value)); break;
      case 'truckName':      emit(s.copyWith(truckNameField: event.value)); break;
      case 'longitude':      emit(s.copyWith(longitude:      event.value)); break;
      case 'latitude':       emit(s.copyWith(latitude:       event.value)); break;
      case 'truckType':      emit(s.copyWith(truckType:      event.value)); break;
    }
  }

  // ── Date changed ─────────────────────────────────────────────────────────────
  void _onDateChanged(
      LicenseUpdateDateChanged event,
      Emitter<LicenseUpdateState> emit) {
    if (state is LicenseUpdateLoaded) {
      emit((state as LicenseUpdateLoaded).withDate(event.key, event.date));
    }
  }

  // ── Checkbox changed ─────────────────────────────────────────────────────────
  void _onCheckboxChanged(
      LicenseUpdateCheckboxChanged event,
      Emitter<LicenseUpdateState> emit) {
    if (state is LicenseUpdateLoaded) {
      emit((state as LicenseUpdateLoaded).withCb(event.key, event.value));
    }
  }

  // ── Save ─────────────────────────────────────────────────────────────────────
  Future<void> _onSaveRequested(
      LicenseUpdateSaveRequested event,
      Emitter<LicenseUpdateState> emit) async {
    if (state is! LicenseUpdateLoaded) return;
    final s = state as LicenseUpdateLoaded;

    emit(LicenseUpdateLoading());
    try {
      // a ticked date is saved (yyyy-MM-dd), an unticked one cleared
      String? ymd(bool cb, String date) => cb ? DateFormat('yyyy-MM-dd').format(DateTime.parse(date)) : null;

      // the shared Java truck save (was .NET TruckApp/InsertTruck); the rest of the truck is kept
      await sl<TruckApi>().update(s.truckId, {
        'truckName':    s.truckNameField,
        'truckNumber':  s.truckNo,
        'truckNumber1': s.truckNo2,
        'truckType':    s.truckType,
        'latitude':     s.latitude,
        'longitude':    s.longitude,
        'active':       s.active,
        'rotexMyExp':   ymd(s.cbRotexMyExp,    s.rotexMyExp),
        'rotexSGExp':   ymd(s.cbRotexSGExp,    s.rotexSGExp),
        'puspacomExp':  ymd(s.cbPuspacomExp,   s.puspacomExp),
        'rotexMyExp1':  ymd(s.cbRotexMyExp1,   s.rotexMyExp1),
        'rotexSGExp1':  ymd(s.cbRotexSGExp1,   s.rotexSGExp1),
        'puspacomExp1': ymd(s.cbPuspacomExp1,  s.puspacomExp1),
        'insuranceExp': ymd(s.cbInsuratnceExp, s.insuratnceExp),
        'bonamExp':     ymd(s.cbBonamExp,      s.bonamExp),
        'apadExp':      ymd(s.cbApadExp,       s.apadExp),
        'serviceExp':   ymd(s.cbServiceExp,    s.serviceExp),
        'alignmentExp': ymd(s.cbAlignmentExp,  s.alignmentExp),
        'greeceExp':    ymd(s.cbGreeceExp,     s.greeceExp),
      });
      emit(LicenseUpdateSaveSuccess());
      emit(LicenseUpdateLoaded.empty(admin: s.admin));
      return;
    } on ApiFailure catch (e) {
      emit(LicenseUpdateError(e.message));
      emit(s); // the form back as it was
      return;
    } catch (e) {
      emit(LicenseUpdateError(e.toString()));
    }
  }

  // ── Clear ────────────────────────────────────────────────────────────────────
  void _onClearRequested(
      LicenseUpdateClearRequested event,
      Emitter<LicenseUpdateState> emit) {
    if (state is LicenseUpdateLoaded) {
      final s = state as LicenseUpdateLoaded;
      AppGlobals.TruckDetailsList = [];
      AppGlobals.SelectTruckList  = GetTruckModel.Empty();
      emit(LicenseUpdateLoaded.empty(admin: s.admin));
    }
  }

  // ── Helper: fetch truck + parse all 12 date fields ───────────────────────────
  /// The truck from the shared Java truck master (was .NET TruckApp/SelectTruck);
  /// a date it does not have is shown as today, unticked.
  Future<LicenseUpdateLoaded> _fetchAndBuild(
      int truckId, {required bool admin}) async {
    final t = await sl<TruckApi>().byId(truckId);
    if (t == null) {
      return LicenseUpdateLoaded.empty(admin: admin).copyWith(truckId: truckId);
    }
    dynamic f(String k) => JsonRead.field(t, k);
    final day = DateFormat('yyyy-MM-dd');
    final today = day.format(DateTime.now());
    String text(String k) => JsonRead.string(f(k));
    String date(String k) {
      final d = JsonRead.date(f(k));
      return d == null ? today : day.format(d);
    }
    bool has(String k) => JsonRead.date(f(k)) != null;

    return LicenseUpdateLoaded(
      truckId:        truckId,
      truckName:      text('truckNumber'), // shown in selector
      admin:          admin,
      truckNo:        text('truckNumber'),
      truckNo2:       text('truckNumber1'),
      truckNameField: text('truckName'),
      longitude:      text('longitude'),
      latitude:       text('latitude'),
      truckType:      text('truckType'),
      cNumberDisplay: text('cNumberDisplay'),
      cNumber:        JsonRead.integer(f('cNumber')),
      active:         JsonRead.integer(f('active')),

      rotexMyExp:    date('rotexMyExp'),
      cbRotexMyExp:  has('rotexMyExp'),
      rotexSGExp:    date('rotexSGExp'),
      cbRotexSGExp:  has('rotexSGExp'),
      puspacomExp:   date('puspacomExp'),
      cbPuspacomExp: has('puspacomExp'),
      rotexMyExp1:   date('rotexMyExp1'),
      cbRotexMyExp1: has('rotexMyExp1'),
      rotexSGExp1:   date('rotexSGExp1'),
      cbRotexSGExp1: has('rotexSGExp1'),
      puspacomExp1:  date('puspacomExp1'),
      cbPuspacomExp1:has('puspacomExp1'),
      insuratnceExp: date('insuranceExp'),
      cbInsuratnceExp:has('insuranceExp'),
      bonamExp:      date('bonamExp'),
      cbBonamExp:    has('bonamExp'),
      apadExp:       date('apadExp'),
      cbApadExp:     has('apadExp'),
      serviceExp:    date('serviceExp'),
      cbServiceExp:  has('serviceExp'),
      alignmentExp:  date('alignmentExp'),
      cbAlignmentExp:has('alignmentExp'),
      greeceExp:     date('greeceExp'),
      cbGreeceExp:   has('greeceExp'),
    );
  }
}
