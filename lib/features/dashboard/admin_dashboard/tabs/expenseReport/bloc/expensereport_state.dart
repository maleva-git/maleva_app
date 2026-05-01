import 'package:equatable/equatable.dart';

enum ExpenseReportStatus { initial, loading, loaded, error }

class ExpenseReportState extends Equatable {
  final ExpenseReportStatus status;
  final List<Map<String, dynamic>> saleExpReport;
  final List<Map<String, dynamic>> saleExpReport2;
  // Use DateTime instead of String for easier UI DatePicker management
  final DateTime? fromDate;
  final DateTime? toDate;
  final String errorMessage;

  const ExpenseReportState({
    this.status = ExpenseReportStatus.initial,
    this.saleExpReport = const [],
    this.saleExpReport2 = const [],
    this.fromDate,
    this.toDate,
    this.errorMessage = '',
  });

  ExpenseReportState copyWith({
    ExpenseReportStatus? status,
    List<Map<String, dynamic>>? saleExpReport,
    List<Map<String, dynamic>>? saleExpReport2,
    DateTime? fromDate,
    DateTime? toDate,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ExpenseReportState(
      status: status ?? this.status,
      saleExpReport: saleExpReport ?? this.saleExpReport,
      saleExpReport2: saleExpReport2 ?? this.saleExpReport2,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    saleExpReport,
    saleExpReport2,
    fromDate,
    toDate,
    errorMessage,
  ];
}