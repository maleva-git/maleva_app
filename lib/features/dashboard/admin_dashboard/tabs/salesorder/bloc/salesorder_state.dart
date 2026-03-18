import 'package:equatable/equatable.dart';

abstract class SalesOrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InvoiceInitial extends SalesOrderState {}

class InvoiceLoading extends SalesOrderState {}

// Tab switch-ல் full loading screen வேண்டாம்
// isTabSwitching = true → spinner இல்லாம existing UI காட்டு
class InvoiceTabSwitching extends SalesOrderState {
  final InvoiceLoaded previous;
  final int targetTabIndex;

  InvoiceTabSwitching({
    required this.previous,
    required this.targetTabIndex,
  });

  @override
  List<Object?> get props => [previous, targetTabIndex];
}

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

  @override
  List<Object?> get props => [
    saleDataAll,
    saleMonthData,
    waitingBilling,
    monthList,
    monthData,
    is6Months,
    currentMonthName,
    showWaitingSheet,
    employeeData,
    selectedTabIndex,
  ];

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
    int? selectedTabIndex,
    bool clearEmployeeData = false,
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
      employeeData:
      clearEmployeeData ? null : (employeeData ?? this.employeeData),
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}

class InvoiceError extends SalesOrderState {
  final String message;
  InvoiceError(this.message);

  @override
  List<Object?> get props => [message];
}