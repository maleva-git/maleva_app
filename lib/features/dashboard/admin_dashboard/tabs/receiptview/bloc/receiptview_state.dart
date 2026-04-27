// lib/features/dashboard/admin_dashboard/tabs/receiptview/bloc/receiptview_state.dart

import 'package:equatable/equatable.dart';

// ── Status enum — replaces the confusing `progress` bool ──────────────────────
// BEFORE: progress=false means loading, progress=true means done — inverted!
// AFTER:  explicit enum — clear, readable
enum ReceiptStatus { initial, loading, loaded, error }

class ReceiptState extends Equatable {
  final ReceiptStatus status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final List<Map<String, dynamic>> receiptMaster;
  final List<Map<String, dynamic>> receiptDetails;
  final double totalAmount;
  final double totalBalance;
  final String? errorMessage;

  const ReceiptState({
    this.status = ReceiptStatus.initial,
    this.fromDate,
    this.toDate,
    this.receiptMaster = const [],
    this.receiptDetails = const [],
    this.totalAmount = 0.0,
    this.totalBalance = 0.0,
    this.errorMessage,
  });

  // Convenience getters for view
  bool get isLoading => status == ReceiptStatus.loading;
  bool get isLoaded  => status == ReceiptStatus.loaded;
  bool get hasError  => status == ReceiptStatus.error;

  ReceiptState copyWith({
    ReceiptStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
    List<Map<String, dynamic>>? receiptMaster,
    List<Map<String, dynamic>>? receiptDetails,
    double? totalAmount,
    double? totalBalance,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReceiptState(
      status:         status         ?? this.status,
      fromDate:       fromDate       ?? this.fromDate,
      toDate:         toDate         ?? this.toDate,
      receiptMaster:  receiptMaster  ?? this.receiptMaster,
      receiptDetails: receiptDetails ?? this.receiptDetails,
      totalAmount:    totalAmount    ?? this.totalAmount,
      totalBalance:   totalBalance   ?? this.totalBalance,
      errorMessage:   clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    fromDate,
    toDate,
    receiptMaster.length,
    totalAmount,
    totalBalance,
    errorMessage,
  ];
}