

abstract class TruckMaintenanceEvent {}

// ── Startup — pre-fill TruckId from driver login if available ─────────────────
class TruckMaintenanceStarted extends TruckMaintenanceEvent {}

// ── Truck search field ────────────────────────────────────────────────────────
class TruckMaintenanceTruckSelected extends TruckMaintenanceEvent {
  final int    truckId;
  final String truckName;
  TruckMaintenanceTruckSelected(
      {required this.truckId, required this.truckName});
}

class TruckMaintenanceTruckCleared extends TruckMaintenanceEvent {}