import 'package:maleva/core/network/api_legacy_helper.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/app_globals.dart';

import 'maintenance_event.dart';
import 'maintenance_state.dart';
import 'package:maleva/core/models/shared/truck_details_model.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';





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
      AppGlobals.TruckDetailsList = [];
      final isDriverLogin = AppGlobals.DriverLogin == 1;
      final truckId       = AppGlobals.DriverTruckRefId;

      final expDate          = AppGlobals.currentdate(AppGlobals.commonexpirydays);
      final expApadBonam     = AppGlobals.currentdate(AppGlobals.apadbonamexpirydays);
      final expServiceAlignGreece =
      AppGlobals.currentdate(AppGlobals.ExpServiceAligmentGreecedays);

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
    AppGlobals.TruckDetailsList = [];
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
      'Comid':                  AppGlobals.Comid,
    };
    final header = {'Content-Type': 'application/json; charset=UTF-8'};

    final resultData = await ApiLegacyHelper.apiAllinoneSelectArray(
        ApiConstants.apiSelectTruckDetails, master, header, null);

    if (resultData != '' && resultData != null) {
      final value = ResponseViewModel.fromJson(resultData);
      if (value.IsSuccess == true && value.data1 != null) {
        final list = (value.data1 as List)
            .map((e) => TruckDetailsModel.fromJson(e))
            .cast<TruckDetailsModel>()
            .toList();
        AppGlobals.TruckDetailsList = list;
        return list;
      }
    }
    return [];
  }
}