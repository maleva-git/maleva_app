// ═══════════════════════════════════════════════════════
// salesorder_view_state.dart
// ═══════════════════════════════════════════════════════
import 'package:equatable/equatable.dart';
import 'package:maleva/core/models/model.dart';

abstract class SalesOrderViewState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SalesOrderViewInitial extends SalesOrderViewState {}

class SalesOrderViewLoading extends SalesOrderViewState {}

class SalesOrderViewLoaded extends SalesOrderViewState {
  final List<SaleOrderMasterModel> masterList;
  final List<SaleOrderDetailModel> detailList;
  final List<SaleOrderDetailModel> selectedDetails;
  final bool progress;
  final int expandedIndex;

  // Filter fields
  final String dtpFromDate;
  final String dtpToDate;
  final int custId;
  final int empId;
  final int statusId;
  final String cls;
  final String etaVal;
  final String etaRadioVal;
  final bool checkBoxValueETA;
  final bool checkBoxValuePickUp;
  final bool checkBoxValueLEmp;
  final String txtJobNo;
  final String txtLoadingVessel;
  final String txtOffVessel;
  final String txtCustomer;
  final String txtEmployee;
  final String txtStatus;

  SalesOrderViewLoaded({
    this.masterList = const [],
    this.detailList = const [],
    this.selectedDetails = const [],
    this.progress = false,
    this.expandedIndex = -1,
    required this.dtpFromDate,
    required this.dtpToDate,
    this.custId = 0,
    this.empId = 0,
    this.statusId = 0,
    this.cls = '3',
    this.etaVal = '0',
    this.etaRadioVal = '0',
    this.checkBoxValueETA = false,
    this.checkBoxValuePickUp = false,
    this.checkBoxValueLEmp = false,
    this.txtJobNo = '',
    this.txtLoadingVessel = '',
    this.txtOffVessel = '',
    this.txtCustomer = '',
    this.txtEmployee = '',
    this.txtStatus = '',
  });

  @override
  List<Object?> get props => [
    masterList.length,
    progress,
    expandedIndex,
    dtpFromDate,
    dtpToDate,
    custId,
    empId,
    statusId,
    cls,
    etaVal,
    checkBoxValueETA,
    checkBoxValuePickUp,
    checkBoxValueLEmp,
    txtJobNo,
    txtLoadingVessel,
    txtOffVessel,
    txtCustomer,
    txtEmployee,
    txtStatus,
  ];

  SalesOrderViewLoaded copyWith({
    List<SaleOrderMasterModel>? masterList,
    List<SaleOrderDetailModel>? detailList,
    List<SaleOrderDetailModel>? selectedDetails,
    bool? progress,
    int? expandedIndex,
    String? dtpFromDate,
    String? dtpToDate,
    int? custId,
    int? empId,
    int? statusId,
    String? cls,
    String? etaVal,
    String? etaRadioVal,
    bool? checkBoxValueETA,
    bool? checkBoxValuePickUp,
    bool? checkBoxValueLEmp,
    String? txtJobNo,
    String? txtLoadingVessel,
    String? txtOffVessel,
    String? txtCustomer,
    String? txtEmployee,
    String? txtStatus,
  }) {
    return SalesOrderViewLoaded(
      masterList: masterList ?? this.masterList,
      detailList: detailList ?? this.detailList,
      selectedDetails: selectedDetails ?? this.selectedDetails,
      progress: progress ?? this.progress,
      expandedIndex: expandedIndex ?? this.expandedIndex,
      dtpFromDate: dtpFromDate ?? this.dtpFromDate,
      dtpToDate: dtpToDate ?? this.dtpToDate,
      custId: custId ?? this.custId,
      empId: empId ?? this.empId,
      statusId: statusId ?? this.statusId,
      cls: cls ?? this.cls,
      etaVal: etaVal ?? this.etaVal,
      etaRadioVal: etaRadioVal ?? this.etaRadioVal,
      checkBoxValueETA: checkBoxValueETA ?? this.checkBoxValueETA,
      checkBoxValuePickUp: checkBoxValuePickUp ?? this.checkBoxValuePickUp,
      checkBoxValueLEmp: checkBoxValueLEmp ?? this.checkBoxValueLEmp,
      txtJobNo: txtJobNo ?? this.txtJobNo,
      txtLoadingVessel: txtLoadingVessel ?? this.txtLoadingVessel,
      txtOffVessel: txtOffVessel ?? this.txtOffVessel,
      txtCustomer: txtCustomer ?? this.txtCustomer,
      txtEmployee: txtEmployee ?? this.txtEmployee,
      txtStatus: txtStatus ?? this.txtStatus,
    );
  }
}

class SalesOrderViewError extends SalesOrderViewState {
  final String message;
  SalesOrderViewError(this.message);

  @override
  List<Object?> get props => [message];
}