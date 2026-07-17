

import 'package:equatable/equatable.dart';

import '../../../../../core/models/model.dart';
import 'package:maleva/core/models/shared/email_model.dart';
import 'package:maleva/core/models/shared/r_t_i_details_view_model.dart';
import 'package:maleva/core/models/shared/review.dart';
import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:maleva/core/models/shared/r_t_i_master_view_model.dart';

enum TransportDashboardStatus { initial, loading, success, failure }

class TransportDashboardState extends Equatable {
  // ─── Global ──────────────────────────────────────────────────────────────
  final TransportDashboardStatus status;
  final String? errorMessage;

  // ─── Sales Tab ───────────────────────────────────────────────────────────
  final int withoutInvoiceCount;
  final int totalCount;
  final int totalBilledCount;
  final int totalUnBilledCount;
  final List<dynamic> salesReport;
  final List<Map<String, dynamic>> rulesTypeEmployee;
  final String? dropdownValueEmp;
  final int empId;

  // ─── Transport Tab ───────────────────────────────────────────────────────
  final List<dynamic> saleTransReport;
  final bool isPlanToday;

  // ─── Enquiry Tab ─────────────────────────────────────────────────────────
  final List<dynamic> enquiryMasterList;

  // ─── Email Inbox Tab ─────────────────────────────────────────────────────
  final List<EmployeeModel> employees;
  final EmployeeModel? selectedEmployee;
  final List<EmailModel> emails;
  final bool isSavingEmails;

  // ─── Google Review Tab ───────────────────────────────────────────────────
  final int selectedReview;
  final int? selectedEmpId;
  final DateTime selectedDate;
  final bool isSavingReview;

  // ─── RTI / PDO Tab ───────────────────────────────────────────────────────
  final List<RTIMasterViewModel> allRTIMasterList;
  final List<RTIMasterViewModel> filteredRTIMasterList;
  final List<RTIDetailsViewModel> rtiDetailList;
  final bool isSavingRTI;

  const TransportDashboardState({
    this.status = TransportDashboardStatus.initial,
    this.errorMessage,
    // Sales
    this.withoutInvoiceCount = 0,
    this.totalCount = 0,
    this.totalBilledCount = 0,
    this.totalUnBilledCount = 0,
    this.salesReport = const [],
    this.rulesTypeEmployee = const [],
    this.dropdownValueEmp,
    this.empId = 0,
    // Transport
    this.saleTransReport = const [],
    this.isPlanToday = true,
    // Enquiry
    this.enquiryMasterList = const [],
    // Email
    this.employees = const [],
    this.selectedEmployee,
    this.emails = const [],
    this.isSavingEmails = false,
    // Review
    this.selectedReview = 1,
    this.selectedEmpId,
    DateTime? selectedDate,
    this.isSavingReview = false,
    // RTI
    this.allRTIMasterList = const [],
    this.filteredRTIMasterList = const [],
    this.rtiDetailList = const [],
    this.isSavingRTI = false,
  }) : selectedDate = selectedDate ?? const _NowDate();

  // Helper factory for initial state
  factory TransportDashboardState.initial() => TransportDashboardState(
    selectedDate: DateTime.now(),
  );

  TransportDashboardState copyWith({
    TransportDashboardStatus? status,
    String? errorMessage,
    // Sales
    int? withoutInvoiceCount,
    int? totalCount,
    int? totalBilledCount,
    int? totalUnBilledCount,
    List<dynamic>? salesReport,
    List<Map<String, dynamic>>? rulesTypeEmployee,
    String? dropdownValueEmp,
    bool clearDropdownValueEmp = false,
    int? empId,
    // Transport
    List<dynamic>? saleTransReport,
    bool? isPlanToday,
    // Enquiry
    List<dynamic>? enquiryMasterList,
    // Email
    List<EmployeeModel>? employees,
    EmployeeModel? selectedEmployee,
    List<EmailModel>? emails,
    bool? isSavingEmails,
    // Review
    int? selectedReview,
    int? selectedEmpId,
    bool clearSelectedEmpId = false,
    DateTime? selectedDate,
    bool? isSavingReview,
    // RTI
    List<RTIMasterViewModel>? allRTIMasterList,
    List<RTIMasterViewModel>? filteredRTIMasterList,
    List<RTIDetailsViewModel>? rtiDetailList,
    bool? isSavingRTI,
  }) {
    return TransportDashboardState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      // Sales
      withoutInvoiceCount: withoutInvoiceCount ?? this.withoutInvoiceCount,
      totalCount: totalCount ?? this.totalCount,
      totalBilledCount: totalBilledCount ?? this.totalBilledCount,
      totalUnBilledCount: totalUnBilledCount ?? this.totalUnBilledCount,
      salesReport: salesReport ?? this.salesReport,
      rulesTypeEmployee: rulesTypeEmployee ?? this.rulesTypeEmployee,
      dropdownValueEmp: clearDropdownValueEmp ? null : (dropdownValueEmp ?? this.dropdownValueEmp),
      empId: empId ?? this.empId,
      // Transport
      saleTransReport: saleTransReport ?? this.saleTransReport,
      isPlanToday: isPlanToday ?? this.isPlanToday,
      // Enquiry
      enquiryMasterList: enquiryMasterList ?? this.enquiryMasterList,
      // Email
      employees: employees ?? this.employees,
      selectedEmployee: selectedEmployee ?? this.selectedEmployee,
      emails: emails ?? this.emails,
      isSavingEmails: isSavingEmails ?? this.isSavingEmails,
      // Review
      selectedReview: selectedReview ?? this.selectedReview,
      selectedEmpId: clearSelectedEmpId ? null : (selectedEmpId ?? this.selectedEmpId),
      selectedDate: selectedDate ?? this.selectedDate,
      isSavingReview: isSavingReview ?? this.isSavingReview,
      // RTI
      allRTIMasterList: allRTIMasterList ?? this.allRTIMasterList,
      filteredRTIMasterList: filteredRTIMasterList ?? this.filteredRTIMasterList,
      rtiDetailList: rtiDetailList ?? this.rtiDetailList,
      isSavingRTI: isSavingRTI ?? this.isSavingRTI,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    withoutInvoiceCount,
    totalCount,
    totalBilledCount,
    totalUnBilledCount,
    salesReport,
    rulesTypeEmployee,
    dropdownValueEmp,
    empId,
    saleTransReport,
    isPlanToday,
    enquiryMasterList,
    employees,
    selectedEmployee,
    emails,
    isSavingEmails,
    selectedReview,
    selectedEmpId,
    selectedDate,
    isSavingReview,
    allRTIMasterList,
    filteredRTIMasterList,
    rtiDetailList,
    isSavingRTI,
  ];
}

// Private sentinel so we can default DateTime in const context
class _NowDate implements DateTime {
  const _NowDate();
  // This is never actually used; the factory handles real DateTime.now()
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}