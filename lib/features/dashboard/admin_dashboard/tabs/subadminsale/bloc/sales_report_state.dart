// salesreport_state.dart

abstract class SalesReportState {
  const SalesReportState();
}

class SalesReportInitial extends SalesReportState {
  const SalesReportInitial();
}

class SalesReportLoading extends SalesReportState {
  const SalesReportLoading();
}

class SalesReportLoaded extends SalesReportState {
  final List<Map<String, dynamic>> rulesTypeEmployee;
  final String? dropdownValueEmp;
  final int withoutInvoiceCount;
  final int totalCount;
  final int totalBilledCount;
  final int totalUnBilledCount;
  final List<dynamic> salesReport;

  const SalesReportLoaded({
    required this.rulesTypeEmployee,
    required this.dropdownValueEmp,
    required this.withoutInvoiceCount,
    required this.totalCount,
    required this.totalBilledCount,
    required this.totalUnBilledCount,
    required this.salesReport,
  });

  // CopyWith — dropdown change பண்ணும் போது use பண்ண
  SalesReportLoaded copyWith({
    List<Map<String, dynamic>>? rulesTypeEmployee,
    String? dropdownValueEmp,
    bool clearDropdown = false,
    int? withoutInvoiceCount,
    int? totalCount,
    int? totalBilledCount,
    int? totalUnBilledCount,
    List<dynamic>? salesReport,
  }) {
    return SalesReportLoaded(
      rulesTypeEmployee: rulesTypeEmployee ?? this.rulesTypeEmployee,
      dropdownValueEmp: clearDropdown ? null : (dropdownValueEmp ?? this.dropdownValueEmp),
      withoutInvoiceCount: withoutInvoiceCount ?? this.withoutInvoiceCount,
      totalCount: totalCount ?? this.totalCount,
      totalBilledCount: totalBilledCount ?? this.totalBilledCount,
      totalUnBilledCount: totalUnBilledCount ?? this.totalUnBilledCount,
      salesReport: salesReport ?? this.salesReport,
    );
  }
}

class SalesReportError extends SalesReportState {
  final String errorMessage;
  const SalesReportError({required this.errorMessage});
}

// Employee detail dialog state
class SalesReportEmpDetailLoaded extends SalesReportState {
  final List<dynamic> empSalesReport;
  const SalesReportEmpDetailLoaded({required this.empSalesReport});
}