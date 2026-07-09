abstract class PlanningEvent {}

class LoadPlanningEvent extends PlanningEvent {
  final String fromDate;
  final String toDate;
  final int employeeId;
  final String employeeName;
  final String planningNo;
  final bool checkLoggedEmp;

  LoadPlanningEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
    required this.employeeName,
    required this.planningNo,
    required this.checkLoggedEmp,
  });
}

class TogglePlanningExpand extends PlanningEvent {
  final int index;
  final int masterRefId;
  TogglePlanningExpand({required this.index, required this.masterRefId});
}

class SharePlanningPdfEvent extends PlanningEvent {
  final int id;
  final String planningNoDisplay;
  SharePlanningPdfEvent({required this.id, required this.planningNoDisplay});
}

class PlanningEditRequestedEvent extends PlanningEvent {
  final int id;
  final int planningNo;
  PlanningEditRequestedEvent({required this.id, required this.planningNo});
}