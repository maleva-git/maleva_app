// ════════════════════════════════════════════════════════════════════
//  planning_event.dart
// ════════════════════════════════════════════════════════════════════

abstract class PlanningEvent {}

// ── Initial load + filter load ──
class LoadPlanningEvent extends PlanningEvent {
  final String fromDate;
  final String toDate;
  final int employeeId;
  final String planningNo;

  LoadPlanningEvent({
    required this.fromDate,
    required this.toDate,
    required this.employeeId,
    required this.planningNo,
  });
}

// ── Expand / collapse a planning card ──
class TogglePlanningExpand extends PlanningEvent {
  final int index;
  final int masterRefId;
  TogglePlanningExpand({required this.index, required this.masterRefId});
}

// ── Share / export PDF ──
class SharePlanningPdfEvent extends PlanningEvent {
  final int id;
  final String planningNoDisplay;
  SharePlanningPdfEvent({required this.id, required this.planningNoDisplay});
}

// ── Password verified → edit planning ──
class EditPlanningEvent extends PlanningEvent {
  final int id;
  final int planningNo;
  EditPlanningEvent({required this.id, required this.planningNo});
}

// ── Employee selected in filter ──
class SelectEmployeeEvent extends PlanningEvent {
  final int empId;
  final String empName;
  SelectEmployeeEvent({required this.empId, required this.empName});
}

// ── Clear employee filter ──
class ClearEmployeeEvent extends PlanningEvent {}

// ── Toggle "Logged-in Employee" checkbox ──
class ToggleLoggedEmpEvent extends PlanningEvent {
  final bool value;
  ToggleLoggedEmpEvent(this.value);
}

// ── Update filter dates ──
class UpdateFilterDatesEvent extends PlanningEvent {
  final String? fromDate;
  final String? toDate;
  UpdateFilterDatesEvent({this.fromDate, this.toDate});
}

// ── Update planning no search text ──
class UpdatePlanningNoEvent extends PlanningEvent {
  final String value;
  UpdatePlanningNoEvent(this.value);
}