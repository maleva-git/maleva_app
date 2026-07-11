

import 'package:equatable/equatable.dart';
import 'package:flutter/Material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/models/model.dart';

enum SaleOrderStatus { initial, loading, success, failure, updating }

class SaleOrderState extends Equatable {
   SaleOrderState({
    this.status           = SaleOrderStatus.initial,
    this.masterList       = const [],
    this.errorMessage     = '',
    this.currentlyVisibleIndex = -1,
    this.toggleTrigger    = 0,
    // ── Filters ───────────────────────────────────────────
    String? fromDate,
    String? toDate,
    this.custId           = 0,
    this.custName         = '',
    this.empId            = 0,
    this.empName          = '',
    this.statusId         = 0,
    this.statusName       = '',
    this.checkBoxValueLEmp = false,
    this.checkBoxValuePickUp = false,
    this.completeStatusNotShow = false,
    this.cls              = '3',
    this.etaVal           = '0',
    this.etaRadioVal      = '0',
    this.checkBoxValueETA = false,
    this.jobNo            = '',
    this.loadingVessel    = '',
    this.offVessel        = '',
    // ── ETA dialog dates ─────────────────────────────────
    this.leta,
    this.letb,
    this.oeta,
    this.oetb,
  })  : fromDate = fromDate ?? today(),
        toDate   = toDate   ?? today();

  final SaleOrderStatus status;
  final List<SaleOrderMasterModel> masterList;
  final String errorMessage;
  final int currentlyVisibleIndex;
  final int toggleTrigger;

  // Filters
  final String fromDate;
  final String toDate;
  final int custId;
  final String custName;
  final int empId;
  final String empName;
  final int statusId;
  final String statusName;
  final bool checkBoxValueLEmp;
  final bool checkBoxValuePickUp;
  final bool completeStatusNotShow;
  final String cls;
  final String etaVal;
  final String etaRadioVal;
  final bool checkBoxValueETA;
  final String jobNo;
  final String loadingVessel;
  final String offVessel;

  // ETA dialog dates
  final DateTime? leta;
  final DateTime? letb;
  final DateTime? oeta;
  final DateTime? oetb;

  // ── Derived helpers ───────────────────────────────────────────────────────

  bool get isLoading   => status == SaleOrderStatus.loading;
  bool get isUpdating  => status == SaleOrderStatus.updating;
  bool get hasData     => status == SaleOrderStatus.success && masterList.isNotEmpty;
  bool get isEmpty     => status == SaleOrderStatus.success && masterList.isEmpty;

  /// Card background colour — mirrors original _CardColor logic
  Color? cardColor(int index) {
    final item = masterList[index];
    final hasPickup = item.SPickupDate.toString().isNotEmpty;
    final hasSETA   = item.SETA.toString().isNotEmpty;
    final hasSOETA  = item.SOETA.toString().isNotEmpty;

    if (hasPickup && (hasSETA || hasSOETA)) return null;
    if (!hasPickup && !hasSETA && !hasSOETA)
      return Colors.redAccent.withOpacity(0.3);
    if (!hasPickup) return Colors.yellowAccent.withOpacity(0.3);
    if (item.JobMasterRefId == 10) return null;
    return Colors.greenAccent.withOpacity(0.3);
  }

  static String today() =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  SaleOrderState copyWith({
    SaleOrderStatus? status,
    List<SaleOrderMasterModel>? masterList,
    String? errorMessage,
    int? currentlyVisibleIndex,
    int? toggleTrigger,
    String? fromDate,
    String? toDate,
    int? custId,
    String? custName,
    int? empId,
    String? empName,
    int? statusId,
    String? statusName,
    bool? checkBoxValueLEmp,
    bool? checkBoxValuePickUp,
    bool? completeStatusNotShow,
    String? cls,
    String? etaVal,
    String? etaRadioVal,
    bool? checkBoxValueETA,
    String? jobNo,
    String? loadingVessel,
    String? offVessel,
    DateTime? leta,
    DateTime? letb,
    DateTime? oeta,
    DateTime? oetb,
    bool clearLeta  = false,
    bool clearLetb  = false,
    bool clearOeta  = false,
    bool clearOetb  = false,
  }) {
    return SaleOrderState(
      status:               status               ?? this.status,
      masterList:           masterList           ?? this.masterList,
      errorMessage:         errorMessage         ?? this.errorMessage,
      currentlyVisibleIndex: currentlyVisibleIndex ?? this.currentlyVisibleIndex,
      toggleTrigger:        toggleTrigger        ?? this.toggleTrigger,
      fromDate:             fromDate             ?? this.fromDate,
      toDate:               toDate               ?? this.toDate,
      custId:               custId               ?? this.custId,
      custName:             custName             ?? this.custName,
      empId:                empId                ?? this.empId,
      empName:              empName              ?? this.empName,
      statusId:             statusId             ?? this.statusId,
      statusName:           statusName           ?? this.statusName,
      checkBoxValueLEmp:    checkBoxValueLEmp    ?? this.checkBoxValueLEmp,
      checkBoxValuePickUp:  checkBoxValuePickUp  ?? this.checkBoxValuePickUp,
      completeStatusNotShow: completeStatusNotShow ?? this.completeStatusNotShow,
      cls:                  cls                  ?? this.cls,
      etaVal:               etaVal               ?? this.etaVal,
      etaRadioVal:          etaRadioVal          ?? this.etaRadioVal,
      checkBoxValueETA:     checkBoxValueETA     ?? this.checkBoxValueETA,
      jobNo:                jobNo                ?? this.jobNo,
      loadingVessel:        loadingVessel        ?? this.loadingVessel,
      offVessel:            offVessel            ?? this.offVessel,
      leta:  clearLeta  ? null : (leta  ?? this.leta),
      letb:  clearLetb  ? null : (letb  ?? this.letb),
      oeta:  clearOeta  ? null : (oeta  ?? this.oeta),
      oetb:  clearOetb  ? null : (oetb  ?? this.oetb),
    );
  }

  @override
  List<Object?> get props => [
    status, masterList, errorMessage, currentlyVisibleIndex, toggleTrigger,
    fromDate, toDate, custId, empId, statusId,
    checkBoxValueLEmp, checkBoxValuePickUp, completeStatusNotShow,
    cls, etaVal, etaRadioVal, checkBoxValueETA,
    jobNo, loadingVessel, offVessel,
    leta, letb, oeta, oetb,
  ];
}