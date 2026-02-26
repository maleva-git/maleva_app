  abstract class SalesOrderState {}

  class InvoiceInitial extends SalesOrderState {}

  class InvoiceLoading extends SalesOrderState {}

  class InvoiceLoaded extends SalesOrderState {
    final List<dynamic> saleDataAll;
    final List<dynamic> saleMonthData;
    final List<dynamic> waitingBilling;
    final List<String> monthList;
    final List<dynamic> monthData;
    final bool is6Months;
    final String currentMonthName;
    final List<dynamic>? employeeData;
    final bool showWaitingSheet;
    final int selectedTabIndex;

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
      this.selectedTabIndex = 0,
    });
  }

  class InvoiceError extends SalesOrderState {
    final String message;
    InvoiceError(this.message);
  }

