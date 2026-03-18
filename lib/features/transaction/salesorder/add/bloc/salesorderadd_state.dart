import 'package:equatable/equatable.dart';
import 'package:maleva/core/models/model.dart';

// ═══════════════════════════════════════════════════════
// STATE
// ═══════════════════════════════════════════════════════
abstract class SalesOrderAddState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SalesOrderAddInitial extends SalesOrderAddState {}

class SalesOrderAddLoading extends SalesOrderAddState {}

class SalesOrderAddLoaded extends SalesOrderAddState {
  // ── Progress / UI flags ──────────────────────────────
  final bool progress;
  final bool showSearch;

  // ── Product list ─────────────────────────────────────
  final List<SaleEditDetailModel> productViewList;
  final int? productUpdateIndex;

  // ── Amounts ──────────────────────────────────────────
  final double totalAmount;
  final double taxAmount;
  final double currencyValue;
  final double actualAmount;
  final double coinage;

  // ── IDs ──────────────────────────────────────────────
  final int custId;
  final int statusId;
  final int jobTypeId;
  final int lAgentCompanyId;
  final int lAgentId;
  final int oAgentCompanyId;
  final int oAgentId;
  final int sealEmpId1;
  final int sealEmpId2;
  final int sealEmpId3;
  final int breakEmpId1;
  final int breakEmpId2;
  final int breakEmpId3;
  final int boardOfficerId1;
  final int boardOfficerId2;
  final int originId;
  final int destinationId;
  final int editId;
  final int enquiryId;

  // ── Date strings ─────────────────────────────────────
  final String dtpSaleOrderdate;
  final String dtpOETAdate;
  final String dtpOETBdate;
  final String dtpOETDdate;
  final String dtpLETAdate;
  final String dtpLETBdate;
  final String dtpLETDdate;
  final String dtpFlightTimedate;
  final String dtpPickUpdate;
  final String dtpDeliverydate;
  final String dtpWHEntrydate;
  final String dtpWHExitdate;
  final String dtpFW1date;
  final String dtpFW2date;
  final String dtpFW3date;

  // ── Checkboxes ───────────────────────────────────────
  final bool checkBoxValueOETA;
  final bool checkBoxValueOETB;
  final bool checkBoxValueOETD;
  final bool checkBoxValueLETA;
  final bool checkBoxValueFlightTime;
  final bool checkBoxValueLETB;
  final bool checkBoxValueLETD;
  final bool checkBoxValuePickUp;
  final bool checkBoxValueDelivery;
  final bool checkBoxValueWHEntry;
  final bool checkBoxValueWHExit;
  final bool checkBoxValueFW1;
  final bool checkBoxValueFW2;
  final bool checkBoxValueFW3;

  // ── Visibility flags ─────────────────────────────────
  final bool visibleOffVessel;
  final bool visibleLoadingVessel;
  final bool visibleLETA;
  final bool visibleFlightTime;
  final bool visibleLETB;
  final bool visibleLETD;
  final bool visibleAWBNo;
  final bool visibleBLCopy;
  final bool visibleFORWARDING;
  final bool visibleOrigin;
  final bool visibleDestination;
  final bool visibleZB;
  final bool visibleOETA;
  final bool visibleOETB;
  final bool visibleOETD;
  final bool visibleOShippingAgent;
  final bool visibleOAgentName;
  final bool visibleOScn;
  final bool visibleLScn;
  final bool visibleLShippingAgent;
  final bool visibleLAgentName;
  final bool visibleLVesselType;
  final bool visibleOVesselType;
  final bool visibleOPort;
  final bool visibleLPort;
  final bool visibleProductview;
  final bool visibleFW1;
  final bool visibleFW2;
  final bool visibleFW3;
  final bool visibleGC;

  // ── Disabled flags ───────────────────────────────────
  final bool disabledBillType;
  final bool disabledAmount1;
  final bool disabledAmount2;

  // ── Dropdown values ──────────────────────────────────
  final String dropdownValue;
  final String? dropdownValueTruckSize;
  final String? dropdownValueFW1;
  final String? dropdownValueFW2;
  final String? dropdownValueFW3;
  final String? dropdownValueZB1;
  final String? dropdownValueZB2;

  // ── Address lists ────────────────────────────────────
  final List<dynamic> pickUpAddressList;
  final List<dynamic> pickUpQuantityList;
  final List<dynamic> deliveryAddressList;
  final List<dynamic> deliveryQuantityList;

  // ── Text field values (read-only display) ────────────
  final String txtJobNo;
  final String txtCustomer;
  final String txtJobType;
  final String txtJobStatus;
  final String txtRemarks;
  final String txtDoDescription;
  final String txtWeight;
  final String txtQuantity;
  final String txtTruckSize;
  final String txtAWBNo;
  final String txtBLCopy;
  final String txtPTWNo;
  final String txtCommodityType;
  final String txtCargo;
  final String txtLAgentCompany;
  final String txtLAgentName;
  final String txtLSCN;
  final String txtLoadingVessel;
  final String txtLPort;
  final String txtLVesselType;
  final String txtOAgentCompany;
  final String txtOAgentName;
  final String txtOSCN;
  final String txtOffVessel;
  final String txtOPort;
  final String txtOVesselType;
  final String txtPickUpAddress;
  final String txtPickUpQuantity;
  final String txtDeliveryAddress;
  final String txtDeliveryQuantity;
  final String txtWarehouseAddress;
  final String txtOrigin;
  final String txtDestination;
  final String txtSmk1;
  final String txtSmk2;
  final String txtSmk3;
  final String txtENRef1;
  final String txtENRef2;
  final String txtENRef3;
  final String txtExRef1;
  final String txtExRef2;
  final String txtExRef3;
  final String txtSealByEmp1;
  final String txtSealByEmp2;
  final String txtSealByEmp3;
  final String txtBreakByEmp1;
  final String txtBreakByEmp2;
  final String txtBreakByEmp3;
  final String txtZBRef1;
  final String txtZBRef2;
  final String txtBoardingOfficer1;
  final String txtBoardingOfficer2;
  final String txtAmount1;
  final String txtAmount2;
  final String txtPortChargeRef1;
  final String txtPortCharges;
  final String txtForwarding1S1;
  final String txtForwarding1S2;
  final String txtForwarding2S1;
  final String txtForwarding2S2;
  final String txtForwarding3S1;
  final String txtForwarding3S2;

  // ── Product dialog fields ────────────────────────────
  final String txtProductCode;
  final String txtProductDescription;
  final String txtProductQty;
  final String txtProductSaleRate;
  final String txtProductGst;
  final String txtProductAmount;

  // ── Permission ───────────────────────────────────────
  final Map<String, bool> fieldPermission;

  // ── Saved message ────────────────────────────────────
  final String? savedMessage;
  final bool isSaved;

  SalesOrderAddLoaded({
    this.progress = false,
    this.showSearch = false,
    this.productViewList = const [],
    this.productUpdateIndex,
    this.totalAmount = 0.0,
    this.taxAmount = 0.0,
    this.currencyValue = 0.0,
    this.actualAmount = 0.0,
    this.coinage = 0.0,
    this.custId = 0,
    this.statusId = 0,
    this.jobTypeId = 0,
    this.lAgentCompanyId = 0,
    this.lAgentId = 0,
    this.oAgentCompanyId = 0,
    this.oAgentId = 0,
    this.sealEmpId1 = 0,
    this.sealEmpId2 = 0,
    this.sealEmpId3 = 0,
    this.breakEmpId1 = 0,
    this.breakEmpId2 = 0,
    this.breakEmpId3 = 0,
    this.boardOfficerId1 = 0,
    this.boardOfficerId2 = 0,
    this.originId = 0,
    this.destinationId = 0,
    this.editId = 0,
    this.enquiryId = 0,
    required this.dtpSaleOrderdate,
    required this.dtpOETAdate,
    required this.dtpOETBdate,
    required this.dtpOETDdate,
    required this.dtpLETAdate,
    required this.dtpLETBdate,
    required this.dtpLETDdate,
    required this.dtpFlightTimedate,
    required this.dtpPickUpdate,
    required this.dtpDeliverydate,
    required this.dtpWHEntrydate,
    required this.dtpWHExitdate,
    required this.dtpFW1date,
    required this.dtpFW2date,
    required this.dtpFW3date,
    this.checkBoxValueOETA = false,
    this.checkBoxValueOETB = false,
    this.checkBoxValueOETD = false,
    this.checkBoxValueLETA = false,
    this.checkBoxValueFlightTime = false,
    this.checkBoxValueLETB = false,
    this.checkBoxValueLETD = false,
    this.checkBoxValuePickUp = false,
    this.checkBoxValueDelivery = false,
    this.checkBoxValueWHEntry = false,
    this.checkBoxValueWHExit = false,
    this.checkBoxValueFW1 = false,
    this.checkBoxValueFW2 = false,
    this.checkBoxValueFW3 = false,
    this.visibleOffVessel = true,
    this.visibleLoadingVessel = true,
    this.visibleLETA = true,
    this.visibleFlightTime = true,
    this.visibleLETB = true,
    this.visibleLETD = true,
    this.visibleAWBNo = true,
    this.visibleBLCopy = true,
    this.visibleFORWARDING = true,
    this.visibleOrigin = true,
    this.visibleDestination = true,
    this.visibleZB = true,
    this.visibleOETA = true,
    this.visibleOETB = true,
    this.visibleOETD = true,
    this.visibleOShippingAgent = true,
    this.visibleOAgentName = true,
    this.visibleOScn = true,
    this.visibleLScn = true,
    this.visibleLShippingAgent = true,
    this.visibleLAgentName = true,
    this.visibleLVesselType = true,
    this.visibleOVesselType = true,
    this.visibleOPort = true,
    this.visibleLPort = true,
    this.visibleProductview = false,
    this.visibleFW1 = false,
    this.visibleFW2 = false,
    this.visibleFW3 = false,
    this.visibleGC = false,
    this.disabledBillType = false,
    this.disabledAmount1 = false,
    this.disabledAmount2 = false,
    this.dropdownValue = 'MY',
    this.dropdownValueTruckSize,
    this.dropdownValueFW1,
    this.dropdownValueFW2,
    this.dropdownValueFW3,
    this.dropdownValueZB1,
    this.dropdownValueZB2,
    this.pickUpAddressList = const [],
    this.pickUpQuantityList = const [],
    this.deliveryAddressList = const [],
    this.deliveryQuantityList = const [],
    this.txtJobNo = '',
    this.txtCustomer = '',
    this.txtJobType = '',
    this.txtJobStatus = '',
    this.txtRemarks = '',
    this.txtDoDescription = '',
    this.txtWeight = '',
    this.txtQuantity = '',
    this.txtTruckSize = '',
    this.txtAWBNo = '',
    this.txtBLCopy = '',
    this.txtPTWNo = '',
    this.txtCommodityType = '',
    this.txtCargo = '',
    this.txtLAgentCompany = '',
    this.txtLAgentName = '',
    this.txtLSCN = '',
    this.txtLoadingVessel = '',
    this.txtLPort = '',
    this.txtLVesselType = '',
    this.txtOAgentCompany = '',
    this.txtOAgentName = '',
    this.txtOSCN = '',
    this.txtOffVessel = '',
    this.txtOPort = '',
    this.txtOVesselType = '',
    this.txtPickUpAddress = '',
    this.txtPickUpQuantity = '',
    this.txtDeliveryAddress = '',
    this.txtDeliveryQuantity = '',
    this.txtWarehouseAddress = '',
    this.txtOrigin = '',
    this.txtDestination = '',
    this.txtSmk1 = '',
    this.txtSmk2 = '',
    this.txtSmk3 = '',
    this.txtENRef1 = '',
    this.txtENRef2 = '',
    this.txtENRef3 = '',
    this.txtExRef1 = '',
    this.txtExRef2 = '',
    this.txtExRef3 = '',
    this.txtSealByEmp1 = '',
    this.txtSealByEmp2 = '',
    this.txtSealByEmp3 = '',
    this.txtBreakByEmp1 = '',
    this.txtBreakByEmp2 = '',
    this.txtBreakByEmp3 = '',
    this.txtZBRef1 = '',
    this.txtZBRef2 = '',
    this.txtBoardingOfficer1 = '',
    this.txtBoardingOfficer2 = '',
    this.txtAmount1 = '',
    this.txtAmount2 = '',
    this.txtPortChargeRef1 = '',
    this.txtPortCharges = '',
    this.txtForwarding1S1 = '',
    this.txtForwarding1S2 = '',
    this.txtForwarding2S1 = '',
    this.txtForwarding2S2 = '',
    this.txtForwarding3S1 = '',
    this.txtForwarding3S2 = '',
    this.txtProductCode = '',
    this.txtProductDescription = '',
    this.txtProductQty = '',
    this.txtProductSaleRate = '',
    this.txtProductGst = '',
    this.txtProductAmount = '',
    this.fieldPermission = const {},
    this.savedMessage,
    this.isSaved = false,
  });

  @override
  List<Object?> get props => [
    progress,
    showSearch,
    productViewList.length,
    productUpdateIndex,
    totalAmount,
    taxAmount,
    currencyValue,
    actualAmount,
    coinage,
    custId,
    statusId,
    jobTypeId,
    editId,
    enquiryId,
    dtpSaleOrderdate,
    dtpLETAdate,
    dtpLETBdate,
    dtpLETDdate,
    dtpOETAdate,
    dtpOETBdate,
    dtpOETDdate,
    dtpFlightTimedate,
    dtpPickUpdate,
    dtpDeliverydate,
    dtpWHEntrydate,
    dtpWHExitdate,
    dtpFW1date,
    dtpFW2date,
    dtpFW3date,
    checkBoxValueOETA,
    checkBoxValueOETB,
    checkBoxValueOETD,
    checkBoxValueLETA,
    checkBoxValueFlightTime,
    checkBoxValueLETB,
    checkBoxValueLETD,
    checkBoxValuePickUp,
    checkBoxValueDelivery,
    checkBoxValueWHEntry,
    checkBoxValueWHExit,
    checkBoxValueFW1,
    checkBoxValueFW2,
    checkBoxValueFW3,
    visibleOffVessel,
    visibleLoadingVessel,
    visibleGC,
    visibleFORWARDING,
    visibleProductview,
    visibleFW1,
    visibleFW2,
    visibleFW3,
    disabledBillType,
    dropdownValue,
    dropdownValueTruckSize,
    dropdownValueFW1,
    dropdownValueFW2,
    dropdownValueFW3,
    dropdownValueZB1,
    dropdownValueZB2,
    pickUpAddressList.length,
    deliveryAddressList.length,
    txtJobNo,
    txtCustomer,
    txtJobType,
    txtJobStatus,
    txtOrigin,
    txtDestination,
    txtProductDescription,
    txtProductQty,
    txtProductSaleRate,
    txtProductGst,
    txtProductAmount,
    savedMessage,
    isSaved,
  ];

  SalesOrderAddLoaded copyWith({
    bool? progress,
    bool? showSearch,
    List<SaleEditDetailModel>? productViewList,
    Object? productUpdateIndex = _sentinel,
    double? totalAmount,
    double? taxAmount,
    double? currencyValue,
    double? actualAmount,
    double? coinage,
    int? custId,
    int? statusId,
    int? jobTypeId,
    int? lAgentCompanyId,
    int? lAgentId,
    int? oAgentCompanyId,
    int? oAgentId,
    int? sealEmpId1,
    int? sealEmpId2,
    int? sealEmpId3,
    int? breakEmpId1,
    int? breakEmpId2,
    int? breakEmpId3,
    int? boardOfficerId1,
    int? boardOfficerId2,
    int? originId,
    int? destinationId,
    int? editId,
    int? enquiryId,
    String? dtpSaleOrderdate,
    String? dtpOETAdate,
    String? dtpOETBdate,
    String? dtpOETDdate,
    String? dtpLETAdate,
    String? dtpLETBdate,
    String? dtpLETDdate,
    String? dtpFlightTimedate,
    String? dtpPickUpdate,
    String? dtpDeliverydate,
    String? dtpWHEntrydate,
    String? dtpWHExitdate,
    String? dtpFW1date,
    String? dtpFW2date,
    String? dtpFW3date,
    bool? checkBoxValueOETA,
    bool? checkBoxValueOETB,
    bool? checkBoxValueOETD,
    bool? checkBoxValueLETA,
    bool? checkBoxValueFlightTime,
    bool? checkBoxValueLETB,
    bool? checkBoxValueLETD,
    bool? checkBoxValuePickUp,
    bool? checkBoxValueDelivery,
    bool? checkBoxValueWHEntry,
    bool? checkBoxValueWHExit,
    bool? checkBoxValueFW1,
    bool? checkBoxValueFW2,
    bool? checkBoxValueFW3,
    bool? visibleOffVessel,
    bool? visibleLoadingVessel,
    bool? visibleLETA,
    bool? visibleFlightTime,
    bool? visibleLETB,
    bool? visibleLETD,
    bool? visibleAWBNo,
    bool? visibleBLCopy,
    bool? visibleFORWARDING,
    bool? visibleOrigin,
    bool? visibleDestination,
    bool? visibleZB,
    bool? visibleOETA,
    bool? visibleOETB,
    bool? visibleOETD,
    bool? visibleOShippingAgent,
    bool? visibleOAgentName,
    bool? visibleOScn,
    bool? visibleLScn,
    bool? visibleLShippingAgent,
    bool? visibleLAgentName,
    bool? visibleLVesselType,
    bool? visibleOVesselType,
    bool? visibleOPort,
    bool? visibleLPort,
    bool? visibleProductview,
    bool? visibleFW1,
    bool? visibleFW2,
    bool? visibleFW3,
    bool? visibleGC,
    bool? disabledBillType,
    bool? disabledAmount1,
    bool? disabledAmount2,
    String? dropdownValue,
    Object? dropdownValueTruckSize = _sentinel,
    Object? dropdownValueFW1 = _sentinel,
    Object? dropdownValueFW2 = _sentinel,
    Object? dropdownValueFW3 = _sentinel,
    Object? dropdownValueZB1 = _sentinel,
    Object? dropdownValueZB2 = _sentinel,
    List<dynamic>? pickUpAddressList,
    List<dynamic>? pickUpQuantityList,
    List<dynamic>? deliveryAddressList,
    List<dynamic>? deliveryQuantityList,
    String? txtJobNo,
    String? txtCustomer,
    String? txtJobType,
    String? txtJobStatus,
    String? txtRemarks,
    String? txtDoDescription,
    String? txtWeight,
    String? txtQuantity,
    String? txtTruckSize,
    String? txtAWBNo,
    String? txtBLCopy,
    String? txtPTWNo,
    String? txtCommodityType,
    String? txtCargo,
    String? txtLAgentCompany,
    String? txtLAgentName,
    String? txtLSCN,
    String? txtLoadingVessel,
    String? txtLPort,
    String? txtLVesselType,
    String? txtOAgentCompany,
    String? txtOAgentName,
    String? txtOSCN,
    String? txtOffVessel,
    String? txtOPort,
    String? txtOVesselType,
    String? txtPickUpAddress,
    String? txtPickUpQuantity,
    String? txtDeliveryAddress,
    String? txtDeliveryQuantity,
    String? txtWarehouseAddress,
    String? txtOrigin,
    String? txtDestination,
    String? txtSmk1,
    String? txtSmk2,
    String? txtSmk3,
    String? txtENRef1,
    String? txtENRef2,
    String? txtENRef3,
    String? txtExRef1,
    String? txtExRef2,
    String? txtExRef3,
    String? txtSealByEmp1,
    String? txtSealByEmp2,
    String? txtSealByEmp3,
    String? txtBreakByEmp1,
    String? txtBreakByEmp2,
    String? txtBreakByEmp3,
    String? txtZBRef1,
    String? txtZBRef2,
    String? txtBoardingOfficer1,
    String? txtBoardingOfficer2,
    String? txtAmount1,
    String? txtAmount2,
    String? txtPortChargeRef1,
    String? txtPortCharges,
    String? txtForwarding1S1,
    String? txtForwarding1S2,
    String? txtForwarding2S1,
    String? txtForwarding2S2,
    String? txtForwarding3S1,
    String? txtForwarding3S2,
    String? txtProductCode,
    String? txtProductDescription,
    String? txtProductQty,
    String? txtProductSaleRate,
    String? txtProductGst,
    String? txtProductAmount,
    Map<String, bool>? fieldPermission,
    Object? savedMessage = _sentinel,
    bool? isSaved,
  }) {
    return SalesOrderAddLoaded(
      progress: progress ?? this.progress,
      showSearch: showSearch ?? this.showSearch,
      productViewList: productViewList ?? this.productViewList,
      productUpdateIndex: identical(productUpdateIndex, _sentinel)
          ? this.productUpdateIndex
          : productUpdateIndex as int?,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      currencyValue: currencyValue ?? this.currencyValue,
      actualAmount: actualAmount ?? this.actualAmount,
      coinage: coinage ?? this.coinage,
      custId: custId ?? this.custId,
      statusId: statusId ?? this.statusId,
      jobTypeId: jobTypeId ?? this.jobTypeId,
      lAgentCompanyId: lAgentCompanyId ?? this.lAgentCompanyId,
      lAgentId: lAgentId ?? this.lAgentId,
      oAgentCompanyId: oAgentCompanyId ?? this.oAgentCompanyId,
      oAgentId: oAgentId ?? this.oAgentId,
      sealEmpId1: sealEmpId1 ?? this.sealEmpId1,
      sealEmpId2: sealEmpId2 ?? this.sealEmpId2,
      sealEmpId3: sealEmpId3 ?? this.sealEmpId3,
      breakEmpId1: breakEmpId1 ?? this.breakEmpId1,
      breakEmpId2: breakEmpId2 ?? this.breakEmpId2,
      breakEmpId3: breakEmpId3 ?? this.breakEmpId3,
      boardOfficerId1: boardOfficerId1 ?? this.boardOfficerId1,
      boardOfficerId2: boardOfficerId2 ?? this.boardOfficerId2,
      originId: originId ?? this.originId,
      destinationId: destinationId ?? this.destinationId,
      editId: editId ?? this.editId,
      enquiryId: enquiryId ?? this.enquiryId,
      dtpSaleOrderdate: dtpSaleOrderdate ?? this.dtpSaleOrderdate,
      dtpOETAdate: dtpOETAdate ?? this.dtpOETAdate,
      dtpOETBdate: dtpOETBdate ?? this.dtpOETBdate,
      dtpOETDdate: dtpOETDdate ?? this.dtpOETDdate,
      dtpLETAdate: dtpLETAdate ?? this.dtpLETAdate,
      dtpLETBdate: dtpLETBdate ?? this.dtpLETBdate,
      dtpLETDdate: dtpLETDdate ?? this.dtpLETDdate,
      dtpFlightTimedate: dtpFlightTimedate ?? this.dtpFlightTimedate,
      dtpPickUpdate: dtpPickUpdate ?? this.dtpPickUpdate,
      dtpDeliverydate: dtpDeliverydate ?? this.dtpDeliverydate,
      dtpWHEntrydate: dtpWHEntrydate ?? this.dtpWHEntrydate,
      dtpWHExitdate: dtpWHExitdate ?? this.dtpWHExitdate,
      dtpFW1date: dtpFW1date ?? this.dtpFW1date,
      dtpFW2date: dtpFW2date ?? this.dtpFW2date,
      dtpFW3date: dtpFW3date ?? this.dtpFW3date,
      checkBoxValueOETA: checkBoxValueOETA ?? this.checkBoxValueOETA,
      checkBoxValueOETB: checkBoxValueOETB ?? this.checkBoxValueOETB,
      checkBoxValueOETD: checkBoxValueOETD ?? this.checkBoxValueOETD,
      checkBoxValueLETA: checkBoxValueLETA ?? this.checkBoxValueLETA,
      checkBoxValueFlightTime: checkBoxValueFlightTime ?? this.checkBoxValueFlightTime,
      checkBoxValueLETB: checkBoxValueLETB ?? this.checkBoxValueLETB,
      checkBoxValueLETD: checkBoxValueLETD ?? this.checkBoxValueLETD,
      checkBoxValuePickUp: checkBoxValuePickUp ?? this.checkBoxValuePickUp,
      checkBoxValueDelivery: checkBoxValueDelivery ?? this.checkBoxValueDelivery,
      checkBoxValueWHEntry: checkBoxValueWHEntry ?? this.checkBoxValueWHEntry,
      checkBoxValueWHExit: checkBoxValueWHExit ?? this.checkBoxValueWHExit,
      checkBoxValueFW1: checkBoxValueFW1 ?? this.checkBoxValueFW1,
      checkBoxValueFW2: checkBoxValueFW2 ?? this.checkBoxValueFW2,
      checkBoxValueFW3: checkBoxValueFW3 ?? this.checkBoxValueFW3,
      visibleOffVessel: visibleOffVessel ?? this.visibleOffVessel,
      visibleLoadingVessel: visibleLoadingVessel ?? this.visibleLoadingVessel,
      visibleLETA: visibleLETA ?? this.visibleLETA,
      visibleFlightTime: visibleFlightTime ?? this.visibleFlightTime,
      visibleLETB: visibleLETB ?? this.visibleLETB,
      visibleLETD: visibleLETD ?? this.visibleLETD,
      visibleAWBNo: visibleAWBNo ?? this.visibleAWBNo,
      visibleBLCopy: visibleBLCopy ?? this.visibleBLCopy,
      visibleFORWARDING: visibleFORWARDING ?? this.visibleFORWARDING,
      visibleOrigin: visibleOrigin ?? this.visibleOrigin,
      visibleDestination: visibleDestination ?? this.visibleDestination,
      visibleZB: visibleZB ?? this.visibleZB,
      visibleOETA: visibleOETA ?? this.visibleOETA,
      visibleOETB: visibleOETB ?? this.visibleOETB,
      visibleOETD: visibleOETD ?? this.visibleOETD,
      visibleOShippingAgent: visibleOShippingAgent ?? this.visibleOShippingAgent,
      visibleOAgentName: visibleOAgentName ?? this.visibleOAgentName,
      visibleOScn: visibleOScn ?? this.visibleOScn,
      visibleLScn: visibleLScn ?? this.visibleLScn,
      visibleLShippingAgent: visibleLShippingAgent ?? this.visibleLShippingAgent,
      visibleLAgentName: visibleLAgentName ?? this.visibleLAgentName,
      visibleLVesselType: visibleLVesselType ?? this.visibleLVesselType,
      visibleOVesselType: visibleOVesselType ?? this.visibleOVesselType,
      visibleOPort: visibleOPort ?? this.visibleOPort,
      visibleLPort: visibleLPort ?? this.visibleLPort,
      visibleProductview: visibleProductview ?? this.visibleProductview,
      visibleFW1: visibleFW1 ?? this.visibleFW1,
      visibleFW2: visibleFW2 ?? this.visibleFW2,
      visibleFW3: visibleFW3 ?? this.visibleFW3,
      visibleGC: visibleGC ?? this.visibleGC,
      disabledBillType: disabledBillType ?? this.disabledBillType,
      disabledAmount1: disabledAmount1 ?? this.disabledAmount1,
      disabledAmount2: disabledAmount2 ?? this.disabledAmount2,
      dropdownValue: dropdownValue ?? this.dropdownValue,
      dropdownValueTruckSize: identical(dropdownValueTruckSize, _sentinel)
          ? this.dropdownValueTruckSize : dropdownValueTruckSize as String?,
      dropdownValueFW1: identical(dropdownValueFW1, _sentinel)
          ? this.dropdownValueFW1 : dropdownValueFW1 as String?,
      dropdownValueFW2: identical(dropdownValueFW2, _sentinel)
          ? this.dropdownValueFW2 : dropdownValueFW2 as String?,
      dropdownValueFW3: identical(dropdownValueFW3, _sentinel)
          ? this.dropdownValueFW3 : dropdownValueFW3 as String?,
      dropdownValueZB1: identical(dropdownValueZB1, _sentinel)
          ? this.dropdownValueZB1 : dropdownValueZB1 as String?,
      dropdownValueZB2: identical(dropdownValueZB2, _sentinel)
          ? this.dropdownValueZB2 : dropdownValueZB2 as String?,
      pickUpAddressList: pickUpAddressList ?? this.pickUpAddressList,
      pickUpQuantityList: pickUpQuantityList ?? this.pickUpQuantityList,
      deliveryAddressList: deliveryAddressList ?? this.deliveryAddressList,
      deliveryQuantityList: deliveryQuantityList ?? this.deliveryQuantityList,
      txtJobNo: txtJobNo ?? this.txtJobNo,
      txtCustomer: txtCustomer ?? this.txtCustomer,
      txtJobType: txtJobType ?? this.txtJobType,
      txtJobStatus: txtJobStatus ?? this.txtJobStatus,
      txtRemarks: txtRemarks ?? this.txtRemarks,
      txtDoDescription: txtDoDescription ?? this.txtDoDescription,
      txtWeight: txtWeight ?? this.txtWeight,
      txtQuantity: txtQuantity ?? this.txtQuantity,
      txtTruckSize: txtTruckSize ?? this.txtTruckSize,
      txtAWBNo: txtAWBNo ?? this.txtAWBNo,
      txtBLCopy: txtBLCopy ?? this.txtBLCopy,
      txtPTWNo: txtPTWNo ?? this.txtPTWNo,
      txtCommodityType: txtCommodityType ?? this.txtCommodityType,
      txtCargo: txtCargo ?? this.txtCargo,
      txtLAgentCompany: txtLAgentCompany ?? this.txtLAgentCompany,
      txtLAgentName: txtLAgentName ?? this.txtLAgentName,
      txtLSCN: txtLSCN ?? this.txtLSCN,
      txtLoadingVessel: txtLoadingVessel ?? this.txtLoadingVessel,
      txtLPort: txtLPort ?? this.txtLPort,
      txtLVesselType: txtLVesselType ?? this.txtLVesselType,
      txtOAgentCompany: txtOAgentCompany ?? this.txtOAgentCompany,
      txtOAgentName: txtOAgentName ?? this.txtOAgentName,
      txtOSCN: txtOSCN ?? this.txtOSCN,
      txtOffVessel: txtOffVessel ?? this.txtOffVessel,
      txtOPort: txtOPort ?? this.txtOPort,
      txtOVesselType: txtOVesselType ?? this.txtOVesselType,
      txtPickUpAddress: txtPickUpAddress ?? this.txtPickUpAddress,
      txtPickUpQuantity: txtPickUpQuantity ?? this.txtPickUpQuantity,
      txtDeliveryAddress: txtDeliveryAddress ?? this.txtDeliveryAddress,
      txtDeliveryQuantity: txtDeliveryQuantity ?? this.txtDeliveryQuantity,
      txtWarehouseAddress: txtWarehouseAddress ?? this.txtWarehouseAddress,
      txtOrigin: txtOrigin ?? this.txtOrigin,
      txtDestination: txtDestination ?? this.txtDestination,
      txtSmk1: txtSmk1 ?? this.txtSmk1,
      txtSmk2: txtSmk2 ?? this.txtSmk2,
      txtSmk3: txtSmk3 ?? this.txtSmk3,
      txtENRef1: txtENRef1 ?? this.txtENRef1,
      txtENRef2: txtENRef2 ?? this.txtENRef2,
      txtENRef3: txtENRef3 ?? this.txtENRef3,
      txtExRef1: txtExRef1 ?? this.txtExRef1,
      txtExRef2: txtExRef2 ?? this.txtExRef2,
      txtExRef3: txtExRef3 ?? this.txtExRef3,
      txtSealByEmp1: txtSealByEmp1 ?? this.txtSealByEmp1,
      txtSealByEmp2: txtSealByEmp2 ?? this.txtSealByEmp2,
      txtSealByEmp3: txtSealByEmp3 ?? this.txtSealByEmp3,
      txtBreakByEmp1: txtBreakByEmp1 ?? this.txtBreakByEmp1,
      txtBreakByEmp2: txtBreakByEmp2 ?? this.txtBreakByEmp2,
      txtBreakByEmp3: txtBreakByEmp3 ?? this.txtBreakByEmp3,
      txtZBRef1: txtZBRef1 ?? this.txtZBRef1,
      txtZBRef2: txtZBRef2 ?? this.txtZBRef2,
      txtBoardingOfficer1: txtBoardingOfficer1 ?? this.txtBoardingOfficer1,
      txtBoardingOfficer2: txtBoardingOfficer2 ?? this.txtBoardingOfficer2,
      txtAmount1: txtAmount1 ?? this.txtAmount1,
      txtAmount2: txtAmount2 ?? this.txtAmount2,
      txtPortChargeRef1: txtPortChargeRef1 ?? this.txtPortChargeRef1,
      txtPortCharges: txtPortCharges ?? this.txtPortCharges,
      txtForwarding1S1: txtForwarding1S1 ?? this.txtForwarding1S1,
      txtForwarding1S2: txtForwarding1S2 ?? this.txtForwarding1S2,
      txtForwarding2S1: txtForwarding2S1 ?? this.txtForwarding2S1,
      txtForwarding2S2: txtForwarding2S2 ?? this.txtForwarding2S2,
      txtForwarding3S1: txtForwarding3S1 ?? this.txtForwarding3S1,
      txtForwarding3S2: txtForwarding3S2 ?? this.txtForwarding3S2,
      txtProductCode: txtProductCode ?? this.txtProductCode,
      txtProductDescription: txtProductDescription ?? this.txtProductDescription,
      txtProductQty: txtProductQty ?? this.txtProductQty,
      txtProductSaleRate: txtProductSaleRate ?? this.txtProductSaleRate,
      txtProductGst: txtProductGst ?? this.txtProductGst,
      txtProductAmount: txtProductAmount ?? this.txtProductAmount,
      fieldPermission: fieldPermission ?? this.fieldPermission,
      savedMessage: identical(savedMessage, _sentinel)
          ? this.savedMessage : savedMessage as String?,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

// Sentinel for nullable copyWith
const Object _sentinel = Object();

class SalesOrderAddError extends SalesOrderAddState {
  final String message;
  SalesOrderAddError(this.message);

  @override
  List<Object?> get props => [message];
}