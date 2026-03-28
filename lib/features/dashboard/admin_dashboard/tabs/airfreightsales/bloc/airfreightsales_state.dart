

class CustomerDashboardState {
  final bool isLoading;
  final List<Map<String, dynamic>> rulesTypeEmployee;
  final String dropdownValueEmp;
  final int empId;

  final int withoutInvoiceCount;
  final int totalCount;
  final int totalBilledCount;
  final int totalUnBilledCount;
  final List<dynamic> salesReport;

  const CustomerDashboardState({
    this.isLoading = false,
    this.rulesTypeEmployee = const [],
    this.dropdownValueEmp = '',
    this.empId = 0,
    this.withoutInvoiceCount = 0,
    this.totalCount = 0,
    this.totalBilledCount = 0,
    this.totalUnBilledCount = 0,
    this.salesReport = const [],
  });

  CustomerDashboardState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? rulesTypeEmployee,
    String? dropdownValueEmp,
    int? empId,
    int? withoutInvoiceCount,
    int? totalCount,
    int? totalBilledCount,
    int? totalUnBilledCount,
    List<dynamic>? salesReport,
  }) {
    return CustomerDashboardState(
      isLoading: isLoading ?? this.isLoading,
      rulesTypeEmployee: rulesTypeEmployee ?? this.rulesTypeEmployee,
      dropdownValueEmp: dropdownValueEmp ?? this.dropdownValueEmp,
      empId: empId ?? this.empId,
      withoutInvoiceCount: withoutInvoiceCount ?? this.withoutInvoiceCount,
      totalCount: totalCount ?? this.totalCount,
      totalBilledCount: totalBilledCount ?? this.totalBilledCount,
      totalUnBilledCount: totalUnBilledCount ?? this.totalUnBilledCount,
      salesReport: salesReport ?? this.salesReport,
    );
  }
}