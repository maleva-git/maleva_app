enum ExpStatus { initial , loading , success, failure}

class ExpReportState {
  final ExpStatus status;
  final List<dynamic> saleExpReport;
  final List<dynamic> saleExpReport2;
  final String dtpFromDate;
  final String dtpToDate;
  final String errorMessage;

  const ExpReportState ({
    this.status = ExpStatus.initial,
    this.saleExpReport = const [],
    this.saleExpReport2 = const [],
    this.dtpFromDate = '',
    this.dtpToDate = '',
    this.errorMessage = '',
});

  ExpReportState copyWith({
    ExpStatus? status,
    List<dynamic>? saleExpReport,
    List<dynamic>? saleExpReport2,
    String? dtpFromDate,
    String? dtpToDate,
    String? errorMessage,
}) {
    return ExpReportState(
      status: status ?? this.status,
      saleExpReport: saleExpReport ?? this.saleExpReport,
      saleExpReport2: saleExpReport2 ?? this.saleExpReport2,
      dtpFromDate: dtpFromDate ?? this.dtpFromDate,
      dtpToDate: dtpToDate ?? this.dtpToDate,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}