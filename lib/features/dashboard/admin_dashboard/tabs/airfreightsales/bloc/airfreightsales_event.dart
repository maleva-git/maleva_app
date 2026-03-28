

abstract class CustomerDashboardEvent {}

class LoadRulesTypeEvent extends CustomerDashboardEvent {}

class EmployeeChangedEvent extends CustomerDashboardEvent {
  final String selectedEmpId;
  EmployeeChangedEvent(this.selectedEmpId);
}

class LoadSalesDataEvent extends CustomerDashboardEvent {
  final int empId;
  LoadSalesDataEvent(this.empId);
}