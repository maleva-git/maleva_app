enum FWStatus { initial, loading, success, failure }

class ForwardingReportState  {
  final FWStatus status;
  final List<dynamic> saleFWReport;
  final List<dynamic> saleFWReport2;
  final String dtpFromDate;
  final String dtpToDate;
  final String errorMessage;

  const ForwardingReportState({
    this.status = FWStatus.initial,
    this.saleFWReport = const [],
    this.saleFWReport2 = const [],
    this.dtpFromDate = '',
    this.dtpToDate = '',
    this.errorMessage = '',
  });

  ForwardingReportState copyWith({
    FWStatus? status,
    List<dynamic>? saleFWReport,
    List<dynamic>? saleFWReport2,
    String? dtpFromDate,
    String? dtpToDate,
    String? errorMessage,
  }) {
    return ForwardingReportState(
      status: status ?? this.status,
      saleFWReport: saleFWReport ?? this.saleFWReport,
      saleFWReport2: saleFWReport2 ?? this.saleFWReport2,
      dtpFromDate: dtpFromDate ?? this.dtpFromDate,
      dtpToDate: dtpToDate ?? this.dtpToDate,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
    status,
    saleFWReport,
    saleFWReport2,
    dtpFromDate,
    dtpToDate,
    errorMessage,
  ];
}