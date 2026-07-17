
// ── Visibility flags (one per field group) ────────────────────────────────────

import 'package:equatable/equatable.dart';

import '../../../../../core/models/model.dart';
import 'package:maleva/core/models/shared/sale_edit_detail_model.dart';

class SaleOrderVisibility extends Equatable {
  final bool offVessel;
  final bool loadingVessel;
  final bool lEta;
  final bool lEtb;
  final bool lEtd;
  final bool awbNo;
  final bool blCopy;
  final bool forklift;
  final bool sealBy;
  final bool breakSealBy;
  final bool forwarding;
  final bool origin;
  final bool destination;
  final bool zb;
  final bool oEta;
  final bool oEtb;
  final bool oEtd;
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

  const SaleOrderVisibility({
    this.offVessel = true,
    this.loadingVessel = true,
    this.lEta = true,
    this.lEtb = true,
    this.lEtd = true,
    this.awbNo = true,
    this.blCopy = true,
    this.forklift = true,
    this.sealBy = true,
    this.breakSealBy = true,
    this.forwarding = true,
    this.origin = true,
    this.destination = true,
    this.zb = true,
    this.oEta = true,
    this.oEtb = true,
    this.oEtd = true,
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
  });

  /// All flags start as hidden then toggled on by job-type details.
  const SaleOrderVisibility.allHidden()
      : offVessel = false,
        loadingVessel = false,
        lEta = false,
        lEtb = false,
        lEtd = false,
        awbNo = false,
        blCopy = false,
        forklift = false,
        sealBy = false,
        breakSealBy = false,
        forwarding = false,
        origin = false,
        destination = false,
        zb = false,
        oEta = false,
        oEtb = false,
        oEtd = false,
        oShippingAgent = false,
        oAgentName = false,
        oScn = false,
        lScn = false,
        lShippingAgent = false,
        lAgentName = false,
        lVesselType = false,
        oVesselType = false,
        oPort = false,
        lPort = false;

  SaleOrderVisibility copyWith({
    bool? offVessel,
    bool? loadingVessel,
    bool? lEta,
    bool? lEtb,
    bool? lEtd,
    bool? awbNo,
    bool? blCopy,
    bool? forklift,
    bool? sealBy,
    bool? breakSealBy,
    bool? forwarding,
    bool? origin,
    bool? destination,
    bool? zb,
    bool? oEta,
    bool? oEtb,
    bool? oEtd,
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
  }) {
    return SaleOrderVisibility(
      offVessel: offVessel ?? this.offVessel,
      loadingVessel: loadingVessel ?? this.loadingVessel,
      lEta: lEta ?? this.lEta,
      lEtb: lEtb ?? this.lEtb,
      lEtd: lEtd ?? this.lEtd,
      awbNo: awbNo ?? this.awbNo,
      blCopy: blCopy ?? this.blCopy,
      forklift: forklift ?? this.forklift,
      sealBy: sealBy ?? this.sealBy,
      breakSealBy: breakSealBy ?? this.breakSealBy,
      forwarding: forwarding ?? this.forwarding,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      zb: zb ?? this.zb,
      oEta: oEta ?? this.oEta,
      oEtb: oEtb ?? this.oEtb,
      oEtd: oEtd ?? this.oEtd,
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
    );
  }

  @override
  List<Object?> get props => [
    offVessel, loadingVessel, lEta, lEtb, lEtd, awbNo, blCopy, forklift,
    sealBy, breakSealBy, forwarding, origin, destination, zb, oEta, oEtb,
    oEtd, oShippingAgent, oAgentName, oScn, lScn, lShippingAgent,
    lAgentName, lVesselType, oVesselType, oPort, lPort,
  ];
}

// ── Main state ────────────────────────────────────────────────────────────────

enum SaleOrderStatus { initial, loading, ready, error }

class SaleOrderDetailsState extends Equatable {
  // ── Loading ──────────────────────────────────────────────────────────────
  final SaleOrderStatus status;
  final String errorMessage;

  // ── Form identifiers ────────────────────────────────────────────────────
  final String jobNo;
  final String saleOrderDate;
  final String billType;
  final int editId;
  final String userName;

  // ── Customer / job ───────────────────────────────────────────────────────
  final String customerName;
  final int custId;
  final String jobType;
  final int jobTypeId;
  final String jobStatus;
  final int statusId;
  final String remarks;
  final String doDescription;

  // ── Cargo fields ─────────────────────────────────────────────────────────
  final String commodityType;
  final String weight;
  final String quantity;
  final String truckSize;
  final String awbNo;
  final String blCopy;
  final String cargo;
  final String ptwNo;

  // ── Loading vessel ───────────────────────────────────────────────────────
  final String lAgentCompany;
  final int lAgentCompanyId;
  final String lAgentName;
  final int lAgentId;
  final String loadingVessel;
  final String lScn;
  final String lVesselType;
  final String lPort;

  // ── Off-load vessel ──────────────────────────────────────────────────────
  final String oAgentCompany;
  final int oAgentCompanyId;
  final String oAgentName;
  final int oAgentId;
  final String offVessel;
  final String oScn;
  final String oVesselType;
  final String oPort;

  // ── Dates (stored as ISO strings) ────────────────────────────────────────
  final String dtpSaleOrderDate;
  final String dtpLEta;
  final String dtpLEtb;
  final String dtpLEtd;
  final String dtpOEta;
  final String dtpOEtb;
  final String dtpOEtd;
  final String dtpPickUpDate;
  final String dtpDeliveryDate;
  final String dtpWhEntryDate;
  final String dtpWhExitDate;

  // ── Checkbox states ───────────────────────────────────────────────────────
  final bool checkLEta;
  final bool checkLEtb;
  final bool checkLEtd;
  final bool checkOEta;
  final bool checkOEtb;
  final bool checkOEtd;
  final bool checkPickUp;
  final bool checkDelivery;
  final bool checkWhEntry;
  final bool checkWhExit;

  // ── Addresses ────────────────────────────────────────────────────────────
  final String pickUpAddress;
  final List<dynamic> pickUpAddressList;
  final String deliveryAddress;
  final List<dynamic> deliveryAddressList;
  final String warehouseAddress;
  final String origin;
  final String destination;

  // ── Forwarding ───────────────────────────────────────────────────────────
  final String? dropdownFW1;
  final String? dropdownFW2;
  final String? dropdownFW3;
  final bool visibleFW1;
  final bool visibleFW2;
  final bool visibleFW3;
  final String smk1;
  final String smk2;
  final String smk3;
  final String enRef1;
  final String enRef2;
  final String enRef3;
  final String exRef1;
  final String exRef2;
  final String exRef3;
  final String sealByEmp1;
  final int sealEmpId1;
  final String sealByEmp2;
  final int sealEmpId2;
  final String sealByEmp3;
  final int sealEmpId3;
  final String breakByEmp1;
  final int breakEmpId1;
  final String breakByEmp2;
  final int breakEmpId2;
  final String breakByEmp3;
  final int breakEmpId3;

  // ── ZB ────────────────────────────────────────────────────────────────────
  final String? dropdownZB1;
  final String? dropdownZB2;
  final String zbRef1;
  final String zbRef2;

  // ── Boarding ─────────────────────────────────────────────────────────────
  final String boardingOfficer1;
  final int boardOfficerId1;
  final String boardingOfficer2;
  final int boardOfficerId2;
  final String amount1;
  final String amount2;
  final String portChargeRef1;
  final String portCharges;

  // ── Disabled flags ────────────────────────────────────────────────────────
  final bool disabledBillType;
  final bool disabledAmount1;
  final bool disabledAmount2;

  // ── Visibility ────────────────────────────────────────────────────────────
  final SaleOrderVisibility visibility;

  // ── Tab ───────────────────────────────────────────────────────────────────
  final int currentTabIndex;

  // ── Product list ─────────────────────────────────────────────────────────
  final List<SaleEditDetailModel> productViewList;

  // ── Financial ────────────────────────────────────────────────────────────
  final double coinage;
  final double totalAmount;
  final double taxAmount;

  const SaleOrderDetailsState({
    this.status = SaleOrderStatus.initial,
    this.errorMessage = '',
    this.jobNo = '',
    this.saleOrderDate = '',
    this.billType = 'MY',
    this.editId = 0,
    this.userName = '',
    this.customerName = '',
    this.custId = 0,
    this.jobType = '',
    this.jobTypeId = 0,
    this.jobStatus = '',
    this.statusId = 0,
    this.remarks = '',
    this.doDescription = '',
    this.commodityType = '',
    this.weight = '',
    this.quantity = '',
    this.truckSize = '',
    this.awbNo = '',
    this.blCopy = '',
    this.cargo = '',
    this.ptwNo = '',
    this.lAgentCompany = '',
    this.lAgentCompanyId = 0,
    this.lAgentName = '',
    this.lAgentId = 0,
    this.loadingVessel = '',
    this.lScn = '',
    this.lVesselType = '',
    this.lPort = '',
    this.oAgentCompany = '',
    this.oAgentCompanyId = 0,
    this.oAgentName = '',
    this.oAgentId = 0,
    this.offVessel = '',
    this.oScn = '',
    this.oVesselType = '',
    this.oPort = '',
    this.dtpSaleOrderDate = '',
    this.dtpLEta = '',
    this.dtpLEtb = '',
    this.dtpLEtd = '',
    this.dtpOEta = '',
    this.dtpOEtb = '',
    this.dtpOEtd = '',
    this.dtpPickUpDate = '',
    this.dtpDeliveryDate = '',
    this.dtpWhEntryDate = '',
    this.dtpWhExitDate = '',
    this.checkLEta = false,
    this.checkLEtb = false,
    this.checkLEtd = false,
    this.checkOEta = false,
    this.checkOEtb = false,
    this.checkOEtd = false,
    this.checkPickUp = false,
    this.checkDelivery = false,
    this.checkWhEntry = false,
    this.checkWhExit = false,
    this.pickUpAddress = '',
    this.pickUpAddressList = const [],
    this.deliveryAddress = '',
    this.deliveryAddressList = const [],
    this.warehouseAddress = '',
    this.origin = '',
    this.destination = '',
    this.dropdownFW1,
    this.dropdownFW2,
    this.dropdownFW3,
    this.visibleFW1 = false,
    this.visibleFW2 = false,
    this.visibleFW3 = false,
    this.smk1 = '',
    this.smk2 = '',
    this.smk3 = '',
    this.enRef1 = '',
    this.enRef2 = '',
    this.enRef3 = '',
    this.exRef1 = '',
    this.exRef2 = '',
    this.exRef3 = '',
    this.sealByEmp1 = '',
    this.sealEmpId1 = 0,
    this.sealByEmp2 = '',
    this.sealEmpId2 = 0,
    this.sealByEmp3 = '',
    this.sealEmpId3 = 0,
    this.breakByEmp1 = '',
    this.breakEmpId1 = 0,
    this.breakByEmp2 = '',
    this.breakEmpId2 = 0,
    this.breakByEmp3 = '',
    this.breakEmpId3 = 0,
    this.dropdownZB1,
    this.dropdownZB2,
    this.zbRef1 = '',
    this.zbRef2 = '',
    this.boardingOfficer1 = '',
    this.boardOfficerId1 = 0,
    this.boardingOfficer2 = '',
    this.boardOfficerId2 = 0,
    this.amount1 = '',
    this.amount2 = '',
    this.portChargeRef1 = '',
    this.portCharges = '',
    this.disabledBillType = false,
    this.disabledAmount1 = false,
    this.disabledAmount2 = false,
    this.visibility = const SaleOrderVisibility(),
    this.currentTabIndex = 0,
    this.productViewList = const [],
    this.coinage = 0.0,
    this.totalAmount = 0.0,
    this.taxAmount = 0.0,
  });

  SaleOrderDetailsState copyWith({
    SaleOrderStatus? status,
    String? errorMessage,
    String? jobNo,
    String? saleOrderDate,
    String? billType,
    int? editId,
    String? userName,
    String? customerName,
    int? custId,
    String? jobType,
    int? jobTypeId,
    String? jobStatus,
    int? statusId,
    String? remarks,
    String? doDescription,
    String? commodityType,
    String? weight,
    String? quantity,
    String? truckSize,
    String? awbNo,
    String? blCopy,
    String? cargo,
    String? ptwNo,
    String? lAgentCompany,
    int? lAgentCompanyId,
    String? lAgentName,
    int? lAgentId,
    String? loadingVessel,
    String? lScn,
    String? lVesselType,
    String? lPort,
    String? oAgentCompany,
    int? oAgentCompanyId,
    String? oAgentName,
    int? oAgentId,
    String? offVessel,
    String? oScn,
    String? oVesselType,
    String? oPort,
    String? dtpSaleOrderDate,
    String? dtpLEta,
    String? dtpLEtb,
    String? dtpLEtd,
    String? dtpOEta,
    String? dtpOEtb,
    String? dtpOEtd,
    String? dtpPickUpDate,
    String? dtpDeliveryDate,
    String? dtpWhEntryDate,
    String? dtpWhExitDate,
    bool? checkLEta,
    bool? checkLEtb,
    bool? checkLEtd,
    bool? checkOEta,
    bool? checkOEtb,
    bool? checkOEtd,
    bool? checkPickUp,
    bool? checkDelivery,
    bool? checkWhEntry,
    bool? checkWhExit,
    String? pickUpAddress,
    List<dynamic>? pickUpAddressList,
    String? deliveryAddress,
    List<dynamic>? deliveryAddressList,
    String? warehouseAddress,
    String? origin,
    String? destination,
    String? dropdownFW1,
    String? dropdownFW2,
    String? dropdownFW3,
    bool? visibleFW1,
    bool? visibleFW2,
    bool? visibleFW3,
    String? smk1,
    String? smk2,
    String? smk3,
    String? enRef1,
    String? enRef2,
    String? enRef3,
    String? exRef1,
    String? exRef2,
    String? exRef3,
    String? sealByEmp1,
    int? sealEmpId1,
    String? sealByEmp2,
    int? sealEmpId2,
    String? sealByEmp3,
    int? sealEmpId3,
    String? breakByEmp1,
    int? breakEmpId1,
    String? breakByEmp2,
    int? breakEmpId2,
    String? breakByEmp3,
    int? breakEmpId3,
    String? dropdownZB1,
    String? dropdownZB2,
    String? zbRef1,
    String? zbRef2,
    String? boardingOfficer1,
    int? boardOfficerId1,
    String? boardingOfficer2,
    int? boardOfficerId2,
    String? amount1,
    String? amount2,
    String? portChargeRef1,
    String? portCharges,
    bool? disabledBillType,
    bool? disabledAmount1,
    bool? disabledAmount2,
    SaleOrderVisibility? visibility,
    int? currentTabIndex,
    List<SaleEditDetailModel>? productViewList,
    double? coinage,
    double? totalAmount,
    double? taxAmount,
  }) {
    return SaleOrderDetailsState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      jobNo: jobNo ?? this.jobNo,
      saleOrderDate: saleOrderDate ?? this.saleOrderDate,
      billType: billType ?? this.billType,
      editId: editId ?? this.editId,
      userName: userName ?? this.userName,
      customerName: customerName ?? this.customerName,
      custId: custId ?? this.custId,
      jobType: jobType ?? this.jobType,
      jobTypeId: jobTypeId ?? this.jobTypeId,
      jobStatus: jobStatus ?? this.jobStatus,
      statusId: statusId ?? this.statusId,
      remarks: remarks ?? this.remarks,
      doDescription: doDescription ?? this.doDescription,
      commodityType: commodityType ?? this.commodityType,
      weight: weight ?? this.weight,
      quantity: quantity ?? this.quantity,
      truckSize: truckSize ?? this.truckSize,
      awbNo: awbNo ?? this.awbNo,
      blCopy: blCopy ?? this.blCopy,
      cargo: cargo ?? this.cargo,
      ptwNo: ptwNo ?? this.ptwNo,
      lAgentCompany: lAgentCompany ?? this.lAgentCompany,
      lAgentCompanyId: lAgentCompanyId ?? this.lAgentCompanyId,
      lAgentName: lAgentName ?? this.lAgentName,
      lAgentId: lAgentId ?? this.lAgentId,
      loadingVessel: loadingVessel ?? this.loadingVessel,
      lScn: lScn ?? this.lScn,
      lVesselType: lVesselType ?? this.lVesselType,
      lPort: lPort ?? this.lPort,
      oAgentCompany: oAgentCompany ?? this.oAgentCompany,
      oAgentCompanyId: oAgentCompanyId ?? this.oAgentCompanyId,
      oAgentName: oAgentName ?? this.oAgentName,
      oAgentId: oAgentId ?? this.oAgentId,
      offVessel: offVessel ?? this.offVessel,
      oScn: oScn ?? this.oScn,
      oVesselType: oVesselType ?? this.oVesselType,
      oPort: oPort ?? this.oPort,
      dtpSaleOrderDate: dtpSaleOrderDate ?? this.dtpSaleOrderDate,
      dtpLEta: dtpLEta ?? this.dtpLEta,
      dtpLEtb: dtpLEtb ?? this.dtpLEtb,
      dtpLEtd: dtpLEtd ?? this.dtpLEtd,
      dtpOEta: dtpOEta ?? this.dtpOEta,
      dtpOEtb: dtpOEtb ?? this.dtpOEtb,
      dtpOEtd: dtpOEtd ?? this.dtpOEtd,
      dtpPickUpDate: dtpPickUpDate ?? this.dtpPickUpDate,
      dtpDeliveryDate: dtpDeliveryDate ?? this.dtpDeliveryDate,
      dtpWhEntryDate: dtpWhEntryDate ?? this.dtpWhEntryDate,
      dtpWhExitDate: dtpWhExitDate ?? this.dtpWhExitDate,
      checkLEta: checkLEta ?? this.checkLEta,
      checkLEtb: checkLEtb ?? this.checkLEtb,
      checkLEtd: checkLEtd ?? this.checkLEtd,
      checkOEta: checkOEta ?? this.checkOEta,
      checkOEtb: checkOEtb ?? this.checkOEtb,
      checkOEtd: checkOEtd ?? this.checkOEtd,
      checkPickUp: checkPickUp ?? this.checkPickUp,
      checkDelivery: checkDelivery ?? this.checkDelivery,
      checkWhEntry: checkWhEntry ?? this.checkWhEntry,
      checkWhExit: checkWhExit ?? this.checkWhExit,
      pickUpAddress: pickUpAddress ?? this.pickUpAddress,
      pickUpAddressList: pickUpAddressList ?? this.pickUpAddressList,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryAddressList: deliveryAddressList ?? this.deliveryAddressList,
      warehouseAddress: warehouseAddress ?? this.warehouseAddress,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      dropdownFW1: dropdownFW1 ?? this.dropdownFW1,
      dropdownFW2: dropdownFW2 ?? this.dropdownFW2,
      dropdownFW3: dropdownFW3 ?? this.dropdownFW3,
      visibleFW1: visibleFW1 ?? this.visibleFW1,
      visibleFW2: visibleFW2 ?? this.visibleFW2,
      visibleFW3: visibleFW3 ?? this.visibleFW3,
      smk1: smk1 ?? this.smk1,
      smk2: smk2 ?? this.smk2,
      smk3: smk3 ?? this.smk3,
      enRef1: enRef1 ?? this.enRef1,
      enRef2: enRef2 ?? this.enRef2,
      enRef3: enRef3 ?? this.enRef3,
      exRef1: exRef1 ?? this.exRef1,
      exRef2: exRef2 ?? this.exRef2,
      exRef3: exRef3 ?? this.exRef3,
      sealByEmp1: sealByEmp1 ?? this.sealByEmp1,
      sealEmpId1: sealEmpId1 ?? this.sealEmpId1,
      sealByEmp2: sealByEmp2 ?? this.sealByEmp2,
      sealEmpId2: sealEmpId2 ?? this.sealEmpId2,
      sealByEmp3: sealByEmp3 ?? this.sealByEmp3,
      sealEmpId3: sealEmpId3 ?? this.sealEmpId3,
      breakByEmp1: breakByEmp1 ?? this.breakByEmp1,
      breakEmpId1: breakEmpId1 ?? this.breakEmpId1,
      breakByEmp2: breakByEmp2 ?? this.breakByEmp2,
      breakEmpId2: breakEmpId2 ?? this.breakEmpId2,
      breakByEmp3: breakByEmp3 ?? this.breakByEmp3,
      breakEmpId3: breakEmpId3 ?? this.breakEmpId3,
      dropdownZB1: dropdownZB1 ?? this.dropdownZB1,
      dropdownZB2: dropdownZB2 ?? this.dropdownZB2,
      zbRef1: zbRef1 ?? this.zbRef1,
      zbRef2: zbRef2 ?? this.zbRef2,
      boardingOfficer1: boardingOfficer1 ?? this.boardingOfficer1,
      boardOfficerId1: boardOfficerId1 ?? this.boardOfficerId1,
      boardingOfficer2: boardingOfficer2 ?? this.boardingOfficer2,
      boardOfficerId2: boardOfficerId2 ?? this.boardOfficerId2,
      amount1: amount1 ?? this.amount1,
      amount2: amount2 ?? this.amount2,
      portChargeRef1: portChargeRef1 ?? this.portChargeRef1,
      portCharges: portCharges ?? this.portCharges,
      disabledBillType: disabledBillType ?? this.disabledBillType,
      disabledAmount1: disabledAmount1 ?? this.disabledAmount1,
      disabledAmount2: disabledAmount2 ?? this.disabledAmount2,
      visibility: visibility ?? this.visibility,
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      productViewList: productViewList ?? this.productViewList,
      coinage: coinage ?? this.coinage,
      totalAmount: totalAmount ?? this.totalAmount,
      taxAmount: taxAmount ?? this.taxAmount,
    );
  }

  @override
  List<Object?> get props => [
    status, errorMessage, jobNo, saleOrderDate, billType, editId, userName,
    customerName, custId, jobType, jobTypeId, jobStatus, statusId,
    remarks, doDescription, commodityType, weight, quantity, truckSize,
    awbNo, blCopy, cargo, ptwNo,
    lAgentCompany, lAgentCompanyId, lAgentName, lAgentId,
    loadingVessel, lScn, lVesselType, lPort,
    oAgentCompany, oAgentCompanyId, oAgentName, oAgentId,
    offVessel, oScn, oVesselType, oPort,
    dtpSaleOrderDate, dtpLEta, dtpLEtb, dtpLEtd,
    dtpOEta, dtpOEtb, dtpOEtd,
    dtpPickUpDate, dtpDeliveryDate, dtpWhEntryDate, dtpWhExitDate,
    checkLEta, checkLEtb, checkLEtd,
    checkOEta, checkOEtb, checkOEtd,
    checkPickUp, checkDelivery, checkWhEntry, checkWhExit,
    pickUpAddress, pickUpAddressList,
    deliveryAddress, deliveryAddressList,
    warehouseAddress, origin, destination,
    dropdownFW1, dropdownFW2, dropdownFW3,
    visibleFW1, visibleFW2, visibleFW3,
    smk1, smk2, smk3,
    enRef1, enRef2, enRef3,
    exRef1, exRef2, exRef3,
    sealByEmp1, sealEmpId1, sealByEmp2, sealEmpId2, sealByEmp3, sealEmpId3,
    breakByEmp1, breakEmpId1, breakByEmp2, breakEmpId2, breakByEmp3, breakEmpId3,
    dropdownZB1, dropdownZB2, zbRef1, zbRef2,
    boardingOfficer1, boardOfficerId1, boardingOfficer2, boardOfficerId2,
    amount1, amount2, portChargeRef1, portCharges,
    disabledBillType, disabledAmount1, disabledAmount2,
    visibility, currentTabIndex, productViewList,
    coinage, totalAmount, taxAmount,
  ];
}