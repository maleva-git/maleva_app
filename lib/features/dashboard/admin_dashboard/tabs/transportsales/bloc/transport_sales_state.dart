import 'package:equatable/equatable.dart';

enum TransportSalesStatus { loading, success, failure }

class TransportSalesState extends Equatable {
  final TransportSalesStatus status;
  final List<Map<String, dynamic>> rulesTypeEmployee;
  final String? selectedEmpId;
  final int withoutInvoiceCount;
  final int totalCount;
  final int totalBilledCount;
  final int totalUnBilledCount;
  final List<dynamic> salesReport;
  final String errorMessage;

  const TransportSalesState({
    this.status = TransportSalesStatus.loading,
    this.rulesTypeEmployee = const [],
    this.selectedEmpId,
    this.withoutInvoiceCount = 0,
    this.totalCount = 0,
    this.totalBilledCount = 0,
    this.totalUnBilledCount = 0,
    this.salesReport = const [],
    this.errorMessage = '',
  });

  TransportSalesState copyWith({
    TransportSalesStatus? status,
    List<Map<String, dynamic>>? rulesTypeEmployee,
    String? selectedEmpId,
    int? withoutInvoiceCount,
    int? totalCount,
    int? totalBilledCount,
    int? totalUnBilledCount,
    List<dynamic>? salesReport,
    String? errorMessage,
  }) {
    return TransportSalesState(
      status: status ?? this.status,
      rulesTypeEmployee: rulesTypeEmployee ?? this.rulesTypeEmployee,
      selectedEmpId: selectedEmpId ?? this.selectedEmpId,
      withoutInvoiceCount: withoutInvoiceCount ?? this.withoutInvoiceCount,
      totalCount: totalCount ?? this.totalCount,
      totalBilledCount: totalBilledCount ?? this.totalBilledCount,
      totalUnBilledCount: totalUnBilledCount ?? this.totalUnBilledCount,
      salesReport: salesReport ?? this.salesReport,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    rulesTypeEmployee,
    selectedEmpId,
    withoutInvoiceCount,
    totalCount,
    totalBilledCount,
    totalUnBilledCount,
    salesReport,
    errorMessage,
  ];
}