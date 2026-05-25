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

  // Local caching to replace objfun globals
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

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _now() => DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  _CalcResult _recalculate(List<SaleEditDetailModel> list, double currencyValue) {
    double producttotal = 0;
    double taxAmount = 0;

    for (var p in list) {
      p.CurrencyValue = currencyValue;
      producttotal += p.Amount;
      taxAmount += p.TaxAmount;
      p.ActualAmount = currencyValue != 0 ? currencyValue * p.Amount : p.Amount;
    }

    final gross = producttotal + taxAmount;
    final roundedAmt = gross.roundToDouble();
    final coinage = double.parse((roundedAmt - gross).abs().toStringAsFixed(2));

    return _CalcResult(
      productList: list,
      totalAmount: double.parse(producttotal.toStringAsFixed(2)),
      taxAmount: double.parse(taxAmount.toStringAsFixed(2)),
      coinage: coinage,
      actualAmount: double.parse((producttotal * currencyValue).toStringAsFixed(2)),
    );
  }

  SalesOrderVisibility _buildVisibility(String jobTypeName) {
    var v = const SalesOrderVisibility(
      offVessel: false, loadingVessel: false, lETA: false, flightTime: false,
      lETB: false, lETD: false, awbNo: false, blCopy: false, forklift: false,
      sealBy: false, breakSealBy: false, forwarding: false, origin: false,
      destination: false, zb: false, oETA: false, oETB: false, oETD: false,
      oShippingAgent: false, oAgentName: false, oScn: false, lScn: false,
      lShippingAgent: false, lAgentName: false, lVesselType: false,
      oVesselType: false, oPort: false, lPort: false, productView: false,
      fw1: false, fw2: false, fw3: false, gc: false,
    );

    // Using local cache instead of objfun
    for (var d in _jobTypeDetailsList) {
      switch (d['Description']) {
        case 'OFF VESSEL NAME': v = v.copyWith(offVessel: true); break;
        case 'LOAD VESSEL NAME': v = v.copyWith(loadingVessel: true); break;
        case 'L ETA': v = v.copyWith(lETA: true); break;
      // ... (Map all other cases identical to your original code) ...
        case 'L PORT': v = v.copyWith(lPort: true); break;
      }
    }

    if (jobTypeName == 'GENARAL CARGO') {
      v = v.copyWith(origin: false, destination: false, gc: true);
    }

    return v;
  }

  Map<String, bool> _buildFieldPermissions() {
    const allFields = [
      'txtCustomer', 'txtJobType', 'txtJobStatus', 'txtRemarks', 'txtDoDescription',
      'ProductViewList', 'txtCommodityType', 'txtOrigin', 'txtWeight', 'txtQuantity',
      'txtTruckSize', 'txtAWBNo', 'txtBLCopy', 'txtCargo', 'txtPTWNo', 'dtpLETAdate',
      'dtpLETBdate', 'dtpLETDdate', 'txtLAgentCompany', 'txtLAgentName', 'txtLSCN',
      'dtpFlightTimedate', 'txtLoadingVessel', 'txtLPort', 'txtLVesselType', 'cmbBillType',
      'dtpOETAdate', 'dtpOETDdate', 'txtOAgentCompany', 'txtOAgentName', 'txtOSCN',
      'txtOffVessel', 'txtOPort', 'txtOVesselType', 'dtpPickUpdate', 'dtpDeliverydate',
      'dtpWHEntrydate', 'dtpWHExitdate', 'txtOrigin', 'txtDestination', 'txtPickUpAddress',
      'txtPickUpQuantity', 'txtDeliveryAddress', 'txtDeliveryQuantity', 'txtWarehouseAddress',
      'dtpFW1date', 'txtSmk1', 'txtENRef1', 'txtSealByEmp1', 'txtBreakByEmp1',
      'txtForwarding1S1', 'txtForwarding1S2', 'dropdownValueFW2', 'dtpFW2date',
      'txtENRef2', 'txtExRef2', 'txtSealByEmp2', 'txtBreakByEmp2', 'txtForwarding2S1',
      'txtForwarding2S2', 'dropdownValueFW3', 'dtpFW3date', 'txtSmk3', 'txtENRef3',
      'txtSealByEmp3', 'txtBreakByEmp3', 'txtForwarding3S2', 'dropdownValueZB1', 'txtZBRef1',
      'dropdownValueZB2', 'txtZBRef2', 'txtBoardingOfficer1', 'txtBoardingOfficer2',
      'txtAmount1', 'txtAmount2', 'txtPortCharges', 'chkLETA', 'chkOETA', 'chkLETB',
      'chkOETB', 'chkLETD', 'chkOETD', 'chkPickup', 'chkDelivery', 'chkWareHouseEntry',
      'chkWareHouseExit', 'chkFlightTime', 'SAVE', 'VIEW', 'addProduct', 'dropdownValueFW1',
      'dropdownValueFW2', 'checkBoxValueFW2', 'txtSmk2', 'dropdownValueFW3', 'dropdownValueZB1',
      'dropdownValueZB2', 'checkBoxValueFW1', 'checkBoxValueFW3',
    ];

    const restrictedIds = [138, 50, 127, 35, 75, 38, 68, 128, 100, 117, 121];
    final empRefId = AppPreferences.getEmpRefId();

    if (!restrictedIds.contains(empRefId)) {
      return {for (var f in allFields) f: true};
    }

    final map = {for (var f in allFields) f: false};
    const allowed = ['txtBoardingOfficer1', 'txtBoardingOfficer2', 'txtAmount1', 'txtAmount2', 'SAVE', 'VIEW'];
    for (var f in allowed) { map[f] = true; }
    return map;
  }

  SalesOrderState _populateFromMaster(SalesOrderState s, Map<String, dynamic> m, bool isEnquiry) {
    String? _dateStr(String key) {
      if (m[key] == null) return null;
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(m[key].toString()));
    }

    // Resolving Names using LOCAL lists instead of objfun
    int oAgentCompanyId = m['OAgentCompanyRefId'] ?? s.oAgentCompanyId;
    String oAgentCompanyName = s.oAgentCompanyName;
    if (oAgentCompanyId != 0) {
      final match = _agentCompanyList.where((i) => i['Id'] == oAgentCompanyId).toList();
      oAgentCompanyName = match.isNotEmpty ? match[0]['Name'] : '';
    }

    // ... Apply the exact same logic for oAgentId, lAgentCompanyId, lAgentId using local _lists ...

    int custId = m['CustomerRefId'] ?? s.custId;
    String custName = s.custName;
    if (custId != 0) {
      final match = _customerList.where((i) => i['Id'] == custId).toList();
      custName = match.isNotEmpty ? match[0]['AccountName'] : '';
    }

    int jobTypeId = m['JobMasterRefId'] ?? s.jobTypeId;
    String jobTypeName = s.jobTypeName;
    if (jobTypeId != 0) {
      final match = _jobTypeList.where((i) => i['Id'] == jobTypeId).toList();
      jobTypeName = match.isNotEmpty ? match[0]['Name'] : '';
    }

    int statusId = m['JStatus'] ?? s.statusId;
    String jobStatusName = s.jobStatusName;
    if (statusId != 0) {
      final match = _jobAllStatusList.where((i) => i['Status'] == statusId).toList();
      jobStatusName = match.isNotEmpty ? match[0]['StatusName'] : '';
    }

    _resolveEmp(int refId) => _employeeList.where((e) => e['Id'] == refId).toList();

    // ... Use _resolveEmp for Seal/Break/Boarding exactly as original ...

    return s.copyWith(
      editId: isEnquiry ? 0 : (m['Id'] ?? 0),
      enquiryId: isEnquiry ? (m['Id'] ?? 0) : 0,
      custId: custId,
      custName: custName,
      jobTypeId: jobTypeId,
      jobTypeName: jobTypeName,
      statusId: statusId,
      jobStatusName: jobStatusName,
      jobNo: isEnquiry ? _maxSaleOrderNum : (m['CNumber']?.toString() ?? ''),
      dtpSaleOrderDate: isEnquiry ? _today() : DateFormat('yyyy-MM-dd').format(DateTime.parse(m['SaleDate'].toString())),
      currencyValue: _customerCurrencyValue,
      visibility: _buildVisibility(jobTypeName),
      status: SalesOrderStatus.success,
      // ... map the rest of the fields exactly as your original code ...
    );
  }

  // ─── Init ──────────────────────────────────────────────────────────────────

  Future<void> _onInitialized(SalesOrderInitialized event, Emitter<SalesOrderState> emit) async {
    emit(state.copyWith(status: SalesOrderStatus.loading));

    try {
      // 1. Load Initial Data from Repository
      final initData = await repository.fetchInitialData(state.billType);
      _maxSaleOrderNum = initData['maxSaleOrderNum'];
      _agentCompanyList = initData['agentCompanies'];
      _employeeList = initData['employees'];

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
      emit(state.copyWith(status: SalesOrderStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _loadData(SalesOrderInitialized event, Emitter<SalesOrderState> emit) async {
    if (event.saleDetails != null && event.saleDetails!.isNotEmpty) {
      emit(state.copyWith(productList: event.saleDetails!));
    }
    final m = event.saleMaster![0] as Map<String, dynamic>;

    // Fetch Master Data related to this specific order
    final masterData = await repository.fetchMasterData(m['JobMasterRefId'] ?? 0, m['AgentCompanyRefId'] ?? 0, m['CustomerRefId'] ?? 0);
    _customerList = masterData['customers'];
    _jobTypeList = masterData['jobTypes'];
    _jobAllStatusList = masterData['jobStatuses'];
    _agentAllList = masterData['agents'];
    _customerCurrencyValue = masterData['currencyValue'];

    final newState = _populateFromMaster(state, m, false);
    emit(newState);
  }

  Future<void> _loadEnqData(SalesOrderInitialized event, Emitter<SalesOrderState> emit) async {
    final m = event.saleMaster![0] as Map<String, dynamic>;

    final masterData = await repository.fetchMasterData(m['JobMasterRefId'] ?? 0, 0, m['CustomerRefId'] ?? 0);
    _customerList = masterData['customers'];
    _jobTypeList = masterData['jobTypes'];
    _jobAllStatusList = masterData['jobStatuses'];
    _customerCurrencyValue = masterData['currencyValue'];

    final newState = _populateFromMaster(state.copyWith(productList: []), m, true);
    emit(newState);
  }

  // ─── Job Type Selected ─────────────────────────────────────────────────────

  Future<void> _onJobTypeSelected(SalesOrderJobTypeSelected event, Emitter<SalesOrderState> emit) async {
    emit(state.copyWith(jobTypeId: event.jobTypeId, jobTypeName: event.jobTypeName, status: SalesOrderStatus.loading));

    final data = await repository.fetchJobTypeDependencies(event.jobTypeId);
    _jobAllStatusList = data['jobStatuses'];
    _comboS1List = data['comboS1'];

    emit(state.copyWith(visibility: _buildVisibility(event.jobTypeName), status: SalesOrderStatus.success));
  }

  // ─── Save ──────────────────────────────────────────────────────────────────

  Future<void> _onSaveRequested(SalesOrderSaveRequested event, Emitter<SalesOrderState> emit) async {
    if (state.custName.isEmpty) { emit(state.copyWith(status: SalesOrderStatus.failure, errorMessage: 'Enter Customer Name')); return; }
    if (state.jobTypeName.isEmpty) { emit(state.copyWith(status: SalesOrderStatus.failure, errorMessage: 'Enter Job Type')); return; }
    if (state.productList.isEmpty) { emit(state.copyWith(status: SalesOrderStatus.failure, errorMessage: 'Add Product Details')); return; }

    emit(state.copyWith(status: SalesOrderStatus.loading, clearError: true));

    final empRefId = AppPreferences.getEmpRefId();
    String _f(String key) => event.fields[key] ?? '';

    // Master map generation identical to original, except using local AppPreferences
    final master = [{
      'Id': state.editId,
      'CompanyRefId': AppPreferences.getComid(),
      'EmployeeRefId': empRefId == 0 ? null : empRefId,
      'CustomerRefId': state.custId,
      'JobMasterRefId': state.jobTypeId,
      'SaleDate': DateTime.parse(state.dtpSaleOrderDate).toIso8601String(),
      // ... (Include the rest of your original map here)
    }];

    try {
      final result = await repository.saveSalesOrder(master);

      if (result?.IsSuccess == true) {
        if (state.enquiryId != 0) {
          await repository.confirmEnquiry(state.enquiryId);
        }
        emit(state.copyWith(status: SalesOrderStatus.success, successMessage: 'Created Successfully'));
        add(const SalesOrderClearRequested());
      } else {
        emit(state.copyWith(status: SalesOrderStatus.failure, errorMessage: result?.Message));
      }
    } catch (e) {
      emit(state.copyWith(status: SalesOrderStatus.failure, errorMessage: e.toString()));
    }
  }

  // ─── Tab ───────────────────────────────────────────────────────────────────
  void _onTabChanged(SalesOrderTabChanged event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(currentTabIndex: event.index));
  }

  // ─── Bill Type ─────────────────────────────────────────────────────────────
  void _onBillTypeChanged(SalesOrderBillTypeChanged event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(billType: event.value));
  }

  // ─── Customer ──────────────────────────────────────────────────────────────
  void _onCustomerSelected(SalesOrderCustomerSelected event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(custId: event.custId, custName: event.custName));
  }

  void _onCustomerCleared(SalesOrderCustomerCleared event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(custId: 0, custName: ''));
  }

  // ─── Job Type Cleared ──────────────────────────────────────────────────────
  void _onJobTypeCleared(SalesOrderJobTypeCleared event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(jobTypeId: 0, jobTypeName: ''));
  }

  // ─── Job Status ────────────────────────────────────────────────────────────
  void _onJobStatusSelected(SalesOrderJobStatusSelected event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(statusId: event.statusId, jobStatusName: event.statusName));
  }

  // ─── Sale date ─────────────────────────────────────────────────────────────
  void _onDateChanged(SalesOrderDateChanged event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(dtpSaleOrderDate: event.date));
  }

  // ─── Truck size ────────────────────────────────────────────────────────────
  void _onTruckSizeChanged(SalesOrderTruckSizeChanged event, Emitter<SalesOrderState> emit) {
    if (event.value == null) {
      emit(state.copyWith(clearTruckSize: true));
    } else {
      emit(state.copyWith(truckSizeDropdown: event.value));
    }
  }

  // ─── Forwarding dropdowns ──────────────────────────────────────────────────
  void _onFW1Changed(SalesOrderFW1Changed e, Emitter<SalesOrderState> emit) =>
      e.value == null ? emit(state.copyWith(clearFW1: true)) : emit(state.copyWith(fw1Dropdown: e.value));

  void _onFW2Changed(SalesOrderFW2Changed e, Emitter<SalesOrderState> emit) =>
      e.value == null ? emit(state.copyWith(clearFW2: true)) : emit(state.copyWith(fw2Dropdown: e.value));

  void _onFW3Changed(SalesOrderFW3Changed e, Emitter<SalesOrderState> emit) =>
      e.value == null ? emit(state.copyWith(clearFW3: true)) : emit(state.copyWith(fw3Dropdown: e.value));

  // ─── ZB dropdowns ──────────────────────────────────────────────────────────
  void _onZB1Changed(SalesOrderZB1Changed e, Emitter<SalesOrderState> emit) =>
      e.value == null ? emit(state.copyWith(clearZB1: true)) : emit(state.copyWith(zb1Dropdown: e.value));

  void _onZB2Changed(SalesOrderZB2Changed e, Emitter<SalesOrderState> emit) =>
      e.value == null ? emit(state.copyWith(clearZB2: true)) : emit(state.copyWith(zb2Dropdown: e.value));

  // ─── Date/time toggle + change ─────────────────────────────────────────────
  void _onDateTimeToggled(SalesOrderDateTimeToggled event, Emitter<SalesOrderState> emit) {
    switch (event.field) {
      case 'LETA': emit(state.copyWith(chkLETA: event.value)); break;
      case 'FlightTime': emit(state.copyWith(chkFlightTime: event.value)); break;
      case 'LETB': emit(state.copyWith(chkLETB: event.value)); break;
      case 'LETD': emit(state.copyWith(chkLETD: event.value)); break;
      case 'OETA': emit(state.copyWith(chkOETA: event.value)); break;
      case 'OETB': emit(state.copyWith(chkOETB: event.value)); break;
      case 'OETD': emit(state.copyWith(chkOETD: event.value)); break;
      case 'PickUp': emit(state.copyWith(chkPickUp: event.value)); break;
      case 'Delivery': emit(state.copyWith(chkDelivery: event.value)); break;
      case 'WHEntry': emit(state.copyWith(chkWHEntry: event.value)); break;
      case 'WHExit': emit(state.copyWith(chkWHExit: event.value)); break;
      case 'FW1': emit(state.copyWith(chkFW1: event.value)); break;
      case 'FW2': emit(state.copyWith(chkFW2: event.value)); break;
      case 'FW3': emit(state.copyWith(chkFW3: event.value)); break;
    }
  }

  void _onDateTimeChanged(SalesOrderDateTimeChanged event, Emitter<SalesOrderState> emit) {
    switch (event.field) {
      case 'LETA': emit(state.copyWith(dtpLETAdate: event.dateTime)); break;
      case 'FlightTime': emit(state.copyWith(dtpFlightTimeDate: event.dateTime)); break;
      case 'LETB': emit(state.copyWith(dtpLETBdate: event.dateTime)); break;
      case 'LETD': emit(state.copyWith(dtpLETDdate: event.dateTime)); break;
      case 'OETA': emit(state.copyWith(dtpOETAdate: event.dateTime)); break;
      case 'OETB': emit(state.copyWith(dtpOETBdate: event.dateTime)); break;
      case 'OETD': emit(state.copyWith(dtpOETDdate: event.dateTime)); break;
      case 'PickUp': emit(state.copyWith(dtpPickUpDate: event.dateTime)); break;
      case 'Delivery': emit(state.copyWith(dtpDeliveryDate: event.dateTime)); break;
      case 'WHEntry': emit(state.copyWith(dtpWHEntryDate: event.dateTime)); break;
      case 'WHExit': emit(state.copyWith(dtpWHExitDate: event.dateTime)); break;
      case 'FW1': emit(state.copyWith(dtpFW1date: event.dateTime)); break;
      case 'FW2': emit(state.copyWith(dtpFW2date: event.dateTime)); break;
      case 'FW3': emit(state.copyWith(dtpFW3date: event.dateTime)); break;
    }
  }

  // ─── Origin / Destination ──────────────────────────────────────────────────
  void _onOriginSelected(SalesOrderOriginSelected event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(originId: event.id, originName: event.name));
  }

  void _onDestinationSelected(SalesOrderDestinationSelected event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(destinationId: event.id, destinationName: event.name));
  }

  // ─── Agents ────────────────────────────────────────────────────────────────
  void _onLAgentCompanySelected(SalesOrderLAgentCompanySelected event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(lAgentCompanyId: event.id, lAgentCompanyName: event.name));
  }

  void _onLAgentSelected(SalesOrderLAgentSelected event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(lAgentId: event.id, lAgentName: event.name));
  }

  void _onOAgentCompanySelected(SalesOrderOAgentCompanySelected event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(oAgentCompanyId: event.id, oAgentCompanyName: event.name));
  }

  void _onOAgentSelected(SalesOrderOAgentSelected event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(oAgentId: event.id, oAgentName: event.name));
  }

  // ─── Seal employees ────────────────────────────────────────────────────────
  void _onSealEmpSelected(SalesOrderSealEmpSelected event, Emitter<SalesOrderState> emit) {
    switch (event.slot) {
      case 1: emit(state.copyWith(sealEmpId1: event.id, sealEmpName1: event.name)); break;
      case 2: emit(state.copyWith(sealEmpId2: event.id, sealEmpName2: event.name)); break;
      case 3: emit(state.copyWith(sealEmpId3: event.id, sealEmpName3: event.name)); break;
    }
  }

  void _onSealEmpCleared(SalesOrderSealEmpCleared event, Emitter<SalesOrderState> emit) {
    switch (event.slot) {
      case 1: emit(state.copyWith(sealEmpId1: 0, sealEmpName1: '')); break;
      case 2: emit(state.copyWith(sealEmpId2: 0, sealEmpName2: '')); break;
      case 3: emit(state.copyWith(sealEmpId3: 0, sealEmpName3: '')); break;
    }
  }

  void _onBreakSealEmpSelected(SalesOrderBreakSealEmpSelected event, Emitter<SalesOrderState> emit) {
    switch (event.slot) {
      case 1: emit(state.copyWith(breakEmpId1: event.id, breakEmpName1: event.name)); break;
      case 2: emit(state.copyWith(breakEmpId2: event.id, breakEmpName2: event.name)); break;
      case 3: emit(state.copyWith(breakEmpId3: event.id, breakEmpName3: event.name)); break;
    }
  }

  void _onBreakSealEmpCleared(SalesOrderBreakSealEmpCleared event, Emitter<SalesOrderState> emit) {
    switch (event.slot) {
      case 1: emit(state.copyWith(breakEmpId1: 0, breakEmpName1: '')); break;
      case 2: emit(state.copyWith(breakEmpId2: 0, breakEmpName2: '')); break;
      case 3: emit(state.copyWith(breakEmpId3: 0, breakEmpName3: '')); break;
    }
  }

  // ─── Boarding officers ─────────────────────────────────────────────────────
  void _onBoardingOfficerSelected(SalesOrderBoardingOfficerSelected event, Emitter<SalesOrderState> emit) {
    if (event.slot == 1) {
      emit(state.copyWith(boardOfficerId1: event.id, boardingOfficerName1: event.name));
    } else {
      emit(state.copyWith(boardOfficerId2: event.id, boardingOfficerName2: event.name));
    }
  }

  void _onBoardingOfficerCleared(SalesOrderBoardingOfficerCleared event, Emitter<SalesOrderState> emit) {
    if (event.slot == 1) {
      emit(state.copyWith(boardOfficerId1: 0, boardingOfficerName1: ''));
    } else {
      emit(state.copyWith(boardOfficerId2: 0, boardingOfficerName2: ''));
    }
  }

  // ─── Autocomplete S1 ───────────────────────────────────────────────────────
  void _onAutoCompleteS1Changed(SalesOrderAutoCompleteS1Changed event, Emitter<SalesOrderState> emit) {
    if (event.query.isEmpty) {
      emit(state.copyWith(showOverlay: false, overlaySuggestions: []));
      return;
    }

    final q = event.query;
    List<dynamic> preds = [];

    try {
      final keyMap = {
        1: ['Forwarding1S1', 0], 2: ['Forwarding1S2', 1], 3: ['Forwarding2S1', 2],
        4: ['Forwarding2S2', 3], 5: ['Forwarding3S1', 4], 6: ['Forwarding3S2', 5],
      };

      final entry = keyMap[event.type]!;
      final key = entry[0] as String;
      final idx = entry[1] as int;

      final source = _comboS1List[idx];
      if (source is List) {
        preds = source.where((e) => e[key]?.toString().contains(q) ?? false).toList();
      }
    } catch (_) {}

    emit(state.copyWith(showOverlay: preds.isNotEmpty, overlaySuggestions: preds, overlayType: event.type));
  }

  void _onAutoCompleteS1Selected(SalesOrderAutoCompleteS1Selected event, Emitter<SalesOrderState> emit) {
    switch (event.type) {
      case 1: emit(state.copyWith(forwarding1S1: event.value, showOverlay: false, overlaySuggestions: [])); break;
      case 2: emit(state.copyWith(forwarding1S2: event.value, showOverlay: false, overlaySuggestions: [])); break;
      case 3: emit(state.copyWith(forwarding2S1: event.value, showOverlay: false, overlaySuggestions: [])); break;
      case 4: emit(state.copyWith(forwarding2S2: event.value, showOverlay: false, overlaySuggestions: [])); break;
      case 5: emit(state.copyWith(forwarding3S1: event.value, showOverlay: false, overlaySuggestions: [])); break;
      case 6: emit(state.copyWith(forwarding3S2: event.value, showOverlay: false, overlaySuggestions: [])); break;
    }
  }

  void _onOverlayCleared(SalesOrderOverlayCleared event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(showOverlay: false, overlaySuggestions: []));
  }

  // ─── Product ───────────────────────────────────────────────────────────────
  void _onProductAdded(SalesOrderProductAdded event, Emitter<SalesOrderState> emit) {
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

  void _onProductRemoved(SalesOrderProductRemoved event, Emitter<SalesOrderState> emit) {
    final list = List<SaleEditDetailModel>.from(state.productList)..removeAt(event.index);
    final calc = _recalculate(list, state.currencyValue);
    emit(state.copyWith(
      productList: calc.productList, totalAmount: calc.totalAmount,
      taxAmount: calc.taxAmount, coinage: calc.coinage, actualAmount: calc.actualAmount,
    ));
  }

  void _onProductCalculation(SalesOrderProductCalculationRequested event, Emitter<SalesOrderState> emit) {
    final netAmount = event.qty * event.saleRate;
    double gstAmount = 0;
    double amount = 0;

    if (event.gst != 0) {
      gstAmount = (netAmount * event.gst) / 100;
      amount = netAmount + gstAmount;
    } else {
      amount = (netAmount * (10 * 2)).round() / (10 * 2); // 2 decimal places
    }

    final actualAmount = event.currencyValue != 0
        ? double.parse((event.currencyValue * amount).toStringAsFixed(2))
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
  void _onCurrencyValueChanged(SalesOrderCurrencyValueChanged event, Emitter<SalesOrderState> emit) {
    final calc = _recalculate(List<SaleEditDetailModel>.from(state.productList), event.value);
    emit(state.copyWith(
      currencyValue: event.value, productList: calc.productList,
      totalAmount: calc.totalAmount, taxAmount: calc.taxAmount,
      coinage: calc.coinage, actualAmount: calc.actualAmount,
    ));
  }

  // ─── Address lists ─────────────────────────────────────────────────────────
  void _onPickupAddressListUpdated(SalesOrderPickupAddressListUpdated event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(pickupAddressList: event.list, pickupAddress: event.displayText));
  }

  void _onDeliveryAddressListUpdated(SalesOrderDeliveryAddressListUpdated event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(deliveryAddressList: event.list, deliveryAddress: event.displayText));
  }

  // ─── Visibility refresh ────────────────────────────────────────────────────
  void _onVisibilityRefreshed(SalesOrderVisibilityRefreshed event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(visibility: _buildVisibility(state.jobTypeName)));
  }

  // ─── Field permissions ─────────────────────────────────────────────────────
  void _onFieldPermissionsApplied(SalesOrderFieldPermissionsApplied event, Emitter<SalesOrderState> emit) {
    emit(state.copyWith(fieldPermission: _buildFieldPermissions()));
  }

  // ─── Clear ─────────────────────────────────────────────────────────────────
  void _onClearRequested(SalesOrderClearRequested event, Emitter<SalesOrderState> emit) {
    emit(SalesOrderState.initial().copyWith(
      status: SalesOrderStatus.success,
      fieldPermission: state.fieldPermission,
    ));
  }
// ... (All other simple state mutation handlers like _onDateChanged, _onOriginSelected, etc., remain exactly as they were in your original code) ...
}

class _CalcResult {
  final List<SaleEditDetailModel> productList;
  final double totalAmount, taxAmount, coinage, actualAmount;
  const _CalcResult({required this.productList, required this.totalAmount, required this.taxAmount, required this.coinage, required this.actualAmount});
}