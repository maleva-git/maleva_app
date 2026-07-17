

import 'package:equatable/equatable.dart';

import '../../../../../core/models/model.dart';
import 'package:maleva/core/models/shared/payment_pending_model.dart';
import 'package:maleva/features/transport/models/fuelselect_model.dart';

enum CustDashboardStatus { initial, loading, success, failure }

class CustDashboardState extends Equatable {
  const CustDashboardState({
    // ─── Global ────────────────────────────────────────────────────────────────
    this.status = CustDashboardStatus.initial,
    this.errorMessage = '',
    this.activeTabIndex = 0,

    // ─── Rules / Employee dropdown ──────────────────────────────────────────────
    this.rulesTypeEmployee = const [],
    this.selectedEmpId = '',
    this.empRefId = 0,

    // ─── Sales tab ─────────────────────────────────────────────────────────────
    this.withoutInvoiceCount = 0,
    this.totalCount = 0,
    this.totalBilledCount = 0,
    this.totalUnBilledCount = 0,
    this.salesReport = const [],

    // ─── Vessel tab ────────────────────────────────────────────────────────────
    this.saleCustReport = const [],
    this.vesselPortFilter = '',
    this.vesselPortsText = '',
    this.isVesselToday = true,

    // ─── Transport tab ─────────────────────────────────────────────────────────
    this.saleTransReport = const [],
    this.isPlanToday = true,

    // ─── Enquiry tab ───────────────────────────────────────────────────────────
    this.enquiryMasterList = const [],

    // ─── Fuel tab ──────────────────────────────────────────────────────────────
    this.fuelRecords = const [],
    this.fuelFromDate = '',
    this.fuelToDate = '',

    // ─── Payment tab ───────────────────────────────────────────────────────────
    this.masterList = const [],
    this.detailsList = const [],
    this.selectedCategoryFilter = 'All',
    this.selectedPaidFilter = 'All Payments',
    this.sid = 0,
    this.pSid = 0,
    this.paymentFromDate,
    this.paymentToDate,
  });

  // ─── Global ────────────────────────────────────────────────────────────────
  final CustDashboardStatus status;
  final String errorMessage;
  final int activeTabIndex;

  // ─── Rules / Employee dropdown ─────────────────────────────────────────────
  final List<Map<String, dynamic>> rulesTypeEmployee;
  final String selectedEmpId;
  final int empRefId;

  // ─── Sales tab ─────────────────────────────────────────────────────────────
  final int withoutInvoiceCount;
  final int totalCount;
  final int totalBilledCount;
  final int totalUnBilledCount;
  final List<dynamic> salesReport;

  // ─── Vessel tab ────────────────────────────────────────────────────────────
  final List<dynamic> saleCustReport;
  final String vesselPortFilter;
  final String vesselPortsText;
  final bool isVesselToday;

  // ─── Transport tab ─────────────────────────────────────────────────────────
  final List<dynamic> saleTransReport;
  final bool isPlanToday;

  // ─── Enquiry tab ───────────────────────────────────────────────────────────
  final List<dynamic> enquiryMasterList;

  // ─── Fuel tab ──────────────────────────────────────────────────────────────
  final List<FuelselectModel> fuelRecords;
  final String fuelFromDate;
  final String fuelToDate;

  // ─── Payment tab ───────────────────────────────────────────────────────────
  final List<PaymentPendingModel> masterList;
  final List<PaymentPendingModel> detailsList;
  final String selectedCategoryFilter;
  final String selectedPaidFilter;
  final int sid;
  final int pSid;
  final DateTime? paymentFromDate;
  final DateTime? paymentToDate;

  // ─── Computed helpers ──────────────────────────────────────────────────────

  double get totalFilteredAmount {
    double total = 0;
    for (var m in filteredMasterList) {
      total += (m.Amount ?? 0);
    }
    return total;
  }

  List<PaymentPendingModel> get filteredMasterList {
    return masterList.where((m) {
      bool matchesFilter = selectedCategoryFilter == 'All' ||
          (m.BankName != null &&
              m.BankName!.toLowerCase() ==
                  selectedCategoryFilter.toLowerCase()) ||
          (m.SubExpenseName != null &&
              m.SubExpenseName!.toLowerCase() ==
                  selectedCategoryFilter.toLowerCase()) ||
          (m.ExpenseName != null &&
              m.ExpenseName!
                  .toLowerCase()
                  .contains(selectedCategoryFilter.toLowerCase()));
      return matchesFilter;
    }).toList();
  }

  List<PaymentPendingModel> getRelatedDetails(PaymentPendingModel master) {
    if (master.SubExpenseName == null || master.SubExpenseName!.isEmpty) {
      return [];
    }
    final key = master.SubExpenseName!.split(' ')[0].toLowerCase();
    return detailsList
        .where((d) =>
    d.SubExpenseName?.toLowerCase().contains(key) ?? false)
        .toList();
  }

  CustDashboardState copyWith({
    CustDashboardStatus? status,
    String? errorMessage,
    int? activeTabIndex,
    List<Map<String, dynamic>>? rulesTypeEmployee,
    String? selectedEmpId,
    int? empRefId,
    int? withoutInvoiceCount,
    int? totalCount,
    int? totalBilledCount,
    int? totalUnBilledCount,
    List<dynamic>? salesReport,
    List<dynamic>? saleCustReport,
    String? vesselPortFilter,
    String? vesselPortsText,
    bool? isVesselToday,
    List<dynamic>? saleTransReport,
    bool? isPlanToday,
    List<dynamic>? enquiryMasterList,
    List<FuelselectModel>? fuelRecords,
    String? fuelFromDate,
    String? fuelToDate,
    List<PaymentPendingModel>? masterList,
    List<PaymentPendingModel>? detailsList,
    String? selectedCategoryFilter,
    String? selectedPaidFilter,
    int? sid,
    int? pSid,
    DateTime? paymentFromDate,
    DateTime? paymentToDate,
  }) {
    return CustDashboardState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      rulesTypeEmployee: rulesTypeEmployee ?? this.rulesTypeEmployee,
      selectedEmpId: selectedEmpId ?? this.selectedEmpId,
      empRefId: empRefId ?? this.empRefId,
      withoutInvoiceCount: withoutInvoiceCount ?? this.withoutInvoiceCount,
      totalCount: totalCount ?? this.totalCount,
      totalBilledCount: totalBilledCount ?? this.totalBilledCount,
      totalUnBilledCount: totalUnBilledCount ?? this.totalUnBilledCount,
      salesReport: salesReport ?? this.salesReport,
      saleCustReport: saleCustReport ?? this.saleCustReport,
      vesselPortFilter: vesselPortFilter ?? this.vesselPortFilter,
      vesselPortsText: vesselPortsText ?? this.vesselPortsText,
      isVesselToday: isVesselToday ?? this.isVesselToday,
      saleTransReport: saleTransReport ?? this.saleTransReport,
      isPlanToday: isPlanToday ?? this.isPlanToday,
      enquiryMasterList: enquiryMasterList ?? this.enquiryMasterList,
      fuelRecords: fuelRecords ?? this.fuelRecords,
      fuelFromDate: fuelFromDate ?? this.fuelFromDate,
      fuelToDate: fuelToDate ?? this.fuelToDate,
      masterList: masterList ?? this.masterList,
      detailsList: detailsList ?? this.detailsList,
      selectedCategoryFilter:
      selectedCategoryFilter ?? this.selectedCategoryFilter,
      selectedPaidFilter: selectedPaidFilter ?? this.selectedPaidFilter,
      sid: sid ?? this.sid,
      pSid: pSid ?? this.pSid,
      paymentFromDate: paymentFromDate ?? this.paymentFromDate,
      paymentToDate: paymentToDate ?? this.paymentToDate,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    activeTabIndex,
    rulesTypeEmployee,
    selectedEmpId,
    empRefId,
    withoutInvoiceCount,
    totalCount,
    totalBilledCount,
    totalUnBilledCount,
    salesReport,
    saleCustReport,
    vesselPortFilter,
    vesselPortsText,
    isVesselToday,
    saleTransReport,
    isPlanToday,
    enquiryMasterList,
    fuelRecords,
    fuelFromDate,
    fuelToDate,
    masterList,
    detailsList,
    selectedCategoryFilter,
    selectedPaidFilter,
    sid,
    pSid,
    paymentFromDate,
    paymentToDate,
  ];
}