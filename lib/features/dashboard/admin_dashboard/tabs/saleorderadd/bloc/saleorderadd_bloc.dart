import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/saleorderadd/bloc/saleorderadd_state.dart';
import 'saleorderadd_event.dart';



class SalesOrderBloc extends Bloc<SalesOrderEvent, SalesOrderState> {
  SalesOrderBloc() : super(SalesOrderState.initial()) {
    on<SalesOrderInitialized>(_onInitialized);
    on<SalesOrderTabChanged>(_onTabChanged);
    on<SalesOrderBillTypeChanged>(_onBillTypeChanged);
    on<SalesOrderCustomerSelected>(_onCustomerSelected);
    on<SalesOrderCustomerCleared>(_onCustomerCleared);
    on<SalesOrderJobTypeSelected>(_onJobTypeSelected);
    on<SalesOrderJobTypeCleared>(_onJobTypeCleared);
    on<SalesOrderJobStatusSelected>(_onJobStatusSelected);
    on<SalesOrderDateChanged>(_onDateChanged);
    on<SalesOrderTruckSizeChanged>(_onTruckSizeChanged);
    on<SalesOrderFW1Changed>(_onFW1Changed);
    on<SalesOrderFW2Changed>(_onFW2Changed);
    on<SalesOrderFW3Changed>(_onFW3Changed);
    on<SalesOrderZB1Changed>(_onZB1Changed);
    on<SalesOrderZB2Changed>(_onZB2Changed);
    on<SalesOrderDateTimeToggled>(_onDateTimeToggled);
    on<SalesOrderDateTimeChanged>(_onDateTimeChanged);
    on<SalesOrderOriginSelected>(_onOriginSelected);
    on<SalesOrderDestinationSelected>(_onDestinationSelected);
    on<SalesOrderLAgentCompanySelected>(_onLAgentCompanySelected);
    on<SalesOrderLAgentSelected>(_onLAgentSelected);
    on<SalesOrderOAgentCompanySelected>(_onOAgentCompanySelected);
    on<SalesOrderOAgentSelected>(_onOAgentSelected);
    on<SalesOrderSealEmpSelected>(_onSealEmpSelected);
    on<SalesOrderSealEmpCleared>(_onSealEmpCleared);
    on<SalesOrderBreakSealEmpSelected>(_onBreakSealEmpSelected);
    on<SalesOrderBreakSealEmpCleared>(_onBreakSealEmpCleared);
    on<SalesOrderBoardingOfficerSelected>(_onBoardingOfficerSelected);
    on<SalesOrderBoardingOfficerCleared>(_onBoardingOfficerCleared);
    on<SalesOrderAutoCompleteS1Changed>(_onAutoCompleteS1Changed);
    on<SalesOrderAutoCompleteS1Selected>(_onAutoCompleteS1Selected);
    on<SalesOrderOverlayCleared>(_onOverlayCleared);
    on<SalesOrderProductAdded>(_onProductAdded);
    on<SalesOrderProductRemoved>(_onProductRemoved);
    on<SalesOrderProductCalculationRequested>(_onProductCalculation);
    on<SalesOrderCurrencyValueChanged>(_onCurrencyValueChanged);
    on<SalesOrderPickupAddressListUpdated>(_onPickupAddressListUpdated);
    on<SalesOrderDeliveryAddressListUpdated>(_onDeliveryAddressListUpdated);
    on<SalesOrderVisibilityRefreshed>(_onVisibilityRefreshed);
    on<SalesOrderFieldPermissionsApplied>(_onFieldPermissionsApplied);
    on<SalesOrderSaveRequested>(_onSaveRequested);
    on<SalesOrderClearRequested>(_onClearRequested);
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _now() =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// Re-calculates totals from a product list + currency value.
  /// Returns updated list + totals.
  _CalcResult _recalculate(
      List<SaleEditDetailModel> list,
      double currencyValue,
      ) {
    double producttotal = 0;
    double taxAmount = 0;
    double coinage = 0;

    for (var p in list) {
      p.CurrencyValue = currencyValue;
      producttotal += p.Amount;
      taxAmount += p.TaxAmount;
      if (currencyValue != 0) {
        p.ActualAmount = currencyValue * p.Amount;
      } else {
        p.ActualAmount = p.Amount;
      }
    }

    final gross = producttotal + taxAmount;
    final roundedAmt = gross.roundToDouble();
    coinage = double.parse((roundedAmt - gross).abs().toStringAsFixed(2));

    return _CalcResult(
      productList: list,
      totalAmount: double.parse(producttotal.toStringAsFixed(2)),
      taxAmount: double.parse(taxAmount.toStringAsFixed(2)),
      coinage: coinage,
      actualAmount:
      double.parse((producttotal * currencyValue).toStringAsFixed(2)),
    );
  }

  /// Builds visibility flags from `objfun.JobTypeDetailsList`.
  SalesOrderVisibility _buildVisibility(String jobTypeName) {
    var v = const SalesOrderVisibility(
      offVessel: false,
      loadingVessel: false,
      lETA: false,
      flightTime: false,
      lETB: false,
      lETD: false,
      awbNo: false,
      blCopy: false,
      forklift: false,
      sealBy: false,
      breakSealBy: false,
      forwarding: false,
      origin: false,
      destination: false,
      zb: false,
      oETA: false,
      oETB: false,
      oETD: false,
      oShippingAgent: false,
      oAgentName: false,
      oScn: false,
      lScn: false,
      lShippingAgent: false,
      lAgentName: false,
      lVesselType: false,
      oVesselType: false,
      oPort: false,
      lPort: false,
      productView: false,
      fw1: false,
      fw2: false,
      fw3: false,
      gc: false,
    );

    for (var d in objfun.JobTypeDetailsList) {
      switch (d.Description) {
        case 'OFF VESSEL NAME':
          v = v.copyWith(offVessel: true);
          break;
        case 'LOAD VESSEL NAME':
          v = v.copyWith(loadingVessel: true);
          break;
        case 'L ETA':
          v = v.copyWith(lETA: true);
          break;
        case 'L ETB':
          v = v.copyWith(lETB: true);
          break;
        case 'L ETD':
          v = v.copyWith(lETD: true);
          break;
        case 'AWB NO':
          v = v.copyWith(awbNo: true);
          break;
        case 'BL COPY':
          v = v.copyWith(blCopy: true);
          break;
        case 'FORKLIFT':
          v = v.copyWith(forklift: true);
          break;
        case 'SEAL BY':
          v = v.copyWith(sealBy: true);
          break;
        case 'BREAK SEAL BY':
          v = v.copyWith(breakSealBy: true);
          break;
        case 'FORWARDING':
          v = v.copyWith(forwarding: true);
          break;
        case 'ORIGIN':
          v = v.copyWith(origin: true);
          break;
        case 'DESTINATION':
          v = v.copyWith(destination: true);
          break;
        case 'ZB':
          v = v.copyWith(zb: true);
          break;
        case 'O ETA':
          v = v.copyWith(oETA: true);
          break;
        case 'O ETB':
          v = v.copyWith(oETB: true);
          break;
        case 'O ETD':
          v = v.copyWith(oETD: true);
          break;
        case 'O AGENT':
          v = v.copyWith(oAgentName: true);
          break;
        case 'O AGENT COMPANY':
          v = v.copyWith(oShippingAgent: true);
          break;
        case 'O SCN':
          v = v.copyWith(oScn: true);
          break;
        case 'L SCN':
          v = v.copyWith(lScn: true);
          break;
        case 'L AGENT COMPANY':
          v = v.copyWith(lShippingAgent: true);
          break;
        case 'L AGENT':
          v = v.copyWith(lAgentName: true);
          break;
        case 'L VESSEL TYPE':
          v = v.copyWith(lVesselType: true);
          break;
        case 'O VESSEL TYPE':
          v = v.copyWith(oVesselType: true);
          break;
        case 'O PORT':
          v = v.copyWith(oPort: true);
          break;
        case 'L PORT':
          v = v.copyWith(lPort: true);
          break;
      }
    }

    // General Cargo overrides
    if (jobTypeName == 'GENARAL CARGO') {
      v = v.copyWith(origin: false, destination: false, gc: true);
    }

    return v;
  }

  /// Apply field permissions based on employee ID.
  Map<String, bool> _buildFieldPermissions() {
    const allFields = [
      'txtCustomer', 'txtJobType', 'txtJobStatus', 'txtRemarks',
      'txtDoDescription', 'ProductViewList', 'txtCommodityType', 'txtOrigin',
      'txtWeight', 'txtQuantity', 'txtTruckSize', 'txtAWBNo', 'txtBLCopy',
      'txtCargo', 'txtPTWNo', 'dtpLETAdate', 'dtpLETBdate', 'dtpLETDdate',
      'txtLAgentCompany', 'txtLAgentName', 'txtLSCN', 'dtpFlightTimedate',
      'txtLoadingVessel', 'txtLPort', 'txtLVesselType', 'cmbBillType',
      'dtpOETAdate', 'dtpOETDdate', 'txtOAgentCompany', 'txtOAgentName',
      'txtOSCN', 'txtOffVessel', 'txtOPort', 'txtOVesselType', 'dtpPickUpdate',
      'dtpDeliverydate', 'dtpWHEntrydate', 'dtpWHExitdate', 'txtOrigin',
      'txtDestination', 'txtPickUpAddress', 'txtPickUpQuantity',
      'txtDeliveryAddress', 'txtDeliveryQuantity', 'txtWarehouseAddress',
      'dtpFW1date', 'txtSmk1', 'txtENRef1', 'txtSealByEmp1', 'txtBreakByEmp1',
      'txtForwarding1S1', 'txtForwarding1S2', 'dropdownValueFW2', 'dtpFW2date',
      'txtENRef2', 'txtExRef2', 'txtSealByEmp2', 'txtBreakByEmp2',
      'txtForwarding2S1', 'txtForwarding2S2', 'dropdownValueFW3', 'dtpFW3date',
      'txtSmk3', 'txtENRef3', 'txtSealByEmp3', 'txtBreakByEmp3',
      'txtForwarding3S2', 'dropdownValueZB1', 'txtZBRef1', 'dropdownValueZB2',
      'txtZBRef2', 'txtBoardingOfficer1', 'txtBoardingOfficer2', 'txtAmount1',
      'txtAmount2', 'txtPortCharges', 'chkLETA', 'chkOETA', 'chkLETB',
      'chkOETB', 'chkLETD', 'chkOETD', 'chkPickup', 'chkDelivery',
      'chkWareHouseEntry', 'chkWareHouseExit', 'chkFlightTime', 'SAVE', 'VIEW',
      'addProduct', 'dropdownValueFW1', 'dropdownValueFW2', 'checkBoxValueFW2',
      'txtSmk2', 'dropdownValueFW3', 'dropdownValueZB1', 'dropdownValueZB2',
      'checkBoxValueFW1', 'checkBoxValueFW3',
    ];

    const restrictedIds = [138, 50, 127, 35, 75, 38, 68, 128, 100, 117, 121];

    if (!restrictedIds.contains(objfun.EmpRefId)) {
      return {for (var f in allFields) f: true};
    }

    final map = {for (var f in allFields) f: false};
    const allowed = [
      'txtBoardingOfficer1', 'txtBoardingOfficer2',
      'txtAmount1', 'txtAmount2', 'SAVE', 'VIEW',
    ];
    for (var f in allowed) {
      map[f] = true;
    }
    return map;
  }

  // ─── Populate state from a saleMaster map (shared by loaddata + loadEnqdata) ─

  SalesOrderState _populateFromMaster(
      SalesOrderState s,
      Map<String, dynamic> m,
      bool isEnquiry,
      ) {
    String? _dateStr(String key) {
      if (m[key] == null) return null;
      return DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(DateTime.parse(m[key].toString()));
    }

    // Agents
    int lAgentCompanyId = s.lAgentCompanyId;
    String lAgentCompanyName = s.lAgentCompanyName;
    int lAgentId = s.lAgentId;
    String lAgentName = s.lAgentName;
    int oAgentCompanyId = s.oAgentCompanyId;
    String oAgentCompanyName = s.oAgentCompanyName;
    int oAgentId = s.oAgentId;
    String oAgentName = s.oAgentName;

    if ((m['OAgentCompanyRefId'] ?? 0) != 0) {
      oAgentCompanyId = m['OAgentCompanyRefId'];
      final match = objfun.AgentCompanyList
          .where((i) => i.Id == oAgentCompanyId)
          .toList();
      oAgentCompanyName = match.isNotEmpty ? match[0].Name : '';
    }
    if ((m['OAgentMasterRefId'] ?? 0) != 0) {
      oAgentId = m['OAgentMasterRefId'];
      final match =
      objfun.AgentAllList.where((i) => i.Id == oAgentId).toList();
      oAgentName = match.isNotEmpty ? match[0].AgentName : '';
    }
    if ((m['AgentCompanyRefId'] ?? 0) != 0) {
      lAgentCompanyId = m['AgentCompanyRefId'];
      final match = objfun.AgentCompanyList
          .where((i) => i.Id == lAgentCompanyId)
          .toList();
      lAgentCompanyName = match.isNotEmpty ? match[0].Name : '';
    }
    if ((m['AgentMasterRefId'] ?? 0) != 0) {
      lAgentId = m['AgentMasterRefId'];
      final match =
      objfun.AgentAllList.where((i) => i.Id == lAgentId).toList();
      lAgentName = match.isNotEmpty ? match[0].AgentName : '';
    }

    // Customer
    int custId = s.custId;
    String custName = s.custName;
    if ((m['CustomerRefId'] ?? 0) != 0) {
      custId = m['CustomerRefId'];
      final match =
      objfun.CustomerList.where((i) => i.Id == custId).toList();
      custName = match.isNotEmpty ? match[0].AccountName : '';
    }

    // Job Type
    int jobTypeId = s.jobTypeId;
    String jobTypeName = s.jobTypeName;
    if ((m['JobMasterRefId'] ?? 0) != 0) {
      jobTypeId = m['JobMasterRefId'];
      final match =
      objfun.JobTypeList.where((i) => i.Id == jobTypeId).toList();
      jobTypeName = match.isNotEmpty ? match[0].Name : '';
    }

    // Job Status
    int statusId = s.statusId;
    String jobStatusName = s.jobStatusName;
    if ((m['JStatus'] ?? 0) != 0) {
      statusId = m['JStatus'];
      final match = objfun.JobAllStatusList
          .where((i) => i.Status == statusId)
          .toList();
      jobStatusName = match.isNotEmpty ? match[0].StatusName : '';
    }

    // Seal employees
    int sealEmpId1 = 0, sealEmpId2 = 0, sealEmpId3 = 0;
    String sealEmpName1 = '', sealEmpName2 = '', sealEmpName3 = '';
    int breakEmpId1 = 0, breakEmpId2 = 0, breakEmpId3 = 0;
    String breakEmpName1 = '', breakEmpName2 = '', breakEmpName3 = '';

    _resolveEmp(int refId) => objfun.EmployeeList
        .where((e) => e.Id == refId)
        .toList();

    if ((m['SealbyRefid'] ?? 0) != 0) {
      sealEmpId1 = m['SealbyRefid'];
      final r = _resolveEmp(sealEmpId1);
      sealEmpName1 = r.isNotEmpty ? r[0].AccountName : '';
    }
    if ((m['SealbreakbyRefid'] ?? 0) != 0) {
      breakEmpId1 = m['SealbreakbyRefid'];
      final r = _resolveEmp(breakEmpId1);
      breakEmpName1 = r.isNotEmpty ? r[0].AccountName : '';
    }
    if ((m['SealbyRefid2'] ?? 0) != 0) {
      sealEmpId2 = m['SealbyRefid2'];
      final r = _resolveEmp(sealEmpId2);
      sealEmpName2 = r.isNotEmpty ? r[0].AccountName : '';
    }
    if ((m['SealbreakbyRefid2'] ?? 0) != 0) {
      breakEmpId2 = m['SealbreakbyRefid2'];
      final r = _resolveEmp(breakEmpId2);
      breakEmpName2 = r.isNotEmpty ? r[0].AccountName : '';
    }
    if ((m['SealbyRefid3'] ?? 0) != 0) {
      sealEmpId3 = m['SealbyRefid3'];
      final r = _resolveEmp(sealEmpId3);
      sealEmpName3 = r.isNotEmpty ? r[0].AccountName : '';
    }
    if ((m['SealbreakbyRefid3'] ?? 0) != 0) {
      breakEmpId3 = m['SealbreakbyRefid3'];
      final r = _resolveEmp(breakEmpId3);
      breakEmpName3 = r.isNotEmpty ? r[0].AccountName : '';
    }

    // Boarding officers
    int boardOfficerId1 = 0, boardOfficerId2 = 0;
    String boardingOfficerName1 = '', boardingOfficerName2 = '';
    if ((m['BoardingOfficerRefid'] ?? 0) != 0) {
      boardOfficerId1 = m['BoardingOfficerRefid'];
      final r = _resolveEmp(boardOfficerId1);
      boardingOfficerName1 = r.isNotEmpty ? r[0].AccountName : '';
    }
    if ((m['BoardingOfficer1Refid'] ?? 0) != 0) {
      boardOfficerId2 = m['BoardingOfficer1Refid'];
      final r = _resolveEmp(boardOfficerId2);
      boardingOfficerName2 = r.isNotEmpty ? r[0].AccountName : '';
    }

    // Pick-up address split
    String pickupAddress = '';
    String pickupQuantity = '';
    List<dynamic> pickupAddressList = [];
    List<dynamic> pickupQuantityList = [];

    final rawPickup = m['PickupAddress'] ?? '';
    if (rawPickup.contains('{@}')) {
      pickupAddressList = rawPickup.split('{@}');
      pickupAddress = pickupAddressList[0];
    } else {
      pickupAddress = rawPickup;
    }

    final rawPQty = m['pickupQuantityList'] ?? '';
    if (rawPQty.contains('{@}')) {
      pickupQuantityList = rawPQty.split('{@}');
      pickupQuantity = pickupQuantityList[0];
    } else {
      pickupQuantity = rawPQty;
    }

    // Delivery address split
    String deliveryAddress = '';
    String deliveryQuantity = '';
    List<dynamic> deliveryAddressList = [];
    List<dynamic> deliveryQuantityList = [];

    final rawDelivery = m['DeliveryAddress'] ?? '';
    if (rawDelivery.contains('{@}')) {
      deliveryAddressList = rawDelivery.split('{@}');
      deliveryAddress = deliveryAddressList[0];
    } else {
      deliveryAddress = rawDelivery;
    }

    final rawDQty = m['DeliveryQuantityList'] ?? '';
    if (rawDQty.contains('{@}')) {
      deliveryQuantityList = rawDQty.split('{@}');
      deliveryQuantity = deliveryQuantityList[0];
    } else {
      deliveryQuantity = rawDQty;
    }

    // Build visibility
    final visibility = _buildVisibility(jobTypeName);

    return s.copyWith(
      // IDs
      editId: isEnquiry ? 0 : (m['Id'] ?? 0),
      enquiryId: isEnquiry ? (m['Id'] ?? 0) : 0,
      custId: custId,
      jobTypeId: jobTypeId,
      statusId: statusId,
      lAgentCompanyId: lAgentCompanyId,
      lAgentId: lAgentId,
      oAgentCompanyId: oAgentCompanyId,
      oAgentId: oAgentId,
      originId: m['OriginRefId'] ?? 0,
      destinationId: m['DestinationRefId'] ?? 0,
      sealEmpId1: sealEmpId1,
      sealEmpId2: sealEmpId2,
      sealEmpId3: sealEmpId3,
      breakEmpId1: breakEmpId1,
      breakEmpId2: breakEmpId2,
      breakEmpId3: breakEmpId3,
      boardOfficerId1: boardOfficerId1,
      boardOfficerId2: boardOfficerId2,
      // Names
      custName: custName,
      jobTypeName: jobTypeName,
      jobStatusName: jobStatusName,
      lAgentCompanyName: lAgentCompanyName,
      lAgentName: lAgentName,
      oAgentCompanyName: oAgentCompanyName,
      oAgentName: oAgentName,
      sealEmpName1: sealEmpName1,
      sealEmpName2: sealEmpName2,
      sealEmpName3: sealEmpName3,
      breakEmpName1: breakEmpName1,
      breakEmpName2: breakEmpName2,
      breakEmpName3: breakEmpName3,
      boardingOfficerName1: boardingOfficerName1,
      boardingOfficerName2: boardingOfficerName2,
      // Text fields
      jobNo: isEnquiry
          ? objfun.MaxSaleOrderNum
          : (m['CNumber']?.toString() ?? ''),
      dtpSaleOrderDate: isEnquiry
          ? _today()
          : DateFormat('yyyy-MM-dd').format(
          DateTime.parse(m['SaleDate'].toString())),
      doDescription: m['DODescription'] ?? '',
      truckSize: m['TruckSize']?.toString() ?? '',
      billType: m['BillType'] ?? 'MY',
      coinage: (m['Coinage'] ?? 0).toDouble(),
      taxAmount: (m['TaxAmount'] ?? 0).toDouble(),
      actualAmount: (m['ActualNetAmount'] ?? 0).toDouble(),
      currencyValue: objfun.CustomerCurrencyValue,
      remarks: m['Remarks'] ?? '',
      offVessel: m['Offvesselname'] ?? '',
      loadingVessel: m['Loadingvesselname'] ?? '',
      lPort: m['SPort'] ?? '',
      oPort: m['OPort'] ?? '',
      smk1: m['ForwardingSMKNo'] ?? '',
      smk2: m['ForwardingSMKNo2'] ?? '',
      smk3: m['ForwardingSMKNo3'] ?? '',
      awbNo: m['AWBNo'] ?? '',
      blCopy: m['BLCopy'] ?? '',
      oScn: m['SCN'] ?? '',
      lScn: m['LSCN'] ?? '',
      lVesselType: m['Vessel'] ?? '',
      oVesselType: m['OVessel'] ?? '',
      commodityType: m['Commodity'] ?? '',
      weight: m['TotalWeight']?.toString() ?? '',
      quantity: m['Quantity']?.toString() ?? '',
      originName: m['Origin'] ?? '',
      destinationName: m['Destination'] ?? '',
      ptwNo: m['PTW'] ?? '',
      zbRef1: m['ZbRef'] ?? '',
      zbRef2: m['ZbRef2'] ?? '',
      cargo: m['Cargo'] ?? '',
      enRef1: m['ForwardingEnterRef'] ?? '',
      exRef1: m['ForwardingExitRef'] ?? '',
      enRef2: m['ForwardingEnterRef2'] ?? '',
      exRef2: m['ForwardingExitRef2'] ?? '',
      enRef3: m['ForwardingEnterRef3'] ?? '',
      exRef3: m['ForwardingExitRef3'] ?? '',
      portChargeRef1: m['PortChargesRef'] ?? '',
      portCharges: m['PortCharges']?.toString() ?? '',
      amount1: m['BoardingAmount']?.toString() ?? '',
      amount2: m['BoardingAmount1']?.toString() ?? '',
      forwarding1S1: m['Forwarding1S1'] ?? '',
      forwarding1S2: m['Forwarding1S2'] ?? '',
      forwarding2S1: m['Forwarding2S1'] ?? '',
      forwarding2S2: m['Forwarding2S2'] ?? '',
      forwarding3S1: m['Forwarding3S1'] ?? '',
      forwarding3S2: m['Forwarding3S2'] ?? '',
      warehouseAddress: m['WareHouseAddress'] ?? '',
      pickupAddress: pickupAddress,
      pickupQuantity: pickupQuantity,
      deliveryAddress: deliveryAddress,
      deliveryQuantity: deliveryQuantity,
      pickupAddressList: pickupAddressList,
      pickupQuantityList: pickupQuantityList,
      deliveryAddressList: deliveryAddressList,
      deliveryQuantityList: deliveryQuantityList,
      // Dropdowns (null-safe)
      fw1Dropdown:
      (m['Forwarding'] ?? '').isNotEmpty ? m['Forwarding'] : null,
      fw2Dropdown:
      (m['Forwarding2'] ?? '').isNotEmpty ? m['Forwarding2'] : null,
      fw3Dropdown:
      (m['Forwarding3'] ?? '').isNotEmpty ? m['Forwarding3'] : null,
      zb1Dropdown: (m['Zb'] ?? '').isNotEmpty ? m['Zb'] : null,
      zb2Dropdown: (m['Zb2'] ?? '').isNotEmpty ? m['Zb2'] : null,
      truckSizeDropdown:
      (m['TruckSize']?.toString() ?? '').isNotEmpty
          ? m['TruckSize'].toString()
          : null,
      // Date/time + checkboxes
      chkLETA: m['ETA'] != null,
      dtpLETAdate: _dateStr('ETA') ?? _now(),
      chkFlightTime: m['FlighTime'] != null,
      dtpFlightTimeDate: _dateStr('FlighTime') ?? _now(),
      chkLETB: m['ETB'] != null,
      dtpLETBdate: _dateStr('ETB') ?? _now(),
      chkLETD: m['ETD'] != null,
      dtpLETDdate: _dateStr('ETD') ?? _now(),
      chkOETA: m['OETA'] != null,
      dtpOETAdate: _dateStr('OETA') ?? _now(),
      chkOETB: m['OETB'] != null,
      dtpOETBdate: _dateStr('OETB') ?? _now(),
      chkOETD: m['OETD'] != null,
      dtpOETDdate: _dateStr('OETD') ?? _now(),
      chkFW1: !isEnquiry && m['ForwardingDate'] != null,
      dtpFW1date:
      (!isEnquiry && m['ForwardingDate'] != null)
          ? _dateStr('ForwardingDate')!
          : _now(),
      chkFW2: m['Forwarding2Date'] != null,
      dtpFW2date: _dateStr('Forwarding2Date') ?? _now(),
      chkFW3: m['Forwarding3Date'] != null,
      dtpFW3date: _dateStr('Forwarding3Date') ?? _now(),
      chkPickUp: m['PickupDate'] != null,
      dtpPickUpDate: _dateStr('PickupDate') ?? _now(),
      chkDelivery: m['DeliveryDate'] != null,
      dtpDeliveryDate: _dateStr('DeliveryDate') ?? _now(),
      chkWHEntry: m['WareHouseEnterDate'] != null,
      dtpWHEntryDate: _dateStr('WareHouseEnterDate') ?? _now(),
      chkWHExit: m['WareHouseExitDate'] != null,
      dtpWHExitDate: _dateStr('WareHouseExitDate') ?? _now(),
      // Locks
      disabledBillType: true,
      disabledAmount1: true,
      disabledAmount2: true,
      // Visibility
      visibility: visibility,
      status: SalesOrderStatus.success,
    );
  }

  // ─── Init ──────────────────────────────────────────────────────────────────

  Future<void> _onInitialized(
      SalesOrderInitialized event,
      Emitter<SalesOrderState> emit,
      ) async {
    emit(state.copyWith(status: SalesOrderStatus.loading));

    await OnlineApi.MaxSaleOrderNo(null, state.billType);
    await OnlineApi.selectAddressList();
    await OnlineApi.SelectAgentCompany(null);
    await OnlineApi.SelectEmployee(null, '', 'Operation');

    final permissions = _buildFieldPermissions();

    emit(state.copyWith(
      jobNo: objfun.MaxSaleOrderNum,
      fieldPermission: permissions,
      status: SalesOrderStatus.success,
    ));

    // Load existing order or enquiry
    final chkEnq = objfun.storagenew.getString('EnquiryOpen') ?? 'false';
    if (event.saleMaster != null && event.saleMaster!.isNotEmpty) {
      if (chkEnq == 'true') {
        objfun.storagenew.setString('EnquiryOpen', 'false');
        await _loadEnqData(event, emit);
      } else {
        await _loadData(event, emit);
      }
    } else {
      emit(state.copyWith(status: SalesOrderStatus.success));
    }
  }

  Future<void> _loadData(
      SalesOrderInitialized event,
      Emitter<SalesOrderState> emit,
      ) async {
    if (event.saleDetails != null && event.saleDetails!.isNotEmpty) {
      emit(state.copyWith(productList: event.saleDetails!));
    }

    if (event.saleMaster == null || event.saleMaster!.isEmpty) return;

    final m = event.saleMaster![0] as Map<String, dynamic>;

    await OnlineApi.SelectCustomer(null);
    await OnlineApi.SelectJobType(null);
    await OnlineApi.SelectAllJobStatus(null, m['JobMasterRefId'] ?? 0);
    await OnlineApi.SelectAgentAll(null, m['AgentCompanyRefId'] ?? 0);
    await OnlineApi.loadCustomerCurrency(null, m['CustomerRefId'] ?? 0);

    final newState = _populateFromMaster(state, m, false);
    emit(newState);
  }

  Future<void> _loadEnqData(
      SalesOrderInitialized event,
      Emitter<SalesOrderState> emit,
      ) async {
    if (event.saleMaster == null || event.saleMaster!.isEmpty) return;

    final m = event.saleMaster![0] as Map<String, dynamic>;

    await OnlineApi.MaxSaleOrderNo(null, state.billType);
    await OnlineApi.SelectCustomer(null);
    await OnlineApi.SelectJobType(null);
    if (m['JobMasterRefId'] != null) {
      await OnlineApi.SelectAllJobStatus(null, m['JobMasterRefId']);
    }
    await OnlineApi.loadCustomerCurrency(null, m['CustomerRefId'] ?? 0);

    final newState = _populateFromMaster(
      state.copyWith(productList: []),
      m,
      true,
    );
    emit(newState);
  }

  // ─── Tab ───────────────────────────────────────────────────────────────────

  void _onTabChanged(
      SalesOrderTabChanged event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(currentTabIndex: event.index));
  }

  // ─── Bill Type ─────────────────────────────────────────────────────────────

  void _onBillTypeChanged(
      SalesOrderBillTypeChanged event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(billType: event.value));
  }

  // ─── Customer ──────────────────────────────────────────────────────────────

  void _onCustomerSelected(
      SalesOrderCustomerSelected event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(custId: event.custId, custName: event.custName));
  }

  void _onCustomerCleared(
      SalesOrderCustomerCleared event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(custId: 0, custName: ''));
  }

  // ─── Job Type ──────────────────────────────────────────────────────────────

  Future<void> _onJobTypeSelected(
      SalesOrderJobTypeSelected event,
      Emitter<SalesOrderState> emit,
      ) async {
    emit(state.copyWith(
      jobTypeId: event.jobTypeId,
      jobTypeName: event.jobTypeName,
      status: SalesOrderStatus.loading,
    ));

    await OnlineApi.SelectAllJobStatus(null, event.jobTypeId);
    await OnlineApi.loadComboS1(null, event.jobTypeId);

    final visibility = _buildVisibility(event.jobTypeName);
    emit(state.copyWith(
      visibility: visibility,
      status: SalesOrderStatus.success,
    ));
  }

  void _onJobTypeCleared(
      SalesOrderJobTypeCleared event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(jobTypeId: 0, jobTypeName: ''));
  }

  // ─── Job Status ────────────────────────────────────────────────────────────

  void _onJobStatusSelected(
      SalesOrderJobStatusSelected event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(
        statusId: event.statusId, jobStatusName: event.statusName));
  }

  // ─── Sale date ─────────────────────────────────────────────────────────────

  void _onDateChanged(
      SalesOrderDateChanged event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(dtpSaleOrderDate: event.date));
  }

  // ─── Truck size ────────────────────────────────────────────────────────────

  void _onTruckSizeChanged(
      SalesOrderTruckSizeChanged event,
      Emitter<SalesOrderState> emit,
      ) {
    if (event.value == null) {
      emit(state.copyWith(clearTruckSize: true));
    } else {
      emit(state.copyWith(truckSizeDropdown: event.value));
    }
  }

  // ─── Forwarding dropdowns ──────────────────────────────────────────────────

  void _onFW1Changed(SalesOrderFW1Changed e, Emitter<SalesOrderState> emit) =>
      e.value == null
          ? emit(state.copyWith(clearFW1: true))
          : emit(state.copyWith(fw1Dropdown: e.value));

  void _onFW2Changed(SalesOrderFW2Changed e, Emitter<SalesOrderState> emit) =>
      e.value == null
          ? emit(state.copyWith(clearFW2: true))
          : emit(state.copyWith(fw2Dropdown: e.value));

  void _onFW3Changed(SalesOrderFW3Changed e, Emitter<SalesOrderState> emit) =>
      e.value == null
          ? emit(state.copyWith(clearFW3: true))
          : emit(state.copyWith(fw3Dropdown: e.value));

  // ─── ZB dropdowns ──────────────────────────────────────────────────────────

  void _onZB1Changed(SalesOrderZB1Changed e, Emitter<SalesOrderState> emit) =>
      e.value == null
          ? emit(state.copyWith(clearZB1: true))
          : emit(state.copyWith(zb1Dropdown: e.value));

  void _onZB2Changed(SalesOrderZB2Changed e, Emitter<SalesOrderState> emit) =>
      e.value == null
          ? emit(state.copyWith(clearZB2: true))
          : emit(state.copyWith(zb2Dropdown: e.value));

  // ─── Date/time toggle + change ─────────────────────────────────────────────

  void _onDateTimeToggled(
      SalesOrderDateTimeToggled event,
      Emitter<SalesOrderState> emit,
      ) {
    switch (event.field) {
      case 'LETA':
        emit(state.copyWith(chkLETA: event.value));
        break;
      case 'FlightTime':
        emit(state.copyWith(chkFlightTime: event.value));
        break;
      case 'LETB':
        emit(state.copyWith(chkLETB: event.value));
        break;
      case 'LETD':
        emit(state.copyWith(chkLETD: event.value));
        break;
      case 'OETA':
        emit(state.copyWith(chkOETA: event.value));
        break;
      case 'OETB':
        emit(state.copyWith(chkOETB: event.value));
        break;
      case 'OETD':
        emit(state.copyWith(chkOETD: event.value));
        break;
      case 'PickUp':
        emit(state.copyWith(chkPickUp: event.value));
        break;
      case 'Delivery':
        emit(state.copyWith(chkDelivery: event.value));
        break;
      case 'WHEntry':
        emit(state.copyWith(chkWHEntry: event.value));
        break;
      case 'WHExit':
        emit(state.copyWith(chkWHExit: event.value));
        break;
      case 'FW1':
        emit(state.copyWith(chkFW1: event.value));
        break;
      case 'FW2':
        emit(state.copyWith(chkFW2: event.value));
        break;
      case 'FW3':
        emit(state.copyWith(chkFW3: event.value));
        break;
    }
  }

  void _onDateTimeChanged(
      SalesOrderDateTimeChanged event,
      Emitter<SalesOrderState> emit,
      ) {
    switch (event.field) {
      case 'LETA':
        emit(state.copyWith(dtpLETAdate: event.dateTime));
        break;
      case 'FlightTime':
        emit(state.copyWith(dtpFlightTimeDate: event.dateTime));
        break;
      case 'LETB':
        emit(state.copyWith(dtpLETBdate: event.dateTime));
        break;
      case 'LETD':
        emit(state.copyWith(dtpLETDdate: event.dateTime));
        break;
      case 'OETA':
        emit(state.copyWith(dtpOETAdate: event.dateTime));
        break;
      case 'OETB':
        emit(state.copyWith(dtpOETBdate: event.dateTime));
        break;
      case 'OETD':
        emit(state.copyWith(dtpOETDdate: event.dateTime));
        break;
      case 'PickUp':
        emit(state.copyWith(dtpPickUpDate: event.dateTime));
        break;
      case 'Delivery':
        emit(state.copyWith(dtpDeliveryDate: event.dateTime));
        break;
      case 'WHEntry':
        emit(state.copyWith(dtpWHEntryDate: event.dateTime));
        break;
      case 'WHExit':
        emit(state.copyWith(dtpWHExitDate: event.dateTime));
        break;
      case 'FW1':
        emit(state.copyWith(dtpFW1date: event.dateTime));
        break;
      case 'FW2':
        emit(state.copyWith(dtpFW2date: event.dateTime));
        break;
      case 'FW3':
        emit(state.copyWith(dtpFW3date: event.dateTime));
        break;
    }
  }

  // ─── Origin / Destination ──────────────────────────────────────────────────

  void _onOriginSelected(
      SalesOrderOriginSelected event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(originId: event.id, originName: event.name));
  }

  void _onDestinationSelected(
      SalesOrderDestinationSelected event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(destinationId: event.id, destinationName: event.name));
  }

  // ─── Agents ────────────────────────────────────────────────────────────────

  void _onLAgentCompanySelected(
      SalesOrderLAgentCompanySelected event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(
        lAgentCompanyId: event.id, lAgentCompanyName: event.name));
  }

  void _onLAgentSelected(
      SalesOrderLAgentSelected event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(lAgentId: event.id, lAgentName: event.name));
  }

  void _onOAgentCompanySelected(
      SalesOrderOAgentCompanySelected event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(
        oAgentCompanyId: event.id, oAgentCompanyName: event.name));
  }

  void _onOAgentSelected(
      SalesOrderOAgentSelected event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(oAgentId: event.id, oAgentName: event.name));
  }

  // ─── Seal employees ────────────────────────────────────────────────────────

  void _onSealEmpSelected(
      SalesOrderSealEmpSelected event,
      Emitter<SalesOrderState> emit,
      ) {
    switch (event.slot) {
      case 1:
        emit(state.copyWith(sealEmpId1: event.id, sealEmpName1: event.name));
        break;
      case 2:
        emit(state.copyWith(sealEmpId2: event.id, sealEmpName2: event.name));
        break;
      case 3:
        emit(state.copyWith(sealEmpId3: event.id, sealEmpName3: event.name));
        break;
    }
  }

  void _onSealEmpCleared(
      SalesOrderSealEmpCleared event,
      Emitter<SalesOrderState> emit,
      ) {
    switch (event.slot) {
      case 1:
        emit(state.copyWith(sealEmpId1: 0, sealEmpName1: ''));
        break;
      case 2:
        emit(state.copyWith(sealEmpId2: 0, sealEmpName2: ''));
        break;
      case 3:
        emit(state.copyWith(sealEmpId3: 0, sealEmpName3: ''));
        break;
    }
  }

  void _onBreakSealEmpSelected(
      SalesOrderBreakSealEmpSelected event,
      Emitter<SalesOrderState> emit,
      ) {
    switch (event.slot) {
      case 1:
        emit(state.copyWith(
            breakEmpId1: event.id, breakEmpName1: event.name));
        break;
      case 2:
        emit(state.copyWith(
            breakEmpId2: event.id, breakEmpName2: event.name));
        break;
      case 3:
        emit(state.copyWith(
            breakEmpId3: event.id, breakEmpName3: event.name));
        break;
    }
  }

  void _onBreakSealEmpCleared(
      SalesOrderBreakSealEmpCleared event,
      Emitter<SalesOrderState> emit,
      ) {
    switch (event.slot) {
      case 1:
        emit(state.copyWith(breakEmpId1: 0, breakEmpName1: ''));
        break;
      case 2:
        emit(state.copyWith(breakEmpId2: 0, breakEmpName2: ''));
        break;
      case 3:
        emit(state.copyWith(breakEmpId3: 0, breakEmpName3: ''));
        break;
    }
  }

  // ─── Boarding officers ─────────────────────────────────────────────────────

  void _onBoardingOfficerSelected(
      SalesOrderBoardingOfficerSelected event,
      Emitter<SalesOrderState> emit,
      ) {
    if (event.slot == 1) {
      emit(state.copyWith(
          boardOfficerId1: event.id, boardingOfficerName1: event.name));
    } else {
      emit(state.copyWith(
          boardOfficerId2: event.id, boardingOfficerName2: event.name));
    }
  }

  void _onBoardingOfficerCleared(
      SalesOrderBoardingOfficerCleared event,
      Emitter<SalesOrderState> emit,
      ) {
    if (event.slot == 1) {
      emit(state.copyWith(boardOfficerId1: 0, boardingOfficerName1: ''));
    } else {
      emit(state.copyWith(boardOfficerId2: 0, boardingOfficerName2: ''));
    }
  }

  // ─── Autocomplete S1 ───────────────────────────────────────────────────────

  void _onAutoCompleteS1Changed(
      SalesOrderAutoCompleteS1Changed event,
      Emitter<SalesOrderState> emit,
      ) {
    if (event.query.isEmpty) {
      emit(state.copyWith(showOverlay: false, overlaySuggestions: []));
      return;
    }

    final q = event.query;
    List<dynamic> preds = [];

    try {
      final keyMap = {
        1: ['Forwarding1S1', 0],
        2: ['Forwarding1S2', 1],
        3: ['Forwarding2S1', 2],
        4: ['Forwarding2S2', 3],
        5: ['Forwarding3S1', 4],
        6: ['Forwarding3S2', 5],
      };

      final entry = keyMap[event.type]!;
      final key = entry[0] as String;
      final idx = entry[1] as int;

      final source = objfun.ComboS1List[idx];
      if (source is List) {
        preds = source
            .where((e) =>
        e[key]?.toString().contains(q) ?? false)
            .toList();
      }
    } catch (_) {}

    emit(state.copyWith(
      showOverlay: preds.isNotEmpty,
      overlaySuggestions: preds,
      overlayType: event.type,
    ));
  }

  void _onAutoCompleteS1Selected(
      SalesOrderAutoCompleteS1Selected event,
      Emitter<SalesOrderState> emit,
      ) {
    switch (event.type) {
      case 1:
        emit(state.copyWith(
            forwarding1S1: event.value, showOverlay: false,
            overlaySuggestions: []));
        break;
      case 2:
        emit(state.copyWith(
            forwarding1S2: event.value, showOverlay: false,
            overlaySuggestions: []));
        break;
      case 3:
        emit(state.copyWith(
            forwarding2S1: event.value, showOverlay: false,
            overlaySuggestions: []));
        break;
      case 4:
        emit(state.copyWith(
            forwarding2S2: event.value, showOverlay: false,
            overlaySuggestions: []));
        break;
      case 5:
        emit(state.copyWith(
            forwarding3S1: event.value, showOverlay: false,
            overlaySuggestions: []));
        break;
      case 6:
        emit(state.copyWith(
            forwarding3S2: event.value, showOverlay: false,
            overlaySuggestions: []));
        break;
    }
  }

  void _onOverlayCleared(
      SalesOrderOverlayCleared event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(showOverlay: false, overlaySuggestions: []));
  }

  // ─── Product ───────────────────────────────────────────────────────────────

  void _onProductAdded(
      SalesOrderProductAdded event,
      Emitter<SalesOrderState> emit,
      ) {
    final list = List<SaleEditDetailModel>.from(state.productList);
    if (event.updateIndex != null) {
      list[event.updateIndex!] = event.product;
    } else {
      list.add(event.product);
    }

    final calc = _recalculate(list, state.currencyValue);
    emit(state.copyWith(
      productList: calc.productList,
      totalAmount: calc.totalAmount,
      taxAmount: calc.taxAmount,
      coinage: calc.coinage,
      actualAmount: calc.actualAmount,
      clearProductUpdateIndex: true,
    ));
  }

  void _onProductRemoved(
      SalesOrderProductRemoved event,
      Emitter<SalesOrderState> emit,
      ) {
    final list = List<SaleEditDetailModel>.from(state.productList)
      ..removeAt(event.index);
    final calc = _recalculate(list, state.currencyValue);
    emit(state.copyWith(
      productList: calc.productList,
      totalAmount: calc.totalAmount,
      taxAmount: calc.taxAmount,
      coinage: calc.coinage,
      actualAmount: calc.actualAmount,
    ));
  }

  void _onProductCalculation(
      SalesOrderProductCalculationRequested event,
      Emitter<SalesOrderState> emit,
      ) {
    final netAmount = event.qty * event.saleRate;
    double gstAmount = 0;
    double amount = 0;

    if (event.gst != 0) {
      gstAmount = (netAmount * event.gst) / 100;
      amount = netAmount + gstAmount;
    } else {
      amount =
          (netAmount * (10 * 2)).round() / (10 * 2); // 2 decimal places
    }

    final actualAmount = event.currencyValue != 0
        ? double.parse(
        (event.currencyValue * amount).toStringAsFixed(2))
        : double.parse(amount.toStringAsFixed(2));

    emit(state.copyWith(
      productCalc: ProductCalcResult(
        gstAmount: double.parse(gstAmount.toStringAsFixed(2)),
        amount: double.parse(amount.toStringAsFixed(2)),
        actualAmount: actualAmount,
      ),
    ));
  }

  // ─── Currency value ────────────────────────────────────────────────────────

  void _onCurrencyValueChanged(
      SalesOrderCurrencyValueChanged event,
      Emitter<SalesOrderState> emit,
      ) {
    final calc = _recalculate(
        List<SaleEditDetailModel>.from(state.productList), event.value);
    emit(state.copyWith(
      currencyValue: event.value,
      productList: calc.productList,
      totalAmount: calc.totalAmount,
      taxAmount: calc.taxAmount,
      coinage: calc.coinage,
      actualAmount: calc.actualAmount,
    ));
  }

  // ─── Address lists ─────────────────────────────────────────────────────────

  void _onPickupAddressListUpdated(
      SalesOrderPickupAddressListUpdated event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(
      pickupAddressList: event.list,
      pickupAddress: event.displayText,
    ));
  }

  void _onDeliveryAddressListUpdated(
      SalesOrderDeliveryAddressListUpdated event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(
      deliveryAddressList: event.list,
      deliveryAddress: event.displayText,
    ));
  }

  // ─── Visibility refresh ────────────────────────────────────────────────────

  void _onVisibilityRefreshed(
      SalesOrderVisibilityRefreshed event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(
        visibility: _buildVisibility(state.jobTypeName)));
  }

  // ─── Field permissions ─────────────────────────────────────────────────────

  void _onFieldPermissionsApplied(
      SalesOrderFieldPermissionsApplied event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(state.copyWith(fieldPermission: _buildFieldPermissions()));
  }

  // ─── Save ──────────────────────────────────────────────────────────────────

  Future<void> _onSaveRequested(
      SalesOrderSaveRequested event,
      Emitter<SalesOrderState> emit,
      ) async {
    // Validation
    if (state.custName.isEmpty) {
      emit(state.copyWith(
          status: SalesOrderStatus.failure,
          errorMessage: 'Enter Customer Name'));
      return;
    }
    if (state.jobTypeName.isEmpty) {
      emit(state.copyWith(
          status: SalesOrderStatus.failure,
          errorMessage: 'Enter Job Type'));
      return;
    }
    if (state.productList.isEmpty) {
      emit(state.copyWith(
          status: SalesOrderStatus.failure,
          errorMessage: 'Add Product Details'));
      return;
    }

    emit(state.copyWith(
        status: SalesOrderStatus.loading, clearError: true));

    // Map truck size display → API value
    final truckSizeMap = {
      '1 Tonner': 'OneTon',
      '3 Tonner': 'ThreeTon',
      '5 Tonner': 'FiveTon',
      '10 Tonner': 'TenTon',
      '40 FT Truck': 'FourtyFeet',
    };
    final truckSizeSelected =
        truckSizeMap[state.truckSizeDropdown] ?? '';

    // Pull live text-field values from the event.fields map
    // (UI passes them in since they live in TextEditingControllers)
    String _f(String key) => event.fields[key] ?? '';

    final master = [
      {
        'Id': state.editId,
        'CompanyRefId': objfun.Comid,
        'UserRefId': null,
        'EmployeeRefId':
        objfun.EmpRefId == 0 ? null : objfun.EmpRefId,
        'AgentCompanyRefId':
        state.lAgentCompanyId == 0 ? null : state.lAgentCompanyId,
        'AgentMasterRefId':
        state.lAgentId == 0 ? null : state.lAgentId,
        'OAgentCompanyRefId':
        state.oAgentCompanyId == 0 ? null : state.oAgentCompanyId,
        'OAgentMasterRefId':
        state.oAgentId == 0 ? null : state.oAgentId,
        'CustomerRefId': state.custId,
        'JobMasterRefId': state.jobTypeId,
        'SaleDate':
        DateTime.parse(state.dtpSaleOrderDate).toIso8601String(),
        'SaleType': '',
        'CNumberDisplay': 0,
        'CNumber': 0,
        'Coinage': state.coinage,
        'GrossAmount': state.totalAmount,
        'TaxAmount': state.taxAmount,
        'DiscountAmount': 0,
        'Remarks': _f('remarks'),
        'PlusAmount': 0,
        'MinusAmount': 0,
        'DODescription': _f('doDescription'),
        'Amount': state.totalAmount,
        'Offvesselname': _f('offVessel'),
        'Loadingvesselname': _f('loadingVessel'),
        'BillType': state.billType,
        'SPort': _f('lPort'),
        'OPort': _f('oPort'),
        'Vessel': _f('lVesselType'),
        'OVessel': _f('oVesselType'),
        'Commodity': _f('commodityType'),
        'Cargo': _f('cargo'),
        'ETA': state.chkLETA
            ? DateTime.parse(state.dtpLETAdate).toIso8601String()
            : null,
        'FlighTime': state.chkFlightTime
            ? DateTime.parse(state.dtpFlightTimeDate).toIso8601String()
            : null,
        'ETB': state.chkLETB
            ? DateTime.parse(state.dtpLETBdate).toIso8601String()
            : null,
        'ETD': state.chkLETD
            ? DateTime.parse(state.dtpLETDdate).toIso8601String()
            : null,
        'OETA': state.chkOETA
            ? DateTime.parse(state.dtpOETAdate).toIso8601String()
            : null,
        'OETB': state.chkOETB
            ? DateTime.parse(state.dtpOETBdate).toIso8601String()
            : null,
        'OETD': state.chkOETD
            ? DateTime.parse(state.dtpOETDdate).toIso8601String()
            : null,
        'DOCNo': null,
        'InvoiceNo': null,
        'TruckRefid': null,
        'DriverRefid': null,
        'AWBNo': _f('awbNo'),
        'BLCopy': _f('blCopy'),
        'Quantity': _f('quantity'),
        'TotalWeight': _f('weight'),
        'TruckSize': _f('truckSize'),
        'JStatus': state.statusId == 0 ? null : state.statusId,
        'OStatus': 0,
        'ForkliftbyRefid': null,
        'SealbyRefid': state.sealEmpId1,
        'SealbreakbyRefid': state.breakEmpId1,
        'SealbyRefid2': state.sealEmpId2,
        'SealbreakbyRefid2': state.breakEmpId2,
        'SealbyRefid3': state.sealEmpId3,
        'SealbreakbyRefid3': state.breakEmpId3,
        'BoardingOfficerRefid': state.boardOfficerId1,
        'BoardingOfficer1Refid': state.boardOfficerId2,
        'BoardingAmount': _f('amount1'),
        'BoardingAmount1': _f('amount1'),
        'ForwardingEnterRef': _f('enRef1'),
        'ForwardingExitRef': _f('exRef1'),
        'ForwardingEnterRef2': _f('enRef2'),
        'ForwardingExitRef2': _f('exRef2'),
        'ForwardingEnterRef3': _f('enRef3'),
        'ForwardingExitRef3': _f('exRef3'),
        'ForwardingSMKNo': _f('smk1'),
        'ForwardingSMKNo2': _f('smk2'),
        'ForwardingSMKNo3': _f('smk3'),
        'PortChargesRef': _f('portChargeRef1'),
        'PortCharges': _f('portCharges'),
        'SealAmount': 0,
        'BreakSealAmount': 0,
        'BoatCPop': 0,
        'ForwardingCPop': 0,
        'PermitCPop': 0,
        'LiveCPop': 0,
        'MMHECPop': 0,
        'AFpoCPop': 0,
        'PPFpoCPop': 0,
        'SFWpoCPop': 0,
        'BoatCPop1': 0,
        'PFPPCPop1': 0,
        'SFEWpoCPop': 0,
        'OriginRefId': state.originId,
        'DestinationRefId': state.destinationId,
        'SealAmount2': 0,
        'BreakSealAmount2': 0,
        'SealAmount3': 0,
        'BreakSealAmount3': 0,
        'PickupDate': state.chkPickUp
            ? DateTime.parse(state.dtpPickUpDate).toIso8601String()
            : null,
        'DeliveryDate': state.chkDelivery
            ? DateTime.parse(state.dtpDeliveryDate).toIso8601String()
            : null,
        'WareHouseEnterDate': state.chkWHEntry
            ? DateTime.parse(state.dtpWHEntryDate).toIso8601String()
            : null,
        'WareHouseExitDate': state.chkWHExit
            ? DateTime.parse(state.dtpWHExitDate).toIso8601String()
            : null,
        'WareHouseAddress': _f('warehouseAddress'),
        'PickupAddress': state.pickupAddressList.length <= 1
            ? _f('pickupAddress')
            : state.pickupAddressList.map((e) => e.toString()).join('{@}'),
        'pickupQuantitylist': state.pickupQuantityList.length <= 1
            ? _f('pickupQuantity')
            : state.pickupQuantityList
            .map((e) => e.toString())
            .join('{@}'),
        'DeliveryAddress': state.deliveryAddressList.length <= 1
            ? _f('deliveryAddress')
            : state.deliveryAddressList
            .map((e) => e.toString())
            .join('{@}'),
        'DeliveryQuantitylist': state.deliveryQuantityList.length <= 1
            ? _f('deliveryQuantity')
            : state.deliveryQuantityList
            .map((e) => e.toString())
            .join('{@}'),
        'Forwarding': state.fw1Dropdown,
        'Forwarding2': state.fw2Dropdown,
        'Forwarding3': state.fw3Dropdown,
        'trucksize2': truckSizeSelected,
        'Origin': _f('originName'),
        'Destination': _f('destinationName'),
        'SCN': _f('oScn'),
        'LSCN': _f('lScn'),
        'Zb': state.zb1Dropdown,
        'PTW': _f('ptwNo'),
        'Zb2': state.zb2Dropdown,
        'ZbRef': _f('zbRef1'),
        'ZbRef2': _f('zbRef2'),
        'Forwarding1S1': _f('forwarding1S1'),
        'Forwarding1S2': _f('forwarding1S2'),
        'Forwarding2S1': _f('forwarding2S1'),
        'Forwarding2S2': _f('forwarding2S2'),
        'Forwarding3S1': _f('forwarding3S1'),
        'Forwarding3S2': _f('forwarding3S2'),
        'CurrencyValue': state.currencyValue,
        'ActualNetAmount': state.actualAmount,
        'ForwardingDate': state.chkFW1
            ? DateTime.parse(state.dtpFW1date).toIso8601String()
            : null,
        'Forwarding2Date': state.chkFW2
            ? DateTime.parse(state.dtpFW2date).toIso8601String()
            : null,
        'Forwarding3Date': state.chkFW3
            ? DateTime.parse(state.dtpFW3date).toIso8601String()
            : null,
        'SaleDetails': state.productList,
      }
    ];

    try {
      final result = await objfun.apiAllinoneSelectArray(
        '${objfun.apiInsertSalesOrder}?Comid=${objfun.Comid}',
        master,
        {'Content-Type': 'application/json; charset=UTF-8'},
        null,
      );

      if (result != '') {
        final value = ResponseViewModel.fromJson(result);
        if (value.IsSuccess == true) {
          // Confirm enquiry if opened from one
          if (state.enquiryId != 0) {
            await objfun.apiAllinoneSelectArray(
              '${objfun.apiUpdateEnquiryMaster}${state.enquiryId}'
                  '&Comid=${objfun.Comid}&StatusName=CONFIRMED',
              null,
              {'Content-Type': 'application/json; charset=UTF-8'},
              null,
            );
          }
          emit(state.copyWith(
            status: SalesOrderStatus.success,
            successMessage: 'Created Successfully',
          ));
          add(const SalesOrderClearRequested());
        } else {
          emit(state.copyWith(
            status: SalesOrderStatus.failure,
            errorMessage: value.Message,
          ));
        }
      }
    } catch (e) {
      emit(state.copyWith(
        status: SalesOrderStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // ─── Clear ─────────────────────────────────────────────────────────────────

  void _onClearRequested(
      SalesOrderClearRequested event,
      Emitter<SalesOrderState> emit,
      ) {
    emit(SalesOrderState.initial().copyWith(
      status: SalesOrderStatus.success,
      fieldPermission: state.fieldPermission,
    ));
  }
}

// ─── Private calc result ──────────────────────────────────────────────────────

class _CalcResult {
  final List<SaleEditDetailModel> productList;
  final double totalAmount;
  final double taxAmount;
  final double coinage;
  final double actualAmount;

  const _CalcResult({
    required this.productList,
    required this.totalAmount,
    required this.taxAmount,
    required this.coinage,
    required this.actualAmount,
  });
}