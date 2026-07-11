abstract class VesselDashboardEvent {}

class VesselDashboardStarted extends VesselDashboardEvent {}

class VesselDatesChanged extends VesselDashboardEvent {
  final String fromDate;
  final String toDate;
  VesselDatesChanged({required this.fromDate, required this.toDate});
}

class VesselStatusSelected extends VesselDashboardEvent {
  final int statusId;
  final String statusName;
  VesselStatusSelected({required this.statusId, required this.statusName});
}

class VesselStatusCleared extends VesselDashboardEvent {}

class VesselPortAdded extends VesselDashboardEvent {
  final String port;
  VesselPortAdded(this.port);
}

class VesselRemarksCleared extends VesselDashboardEvent {}

class VesselLoadRequested extends VesselDashboardEvent {}