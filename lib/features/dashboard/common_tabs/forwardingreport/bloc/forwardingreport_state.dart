import 'package:equatable/equatable.dart';

enum ForwardingReportStatus { initial, loading, loaded, error }

class ForwardingReportState extends Equatable {
  final ForwardingReportStatus status;
  final List<Map<String, dynamic>> saleFWReport;
  final List<Map<String, dynamic>> saleFWReport2;
  // Use DateTime instead of String for easier UI DatePicker management
  final DateTime? fromDate;
  final DateTime? toDate;
  final String errorMessage;

  const ForwardingReportState({
    this.status = ForwardingReportStatus.initial,
    this.saleFWReport = const [],
    this.saleFWReport2 = const [],
    this.fromDate,
    this.toDate,
    this.errorMessage = '',
  });

  ForwardingReportState copyWith({
    ForwardingReportStatus? status,
    List<Map<String, dynamic>>? saleFWReport,
    List<Map<String, dynamic>>? saleFWReport2,
    DateTime? fromDate,
    DateTime? toDate,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ForwardingReportState(
      status: status ?? this.status,
      saleFWReport: saleFWReport ?? this.saleFWReport,
      saleFWReport2: saleFWReport2 ?? this.saleFWReport2,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    saleFWReport,
    saleFWReport2,
    fromDate,
    toDate,
    errorMessage,
  ];
}