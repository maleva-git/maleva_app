

abstract class VesselPlanningEvent {}

// Initial load
class VesselPlanningStarted extends VesselPlanningEvent {}

// Filter / search
class VesselPlanningFilterChanged extends VesselPlanningEvent {
  final String fromDate;
  final String toDate;
  final String planningNo;
  final int empId;
  final bool isLoggedInEmp;

  VesselPlanningFilterChanged({
    required this.fromDate,
    required this.toDate,
    required this.planningNo,
    required this.empId,
    required this.isLoggedInEmp,
  });
}

// Expand / collapse card
class VesselPlanningRowToggled extends VesselPlanningEvent {
  final int index;
  final int masterRefId;

  VesselPlanningRowToggled({required this.index, required this.masterRefId});
}

// Share PDF
class VesselPlanningShareRequested extends VesselPlanningEvent {
  final int id;
  final String planningNoDisplay;

  VesselPlanningShareRequested({required this.id, required this.planningNoDisplay});
}

// Password verified → load edit data then navigate
class VesselPlanningEditRequested extends VesselPlanningEvent {
  final int id;
  final int planningNo;

  VesselPlanningEditRequested({required this.id, required this.planningNo});
}

// Employee selected from search page
class VesselPlanningEmployeeSelected extends VesselPlanningEvent {
  final String name;
  final int empId;

  VesselPlanningEmployeeSelected({required this.name, required this.empId});
}

// Clear employee
class VesselPlanningEmployeeCleared extends VesselPlanningEvent {}