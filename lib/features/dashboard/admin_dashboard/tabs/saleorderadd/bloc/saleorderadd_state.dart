
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/models/model.dart';

enum SalesOrderStatus { initial, loading, success, failure }

// ─── Visibility flags packed into a dedicated class to keep state slim ────────

class SalesOrderVisibility extends Equatable {
  final bool offVessel;
  final bool loadingVessel;
  final bool lETA;
  final bool flightTime;
  final bool lETB;
  final bool lETD;
  final bool awbNo;
  final bool blCopy;
  final bool forklift;
  final bool sealBy;
  final bool breakSealBy;
  final bool forwarding;
  final bool origin;
  final bool destination;
  final bool zb;
  final bool oETA;
  final bool oETB;
  final bool oETD;
  final bool oShippingAgent;
  final bool oAgentName;
  final bool oScn;
  final bool lScn;
  final bool lShippingAgent;
  final bool lAgentName;
  final bool lVesselType;
  final bool oVesselType;
  final bool oPort;
  final bool lPort;
  final bool productView;
  final bool fw1;
  final bool fw2;
  final bool fw3;
  final bool gc; // General Cargo

  const SalesOrderVisibility({
    this.offVessel = true,
    this.loadingVessel = true,
    this.lETA = true,
    this.flightTime = true,
    this.lETB = true,
    this.lETD = true,
    this.awbNo = true,
    this.blCopy = true,
    this.forklift = true,
    this.sealBy = true,
    this.breakSealBy = true,
    this.forwarding = true,
    this.origin = true,
    this.destination = true,
    this.zb = true,
    this.oETA = true,
    this.oETB = true,
    this.oETD = true,
    this.oShippingAgent = true,
    this.oAgentName = true,
    this.oScn = true,
    this.lScn = true,
    this.lShippingAgent = true,
    this.lAgentName = true,
    this.lVesselType = true,
    this.oVesselType = true,
    this.oPort = true,
    this.lPort = true,
    this.productView = false,
    this.fw1 = false,
    this.fw2 = false,
    this.fw3 = false,
    this.gc = false,
  });

  SalesOrderVisibility copyWith({
    bool? offVessel,
    bool? loadingVessel,
    bool? lETA,
    bool? flightTime,
    bool? lETB,
    bool? lETD,
    bool? awbNo,
    bool? blCopy,
    bool? forklift,
    bool? sealBy,
    bool? breakSealBy,
    bool? forwarding,
    bool? origin,
    bool? destination,
    bool? zb,
    bool? oETA,
    bool? oETB,
    bool? oETD,
    bool? oShippingAgent,
    bool? oAgentName,
    bool? oScn,
    bool? lScn,
    bool? lShippingAgent,
    bool? lAgentName,
    bool? lVesselType,
    bool? oVesselType,
    bool? oPort,
    bool? lPort,
    bool? productView,
    bool? fw1,
    bool? fw2,
    bool? fw3,
    bool? gc,
  }) {
    return SalesOrderVisibility(
      offVessel: offVessel ?? this.offVessel,
      loadingVessel: loadingVessel ?? this.loadingVessel,
      lETA: lETA ?? this.lETA,
      flightTime: flightTime ?? this.flightTime,
      lETB: lETB ?? this.lETB,
      lETD: lETD ?? this.lETD,
      awbNo: awbNo ?? this.awbNo,
      blCopy: blCopy ?? this.blCopy,
      forklift: forklift ?? this.forklift,
      sealBy: sealBy ?? this.sealBy,
      breakSealBy: breakSealBy ?? this.breakSealBy,
      forwarding: forwarding ?? this.forwarding,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      zb: zb ?? this.zb,
      oETA: oETA ?? this.oETA,
      oETB: oETB ?? this.oETB,
      oETD: oETD ?? this.oETD,
      oShippingAgent: oShippingAgent ?? this.oShippingAgent,
      oAgentName: oAgentName ?? this.oAgentName,
      oScn: oScn ?? this.oScn,
      lScn: lScn ?? this.lScn,
      lShippingAgent: lShippingAgent ?? this.lShippingAgent,
      lAgentName: lAgentName ?? this.lAgentName,
      lVesselType: lVesselType ?? this.lVesselType,
      oVesselType: oVesselType ?? this.oVesselType,
      oPort: oPort ?? this.oPort,
      lPort: lPort ?? this.lPort,
      productView: productView ?? this.productView,
      fw1: fw1 ?? this.fw1,
      fw2: fw2 ?? this.fw2,
      fw3: fw3 ?? this.fw3,
      gc: gc ?? this.gc,
    );
  }

  @override
  List<Object?> get props => [
    offVessel, loadingVessel, lETA, flightTime, lETB, lETD,
    awbNo, blCopy, forklift, sealBy, breakSealBy, forwarding,
    origin, destination, zb, oETA, oETB, oETD, oShippingAgent,
    oAgentName, oScn, lScn, lShippingAgent, lAgentName,
    lVesselType, oVesselType, oPort, lPort,
    productView, fw1, fw2, fw3, gc,
  ];
}

// ─── Product calculation result (inline, not stored in product list) ──────────

class ProductCalcResult extends Equatable {
  final double gstAmount;
  final double amount;
  final double actualAmount;

  const ProductCalcResult({
    this.gstAmount = 0,
    this.amount = 0,
    this.actualAmount = 0,
  });

  @override
  List<Object?> get props => [gstAmount, amount, actualAmount];
}

// ─── Main state ───────────────────────────────────────────────────────────────

class SalesOrderState extends Equatable {
  final SalesOrderStatus status;
  final String? errorMessage;
  final String? successMessage;

  // ─── Tab ────────────────────────────────────────────────────────────────
  final int currentTabIndex;

  // ─── Master IDs ──────────────────────────────────────────────────────────
  final int editId;
  final int enquiryId;
  final int custId;
  final int statusId;
  final int jobTypeId;
  final int lAgentCompanyId;
  final int lAgentId;
  final int oAgentCompanyId;
  final int oAgentId;
  final int lVesselTypeId;
  final int lPortId;
  final int oVesselTypeId;
  final int oPortId;
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

  // ─── Display names (mirror of text controllers; UI reads from state) ──────
  final String jobNo;
  final String custName;
  final String jobTypeName;
  final String jobStatusName;
  final String oAgentCompanyName;
  final String oAgentName;
  final String lAgentCompanyName;
  final String lAgentName;
  final String sealEmpName1;
  final String sealEmpName2;
  final String sealEmpName3;
  final String breakEmpName1;
  final String breakEmpName2;
  final String breakEmpName3;
  final String boardingOfficerName1;
  final String boardingOfficerName2;
  final String originName;
  final String destinationName;

  // ─── Simple text fields ───────────────────────────────────────────────────
  final String remarks;
  final String doDescription;
  final String offVessel;
  final String loadingVessel;
  final String lPort;
  final String oPort;
  final String lVesselType;
  final String oVesselType;
  final String commodityType;
  final String cargo;
  final String awbNo;
  final String blCopy;
  final String oScn;
  final String lScn;
  final String weight;
  final String quantity;
  final String truckSize;
  final String ptwNo;
  final String smk1;
  final String smk2;
  final String smk3;
  final String enRef1;
  final String enRef2;
  final String enRef3;
  final String exRef1;
  final String exRef2;
  final String exRef3;
  final String zbRef1;
  final String zbRef2;
  final String amount1;
  final String amount2;
  final String portChargeRef1;
  final String portCharges;
  final String forwarding1S1;
  final String forwarding1S2;
  final String forwarding2S1;
  final String forwarding2S2;
  final String forwarding3S1;
  final String forwarding3S2;
  final String warehouseAddress;
  final String pickupAddress;
  final String pickupQuantity;
  final String deliveryAddress;
  final String deliveryQuantity;

  // ─── Date/time strings ───────────────────────────────────────────────────
  final String dtpSaleOrderDate;
  final String dtpLETAdate;
  final String dtpFlightTimeDate;
  final String dtpLETBdate;
  final String dtpLETDdate;
  final String dtpOETAdate;
  final String dtpOETBdate;
  final String dtpOETDdate;
  final String dtpPickUpDate;
  final String dtpDeliveryDate;
  final String dtpWHEntryDate;
  final String dtpWHExitDate;
  final String dtpFW1date;
  final String dtpFW2date;
  final String dtpFW3date;

  // ─── Checkboxes ───────────────────────────────────────────────────────────
  final bool chkLETA;
  final bool chkFlightTime;
  final bool chkLETB;
  final bool chkLETD;
  final bool chkOETA;
  final bool chkOETB;
  final bool chkOETD;
  final bool chkPickUp;
  final bool chkDelivery;
  final bool chkWHEntry;
  final bool chkWHExit;
  final bool chkFW1;
  final bool chkFW2;
  final bool chkFW3;

  // ─── Dropdowns ───────────────────────────────────────────────────────────
  final String billType;
  final String? truckSizeDropdown;
  final String? fw1Dropdown;
  final String? fw2Dropdown;
  final String? fw3Dropdown;
  final String? zb1Dropdown;
  final String? zb2Dropdown;

  // ─── Financial ───────────────────────────────────────────────────────────
  final double coinage;
  final double totalAmount;
  final double taxAmount;
  final double currencyValue;
  final double actualAmount;

  // ─── Product calc (current input row) ────────────────────────────────────
  final ProductCalcResult productCalc;

  // ─── Product list ─────────────────────────────────────────────────────────
  final List<SaleEditDetailModel> productList;
  final int? productUpdateIndex;

  // ─── Address lists ────────────────────────────────────────────────────────
  final List<dynamic> pickupAddressList;
  final List<dynamic> pickupQuantityList;
  final List<dynamic> deliveryAddressList;
  final List<dynamic> deliveryQuantityList;

  // ─── Visibility ───────────────────────────────────────────────────────────
  final SalesOrderVisibility visibility;

  // ─── Field permissions ────────────────────────────────────────────────────
  final Map<String, bool> fieldPermission;

  // ─── UI flags ─────────────────────────────────────────────────────────────
  final bool disabledBillType;
  final bool disabledAmount1;
  final bool disabledAmount2;
  final bool showOverlay;
  final List<dynamic> overlaySuggestions;
  final int overlayType;

  const SalesOrderState({
    this.status = SalesOrderStatus.initial,
    this.errorMessage,
    this.successMessage,
    this.currentTabIndex = 0,
    // IDs
    this.editId = 0,
    this.enquiryId = 0,
    this.custId = 0,
    this.statusId = 0,
    this.jobTypeId = 0,
    this.lAgentCompanyId = 0,
    this.lAgentId = 0,
    this.oAgentCompanyId = 0,
    this.oAgentId = 0,
    this.lVesselTypeId = 0,
    this.lPortId = 0,
    this.oVesselTypeId = 0,
    this.oPortId = 0,
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
    // Names
    this.jobNo = '',
    this.custName = '',
    this.jobTypeName = '',
    this.jobStatusName = '',
    this.oAgentCompanyName = '',
    this.oAgentName = '',
    this.lAgentCompanyName = '',
    this.lAgentName = '',
    this.sealEmpName1 = '',
    this.sealEmpName2 = '',
    this.sealEmpName3 = '',
    this.breakEmpName1 = '',
    this.breakEmpName2 = '',
    this.breakEmpName3 = '',
    this.boardingOfficerName1 = '',
    this.boardingOfficerName2 = '',
    this.originName = '',
    this.destinationName = '',
    // Text fields
    this.remarks = '',
    this.doDescription = '',
    this.offVessel = '',
    this.loadingVessel = '',
    this.lPort = '',
    this.oPort = '',
    this.lVesselType = '',
    this.oVesselType = '',
    this.commodityType = '',
    this.cargo = '',
    this.awbNo = '',
    this.blCopy = '',
    this.oScn = '',
    this.lScn = '',
    this.weight = '',
    this.quantity = '',
    this.truckSize = '',
    this.ptwNo = '',
    this.smk1 = '',
    this.smk2 = '',
    this.smk3 = '',
    this.enRef1 = '',
    this.enRef2 = '',
    this.enRef3 = '',
    this.exRef1 = '',
    this.exRef2 = '',
    this.exRef3 = '',
    this.zbRef1 = '',
    this.zbRef2 = '',
    this.amount1 = '',
    this.amount2 = '',
    this.portChargeRef1 = '',
    this.portCharges = '',
    this.forwarding1S1 = '',
    this.forwarding1S2 = '',
    this.forwarding2S1 = '',
    this.forwarding2S2 = '',
    this.forwarding3S1 = '',
    this.forwarding3S2 = '',
    this.warehouseAddress = '',
    this.pickupAddress = '',
    this.pickupQuantity = '',
    this.deliveryAddress = '',
    this.deliveryQuantity = '',
    // Dates
    this.dtpSaleOrderDate = '',
    this.dtpLETAdate = '',
    this.dtpFlightTimeDate = '',
    this.dtpLETBdate = '',
    this.dtpLETDdate = '',
    this.dtpOETAdate = '',
    this.dtpOETBdate = '',
    this.dtpOETDdate = '',
    this.dtpPickUpDate = '',
    this.dtpDeliveryDate = '',
    this.dtpWHEntryDate = '',
    this.dtpWHExitDate = '',
    this.dtpFW1date = '',
    this.dtpFW2date = '',
    this.dtpFW3date = '',
    // Checkboxes
    this.chkLETA = false,
    this.chkFlightTime = false,
    this.chkLETB = false,
    this.chkLETD = false,
    this.chkOETA = false,
    this.chkOETB = false,
    this.chkOETD = false,
    this.chkPickUp = false,
    this.chkDelivery = false,
    this.chkWHEntry = false,
    this.chkWHExit = false,
    this.chkFW1 = false,
    this.chkFW2 = false,
    this.chkFW3 = false,
    // Dropdowns
    this.billType = 'MY',
    this.truckSizeDropdown,
    this.fw1Dropdown,
    this.fw2Dropdown,
    this.fw3Dropdown,
    this.zb1Dropdown,
    this.zb2Dropdown,
    // Financial
    this.coinage = 0,
    this.totalAmount = 0,
    this.taxAmount = 0,
    this.currencyValue = 0,
    this.actualAmount = 0,
    this.productCalc = const ProductCalcResult(),
    // Products
    this.productList = const [],
    this.productUpdateIndex,
    // Address lists
    this.pickupAddressList = const [],
    this.pickupQuantityList = const [],
    this.deliveryAddressList = const [],
    this.deliveryQuantityList = const [],
    // Visibility
    this.visibility = const SalesOrderVisibility(),
    // Permissions
    this.fieldPermission = const {},
    // UI flags
    this.disabledBillType = false,
    this.disabledAmount1 = false,
    this.disabledAmount2 = false,
    this.showOverlay = false,
    this.overlaySuggestions = const [],
    this.overlayType = 1,
  });

  factory SalesOrderState.initial() {
    final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return SalesOrderState(
      dtpSaleOrderDate: today,
      dtpLETAdate: now,
      dtpFlightTimeDate: now,
      dtpLETBdate: now,
      dtpLETDdate: now,
      dtpOETAdate: now,
      dtpOETBdate: now,
      dtpOETDdate: now,
      dtpPickUpDate: now,
      dtpDeliveryDate: now,
      dtpWHEntryDate: now,
      dtpWHExitDate: now,
      dtpFW1date: now,
      dtpFW2date: now,
      dtpFW3date: now,
    );
  }

  bool isAllowed(String field) => fieldPermission[field] ?? false;

  SalesOrderState copyWith({
    SalesOrderStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? successMessage,
    bool clearSuccess = false,
    int? currentTabIndex,
    int? editId,
    int? enquiryId,
    int? custId,
    int? statusId,
    int? jobTypeId,
    int? lAgentCompanyId,
    int? lAgentId,
    int? oAgentCompanyId,
    int? oAgentId,
    int? lVesselTypeId,
    int? lPortId,
    int? oVesselTypeId,
    int? oPortId,
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
    String? jobNo,
    String? custName,
    String? jobTypeName,
    String? jobStatusName,
    String? oAgentCompanyName,
    String? oAgentName,
    String? lAgentCompanyName,
    String? lAgentName,
    String? sealEmpName1,
    String? sealEmpName2,
    String? sealEmpName3,
    String? breakEmpName1,
    String? breakEmpName2,
    String? breakEmpName3,
    String? boardingOfficerName1,
    String? boardingOfficerName2,
    String? originName,
    String? destinationName,
    String? remarks,
    String? doDescription,
    String? offVessel,
    String? loadingVessel,
    String? lPort,
    String? oPort,
    String? lVesselType,
    String? oVesselType,
    String? commodityType,
    String? cargo,
    String? awbNo,
    String? blCopy,
    String? oScn,
    String? lScn,
    String? weight,
    String? quantity,
    String? truckSize,
    String? ptwNo,
    String? smk1,
    String? smk2,
    String? smk3,
    String? enRef1,
    String? enRef2,
    String? enRef3,
    String? exRef1,
    String? exRef2,
    String? exRef3,
    String? zbRef1,
    String? zbRef2,
    String? amount1,
    String? amount2,
    String? portChargeRef1,
    String? portCharges,
    String? forwarding1S1,
    String? forwarding1S2,
    String? forwarding2S1,
    String? forwarding2S2,
    String? forwarding3S1,
    String? forwarding3S2,
    String? warehouseAddress,
    String? pickupAddress,
    String? pickupQuantity,
    String? deliveryAddress,
    String? deliveryQuantity,
    String? dtpSaleOrderDate,
    String? dtpLETAdate,
    String? dtpFlightTimeDate,
    String? dtpLETBdate,
    String? dtpLETDdate,
    String? dtpOETAdate,
    String? dtpOETBdate,
    String? dtpOETDdate,
    String? dtpPickUpDate,
    String? dtpDeliveryDate,
    String? dtpWHEntryDate,
    String? dtpWHExitDate,
    String? dtpFW1date,
    String? dtpFW2date,
    String? dtpFW3date,
    bool? chkLETA,
    bool? chkFlightTime,
    bool? chkLETB,
    bool? chkLETD,
    bool? chkOETA,
    bool? chkOETB,
    bool? chkOETD,
    bool? chkPickUp,
    bool? chkDelivery,
    bool? chkWHEntry,
    bool? chkWHExit,
    bool? chkFW1,
    bool? chkFW2,
    bool? chkFW3,
    String? billType,
    String? truckSizeDropdown,
    bool clearTruckSize = false,
    String? fw1Dropdown,
    bool clearFW1 = false,
    String? fw2Dropdown,
    bool clearFW2 = false,
    String? fw3Dropdown,
    bool clearFW3 = false,
    String? zb1Dropdown,
    bool clearZB1 = false,
    String? zb2Dropdown,
    bool clearZB2 = false,
    double? coinage,
    double? totalAmount,
    double? taxAmount,
    double? currencyValue,
    double? actualAmount,
    ProductCalcResult? productCalc,
    List<SaleEditDetailModel>? productList,
    int? productUpdateIndex,
    bool clearProductUpdateIndex = false,
    List<dynamic>? pickupAddressList,
    List<dynamic>? pickupQuantityList,
    List<dynamic>? deliveryAddressList,
    List<dynamic>? deliveryQuantityList,
    SalesOrderVisibility? visibility,
    Map<String, bool>? fieldPermission,
    bool? disabledBillType,
    bool? disabledAmount1,
    bool? disabledAmount2,
    bool? showOverlay,
    List<dynamic>? overlaySuggestions,
    int? overlayType,
  }) {
    return SalesOrderState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      editId: editId ?? this.editId,
      enquiryId: enquiryId ?? this.enquiryId,
      custId: custId ?? this.custId,
      statusId: statusId ?? this.statusId,
      jobTypeId: jobTypeId ?? this.jobTypeId,
      lAgentCompanyId: lAgentCompanyId ?? this.lAgentCompanyId,
      lAgentId: lAgentId ?? this.lAgentId,
      oAgentCompanyId: oAgentCompanyId ?? this.oAgentCompanyId,
      oAgentId: oAgentId ?? this.oAgentId,
      lVesselTypeId: lVesselTypeId ?? this.lVesselTypeId,
      lPortId: lPortId ?? this.lPortId,
      oVesselTypeId: oVesselTypeId ?? this.oVesselTypeId,
      oPortId: oPortId ?? this.oPortId,
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
      jobNo: jobNo ?? this.jobNo,
      custName: custName ?? this.custName,
      jobTypeName: jobTypeName ?? this.jobTypeName,
      jobStatusName: jobStatusName ?? this.jobStatusName,
      oAgentCompanyName: oAgentCompanyName ?? this.oAgentCompanyName,
      oAgentName: oAgentName ?? this.oAgentName,
      lAgentCompanyName: lAgentCompanyName ?? this.lAgentCompanyName,
      lAgentName: lAgentName ?? this.lAgentName,
      sealEmpName1: sealEmpName1 ?? this.sealEmpName1,
      sealEmpName2: sealEmpName2 ?? this.sealEmpName2,
      sealEmpName3: sealEmpName3 ?? this.sealEmpName3,
      breakEmpName1: breakEmpName1 ?? this.breakEmpName1,
      breakEmpName2: breakEmpName2 ?? this.breakEmpName2,
      breakEmpName3: breakEmpName3 ?? this.breakEmpName3,
      boardingOfficerName1: boardingOfficerName1 ?? this.boardingOfficerName1,
      boardingOfficerName2: boardingOfficerName2 ?? this.boardingOfficerName2,
      originName: originName ?? this.originName,
      destinationName: destinationName ?? this.destinationName,
      remarks: remarks ?? this.remarks,
      doDescription: doDescription ?? this.doDescription,
      offVessel: offVessel ?? this.offVessel,
      loadingVessel: loadingVessel ?? this.loadingVessel,
      lPort: lPort ?? this.lPort,
      oPort: oPort ?? this.oPort,
      lVesselType: lVesselType ?? this.lVesselType,
      oVesselType: oVesselType ?? this.oVesselType,
      commodityType: commodityType ?? this.commodityType,
      cargo: cargo ?? this.cargo,
      awbNo: awbNo ?? this.awbNo,
      blCopy: blCopy ?? this.blCopy,
      oScn: oScn ?? this.oScn,
      lScn: lScn ?? this.lScn,
      weight: weight ?? this.weight,
      quantity: quantity ?? this.quantity,
      truckSize: truckSize ?? this.truckSize,
      ptwNo: ptwNo ?? this.ptwNo,
      smk1: smk1 ?? this.smk1,
      smk2: smk2 ?? this.smk2,
      smk3: smk3 ?? this.smk3,
      enRef1: enRef1 ?? this.enRef1,
      enRef2: enRef2 ?? this.enRef2,
      enRef3: enRef3 ?? this.enRef3,
      exRef1: exRef1 ?? this.exRef1,
      exRef2: exRef2 ?? this.exRef2,
      exRef3: exRef3 ?? this.exRef3,
      zbRef1: zbRef1 ?? this.zbRef1,
      zbRef2: zbRef2 ?? this.zbRef2,
      amount1: amount1 ?? this.amount1,
      amount2: amount2 ?? this.amount2,
      portChargeRef1: portChargeRef1 ?? this.portChargeRef1,
      portCharges: portCharges ?? this.portCharges,
      forwarding1S1: forwarding1S1 ?? this.forwarding1S1,
      forwarding1S2: forwarding1S2 ?? this.forwarding1S2,
      forwarding2S1: forwarding2S1 ?? this.forwarding2S1,
      forwarding2S2: forwarding2S2 ?? this.forwarding2S2,
      forwarding3S1: forwarding3S1 ?? this.forwarding3S1,
      forwarding3S2: forwarding3S2 ?? this.forwarding3S2,
      warehouseAddress: warehouseAddress ?? this.warehouseAddress,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupQuantity: pickupQuantity ?? this.pickupQuantity,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryQuantity: deliveryQuantity ?? this.deliveryQuantity,
      dtpSaleOrderDate: dtpSaleOrderDate ?? this.dtpSaleOrderDate,
      dtpLETAdate: dtpLETAdate ?? this.dtpLETAdate,
      dtpFlightTimeDate: dtpFlightTimeDate ?? this.dtpFlightTimeDate,
      dtpLETBdate: dtpLETBdate ?? this.dtpLETBdate,
      dtpLETDdate: dtpLETDdate ?? this.dtpLETDdate,
      dtpOETAdate: dtpOETAdate ?? this.dtpOETAdate,
      dtpOETBdate: dtpOETBdate ?? this.dtpOETBdate,
      dtpOETDdate: dtpOETDdate ?? this.dtpOETDdate,
      dtpPickUpDate: dtpPickUpDate ?? this.dtpPickUpDate,
      dtpDeliveryDate: dtpDeliveryDate ?? this.dtpDeliveryDate,
      dtpWHEntryDate: dtpWHEntryDate ?? this.dtpWHEntryDate,
      dtpWHExitDate: dtpWHExitDate ?? this.dtpWHExitDate,
      dtpFW1date: dtpFW1date ?? this.dtpFW1date,
      dtpFW2date: dtpFW2date ?? this.dtpFW2date,
      dtpFW3date: dtpFW3date ?? this.dtpFW3date,
      chkLETA: chkLETA ?? this.chkLETA,
      chkFlightTime: chkFlightTime ?? this.chkFlightTime,
      chkLETB: chkLETB ?? this.chkLETB,
      chkLETD: chkLETD ?? this.chkLETD,
      chkOETA: chkOETA ?? this.chkOETA,
      chkOETB: chkOETB ?? this.chkOETB,
      chkOETD: chkOETD ?? this.chkOETD,
      chkPickUp: chkPickUp ?? this.chkPickUp,
      chkDelivery: chkDelivery ?? this.chkDelivery,
      chkWHEntry: chkWHEntry ?? this.chkWHEntry,
      chkWHExit: chkWHExit ?? this.chkWHExit,
      chkFW1: chkFW1 ?? this.chkFW1,
      chkFW2: chkFW2 ?? this.chkFW2,
      chkFW3: chkFW3 ?? this.chkFW3,
      billType: billType ?? this.billType,
      truckSizeDropdown: clearTruckSize ? null : (truckSizeDropdown ?? this.truckSizeDropdown),
      fw1Dropdown: clearFW1 ? null : (fw1Dropdown ?? this.fw1Dropdown),
      fw2Dropdown: clearFW2 ? null : (fw2Dropdown ?? this.fw2Dropdown),
      fw3Dropdown: clearFW3 ? null : (fw3Dropdown ?? this.fw3Dropdown),
      zb1Dropdown: clearZB1 ? null : (zb1Dropdown ?? this.zb1Dropdown),
      zb2Dropdown: clearZB2 ? null : (zb2Dropdown ?? this.zb2Dropdown),
      coinage: coinage ?? this.coinage,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      currencyValue: currencyValue ?? this.currencyValue,
      actualAmount: actualAmount ?? this.actualAmount,
      productCalc: productCalc ?? this.productCalc,
      productList: productList ?? this.productList,
      productUpdateIndex: clearProductUpdateIndex ? null : (productUpdateIndex ?? this.productUpdateIndex),
      pickupAddressList: pickupAddressList ?? this.pickupAddressList,
      pickupQuantityList: pickupQuantityList ?? this.pickupQuantityList,
      deliveryAddressList: deliveryAddressList ?? this.deliveryAddressList,
      deliveryQuantityList: deliveryQuantityList ?? this.deliveryQuantityList,
      visibility: visibility ?? this.visibility,
      fieldPermission: fieldPermission ?? this.fieldPermission,
      disabledBillType: disabledBillType ?? this.disabledBillType,
      disabledAmount1: disabledAmount1 ?? this.disabledAmount1,
      disabledAmount2: disabledAmount2 ?? this.disabledAmount2,
      showOverlay: showOverlay ?? this.showOverlay,
      overlaySuggestions: overlaySuggestions ?? this.overlaySuggestions,
      overlayType: overlayType ?? this.overlayType,
    );
  }

  @override
  List<Object?> get props => [
    status, errorMessage, successMessage, currentTabIndex,
    editId, enquiryId, custId, statusId, jobTypeId,
    lAgentCompanyId, lAgentId, oAgentCompanyId, oAgentId,
    lVesselTypeId, lPortId, oVesselTypeId, oPortId,
    sealEmpId1, sealEmpId2, sealEmpId3,
    breakEmpId1, breakEmpId2, breakEmpId3,
    boardOfficerId1, boardOfficerId2, originId, destinationId,
    jobNo, custName, jobTypeName, jobStatusName,
    oAgentCompanyName, oAgentName, lAgentCompanyName, lAgentName,
    sealEmpName1, sealEmpName2, sealEmpName3,
    breakEmpName1, breakEmpName2, breakEmpName3,
    boardingOfficerName1, boardingOfficerName2,
    originName, destinationName,
    remarks, doDescription, offVessel, loadingVessel,
    lPort, oPort, lVesselType, oVesselType,
    commodityType, cargo, awbNo, blCopy, oScn, lScn,
    weight, quantity, truckSize, ptwNo,
    smk1, smk2, smk3,
    enRef1, enRef2, enRef3, exRef1, exRef2, exRef3,
    zbRef1, zbRef2, amount1, amount2,
    portChargeRef1, portCharges,
    forwarding1S1, forwarding1S2, forwarding2S1, forwarding2S2,
    forwarding3S1, forwarding3S2,
    warehouseAddress, pickupAddress, pickupQuantity,
    deliveryAddress, deliveryQuantity,
    dtpSaleOrderDate, dtpLETAdate, dtpFlightTimeDate,
    dtpLETBdate, dtpLETDdate, dtpOETAdate, dtpOETBdate, dtpOETDdate,
    dtpPickUpDate, dtpDeliveryDate, dtpWHEntryDate, dtpWHExitDate,
    dtpFW1date, dtpFW2date, dtpFW3date,
    chkLETA, chkFlightTime, chkLETB, chkLETD,
    chkOETA, chkOETB, chkOETD,
    chkPickUp, chkDelivery, chkWHEntry, chkWHExit,
    chkFW1, chkFW2, chkFW3,
    billType, truckSizeDropdown,
    fw1Dropdown, fw2Dropdown, fw3Dropdown,
    zb1Dropdown, zb2Dropdown,
    coinage, totalAmount, taxAmount, currencyValue, actualAmount,
    productCalc, productList, productUpdateIndex,
    pickupAddressList, pickupQuantityList,
    deliveryAddressList, deliveryQuantityList,
    visibility, fieldPermission,
    disabledBillType, disabledAmount1, disabledAmount2,
    showOverlay, overlaySuggestions, overlayType,
  ];
}