import 'package:maleva/core/fleet/expiry_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/app_globals.dart';

import 'maintenance_event.dart';
import 'maintenance_state.dart';
import 'package:maleva/core/models/shared/truck_details_model.dart';
import 'package:maleva/core/di/injection.dart';





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
    // every date of the truck (no expiry window), from the shared Java expiry list
    final list = (await sl<ExpiryApi>().trucks(truckId: truckId)).map(TruckDetailsModel.fromJavaExpiry).toList();
    AppGlobals.TruckDetailsList = list;
    return list;
  }
}