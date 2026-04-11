import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';

import 'licenseupdate_event.dart';
import 'licenseupdate_state.dart';



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
      objfun.TruckDetailsList = [];
      final isAdmin = objfun.DriverTruckRefId == 0;

      if (!isAdmin) {
        // Driver login: auto-load truck
        final loaded = await _fetchAndBuild(
            objfun.DriverTruckRefId, admin: false);
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
    objfun.TruckDetailsList = [];
    objfun.SelectTruckList  = GetTruckModel.Empty();
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
      String? _iso(bool cb, String date) =>
          cb ? DateTime.parse(date).toIso8601String() : null;

      final master = [
        {
          'Id':           s.truckId,
          'CompanyRefId': objfun.Comid,
          'TruckName':    s.truckNameField,
          'TruckNumber':  s.truckNo,
          'TruckNumber1': s.truckNo2,
          'TruckType':    s.truckType,
          'Latitude':     s.latitude,
          'longitude':    s.longitude,
          'RotexMyExp':   _iso(s.cbRotexMyExp,    s.rotexMyExp),
          'RotexSGExp':   _iso(s.cbRotexSGExp,    s.rotexSGExp),
          'PuspacomExp':  _iso(s.cbPuspacomExp,   s.puspacomExp),
          'RotexMyExp1':  _iso(s.cbRotexMyExp1,   s.rotexMyExp1),
          'RotexSGExp1':  _iso(s.cbRotexSGExp1,   s.rotexSGExp1),
          'PuspacomExp1': _iso(s.cbPuspacomExp1,  s.puspacomExp1),
          'InsuratnceExp':_iso(s.cbInsuratnceExp, s.insuratnceExp),
          'BonamExp':     _iso(s.cbBonamExp,      s.bonamExp),
          'ApadExp':      _iso(s.cbApadExp,       s.apadExp),
          'ServiceExp':   _iso(s.cbServiceExp,    s.serviceExp),
          'AlignmentExp': _iso(s.cbAlignmentExp,  s.alignmentExp),
          'GreeceExp':    _iso(s.cbGreeceExp,     s.greeceExp),
          'Active':       s.active,
        }
      ];

      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final result = await objfun.apiAllinoneSelectArray(
          '${objfun.apiUpdateTruckDetails}${objfun.Comid}',
          master,
          header,
          null);

      if (result != '') {
        final value = ResponseViewModel.fromJson(result);
        if (value.IsSuccess == true) {
          emit(LicenseUpdateSaveSuccess());
          emit(LicenseUpdateLoaded.empty(admin: s.admin));
          return;
        }
      }
      emit(s); // revert on failure
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
      objfun.TruckDetailsList = [];
      objfun.SelectTruckList  = GetTruckModel.Empty();
      emit(LicenseUpdateLoaded.empty(admin: s.admin));
    }
  }

  // ── Helper: fetch truck + parse all 12 date fields ───────────────────────────
  Future<LicenseUpdateLoaded> _fetchAndBuild(
      int truckId, {required bool admin}) async {
    await OnlineApi.EditTruckList(null, truckId, 'Id', null);

    if (objfun.TruckDetailsList.isEmpty) {
      return LicenseUpdateLoaded.empty(admin: admin)
          .copyWith(truckId: truckId);
    }

    final d  = objfun.TruckDetailsList[0];
    final fmt = DateFormat('MM/dd/yyyy HH:mm:ss');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    String _parse(String raw) {
      if (raw == 'null' || raw.isEmpty) return today;
      try {
        return DateFormat('yyyy-MM-dd').format(fmt.parse(raw));
      } catch (_) {
        return today;
      }
    }

    bool _hasVal(String raw) => raw != 'null' && raw.isNotEmpty;

    return LicenseUpdateLoaded(
      truckId:        truckId,
      truckName:      d.TruckNumber, // shown in selector
      admin:          admin,
      truckNo:        d.TruckNumber,
      truckNo2:       d.TruckNumber1 == 'null' ? '' : d.TruckNumber1,
      truckNameField: d.TruckName,
      longitude:      d.longitude == 'null' ? '' : d.longitude,
      latitude:       d.Latitude  == 'null' ? '' : d.Latitude,
      truckType:      d.TruckType == 'null' ? '' : d.TruckType,
      cNumberDisplay: d.CNumberDisplay,
      cNumber:        d.CNumber,
      active:         d.Active,

      rotexMyExp:    _parse(d.RotexMyExp),
      cbRotexMyExp:  _hasVal(d.RotexMyExp),
      rotexSGExp:    _parse(d.RotexSGExp),
      cbRotexSGExp:  _hasVal(d.RotexSGExp),
      puspacomExp:   _parse(d.PuspacomExp),
      cbPuspacomExp: _hasVal(d.PuspacomExp),
      rotexMyExp1:   _parse(d.RotexMyExp1),
      cbRotexMyExp1: _hasVal(d.RotexMyExp1),
      rotexSGExp1:   _parse(d.RotexSGExp1),
      cbRotexSGExp1: _hasVal(d.RotexSGExp1),
      puspacomExp1:  _parse(d.PuspacomExp1),
      cbPuspacomExp1:_hasVal(d.PuspacomExp1),
      insuratnceExp: _parse(d.InsuratnceExp),
      cbInsuratnceExp:_hasVal(d.InsuratnceExp),
      bonamExp:      _parse(d.BonamExp),
      cbBonamExp:    _hasVal(d.BonamExp),
      apadExp:       _parse(d.ApadExp),
      cbApadExp:     _hasVal(d.ApadExp),
      serviceExp:    _parse(d.ServiceExp),
      cbServiceExp:  _hasVal(d.ServiceExp),
      alignmentExp:  _parse(d.AlignmentExp),
      cbAlignmentExp:_hasVal(d.AlignmentExp),
      greeceExp:     _parse(d.GreeceExp),
      cbGreeceExp:   _hasVal(d.GreeceExp),
    );
  }
}