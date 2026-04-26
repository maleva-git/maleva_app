// lib/features/dashboard/admin_dashboard/tabs/invoice/bloc/invoice_state.dart

import 'package:equatable/equatable.dart';

sealed class InvoiceState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// App just started — nothing loaded yet
class InvoiceInitial extends InvoiceState {}

/// First load spinner
class InvoiceLoading extends InvoiceState {}

/// Pull-to-refresh — keeps stale data visible, shows subtle indicator
/// UI: show previous data + a thin top loading bar
class InvoiceRefreshing extends InvoiceState {
  final InvoiceLoaded previous;
   InvoiceRefreshing(this.previous);

  @override
  List<Object?> get props => [previous];
}

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

  // ── Equatable props — only primitives + lengths ────────────────
  // List full content compare → slow. Length + key booleans = enough
  // for buildWhen to work. View already checks list content itself.
  @override
  List<Object?> get props => [
    is6Months,
    showWaitingSheet,
    currentMonthName,
    saleDataAll.length,
    monthData.length,
    monthList.length,
    waitingBilling.length,
    employeeData, // null vs non-null triggers dialog
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
    bool clearEmployeeData = false,
  }) {
    return InvoiceLoaded(
      saleDataAll:      saleDataAll      ?? this.saleDataAll,
      saleMonthData:    saleMonthData    ?? this.saleMonthData,
      waitingBilling:   waitingBilling   ?? this.waitingBilling,
      monthList:        monthList        ?? this.monthList,
      monthData:        monthData        ?? this.monthData,
      is6Months:        is6Months        ?? this.is6Months,
      currentMonthName: currentMonthName ?? this.currentMonthName,
      showWaitingSheet: showWaitingSheet ?? this.showWaitingSheet,
      employeeData: clearEmployeeData ? null : (employeeData ?? this.employeeData),
    );
  }
}

class InvoiceError extends InvoiceState {
  final String message;
   InvoiceError(this.message);

  @override
  List<Object?> get props => [message];
}