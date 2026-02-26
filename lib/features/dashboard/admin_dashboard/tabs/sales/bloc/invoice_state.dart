abstract class InvoiceState {}

class InvoiceInitial extends InvoiceState {}

class InvoiceLoading extends InvoiceState {}

class InvoiceLoaded extends InvoiceState {
  final List<dynamic> saleDataAll;
  final List<dynamic> saleMonthData;
  final List<dynamic> waitingBilling;
  final List<String> monthList;
  final List<dynamic> monthData;
  final bool is6Months;
  final String currentMonthName;
  final List<dynamic>? employeeData;
  final bool showWaitingSheet;


  InvoiceLoaded({
    required this.saleDataAll,
    required this.saleMonthData,
    required this.waitingBilling,
    required this.monthList,
    required this.monthData,
    required this.is6Months,
    required this.currentMonthName,
    required this.showWaitingSheet,
    this.employeeData,

  });
}

class InvoiceError extends InvoiceState {
  final String message;
  InvoiceError(this.message);
}

