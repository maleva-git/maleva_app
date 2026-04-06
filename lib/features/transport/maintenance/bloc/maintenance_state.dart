

import '../../../../core/models/model.dart';

abstract class TruckMaintenanceState {}

class TruckMaintenanceInitial extends TruckMaintenanceState {}

class TruckMaintenanceLoading extends TruckMaintenanceState {}

class TruckMaintenanceLoaded extends TruckMaintenanceState {
  // ── Truck selector ────────────────────────────────────────────────────────
  final int    truckId;
  final String truckName;
  final bool   visibleTruck; // false when driver auto-login

  // ── Expiry date thresholds (computed from config) ─────────────────────────
  final String expDate;               // general expiry threshold
  final String expApadBonam;          // apad/bonam threshold
  final String expServiceAlignGreece; // service/alignment/greece threshold

  // ── Data ──────────────────────────────────────────────────────────────────
  final List<TruckDetailsModel> truckDetails;

   TruckMaintenanceLoaded({
    required this.truckId,
    required this.truckName,
    required this.visibleTruck,
    required this.expDate,
    required this.expApadBonam,
    required this.expServiceAlignGreece,
    required this.truckDetails,
  });

  TruckMaintenanceLoaded copyWith({
    int?    truckId,
    String? truckName,
    bool?   visibleTruck,
    String? expDate,
    String? expApadBonam,
    String? expServiceAlignGreece,
    List<TruckDetailsModel>? truckDetails,
  }) {
    return TruckMaintenanceLoaded(
      truckId:               truckId               ?? this.truckId,
      truckName:             truckName             ?? this.truckName,
      visibleTruck:          visibleTruck          ?? this.visibleTruck,
      expDate:               expDate               ?? this.expDate,
      expApadBonam:          expApadBonam          ?? this.expApadBonam,
      expServiceAlignGreece: expServiceAlignGreece ?? this.expServiceAlignGreece,
      truckDetails:          truckDetails          ?? this.truckDetails,
    );
  }
}

class TruckMaintenanceError extends TruckMaintenanceState {
  final String message;
  TruckMaintenanceError(this.message);
}