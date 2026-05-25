import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/app_preferences.dart';

import '../data/sale_order_details_repository.dart';
import 'saleorderdetails_event.dart';
import 'saleorderdetails_state.dart';

class SaleOrderDetailsBloc extends Bloc<SaleOrderDetailsEvent, SaleOrderDetailsState> {
  final SaleOrderDetailsRepository repository;

  // Local caching to replace objfun globals
  List<dynamic> _agentCompanyList = [];
  List<dynamic> _agentAllList = [];
  List<dynamic> _customerList = [];
  List<dynamic> _jobTypeList = [];
  List<dynamic> _jobAllStatusList = [];
  List<dynamic> _jobTypeDetailsList = [];
  List<dynamic> _employeeList = [];

  SaleOrderDetailsBloc({required this.repository}) : super(SaleOrderDetailsState(
    dtpSaleOrderDate: _todayIso(),
    dtpLEta: _nowIso(),
    dtpLEtb: _nowIso(),
    dtpLEtd: _nowIso(),
    dtpOEta: _nowIso(),
    dtpOEtb: _nowIso(),
    dtpOEtd: _nowIso(),
    dtpPickUpDate: _nowIso(),
    dtpDeliveryDate: _nowIso(),
    dtpWhEntryDate: _nowIso(),
    dtpWhExitDate: _nowIso(),
    userName: AppPreferences.getUsername(),
  )) {
    on<SaleOrderStartupEvent>(_onStartup);
    on<SaleOrderBillTypeChangedEvent>(_onBillTypeChanged);
    on<SaleOrderLoadMasterEvent>(_onLoadMaster);
    on<SaleOrderSelectPickUpAddressEvent>(_onSelectPickUpAddress);
    on<SaleOrderDeletePickUpAddressEvent>(_onDeletePickUpAddress);
    on<SaleOrderSelectDeliveryAddressEvent>(_onSelectDeliveryAddress);
    on<SaleOrderDeleteDeliveryAddressEvent>(_onDeleteDeliveryAddress);
    on<SaleOrderToggleFW1Event>(_onToggleFW1);
    on<SaleOrderToggleFW2Event>(_onToggleFW2);
    on<SaleOrderToggleFW3Event>(_onToggleFW3);
    on<SaleOrderTabChangedEvent>(_onTabChanged);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static String _nowIso() => DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
  static String _todayIso() => DateFormat("yyyy-MM-dd").format(DateTime.now());

  SaleOrderVisibility _visibilityFromJobTypeDetails() {
    SaleOrderVisibility v = const SaleOrderVisibility.allHidden();

    for (final item in _jobTypeDetailsList) {
      final desc = item['Description'] as String? ?? '';
      switch (desc) {
        case 'OFF VESSEL NAME': v = v.copyWith(offVessel: true); break;
        case 'LOAD VESSEL NAME': v = v.copyWith(loadingVessel: true); break;
        case 'L ETA': v = v.copyWith(lEta: true); break;
        case 'L ETB': v = v.copyWith(lEtb: true); break;
        case 'L ETD': v = v.copyWith(lEtd: true); break;
        case 'AWB NO': v = v.copyWith(awbNo: true); break;
        case 'BL COPY': v = v.copyWith(blCopy: true); break;
        case 'FORKLIFT': v = v.copyWith(forklift: true); break;
        case 'SEAL BY': v = v.copyWith(sealBy: true); break;
        case 'BREAK SEAL BY': v = v.copyWith(breakSealBy: true); break;
        case 'FORWARDING': v = v.copyWith(forwarding: true); break;
        case 'ORIGIN': v = v.copyWith(origin: true); break;
        case 'DESTINATION': v = v.copyWith(destination: true); break;
        case 'ZB': v = v.copyWith(zb: true); break;
        case 'O ETA': v = v.copyWith(oEta: true); break;
        case 'O ETB': v = v.copyWith(oEtb: true); break;
        case 'O ETD': v = v.copyWith(oEtd: true); break;
        case 'O AGENT': v = v.copyWith(oAgentName: true); break;
        case 'O AGENT COMPANY': v = v.copyWith(oShippingAgent: true); break;
        case 'O SCN': v = v.copyWith(oScn: true); break;
        case 'L SCN': v = v.copyWith(lScn: true); break;
        case 'L AGENT COMPANY': v = v.copyWith(lShippingAgent: true); break;
        case 'L AGENT': v = v.copyWith(lAgentName: true); break;
        case 'L VESSEL TYPE': v = v.copyWith(lVesselType: true); break;
        case 'O VESSEL TYPE': v = v.copyWith(oVesselType: true); break;
        case 'O PORT': v = v.copyWith(oPort: true); break;
        case 'L PORT': v = v.copyWith(lPort: true); break;
      }
    }
    return v;
  }

  // ── Startup ────────────────────────────────────────────────────────────────
  Future<void> _onStartup(SaleOrderStartupEvent event, Emitter<SaleOrderDetailsState> emit) async {
    emit(state.copyWith(status: SaleOrderStatus.loading));
    try {
      final initData = await repository.fetchInitialData(event.billType);

      _agentCompanyList = initData['agentCompanies'];
      _employeeList = initData['employees'];

      // Addresses logic could be stored here if needed for pickup/delivery dropdowns

      emit(state.copyWith(
        status: SaleOrderStatus.ready,
        jobNo: initData['maxSaleOrderNum'],
      ));
    } catch (e) {
      emit(state.copyWith(status: SaleOrderStatus.error, errorMessage: e.toString()));
    }
  }

  // ── Bill type changed ──────────────────────────────────────────────────────
  Future<void> _onBillTypeChanged(SaleOrderBillTypeChangedEvent event, Emitter<SaleOrderDetailsState> emit) async {
    try {
      final maxNum = await repository.fetchMaxOrderNo(event.billType);
      emit(state.copyWith(billType: event.billType, jobNo: maxNum));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  // ── Load master (edit mode) ────────────────────────────────────────────────
  Future<void> _onLoadMaster(SaleOrderLoadMasterEvent event, Emitter<SaleOrderDetailsState> emit) async {
    emit(state.copyWith(status: SaleOrderStatus.loading));
    try {
      final m = event.saleMaster[0];

      // Load dependent combo lists via Repository
      final masterData = await repository.fetchMasterDependencies(m["JobMasterRefId"] ?? 0, m["AgentCompanyRefId"] ?? 0);
      _customerList = masterData['customers'];
      _jobTypeList = masterData['jobTypes'];
      _jobAllStatusList = masterData['jobStatuses'];

      // If your API returns JobTypeDetails inside jobStatuses, assign it here.
      // Otherwise, you may need a separate repo call. For now, we assume it's part of the jobStatusResponse or already handled.
      _jobTypeDetailsList = _jobAllStatusList;
      _agentAllList = masterData['agents'];

      // ── Resolve foreign-key display names from LOCAL lists ────────────────
      String custName = '';
      int custId = m["CustomerRefId"] ?? 0;
      if (custId != 0) {
        final found = _customerList.where((c) => c['Id'] == custId).toList();
        if (found.isNotEmpty) custName = found[0]['AccountName'] ?? '';
      }

      String jobTypeName = '';
      int jobTypeId = m["JobMasterRefId"] ?? 0;
      if (jobTypeId != 0) {
        final found = _jobTypeList.where((j) => j['Id'] == jobTypeId).toList();
        if (found.isNotEmpty) jobTypeName = found[0]['Name'] ?? '';
      }

      String jobStatusName = '';
      int statusId = m["JStatus"] ?? 0;
      if (statusId != 0) {
        final found = _jobAllStatusList.where((s) => s['Status'] == statusId).toList();
        if (found.isNotEmpty) jobStatusName = found[0]['StatusName'] ?? '';
      }

      String oAgentCompanyName = '';
      int oAgentCompanyId = m["OAgentCompanyRefId"] ?? 0;
      if (oAgentCompanyId != 0) {
        final found = _agentCompanyList.where((a) => a['Id'] == oAgentCompanyId).toList();
        if (found.isNotEmpty) oAgentCompanyName = found[0]['Name'] ?? '';
      }

      String oAgentName = '';
      int oAgentId = m["OAgentMasterRefId"] ?? 0;
      if (oAgentId != 0) {
        final found = _agentAllList.where((a) => a['Id'] == oAgentId).toList();
        if (found.isNotEmpty) oAgentName = found[0]['AgentName'] ?? '';
      }

      String lAgentCompanyName = '';
      int lAgentCompanyId = m["AgentCompanyRefId"] ?? 0;
      if (lAgentCompanyId != 0) {
        final found = _agentCompanyList.where((a) => a['Id'] == lAgentCompanyId).toList();
        if (found.isNotEmpty) lAgentCompanyName = found[0]['Name'] ?? '';
      }

      String lAgentName = '';
      int lAgentId = m["AgentMasterRefId"] ?? 0;
      if (lAgentId != 0) {
        final found = _agentAllList.where((a) => a['Id'] == lAgentId).toList();
        if (found.isNotEmpty) lAgentName = found[0]['AgentName'] ?? '';
      }

      // ── Seal / Break employees ─────────────────────────────────────────────
      String _empName(dynamic refId) {
        if ((refId ?? 0) == 0) return '';
        final found = _employeeList.where((e) => e['Id'] == refId).toList();
        return found.isNotEmpty ? found[0]['AccountName'] ?? '' : '';
      }

      // ── Dates ─────────────────────────────────────────────────────────────
      String _parseDate(dynamic raw, {bool dateOnly = false}) {
        if (raw == null) return dateOnly ? _todayIso() : _nowIso();
        final dt = DateTime.parse(raw.toString());
        return dateOnly ? DateFormat("yyyy-MM-dd").format(dt) : DateFormat("yyyy-MM-dd HH:mm:ss").format(dt);
      }

      // ── Pickup / Delivery address lists ───────────────────────────────────
      List<dynamic> pickUpList = [];
      String pickUpAddr = '';
      final rawPickup = m["PickupAddress"] ?? '';
      if (rawPickup.toString().contains('{@}')) {
        pickUpList = rawPickup.toString().split('{@}');
        pickUpAddr = pickUpList.isNotEmpty ? pickUpList[0] : '';
      } else { pickUpAddr = rawPickup.toString(); }

      List<dynamic> deliveryList = [];
      String deliveryAddr = '';
      final rawDelivery = m["DeliveryAddress"] ?? '';
      if (rawDelivery.toString().contains('{@}')) {
        deliveryList = rawDelivery.toString().split('{@}');
        deliveryAddr = deliveryList.isNotEmpty ? deliveryList[0] : '';
      } else { deliveryAddr = rawDelivery.toString(); }

      // ── Visibility from JobTypeDetails ────────────────────────────────────
      final visibility = _visibilityFromJobTypeDetails();

      emit(state.copyWith(
        status: SaleOrderStatus.ready,
        editId: m["Id"] ?? 0,
        billType: m["BillType"] ?? 'MY',
        jobNo: m["CNumber"]?.toString() ?? '',
        dtpSaleOrderDate: _parseDate(m["SaleDate"], dateOnly: true),
        customerName: custName, custId: custId,
        jobType: jobTypeName, jobTypeId: jobTypeId,
        jobStatus: jobStatusName, statusId: statusId,
        remarks: m["Remarks"] ?? '',
        doDescription: m["DODescription"] ?? '',
        truckSize: m["TruckSize"]?.toString() ?? '',
        coinage: (m["Coinage"] ?? 0.0).toDouble(),
        taxAmount: (m["TaxAmount"] ?? 0.0).toDouble(),
        offVessel: m["Offvesselname"] ?? '',
        loadingVessel: m["Loadingvesselname"] ?? '',
        lPort: m["SPort"] ?? '', oPort: m["OPort"] ?? '',
        smk1: m["ForwardingSMKNo"] ?? '', smk2: m["ForwardingSMKNo2"] ?? '', smk3: m["ForwardingSMKNo3"] ?? '',
        checkLEta: m["ETA"] != null, dtpLEta: _parseDate(m["ETA"]),
        checkLEtb: m["ETB"] != null, dtpLEtb: _parseDate(m["ETB"]),
        checkLEtd: m["ETD"] != null, dtpLEtd: _parseDate(m["ETD"]),
        checkOEta: m["OETA"] != null, dtpOEta: _parseDate(m["OETA"]),
        checkOEtb: m["OETB"] != null, dtpOEtb: _parseDate(m["OETB"]),
        checkOEtd: m["OETD"] != null, dtpOEtd: _parseDate(m["OETD"]),
        awbNo: m["AWBNo"] ?? '', blCopy: m["BLCopy"] ?? '',
        oScn: m["SCN"] ?? '', lVesselType: m["Vessel"] ?? '',
        oVesselType: m["OVessel"] ?? '', commodityType: m["Commodity"] ?? '',
        weight: m["TotalWeight"]?.toString() ?? '', quantity: m["Quantity"]?.toString() ?? '',
        oAgentCompany: oAgentCompanyName, oAgentCompanyId: oAgentCompanyId,
        oAgentName: oAgentName, oAgentId: oAgentId,
        lAgentCompany: lAgentCompanyName, lAgentCompanyId: lAgentCompanyId,
        lAgentName: lAgentName, lAgentId: lAgentId,
        sealByEmp1: _empName(m["SealbyRefid"]), sealEmpId1: m["SealbyRefid"] ?? 0,
        breakByEmp1: _empName(m["SealbreakbyRefid"]), breakEmpId1: m["SealbreakbyRefid"] ?? 0,
        sealByEmp2: _empName(m["SealbyRefid2"]), sealEmpId2: m["SealbyRefid2"] ?? 0,
        breakByEmp2: _empName(m["SealbreakbyRefid2"]), breakEmpId2: m["SealbreakbyRefid2"] ?? 0,
        sealByEmp3: _empName(m["SealbyRefid3"]), sealEmpId3: m["SealbyRefid3"] ?? 0,
        breakByEmp3: _empName(m["SealbreakbyRefid3"]), breakEmpId3: m["SealbreakbyRefid3"] ?? 0,
        checkPickUp: m["PickupDate"] != null, dtpPickUpDate: _parseDate(m["PickupDate"]),
        checkDelivery: m["DeliveryDate"] != null, dtpDeliveryDate: _parseDate(m["DeliveryDate"]),
        checkWhEntry: m["WareHouseEnterDate"] != null, dtpWhEntryDate: _parseDate(m["WareHouseEnterDate"]),
        checkWhExit: m["WareHouseExitDate"] != null, dtpWhExitDate: _parseDate(m["WareHouseExitDate"]),
        pickUpAddress: pickUpAddr, pickUpAddressList: pickUpList,
        deliveryAddress: deliveryAddr, deliveryAddressList: deliveryList,
        warehouseAddress: m["WareHouseAddress"] ?? '',
        dropdownFW1: (m["Forwarding"] ?? '') != '' ? m["Forwarding"] as String : null,
        dropdownFW2: (m["Forwarding2"] ?? '') != '' ? m["Forwarding2"] as String : null,
        dropdownFW3: (m["Forwarding3"] ?? '') != '' ? m["Forwarding3"] as String : null,
        origin: m["Origin"] ?? '', destination: m["Destination"] ?? '',
        dropdownZB1: (m["Zb"] ?? '') != '' ? m["Zb"] as String : null,
        dropdownZB2: (m["Zb2"] ?? '') != '' ? m["Zb2"] as String : null,
        ptwNo: m["PTW"] ?? '',
        boardingOfficer1: _empName(m["BoardingOfficerRefid"]), boardOfficerId1: m["BoardingOfficerRefid"] ?? 0,
        boardingOfficer2: _empName(m["BoardingOfficer1Refid"]), boardOfficerId2: m["BoardingOfficer1Refid"] ?? 0,
        amount1: m["BoardingAmount"]?.toString() ?? '', amount2: m["BoardingAmount1"]?.toString() ?? '',
        enRef1: m["ForwardingEnterRef"] ?? '', exRef1: m["ForwardingExitRef"] ?? '',
        enRef2: m["ForwardingEnterRef2"] ?? '', exRef2: m["ForwardingExitRef2"] ?? '',
        enRef3: m["ForwardingEnterRef3"] ?? '', exRef3: m["ForwardingExitRef3"] ?? '',
        portChargeRef1: m["PortChargesRef"] ?? '', portCharges: m["PortCharges"]?.toString() ?? '',
        zbRef1: m["ZbRef"] ?? '', zbRef2: m["ZbRef2"] ?? '', lScn: m["LSCN"] ?? '', cargo: m["Cargo"] ?? '',
        disabledBillType: true, disabledAmount1: true, disabledAmount2: true,
        visibility: visibility, productViewList: event.saleDetails,
      ));
    } catch (e) {
      emit(state.copyWith(status: SaleOrderStatus.error, errorMessage: e.toString()));
    }
  }

  // ── Address events ─────────────────────────────────────────────────────────
  void _onSelectPickUpAddress(SaleOrderSelectPickUpAddressEvent event, Emitter<SaleOrderDetailsState> emit) =>
      emit(state.copyWith(pickUpAddress: event.address));

  void _onDeletePickUpAddress(SaleOrderDeletePickUpAddressEvent event, Emitter<SaleOrderDetailsState> emit) {
    final updated = List<dynamic>.from(state.pickUpAddressList)..removeAt(event.index);
    emit(state.copyWith(pickUpAddressList: updated));
  }

  void _onSelectDeliveryAddress(SaleOrderSelectDeliveryAddressEvent event, Emitter<SaleOrderDetailsState> emit) =>
      emit(state.copyWith(deliveryAddress: event.address));

  void _onDeleteDeliveryAddress(SaleOrderDeleteDeliveryAddressEvent event, Emitter<SaleOrderDetailsState> emit) {
    final updated = List<dynamic>.from(state.deliveryAddressList)..removeAt(event.index);
    emit(state.copyWith(deliveryAddressList: updated));
  }

  // ── Forwarding toggle ──────────────────────────────────────────────────────
  void _onToggleFW1(SaleOrderToggleFW1Event _, Emitter<SaleOrderDetailsState> emit) =>
      emit(state.copyWith(visibleFW1: !state.visibleFW1));

  void _onToggleFW2(SaleOrderToggleFW2Event _, Emitter<SaleOrderDetailsState> emit) =>
      emit(state.copyWith(visibleFW2: !state.visibleFW2));

  void _onToggleFW3(SaleOrderToggleFW3Event _, Emitter<SaleOrderDetailsState> emit) =>
      emit(state.copyWith(visibleFW3: !state.visibleFW3));

  // ── Tab ────────────────────────────────────────────────────────────────────
  void _onTabChanged(SaleOrderTabChangedEvent event, Emitter<SaleOrderDetailsState> emit) {
    emit(state.copyWith(currentTabIndex: event.index));
  }
}