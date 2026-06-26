// salesreport_event.dart

abstract class SalesReportEvent {
  const SalesReportEvent();
}

// Initial load — employee dropdown + sales data
class LoadSalesReportEvent extends SalesReportEvent {
  const LoadSalesReportEvent();
}

// Dropdown change பண்ணும் போது
class ChangeEmployeeEvent extends SalesReportEvent {
  final String? employeeId;
  const ChangeEmployeeEvent({required this.employeeId});
}

// Employee detail dialog load
class LoadEmpInvDataEvent extends SalesReportEvent {
  final int type;
  const LoadEmpInvDataEvent({required this.type});
}