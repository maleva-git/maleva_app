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

  // FIX: clearEmployeeData flag — null set பண்ண இதை use பண்றோம்
  InvoiceLoaded copyWith({
    List<dynamic>? saleDataAll,
    List<dynamic>? saleMonthData,
    List<dynamic>? waitingBilling,
    List<String>? monthList,
    List<dynamic>? monthData,
    bool? is6Months,
    String? currentMonthName,
    bool? showWaitingSheet,
    List<dynamic>? employeeData,
    bool clearEmployeeData = false, // ← இது true ஆனா employeeData = null
  }) {
    return InvoiceLoaded(
      saleDataAll: saleDataAll ?? this.saleDataAll,
      saleMonthData: saleMonthData ?? this.saleMonthData,
      waitingBilling: waitingBilling ?? this.waitingBilling,
      monthList: monthList ?? this.monthList,
      monthData: monthData ?? this.monthData,
      is6Months: is6Months ?? this.is6Months,
      currentMonthName: currentMonthName ?? this.currentMonthName,
      showWaitingSheet: showWaitingSheet ?? this.showWaitingSheet,
      // clearEmployeeData true → null, இல்லன்னா existing value
      employeeData: clearEmployeeData ? null : (employeeData ?? this.employeeData),
    );
  }
}

class InvoiceError extends InvoiceState {
  final String message;
  InvoiceError(this.message);
}