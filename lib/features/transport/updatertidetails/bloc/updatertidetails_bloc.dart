import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/models/model.dart';
import 'package:maleva/features/transport/updatertidetails/bloc/updatertidetails_event.dart';
import 'package:maleva/features/transport/updatertidetails/bloc/updatertidetails_state.dart';




class UpdateRTIBloc extends Bloc<UpdateRTIEvent, UpdateRTIState> {
  UpdateRTIBloc() : super(UpdateRTIInitial()) {
    on<UpdateRTIStarted>(_onStarted);
    on<UpdateRTIFromDateChanged>(_onFromDate);
    on<UpdateRTIToDateChanged>(_onToDate);
    on<UpdateRTIDriverChanged>(_onDriverChanged);
    on<UpdateRTIDriverCleared>(_onDriverCleared);
    on<UpdateRTITruckChanged>(_onTruckChanged);
    on<UpdateRTITruckCleared>(_onTruckCleared);
    on<UpdateRTIRtiNoChanged>(_onRtiNoChanged);
    on<UpdateRTILoadRequested>(_onLoadRequested);
    on<UpdateRTIRowToggled>(_onRowToggled);
    on<UpdateRTIShareRequested>(_onShareRequested);
  }

  // ── Default loaded state ────────────────────────────────────────────────────
  UpdateRTILoaded _defaultLoaded() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isDriverLogin  = objfun.DriverLogin == 1;
    final defaultDriver  = isDriverLogin ? objfun.EmpRefId : 0;

    return UpdateRTILoaded(
      fromDate:          today,
      toDate:            today,
      driverId:          defaultDriver,
      driverName:        '',
      truckId:           0,
      truckName:         '',
      rtiNo:             '',
      visibleDriverTruck: !isDriverLogin,
      masterList:        [],
      detailList:        [],
      expandedIndex:     -1,
    );
  }

  // ── Startup ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      UpdateRTIStarted event, Emitter<UpdateRTIState> emit) async {
    emit(UpdateRTILoading());
    try {
      await OnlineApi.SelectEmployee(null, 'Sales', '');
      final def = _defaultLoaded();
      emit(def);
      // Initial load
      add(UpdateRTILoadRequested());
    } catch (e) {
      emit(UpdateRTIError(e.toString()));
    }
  }

  // ── Date ────────────────────────────────────────────────────────────────────
  void _onFromDate(
      UpdateRTIFromDateChanged event, Emitter<UpdateRTIState> emit) {
    if (state is UpdateRTILoaded) {
      emit((state as UpdateRTILoaded).copyWith(fromDate: event.date));
    }
  }

  void _onToDate(
      UpdateRTIToDateChanged event, Emitter<UpdateRTIState> emit) {
    if (state is UpdateRTILoaded) {
      emit((state as UpdateRTILoaded).copyWith(toDate: event.date));
    }
  }

  // ── Driver ──────────────────────────────────────────────────────────────────
  void _onDriverChanged(
      UpdateRTIDriverChanged event, Emitter<UpdateRTIState> emit) {
    if (state is UpdateRTILoaded) {
      emit((state as UpdateRTILoaded)
          .copyWith(driverId: event.driverId, driverName: event.driverName));
    }
  }

  void _onDriverCleared(
      UpdateRTIDriverCleared event, Emitter<UpdateRTIState> emit) {
    if (state is UpdateRTILoaded) {
      emit((state as UpdateRTILoaded).copyWith(driverId: 0, driverName: ''));
    }
  }

  // ── Truck ────────────────────────────────────────────────────────────────────
  void _onTruckChanged(
      UpdateRTITruckChanged event, Emitter<UpdateRTIState> emit) {
    if (state is UpdateRTILoaded) {
      emit((state as UpdateRTILoaded)
          .copyWith(truckId: event.truckId, truckName: event.truckName));
    }
  }

  void _onTruckCleared(
      UpdateRTITruckCleared event, Emitter<UpdateRTIState> emit) {
    if (state is UpdateRTILoaded) {
      emit((state as UpdateRTILoaded).copyWith(truckId: 0, truckName: ''));
    }
  }

  // ── RTI No text ──────────────────────────────────────────────────────────────
  void _onRtiNoChanged(
      UpdateRTIRtiNoChanged event, Emitter<UpdateRTIState> emit) {
    if (state is UpdateRTILoaded) {
      emit((state as UpdateRTILoaded).copyWith(rtiNo: event.rtiNo));
    }
  }

  // ── Load list ────────────────────────────────────────────────────────────────
  Future<void> _onLoadRequested(
      UpdateRTILoadRequested event, Emitter<UpdateRTIState> emit) async {
    if (state is! UpdateRTILoaded) return;
    final s = state as UpdateRTILoaded;

    emit(UpdateRTILoading());
    try {
      await OnlineApi.SelectRTIViewList(
          null,
          s.fromDate,
          s.toDate,
          s.driverId,
          s.truckId,
          0,        // Employeeid — kept 0 as per original
          s.rtiNo);

      emit(s.copyWith(
        masterList:    objfun.RTIViewMasterList,
        detailList:    objfun.RTIViewDetailList,
        expandedIndex: -1,
      ));
    } catch (e) {
      emit(UpdateRTIError(e.toString()));
    }
  }

  // ── Row expand / collapse ────────────────────────────────────────────────────
  void _onRowToggled(
      UpdateRTIRowToggled event, Emitter<UpdateRTIState> emit) {
    if (state is! UpdateRTILoaded) return;
    final s = state as UpdateRTILoaded;
    final newIdx =
    s.expandedIndex == event.masterIndex ? -1 : event.masterIndex;
    emit(s.copyWith(expandedIndex: newIdx));
  }

  // ── Share / PDF ──────────────────────────────────────────────────────────────
  Future<void> _onShareRequested(
      UpdateRTIShareRequested event, Emitter<UpdateRTIState> emit) async {
    if (state is! UpdateRTILoaded) return;
    try {
      final master = {'SoId': event.id, 'Comid': objfun.Comid};
      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final result = await objfun.apiAllinoneSelectArray(
          '${objfun.apiViewRTIPdf}${event.rtiNoDisplay}',
          master,
          header,
          null);
      if (result != '') {
        final value = ResponseViewModel.fromJson(result);
        if (value.IsSuccess == true) objfun.launchInBrowser(value.data1);
      }
    } catch (_) {}
  }
}