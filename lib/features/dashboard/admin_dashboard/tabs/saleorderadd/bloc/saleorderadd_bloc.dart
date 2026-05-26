import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/sales_order_repository.dart';
import 'saleorderadd_event.dart';
import 'saleorderadd_state.dart';

class SalesOrderBloc extends Bloc<SalesOrderEvent, SalesOrderState> {
  final SalesOrderRepository repository;

  // Local caches — never rely on objfun globals inside the BLoC
  List<dynamic> _jobTypeDetailsList = [];
  List<dynamic> _agentCompanyList = [];
  List<dynamic> _agentAllList = [];
  List<dynamic> _customerList = [];
  List<dynamic> _jobTypeList = [];
  List<dynamic> _jobAllStatusList = [];
  List<dynamic> _employeeList = [];
  List<dynamic> _comboS1List = [];
  double _customerCurrencyValue = 0.0;
  String _maxSaleOrderNum = '';

  SalesOrderBloc({required this.repository}) : super(SalesOrderState.initial()) {
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

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// Recalculates product totals whenever the product list or currency changes.
  _CalcResult _recalculate(
      List<SaleEditDetailModel> list, double currencyValue) {
    double productTotal = 0;
    double taxAmount = 0;

    for (var p in list) {
      p.CurrencyValue = currencyValue;
      productTotal += p.Amount;
      taxAmount += p.TaxAmount;
      p.ActualAmount =
      currencyValue != 0 ? currencyValue * p.Amount : p.Amount;
    }

    final gross = productTotal + taxAmount;
    final roundedAmt = gross.roundToDouble();
    final coinage =
    double.parse((roundedAmt - gross).abs().toStringAsFixed(2));

    return _CalcResult(
      productList: list,
      totalAmount: double.parse(productTotal.toStringAsFixed(2)),
      taxAmount: double.parse(taxAmount.toStringAsFixed(2)),
      coinage: coinage,
      actualAmount: double.parse(
          (productTotal * (currencyValue != 0 ? currencyValue : 1))
              .toStringAsFixed(2)),
    );
  }

  /// Builds the field-visibility model from job-type detail rows.
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

    for (var d in _jobTypeDetailsList) {
      switch (d['Description']) {
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
        case 'O ETA':
          v = v.copyWith(oETA: true);
          break;
        case 'O ETB':
          v = v.copyWith(oETB: true);
          break;
        case 'O ETD':
          v = v.copyWith(oETD: true);
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
        case 'O SHIPPING AGENT':
          v = v.copyWith(oShippingAgent: true);
          break;
        case 'O AGENT NAME':
          v = v.copyWith(oAgentName: true);
          break;
        case 'O SCN':
          v = v.copyWith(oScn: true);
          break;
        case 'L SCN':
          v = v.copyWith(lScn: true);
          break;
        case 'L SHIPPING AGENT':
          v = v.copyWith(lShippingAgent: true);
          break;
        case 'L AGENT NAME':
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
        case 'PRODUCT VIEW':
          v = v.copyWith(productView: true);
          break;
        case 'FW1':
          v = v.copyWith(fw1: true);
          break;
        case 'FW2':
          v = v.copyWith(fw2: true);
          break;
        case 'FW3':
          v = v.copyWith(fw3: true);
          break;
        case 'FLIGHT TIME':
          v = v.copyWith(flightTime: true);
          break;
      }
    }

    if (jobTypeName.toUpperCase() == 'GENARAL CARGO') {
      v = v.copyWith(origin: false, destination: false, gc: true);
    }

    return v;
  }

  /// Builds field-permission map based on employee restrictions.
  Map<String, bool> _buildFieldPermissions() {
    const allFields = [
      'txtCustomer', 'txtJobType', 'txtJobStatus', 'txtRemarks',
      'txtDoDescription', 'ProductViewList', 'txtCommodityType', 'txtOrigin',
      'txtWeight', 'txtQuantity', 'txtTruckSize', 'txtAWBNo', 'txtBLCopy',
      'txtCargo', 'txtPTWNo', 'dtpLETAdate', 'dtpLETBdate', 'dtpLETDdate',
      'txtLAgentCompany', 'txtLAgentName', 'txtLSCN', 'dtpFlightTimedate',
      'txtLoadingVessel', 'txtLPort', 'txtLVesselType', 'cmbBillType',
      'dtpOETAdate', 'dtpOETDdate', 'txtOAgentCompany', 'txtOAgentName',
      'txtOSCN', 'txtOffVessel', 'txtOPort', 'txtOVesselType',
      'dtpPickUpdate', 'dtpDeliverydate', 'dtpWHEntrydate', 'dtpWHExitdate',
      'txtDestination', 'txtPickUpAddress', 'txtPickUpQuantity',
      'txtDeliveryAddress', 'txtDeliveryQuantity', 'txtWarehouseAddress',
      'dtpFW1date', 'txtSmk1', 'txtENRef1', 'txtSealByEmp1',
      'txtBreakByEmp1', 'txtForwarding1S1', 'txtForwarding1S2',
      'dropdownValueFW2', 'dtpFW2date', 'txtENRef2', 'txtExRef2',
      'txtSealByEmp2', 'txtBreakByEmp2', 'txtForwarding2S1',
      'txtForwarding2S2', 'dropdownValueFW3', 'dtpFW3date', 'txtSmk3',
      'txtENRef3', 'txtSealByEmp3', 'txtBreakByEmp3', 'txtForwarding3S2',
      'dropdownValueZB1', 'txtZBRef1', 'dropdownValueZB2', 'txtZBRef2',
      'txtBoardingOfficer1', 'txtBoardingOfficer2', 'txtAmount1', 'txtAmount2',
      'txtPortCharges', 'chkLETA', 'chkOETA', 'chkLETB', 'chkOETB',
      'chkLETD', 'chkOETD', 'chkPickup', 'chkDelivery', 'chkWareHouseEntry',
      'chkWareHouseExit', 'chkFlightTime', 'SAVE', 'VIEW', 'addProduct',
      'dropdownValueFW1', 'checkBoxValueFW2', 'txtSmk2', 'checkBoxValueFW1',
      'checkBoxValueFW3', 'txtExRef1', 'txtExRef3', 'txtBreakByEmp3',
      'txtForwarding3S1', 'dropdownValueZB2',
    ];

    const restrictedIds = [138, 50, 127, 35, 75, 38, 68, 128, 100, 117, 121];
    final empRefId = AppPreferences.getEmpRefId();

    if (!restrictedIds.contains(empRefId)) {
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

  /// Populates state from a master data map (edit or enquiry load).
  SalesOrderState _populateFromMaster(
      SalesOrderState s, Map<String, dynamic> m, bool isEnquiry) {
    String _dateStr(String key) {
      if (m[key] == null) return '';
      try {
        return DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(DateTime.parse(m[key].toString()));
      } catch (_) {
        return '';
      }
    }

    // ── Resolve display names from local caches ──────────────────────────

    int oAgentCompanyId = m['OAgentCompanyRefId'] ?? 0;
    String oAgentCompanyName = '';
    if (oAgentCompanyId != 0) {
      final match =
      _agentCompanyList.where((i) => i['Id'] == oAgentCompanyId).toList();
      oAgentCompanyName = match.isNotEmpty ? match[0]['Name'] ?? '' : '';
    }

    int oAgentId = m['OAgentRefId'] ?? 0;
    String oAgentName = '';
    if (oAgentId != 0) {
      final match =
      _agentAllList.where((i) => i['Id'] == oAgentId).toList();
      oAgentName = match.isNotEmpty ? match[0]['AgentName'] ?? '' : '';
    }

    int lAgentCompanyId = m['AgentCompanyRefId'] ?? 0;
    String lAgentCompanyName = '';
    if (lAgentCompanyId != 0) {
      final match =
      _agentCompanyList.where((i) => i['Id'] == lAgentCompanyId).toList();
      lAgentCompanyName = match.isNotEmpty ? match[0]['Name'] ?? '' : '';
    }

    int lAgentId = m['AgentRefId'] ?? 0;
    String lAgentName = '';
    if (lAgentId != 0) {
      final match =
      _agentAllList.where((i) => i['Id'] == lAgentId).toList();
      lAgentName = match.isNotEmpty ? match[0]['AgentName'] ?? '' : '';
    }

    int custId = m['CustomerRefId'] ?? 0;
    String custName = '';
    if (custId != 0) {
      final match =
      _customerList.where((i) => i['Id'] == custId).toList();
      custName = match.isNotEmpty ? match[0]['AccountName'] ?? '' : '';
    }

    int jobTypeId = m['JobMasterRefId'] ?? 0;
    String jobTypeName = '';
    if (jobTypeId != 0) {
      final match =
      _jobTypeList.where((i) => i['Id'] == jobTypeId).toList();
      jobTypeName = match.isNotEmpty ? match[0]['Name'] ?? '' : '';
    }

    int statusId = m['JStatus'] ?? 0;
    String jobStatusName = '';
    if (statusId != 0) {
      final match =
      _jobAllStatusList.where((i) => i['Status'] == statusId).toList();
      jobStatusName =
      match.isNotEmpty ? match[0]['StatusName'] ?? '' : '';
    }

    // Resolve employee names
    String _empName(int refId) {
      if (refId == 0) return '';
      final match =
      _employeeList.where((e) => e['Id'] == refId).toList();
      return match.isNotEmpty ? match[0]['AccountName'] ?? '' : '';
    }

    final sealEmpId1 = m['SealByEmpRefId1'] ?? 0;
    final sealEmpId2 = m['SealByEmpRefId2'] ?? 0;
    final sealEmpId3 = m['SealByEmpRefId3'] ?? 0;
    final breakEmpId1 = m['BreakSealByEmpRefId1'] ?? 0;
    final breakEmpId2 = m['BreakSealByEmpRefId2'] ?? 0;
    final breakEmpId3 = m['BreakSealByEmpRefId3'] ?? 0;
    final boardOfficerId1 = m['BoardingOfficerEmpRefId1'] ?? 0;
    final boardOfficerId2 = m['BoardingOfficerEmpRefId2'] ?? 0;

    final saleDate = m['SaleDate'] != null
        ? DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(m['SaleDate'].toString()))
        : _today();

    return s.copyWith(
      status: SalesOrderStatus.success,
      editId: isEnquiry ? 0 : (m['Id'] ?? 0),
      enquiryId: isEnquiry ? (m['Id'] ?? 0) : 0,
      custId: custId,
      custName: custName,
      jobTypeId: jobTypeId,
      jobTypeName: jobTypeName,
      statusId: statusId,
      jobStatusName: jobStatusName,
      jobNo: isEnquiry ? _maxSaleOrderNum : (m['CNumber']?.toString() ?? ''),
      dtpSaleOrderDate: isEnquiry ? _today() : saleDate,
      billType: m['BillType']?.toString() ?? s.billType,
      currencyValue: _customerCurrencyValue,
      remarks: m['Remarks']?.toString() ?? '',
      doDescription: m['DODescription']?.toString() ?? '',
      offVessel: m['OffVesselName']?.toString() ?? '',
      loadingVessel: m['LoadingVesselName']?.toString() ?? '',
      lPort: m['LPort']?.toString() ?? '',
      oPort: m['OPort']?.toString() ?? '',
      lVesselType: m['LVesselType']?.toString() ?? '',
      oVesselType: m['OVesselType']?.toString() ?? '',
      commodityType: m['CommodityType']?.toString() ?? '',
      cargo: m['Cargo']?.toString() ?? '',
      awbNo: m['AWBNo']?.toString() ?? '',
      blCopy: m['BLCopy']?.toString() ?? '',
      oScn: m['OSCN']?.toString() ?? '',
      lScn: m['LSCN']?.toString() ?? '',
      weight: m['Weight']?.toString() ?? '',
      quantity: m['Quantity']?.toString() ?? '',
      truckSize: m['TruckSize']?.toString() ?? '',
      truckSizeDropdown: m['TruckSize']?.toString(),
      ptwNo: m['PTWNo']?.toString() ?? '',
      smk1: m['SMKNo1']?.toString() ?? '',
      smk2: m['SMKNo2']?.toString() ?? '',
      smk3: m['SMKNo3']?.toString() ?? '',
      enRef1: m['ENRef1']?.toString() ?? '',
      enRef2: m['ENRef2']?.toString() ?? '',
      enRef3: m['ENRef3']?.toString() ?? '',
      exRef1: m['EXRef1']?.toString() ?? '',
      exRef2: m['EXRef2']?.toString() ?? '',
      exRef3: m['EXRef3']?.toString() ?? '',
      zbRef1: m['ZBRef1']?.toString() ?? '',
      zbRef2: m['ZBRef2']?.toString() ?? '',
      amount1: m['Amount1']?.toString() ?? '',
      amount2: m['Amount2']?.toString() ?? '',
      portChargeRef1: m['PortChargeRef1']?.toString() ?? '',
      portCharges: m['PortCharges']?.toString() ?? '',
      forwarding1S1: m['Forwarding1S1']?.toString() ?? '',
      forwarding1S2: m['Forwarding1S2']?.toString() ?? '',
      forwarding2S1: m['Forwarding2S1']?.toString() ?? '',
      forwarding2S2: m['Forwarding2S2']?.toString() ?? '',
      forwarding3S1: m['Forwarding3S1']?.toString() ?? '',
      forwarding3S2: m['Forwarding3S2']?.toString() ?? '',
      warehouseAddress: m['WarehouseAddress']?.toString() ?? '',
      pickupAddress: m['PickUpAddress']?.toString() ?? '',
      pickupQuantity: m['PickUpQuantity']?.toString() ?? '',
      deliveryAddress: m['DeliveryAddress']?.toString() ?? '',
      deliveryQuantity: m['DeliveryQuantity']?.toString() ?? '',
      originId: m['OriginRefId'] ?? 0,
      originName: m['OriginName']?.toString() ?? '',
      destinationId: m['DestinationRefId'] ?? 0,
      destinationName: m['DestinationName']?.toString() ?? '',
      oAgentCompanyId: oAgentCompanyId,
      oAgentCompanyName: oAgentCompanyName,
      oAgentId: oAgentId,
      oAgentName: oAgentName,
      lAgentCompanyId: lAgentCompanyId,
      lAgentCompanyName: lAgentCompanyName,
      lAgentId: lAgentId,
      lAgentName: lAgentName,
      sealEmpId1: sealEmpId1,
      sealEmpName1: _empName(sealEmpId1),
      sealEmpId2: sealEmpId2,
      sealEmpName2: _empName(sealEmpId2),
      sealEmpId3: sealEmpId3,
      sealEmpName3: _empName(sealEmpId3),
      breakEmpId1: breakEmpId1,
      breakEmpName1: _empName(breakEmpId1),
      breakEmpId2: breakEmpId2,
      breakEmpName2: _empName(breakEmpId2),
      breakEmpId3: breakEmpId3,
      breakEmpName3: _empName(breakEmpId3),
      boardOfficerId1: boardOfficerId1,
      boardingOfficerName1: _empName(boardOfficerId1),
      boardOfficerId2: boardOfficerId2,
      boardingOfficerName2: _empName(boardOfficerId2),
      chkLETA: m['ChkLETA'] == 1 || m['ChkLETA'] == true,
      dtpLETAdate: _dateStr('LETADate'),
      chkLETB: m['ChkLETB'] == 1 || m['ChkLETB'] == true,
      dtpLETBdate: _dateStr('LETBDate'),
      chkLETD: m['ChkLETD'] == 1 || m['ChkLETD'] == true,
      dtpLETDdate: _dateStr('LETDDate'),
      chkOETA: m['ChkOETA'] == 1 || m['ChkOETA'] == true,
      dtpOETAdate: _dateStr('OETADate'),
      chkOETB: m['ChkOETB'] == 1 || m['ChkOETB'] == true,
      dtpOETBdate: _dateStr('OETBDate'),
      chkOETD: m['ChkOETD'] == 1 || m['ChkOETD'] == true,
      dtpOETDdate: _dateStr('OETDDate'),
      chkFlightTime: m['ChkFlightTime'] == 1 || m['ChkFlightTime'] == true,
      dtpFlightTimeDate: _dateStr('FlightTimeDate'),
      chkPickUp: m['ChkPickUp'] == 1 || m['ChkPickUp'] == true,
      dtpPickUpDate: _dateStr('PickUpDate'),
      chkDelivery: m['ChkDelivery'] == 1 || m['ChkDelivery'] == true,
      dtpDeliveryDate: _dateStr('DeliveryDate'),
      chkWHEntry: m['ChkWHEntry'] == 1 || m['ChkWHEntry'] == true,
      dtpWHEntryDate: _dateStr('WHEntryDate'),
      chkWHExit: m['ChkWHExit'] == 1 || m['ChkWHExit'] == true,
      dtpWHExitDate: _dateStr('WHExitDate'),
      chkFW1: m['ChkFW1'] == 1 || m['ChkFW1'] == true,
      dtpFW1date: _dateStr('FW1Date'),
      chkFW2: m['ChkFW2'] == 1 || m['ChkFW2'] == true,
      dtpFW2date: _dateStr('FW2Date'),
      chkFW3: m['ChkFW3'] == 1 || m['ChkFW3'] == true,
      dtpFW3date: _dateStr('FW3Date'),
      fw1Dropdown: m['FW1']?.toString(),
      fw2Dropdown: m['FW2']?.toString(),
      fw3Dropdown: m['FW3']?.toString(),
      zb1Dropdown: m['ZB1']?.toString(),
      zb2Dropdown: m['ZB2']?.toString(),
      visibility: _buildVisibility(jobTypeName),
    );
  }

  // ─── Init ─────────────────────────────────────────────────────────────────

  Future<void> _onInitialized(
      SalesOrderInitialized event, Emitter<SalesOrderState> emit) async {
    emit(state.copyWith(status: SalesOrderStatus.loading));

    try {
      final initData = await repository.fetchInitialData(state.billType);
      _maxSaleOrderNum = initData['maxSaleOrderNum'] as String;
      _agentCompanyList = initData['agentCompanies'] as List<dynamic>;
      _employeeList = initData['employees'] as List<dynamic>;

      final permissions = _buildFieldPermissions();

      emit(state.copyWith(
        jobNo: _maxSaleOrderNum,
        fieldPermission: permissions,
      ));

      final prefs = await SharedPreferences.getInstance();
      final chkEnq = prefs.getString('EnquiryOpen') ?? 'false';

      if (event.saleMaster != null && event.saleMaster!.isNotEmpty) {
        if (chkEnq == 'true') {
          await prefs.setString('EnquiryOpen', 'false');
          await _loadEnqData(event, emit);
        } else {
          await _loadData(event, emit);
        }
      } else {
        emit(state.copyWith(status: SalesOrderStatus.success));
      }
    } catch (e) {
      emit(state.copyWith(
          status: SalesOrderStatus.failure,
          errorMessage: e.toString()));
    }
  }

  Future<void> _loadData(
      SalesOrderInitialized event, Emitter<SalesOrderState> emit) async {
    final m = event.saleMaster![0] as Map<String, dynamic>;

    final masterData = await repository.fetchMasterData(
      m['JobMasterRefId'] ?? 0,
      m['AgentCompanyRefId'] ?? 0,
      m['CustomerRefId'] ?? 0,
    );
    _customerList = masterData['customers'] as List<dynamic>;
    _jobTypeList = masterData['jobTypes'] as List<dynamic>;
    _jobAllStatusList = masterData['jobStatuses'] as List<dynamic>;
    _agentAllList = masterData['agents'] as List<dynamic>;
    _customerCurrencyValue = masterData['currencyValue'] as double;

    // Also fetch job-type details for visibility
    final jobDependencies = await repository
        .fetchJobTypeDependencies(m['JobMasterRefId'] ?? 0);
    _jobTypeDetailsList =
        jobDependencies['jobTypeDetails'] as List<dynamic>? ?? [];
    _comboS1List = jobDependencies['comboS1'] as List<dynamic>;

    SalesOrderState newState = _populateFromMaster(state, m, false);

    if (event.saleDetails != null && event.saleDetails!.isNotEmpty) {
      final calc = _recalculate(
          List<SaleEditDetailModel>.from(event.saleDetails!),
          newState.currencyValue);
      newState = newState.copyWith(
        productList: calc.productList,
        totalAmount: calc.totalAmount,
        taxAmount: calc.taxAmount,
        coinage: calc.coinage,
        actualAmount: calc.actualAmount,
      );
    }

    emit(newState);
  }

  Future<void> _loadEnqData(
      SalesOrderInitialized event, Emitter<SalesOrderState> emit) async {
    final m = event.saleMaster![0] as Map<String, dynamic>;

    final masterData = await repository.fetchMasterData(
      m['JobMasterRefId'] ?? 0,
      0,
      m['CustomerRefId'] ?? 0,
    );
    _customerList = masterData['customers'] as List<dynamic>;
    _jobTypeList = masterData['jobTypes'] as List<dynamic>;
    _jobAllStatusList = masterData['jobStatuses'] as List<dynamic>;
    _customerCurrencyValue = masterData['currencyValue'] as double;

    final jobDependencies = await repository
        .fetchJobTypeDependencies(m['JobMasterRefId'] ?? 0);
    _jobTypeDetailsList =
        jobDependencies['jobTypeDetails'] as List<dynamic>? ?? [];
    _comboS1List = jobDependencies['comboS1'] as List<dynamic>;

    final newState = _populateFromMaster(
        state.copyWith(productList: []), m, true);
    emit(newState);
  }

  // ─── Job Type Selected ────────────────────────────────────────────────────

  Future<void> _onJobTypeSelected(
      SalesOrderJobTypeSelected event, Emitter<SalesOrderState> emit) async {
    emit(state.copyWith(
        jobTypeId: event.jobTypeId,
        jobTypeName: event.jobTypeName,
        status: SalesOrderStatus.loading));

    try {
      final data =
      await repository.fetchJobTypeDependencies(event.jobTypeId);
      _jobAllStatusList = data['jobStatuses'] as List<dynamic>;
      _jobTypeDetailsList =
          data['jobTypeDetails'] as List<dynamic>? ?? [];
      _comboS1List = data['comboS1'] as List<dynamic>;

      emit(state.copyWith(
        jobStatusName: '',
        statusId: 0,
        visibility: _buildVisibility(event.jobTypeName),
        status: SalesOrderStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: SalesOrderStatus.failure,
          errorMessage: e.toString()));
    }
  }

  // ─── Save ─────────────────────────────────────────────────────────────────

  Future<void> _onSaveRequested(
      SalesOrderSaveRequested event, Emitter<SalesOrderState> emit) async {
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

    String _f(String key) => event.fields[key] ?? '';

    final master = [
      {
        'Id': state.editId,
        'CompanyRefId': AppPreferences.getComid(),
        'EmployeeRefId': AppPreferences.getEmpRefId() == 0
            ? null
            : AppPreferences.getEmpRefId(),
        'CustomerRefId': state.custId,
        'JobMasterRefId': state.jobTypeId,
        'JStatus': state.statusId,
        'SaleDate': DateTime.parse(state.dtpSaleOrderDate).toIso8601String(),
        'BillType': state.billType,
        'CNumber': state.jobNo,
        'Remarks': _f('remarks'),
        'DODescription': _f('doDescription'),
        'OffVesselName': _f('offVessel'),
        'LoadingVesselName': _f('loadingVessel'),
        'LPort': _f('lPort'),
        'OPort': _f('oPort'),
        'LVesselType': _f('lVesselType'),
        'OVesselType': _f('oVesselType'),
        'CommodityType': _f('commodityType'),
        'Cargo': _f('cargo'),
        'AWBNo': _f('awbNo'),
        'BLCopy': _f('blCopy'),
        'OSCN': _f('oScn'),
        'LSCN': _f('lScn'),
        'Weight': _f('weight'),
        'Quantity': _f('quantity'),
        'TruckSize': state.truckSizeDropdown ?? _f('truckSize'),
        'PTWNo': _f('ptwNo'),
        'SMKNo1': _f('smk1'),
        'SMKNo2': _f('smk2'),
        'SMKNo3': _f('smk3'),
        'ENRef1': _f('enRef1'),
        'ENRef2': _f('enRef2'),
        'ENRef3': _f('enRef3'),
        'EXRef1': _f('exRef1'),
        'EXRef2': _f('exRef2'),
        'EXRef3': _f('exRef3'),
        'ZBRef1': _f('zbRef1'),
        'ZBRef2': _f('zbRef2'),
        'Amount1': _f('amount1'),
        'Amount2': _f('amount2'),
        'PortChargeRef1': _f('portChargeRef1'),
        'PortCharges': _f('portCharges'),
        'Forwarding1S1': _f('forwarding1S1'),
        'Forwarding1S2': _f('forwarding1S2'),
        'Forwarding2S1': _f('forwarding2S1'),
        'Forwarding2S2': _f('forwarding2S2'),
        'Forwarding3S1': _f('forwarding3S1'),
        'Forwarding3S2': _f('forwarding3S2'),
        'WarehouseAddress': _f('warehouseAddress'),
        'PickUpAddress': _f('pickupAddress'),
        'PickUpQuantity': _f('pickupQuantity'),
        'DeliveryAddress': _f('deliveryAddress'),
        'DeliveryQuantity': _f('deliveryQuantity'),
        'OriginRefId': state.originId,
        'OriginName': _f('originName'),
        'DestinationRefId': state.destinationId,
        'DestinationName': _f('destinationName'),
        'AgentCompanyRefId': state.lAgentCompanyId,
        'AgentRefId': state.lAgentId,
        'OAgentCompanyRefId': state.oAgentCompanyId,
        'OAgentRefId': state.oAgentId,
        'SealByEmpRefId1': state.sealEmpId1,
        'SealByEmpRefId2': state.sealEmpId2,
        'SealByEmpRefId3': state.sealEmpId3,
        'BreakSealByEmpRefId1': state.breakEmpId1,
        'BreakSealByEmpRefId2': state.breakEmpId2,
        'BreakSealByEmpRefId3': state.breakEmpId3,
        'BoardingOfficerEmpRefId1': state.boardOfficerId1,
        'BoardingOfficerEmpRefId2': state.boardOfficerId2,
        'ChkLETA': state.chkLETA ? 1 : 0,
        'LETADate': state.chkLETA ? state.dtpLETAdate : null,
        'ChkLETB': state.chkLETB ? 1 : 0,
        'LETBDate': state.chkLETB ? state.dtpLETBdate : null,
        'ChkLETD': state.chkLETD ? 1 : 0,
        'LETDDate': state.chkLETD ? state.dtpLETDdate : null,
        'ChkOETA': state.chkOETA ? 1 : 0,
        'OETADate': state.chkOETA ? state.dtpOETAdate : null,
        'ChkOETB': state.chkOETB ? 1 : 0,
        'OETBDate': state.chkOETB ? state.dtpOETBdate : null,
        'ChkOETD': state.chkOETD ? 1 : 0,
        'OETDDate': state.chkOETD ? state.dtpOETDdate : null,
        'ChkFlightTime': state.chkFlightTime ? 1 : 0,
        'FlightTimeDate': state.chkFlightTime ? state.dtpFlightTimeDate : null,
        'ChkPickUp': state.chkPickUp ? 1 : 0,
        'PickUpDate': state.chkPickUp ? state.dtpPickUpDate : null,
        'ChkDelivery': state.chkDelivery ? 1 : 0,
        'DeliveryDate': state.chkDelivery ? state.dtpDeliveryDate : null,
        'ChkWHEntry': state.chkWHEntry ? 1 : 0,
        'WHEntryDate': state.chkWHEntry ? state.dtpWHEntryDate : null,
        'ChkWHExit': state.chkWHExit ? 1 : 0,
        'WHExitDate': state.chkWHExit ? state.dtpWHExitDate : null,
        'ChkFW1': state.chkFW1 ? 1 : 0,
        'FW1Date': state.chkFW1 ? state.dtpFW1date : null,
        'ChkFW2': state.chkFW2 ? 1 : 0,
        'FW2Date': state.chkFW2 ? state.dtpFW2date : null,
        'ChkFW3': state.chkFW3 ? 1 : 0,
        'FW3Date': state.chkFW3 ? state.dtpFW3date : null,
        'FW1': state.fw1Dropdown,
        'FW2': state.fw2Dropdown,
        'FW3': state.fw3Dropdown,
        'ZB1': state.zb1Dropdown,
        'ZB2': state.zb2Dropdown,
        'TotalAmount': state.totalAmount,
        'ActualAmount': state.actualAmount,
        'TaxAmount': state.taxAmount,
        'Coinage': state.coinage,
        'CurrencyValue': state.currencyValue,
        'EnquiryId': state.enquiryId,
        'SaleDetails': state.productList
            .map((p) => {
          'Id': p.Id,
          'SDId': p.SDId,
          'SaleOrderMasterRefId': p.SaleOrderMasterRefId,
          'ItemMasterRefId': p.ItemMasterRefId,
          'MRP': p.MRP,
          'PurchaseRate': p.PurchaseRate,
          'ItemQty': p.ItemQty,
          'DiscPer': p.DiscPer,
          'DiscAmount': p.DiscAmount,
          'LandingCost': p.LandingCost,
          'TaxPercent': p.TaxPercent,
          'TaxAmount': p.TaxAmount,
          'SalesRate': p.SalesRate,
          'NetSalesRate': p.NetSalesRate,
          'Amount': p.Amount,
          'ProductCode': p.ProductCode,
          'ProductName': p.ProductName,
          'UOM': p.UOM,
          'ActualAmount': p.ActualAmount,
          'CurrencyValue': p.CurrencyValue,
        })
            .toList(),
      }
    ];

    try {
      final result = await repository.saveSalesOrder(master);

      if (result?.IsSuccess == true) {
        if (state.enquiryId != 0) {
          await repository.confirmEnquiry(state.enquiryId);
        }
        emit(state.copyWith(
            status: SalesOrderStatus.success,
            successMessage: 'Created Successfully'));
        add(const SalesOrderClearRequested());
      } else {
        emit(state.copyWith(
            status: SalesOrderStatus.failure,
            errorMessage: result?.Message ?? 'Save failed'));
      }
    } catch (e) {
      emit(state.copyWith(
          status: SalesOrderStatus.failure,
          errorMessage: e.toString()));
    }
  }

  // ─── Simple state mutations ────────────────────────────────────────────────

  void _onTabChanged(SalesOrderTabChanged event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(currentTabIndex: event.index));

  void _onBillTypeChanged(SalesOrderBillTypeChanged event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(billType: event.value));

  void _onCustomerSelected(SalesOrderCustomerSelected event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(custId: event.custId, custName: event.custName));

  void _onCustomerCleared(SalesOrderCustomerCleared event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(custId: 0, custName: ''));

  void _onJobTypeCleared(SalesOrderJobTypeCleared event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(jobTypeId: 0, jobTypeName: ''));

  void _onJobStatusSelected(SalesOrderJobStatusSelected event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(
          statusId: event.statusId, jobStatusName: event.statusName));

  void _onDateChanged(SalesOrderDateChanged event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(dtpSaleOrderDate: event.date));

  void _onTruckSizeChanged(SalesOrderTruckSizeChanged event,
      Emitter<SalesOrderState> emit) =>
      event.value == null
          ? emit(state.copyWith(clearTruckSize: true))
          : emit(state.copyWith(truckSizeDropdown: event.value));

  void _onFW1Changed(SalesOrderFW1Changed e,
      Emitter<SalesOrderState> emit) =>
      e.value == null
          ? emit(state.copyWith(clearFW1: true))
          : emit(state.copyWith(fw1Dropdown: e.value));

  void _onFW2Changed(SalesOrderFW2Changed e,
      Emitter<SalesOrderState> emit) =>
      e.value == null
          ? emit(state.copyWith(clearFW2: true))
          : emit(state.copyWith(fw2Dropdown: e.value));

  void _onFW3Changed(SalesOrderFW3Changed e,
      Emitter<SalesOrderState> emit) =>
      e.value == null
          ? emit(state.copyWith(clearFW3: true))
          : emit(state.copyWith(fw3Dropdown: e.value));

  void _onZB1Changed(SalesOrderZB1Changed e,
      Emitter<SalesOrderState> emit) =>
      e.value == null
          ? emit(state.copyWith(clearZB1: true))
          : emit(state.copyWith(zb1Dropdown: e.value));

  void _onZB2Changed(SalesOrderZB2Changed e,
      Emitter<SalesOrderState> emit) =>
      e.value == null
          ? emit(state.copyWith(clearZB2: true))
          : emit(state.copyWith(zb2Dropdown: e.value));

  void _onDateTimeToggled(SalesOrderDateTimeToggled event,
      Emitter<SalesOrderState> emit) {
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

  void _onDateTimeChanged(SalesOrderDateTimeChanged event,
      Emitter<SalesOrderState> emit) {
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

  void _onOriginSelected(SalesOrderOriginSelected event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(originId: event.id, originName: event.name));

  void _onDestinationSelected(SalesOrderDestinationSelected event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(
          destinationId: event.id, destinationName: event.name));

  void _onLAgentCompanySelected(SalesOrderLAgentCompanySelected event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(
          lAgentCompanyId: event.id, lAgentCompanyName: event.name));

  void _onLAgentSelected(SalesOrderLAgentSelected event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(lAgentId: event.id, lAgentName: event.name));

  void _onOAgentCompanySelected(SalesOrderOAgentCompanySelected event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(
          oAgentCompanyId: event.id, oAgentCompanyName: event.name));

  void _onOAgentSelected(SalesOrderOAgentSelected event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(oAgentId: event.id, oAgentName: event.name));

  void _onSealEmpSelected(SalesOrderSealEmpSelected event,
      Emitter<SalesOrderState> emit) {
    switch (event.slot) {
      case 1:
        emit(state.copyWith(
            sealEmpId1: event.id, sealEmpName1: event.name));
        break;
      case 2:
        emit(state.copyWith(
            sealEmpId2: event.id, sealEmpName2: event.name));
        break;
      case 3:
        emit(state.copyWith(
            sealEmpId3: event.id, sealEmpName3: event.name));
        break;
    }
  }

  void _onSealEmpCleared(SalesOrderSealEmpCleared event,
      Emitter<SalesOrderState> emit) {
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

  void _onBreakSealEmpSelected(SalesOrderBreakSealEmpSelected event,
      Emitter<SalesOrderState> emit) {
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

  void _onBreakSealEmpCleared(SalesOrderBreakSealEmpCleared event,
      Emitter<SalesOrderState> emit) {
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

  void _onBoardingOfficerSelected(SalesOrderBoardingOfficerSelected event,
      Emitter<SalesOrderState> emit) {
    if (event.slot == 1) {
      emit(state.copyWith(
          boardOfficerId1: event.id, boardingOfficerName1: event.name));
    } else {
      emit(state.copyWith(
          boardOfficerId2: event.id, boardingOfficerName2: event.name));
    }
  }

  void _onBoardingOfficerCleared(SalesOrderBoardingOfficerCleared event,
      Emitter<SalesOrderState> emit) {
    if (event.slot == 1) {
      emit(state.copyWith(boardOfficerId1: 0, boardingOfficerName1: ''));
    } else {
      emit(state.copyWith(boardOfficerId2: 0, boardingOfficerName2: ''));
    }
  }

  void _onAutoCompleteS1Changed(SalesOrderAutoCompleteS1Changed event,
      Emitter<SalesOrderState> emit) {
    if (event.query.isEmpty) {
      emit(state.copyWith(showOverlay: false, overlaySuggestions: []));
      return;
    }

    final keyMap = {
      1: 'Forwarding1S1', 2: 'Forwarding1S2',
      3: 'Forwarding2S1', 4: 'Forwarding2S2',
      5: 'Forwarding3S1', 6: 'Forwarding3S2',
    };

    List<dynamic> preds = [];
    try {
      final key = keyMap[event.type]!;
      final idx = event.type - 1;
      if (_comboS1List.length > idx) {
        final source = _comboS1List[idx];
        if (source is List) {
          preds = source
              .where((e) =>
          e[key]?.toString().toLowerCase().contains(
              event.query.toLowerCase()) ??
              false)
              .toList();
        }
      }
    } catch (_) {}

    emit(state.copyWith(
        showOverlay: preds.isNotEmpty,
        overlaySuggestions: preds,
        overlayType: event.type));
  }

  void _onAutoCompleteS1Selected(SalesOrderAutoCompleteS1Selected event,
      Emitter<SalesOrderState> emit) {
    switch (event.type) {
      case 1:
        emit(state.copyWith(
            forwarding1S1: event.value,
            showOverlay: false,
            overlaySuggestions: []));
        break;
      case 2:
        emit(state.copyWith(
            forwarding1S2: event.value,
            showOverlay: false,
            overlaySuggestions: []));
        break;
      case 3:
        emit(state.copyWith(
            forwarding2S1: event.value,
            showOverlay: false,
            overlaySuggestions: []));
        break;
      case 4:
        emit(state.copyWith(
            forwarding2S2: event.value,
            showOverlay: false,
            overlaySuggestions: []));
        break;
      case 5:
        emit(state.copyWith(
            forwarding3S1: event.value,
            showOverlay: false,
            overlaySuggestions: []));
        break;
      case 6:
        emit(state.copyWith(
            forwarding3S2: event.value,
            showOverlay: false,
            overlaySuggestions: []));
        break;
    }
  }

  void _onOverlayCleared(SalesOrderOverlayCleared event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(showOverlay: false, overlaySuggestions: []));

  void _onProductAdded(SalesOrderProductAdded event,
      Emitter<SalesOrderState> emit) {
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
    ));
  }

  void _onProductRemoved(SalesOrderProductRemoved event,
      Emitter<SalesOrderState> emit) {
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

  void _onProductCalculation(SalesOrderProductCalculationRequested event,
      Emitter<SalesOrderState> emit) {
    final netAmount = event.qty * event.saleRate;
    double gstAmount = 0;
    double amount = 0;

    if (event.gst != 0) {
      gstAmount = (netAmount * event.gst) / 100;
      amount = netAmount + gstAmount;
    } else {
      amount = (netAmount * 100).round() / 100;
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

  void _onCurrencyValueChanged(SalesOrderCurrencyValueChanged event,
      Emitter<SalesOrderState> emit) {
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

  void _onPickupAddressListUpdated(SalesOrderPickupAddressListUpdated event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(
          pickupAddressList: event.list,
          pickupAddress: event.displayText));

  void _onDeliveryAddressListUpdated(
      SalesOrderDeliveryAddressListUpdated event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(
          deliveryAddressList: event.list,
          deliveryAddress: event.displayText));

  void _onVisibilityRefreshed(SalesOrderVisibilityRefreshed event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(
          visibility: _buildVisibility(state.jobTypeName)));

  void _onFieldPermissionsApplied(SalesOrderFieldPermissionsApplied event,
      Emitter<SalesOrderState> emit) =>
      emit(state.copyWith(fieldPermission: _buildFieldPermissions()));

  void _onClearRequested(SalesOrderClearRequested event,
      Emitter<SalesOrderState> emit) =>
      emit(SalesOrderState.initial().copyWith(
        status: SalesOrderStatus.success,
        fieldPermission: state.fieldPermission,
      ));
}

// ─── Internal calc result ─────────────────────────────────────────────────────

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