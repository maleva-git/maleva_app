import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';

import 'maintenance_event.dart';
import 'maintenance_state.dart';





class TruckMaintenanceBloc
    extends Bloc<TruckMaintenanceEvent, TruckMaintenanceState> {
  TruckMaintenanceBloc() : super(TruckMaintenanceInitial()) {
    on<TruckMaintenanceStarted>(_onStarted);
    on<TruckMaintenanceTruckSelected>(_onTruckSelected);
    on<TruckMaintenanceTruckCleared>(_onTruckCleared);
  }

  // ── Startup ─────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      TruckMaintenanceStarted event,
      Emitter<TruckMaintenanceState> emit) async {
    emit(TruckMaintenanceLoading());
    try {
      objfun.TruckDetailsList = [];
      final isDriverLogin = objfun.DriverLogin == 1;
      final truckId       = objfun.DriverTruckRefId;

      final expDate          = objfun.currentdate(objfun.commonexpirydays);
      final expApadBonam     = objfun.currentdate(objfun.apadbonamexpirydays);
      final expServiceAlignGreece =
      objfun.currentdate(objfun.ExpServiceAligmentGreecedays);

      // Driver login: auto-load truck data
      if (truckId != 0) {
        final details =
        await _fetchTruckDetails(truckId, expDate, expApadBonam, expServiceAlignGreece);
        emit(TruckMaintenanceLoaded(
          truckId:               truckId,
          truckName:             '',
          visibleTruck:          !isDriverLogin,
          expDate:               expDate,
          expApadBonam:          expApadBonam,
          expServiceAlignGreece: expServiceAlignGreece,
          truckDetails:          details,
        ));
      } else {
        emit(TruckMaintenanceLoaded(
          truckId:               0,
          truckName:             '',
          visibleTruck:          !isDriverLogin,
          expDate:               expDate,
          expApadBonam:          expApadBonam,
          expServiceAlignGreece: expServiceAlignGreece,
          truckDetails:          [],
        ));
      }
    } catch (e) {
      emit(TruckMaintenanceError(e.toString()));
    }
  }

  // ── Truck selected from search ───────────────────────────────────────────────
  Future<void> _onTruckSelected(
      TruckMaintenanceTruckSelected event,
      Emitter<TruckMaintenanceState> emit) async {
    if (state is! TruckMaintenanceLoaded) return;
    final s = state as TruckMaintenanceLoaded;

    emit(TruckMaintenanceLoading());
    try {
      final details = await _fetchTruckDetails(
          event.truckId,
          s.expDate,
          s.expApadBonam,
          s.expServiceAlignGreece);

      emit(s.copyWith(
        truckId:      event.truckId,
        truckName:    event.truckName,
        truckDetails: details,
      ));
    } catch (e) {
      emit(TruckMaintenanceError(e.toString()));
    }
  }

  // ── Truck cleared ────────────────────────────────────────────────────────────
  void _onTruckCleared(
      TruckMaintenanceTruckCleared event,
      Emitter<TruckMaintenanceState> emit) {
    if (state is! TruckMaintenanceLoaded) return;
    final s = state as TruckMaintenanceLoaded;
    objfun.TruckDetailsList = [];
    emit(s.copyWith(truckId: 0, truckName: '', truckDetails: []));
  }

  // ── API helper ───────────────────────────────────────────────────────────────
  Future<List<TruckDetailsModel>> _fetchTruckDetails(
      int truckId,
      String expDate,
      String expApadBonam,
      String expServiceAlignGreece) async {
    final master = {
      'Expdate':                null,
      'ExpApadBonam':           expApadBonam,
      'ExpServiceAligmentGreece': expServiceAlignGreece,
      'Id':                     truckId,
      'SFromDate':              null,
      'Comid':                  objfun.Comid,
    };
    final header = {'Content-Type': 'application/json; charset=UTF-8'};

    final resultData = await objfun.apiAllinoneSelectArray(
        objfun.apiSelectTruckDetails, master, header, null);

    if (resultData != '' && resultData.length != 0) {
      final list = (resultData as List)
          .map((e) => TruckDetailsModel.fromJson(e))
          .cast<TruckDetailsModel>()
          .toList();
      objfun.TruckDetailsList = list;
      return list;
    }
    return [];
  }
}