

abstract class UpdateRTIEvent {}

// ── Startup ───────────────────────────────────────────────────────────────────
class UpdateRTIStarted extends UpdateRTIEvent {}

// ── Filter fields ─────────────────────────────────────────────────────────────
class UpdateRTIFromDateChanged extends UpdateRTIEvent {
  final String date;
  UpdateRTIFromDateChanged(this.date);
}

class UpdateRTIToDateChanged extends UpdateRTIEvent {
  final String date;
  UpdateRTIToDateChanged(this.date);
}

class UpdateRTIDriverChanged extends UpdateRTIEvent {
  final int    driverId;
  final String driverName;
  UpdateRTIDriverChanged({required this.driverId, required this.driverName});
}

class UpdateRTIDriverCleared extends UpdateRTIEvent {}

class UpdateRTITruckChanged extends UpdateRTIEvent {
  final int    truckId;
  final String truckName;
  UpdateRTITruckChanged({required this.truckId, required this.truckName});
}

class UpdateRTITruckCleared extends UpdateRTIEvent {}

class UpdateRTIRtiNoChanged extends UpdateRTIEvent {
  final String rtiNo;
  UpdateRTIRtiNoChanged(this.rtiNo);
}

// ── Load list ─────────────────────────────────────────────────────────────────
class UpdateRTILoadRequested extends UpdateRTIEvent {}

// ── Row expand/collapse ───────────────────────────────────────────────────────
class UpdateRTIRowToggled extends UpdateRTIEvent {
  final int masterIndex;
  UpdateRTIRowToggled(this.masterIndex);
}

// ── Share / PDF ───────────────────────────────────────────────────────────────
class UpdateRTIShareRequested extends UpdateRTIEvent {
  final int    id;
  final String rtiNoDisplay;
  UpdateRTIShareRequested({required this.id, required this.rtiNoDisplay});
}