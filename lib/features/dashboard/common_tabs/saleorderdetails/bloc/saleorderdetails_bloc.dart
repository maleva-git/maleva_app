import 'package:maleva/core/models/shared/agent_company_model.dart';
import 'package:maleva/core/models/shared/agent_model.dart';
import 'package:maleva/features/operations/models/job_type_details_model.dart';
import 'package:maleva/features/operations/models/job_all_status_model.dart';
import 'package:maleva/features/operations/models/job_type_model.dart';
import 'package:maleva/core/models/shared/customer_model.dart';
import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_preferences.dart';

import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/models/shared/sale_edit_detail_model.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';

import '../data/sale_order_details_repository.dart';
import 'saleorderdetails_event.dart';
import 'saleorderdetails_state.dart';

/// A read-only view of one sale order, read from the shared Java
/// `/api/sale-orders/edit` (change `sale-order-on-shared-java-api`).
class SaleOrderDetailsBloc extends Bloc<SaleOrderDetailsEvent, SaleOrderDetailsState> {
  final SaleOrderDetailsRepository repository;
  final SaleOrderApi _saleOrders;

  // Local caching to replace objfun globals
  List<AgentCompanyModel> _agentCompanyList = [];
  List<AgentModel> _agentAllList = [];
  List<CustomerModel> _customerList = [];
  List<JobTypeModel> _jobTypeList = [];
  List<JobAllStatusModel> _jobAllStatusList = [];
  List<JobTypeDetailsModel> _jobTypeDetailsList = [];
  List<EmployeeModel> _employeeList = [];

  SaleOrderDetailsBloc({required this.repository, SaleOrderApi? saleOrders})
      : _saleOrders = saleOrders ?? sl<SaleOrderApi>(),
        super(SaleOrderDetailsState(
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
      final desc = item.Description;
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
      _employeeList = List<EmployeeModel>.from(initData['employees'] as List);

      // Addresses logic could be stored here if needed for pickup/delivery dropdowns

      emit(state.copyWith(
        status: SaleOrderStatus.ready,
        jobNo: initData['maxSaleOrderNum'],
      ));
      if (event.saleOrderId > 0 || event.saleOrderNo > 0) {
        final order = await _saleOrders.edit(id: event.saleOrderId, saleOrderNo: event.saleOrderNo);
        await _loadOrder(order, emit);
      }
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

  // ── Load the order (Java `/api/sale-orders/edit`, Java field names) ───────
  Future<void> _loadOrder(SaleOrderEdit order, Emitter<SaleOrderDetailsState> emit) async {
    emit(state.copyWith(status: SaleOrderStatus.loading));
    try {
      final m = order.master;

      // Load dependent combo lists via Repository
      final masterData = await repository.fetchMasterDependencies(m["jobMasterRefId"] ?? 0, m["agentCompanyRefId"] ?? 0);
      _customerList = masterData['customers'];
      _jobTypeList = masterData['jobTypes'];
      _jobAllStatusList = masterData['jobStatuses'];

      _jobTypeDetailsList = masterData['jobTypeDetails'] as List<JobTypeDetailsModel>? ?? [];
      _agentAllList = masterData['agents'];

      // ── Resolve foreign-key display names from LOCAL lists ────────────────
      String custName = '';
      int custId = m["customerRefId"] ?? 0;
      if (custId != 0) {
        final found = _customerList.where((c) => c.Id == custId).toList();
        if (found.isNotEmpty) custName = found[0].AccountName;
      }

      String jobTypeName = '';
      int jobTypeId = m["jobMasterRefId"] ?? 0;
      if (jobTypeId != 0) {
        final found = _jobTypeList.where((j) => j.Id == jobTypeId).toList();
        if (found.isNotEmpty) jobTypeName = found[0].Name;
      }

      String jobStatusName = '';
      int statusId = m["jStatus"] ?? 0;
      if (statusId != 0) {
        final found = _jobAllStatusList.where((s) => s.Status == statusId).toList();
        if (found.isNotEmpty) jobStatusName = found[0].StatusName;
      }

      String oAgentCompanyName = '';
      int oAgentCompanyId = m["oAgentCompanyRefId"] ?? 0;
      if (oAgentCompanyId != 0) {
        final found = _agentCompanyList.where((a) => a.Id == oAgentCompanyId).toList();
        if (found.isNotEmpty) oAgentCompanyName = found[0].Name;
      }

      String oAgentName = '';
      int oAgentId = m["oAgentMasterRefId"] ?? 0;
      if (oAgentId != 0) {
        final found = _agentAllList.where((a) => a.Id == oAgentId).toList();
        if (found.isNotEmpty) oAgentName = found[0].AgentName;
      }

      String lAgentCompanyName = '';
      int lAgentCompanyId = m["agentCompanyRefId"] ?? 0;
      if (lAgentCompanyId != 0) {
        final found = _agentCompanyList.where((a) => a.Id == lAgentCompanyId).toList();
        if (found.isNotEmpty) lAgentCompanyName = found[0].Name;
      }

      String lAgentName = '';
      int lAgentId = m["agentMasterRefId"] ?? 0;
      if (lAgentId != 0) {
        final found = _agentAllList.where((a) => a.Id == lAgentId).toList();
        if (found.isNotEmpty) lAgentName = found[0].AgentName;
      }

      // ── Seal / Break employees ─────────────────────────────────────────────
      String empName(dynamic refId) {
        if ((refId ?? 0) == 0) return '';
        final found = _employeeList.where((e) => e.Id == refId).toList();
        return found.isNotEmpty ? found[0].AccountName : '';
      }

      // ── Dates ─────────────────────────────────────────────────────────────
      String parseDate(dynamic raw, {bool dateOnly = false}) {
        if (raw == null) return dateOnly ? _todayIso() : _nowIso();
        final dt = DateTime.parse(raw.toString());
        return dateOnly ? DateFormat("yyyy-MM-dd").format(dt) : DateFormat("yyyy-MM-dd HH:mm:ss").format(dt);
      }

      // ── Pickup / Delivery address lists ───────────────────────────────────
      List<dynamic> pickUpList = [];
      String pickUpAddr = '';
      final rawPickup = m["pickupAddress"] ?? '';
      if (rawPickup.toString().contains('{@}')) {
        pickUpList = rawPickup.toString().split('{@}');
        pickUpAddr = pickUpList.isNotEmpty ? pickUpList[0] : '';
      } else { pickUpAddr = rawPickup.toString(); }

      List<dynamic> deliveryList = [];
      String deliveryAddr = '';
      final rawDelivery = m["deliveryAddress"] ?? '';
      if (rawDelivery.toString().contains('{@}')) {
        deliveryList = rawDelivery.toString().split('{@}');
        deliveryAddr = deliveryList.isNotEmpty ? deliveryList[0] : '';
      } else { deliveryAddr = rawDelivery.toString(); }

      // ── Visibility from JobTypeDetails ────────────────────────────────────
      final visibility = _visibilityFromJobTypeDetails();

      emit(state.copyWith(
        status: SaleOrderStatus.ready,
        editId: m["id"] ?? 0,
        billType: m["billType"] ?? 'MY',
        jobNo: m["cNumber"]?.toString() ?? '',
        dtpSaleOrderDate: parseDate(m["saleDate"], dateOnly: true),
        customerName: custName, custId: custId,
        jobType: jobTypeName, jobTypeId: jobTypeId,
        jobStatus: jobStatusName, statusId: statusId,
        remarks: m["remarks"] ?? '',
        doDescription: m["doDescription"] ?? '',
        truckSize: m["truckSize"]?.toString() ?? '',
        coinage: (m["coinage"] as num? ?? 0).toDouble(),
        taxAmount: (m["taxAmount"] as num? ?? 0).toDouble(),
        offVessel: m["offvesselname"] ?? '',
        loadingVessel: m["loadingvesselname"] ?? '',
        lPort: m["sPort"] ?? '', oPort: m["oPort"] ?? '',
        smk1: m["forwardingSMKNo"] ?? '', smk2: m["forwardingSMKNo2"] ?? '', smk3: m["forwardingSMKNo3"] ?? '',
        checkLEta: m["eta"] != null, dtpLEta: parseDate(m["eta"]),
        checkLEtb: m["etb"] != null, dtpLEtb: parseDate(m["etb"]),
        checkLEtd: m["etd"] != null, dtpLEtd: parseDate(m["etd"]),
        checkOEta: m["oeta"] != null, dtpOEta: parseDate(m["oeta"]),
        checkOEtb: m["oetb"] != null, dtpOEtb: parseDate(m["oetb"]),
        checkOEtd: m["oetd"] != null, dtpOEtd: parseDate(m["oetd"]),
        awbNo: m["awbNo"] ?? '', blCopy: m["blCopy"] ?? '',
        oScn: m["scn"] ?? '', lVesselType: m["vessel"] ?? '',
        oVesselType: m["oVessel"] ?? '', commodityType: m["commodity"] ?? '',
        weight: m["totalWeight"]?.toString() ?? '', quantity: m["quantity"]?.toString() ?? '',
        oAgentCompany: oAgentCompanyName, oAgentCompanyId: oAgentCompanyId,
        oAgentName: oAgentName, oAgentId: oAgentId,
        lAgentCompany: lAgentCompanyName, lAgentCompanyId: lAgentCompanyId,
        lAgentName: lAgentName, lAgentId: lAgentId,
        sealByEmp1: empName(m["sealbyRefid"]), sealEmpId1: m["sealbyRefid"] ?? 0,
        breakByEmp1: empName(m["sealbreakbyRefid"]), breakEmpId1: m["sealbreakbyRefid"] ?? 0,
        sealByEmp2: empName(m["sealbyRefid2"]), sealEmpId2: m["sealbyRefid2"] ?? 0,
        breakByEmp2: empName(m["sealbreakbyRefid2"]), breakEmpId2: m["sealbreakbyRefid2"] ?? 0,
        sealByEmp3: empName(m["sealbyRefid3"]), sealEmpId3: m["sealbyRefid3"] ?? 0,
        breakByEmp3: empName(m["sealbreakbyRefid3"]), breakEmpId3: m["sealbreakbyRefid3"] ?? 0,
        checkPickUp: m["pickupDate"] != null, dtpPickUpDate: parseDate(m["pickupDate"]),
        checkDelivery: m["deliveryDate"] != null, dtpDeliveryDate: parseDate(m["deliveryDate"]),
        checkWhEntry: m["wareHouseEnterDate"] != null, dtpWhEntryDate: parseDate(m["wareHouseEnterDate"]),
        checkWhExit: m["wareHouseExitDate"] != null, dtpWhExitDate: parseDate(m["wareHouseExitDate"]),
        pickUpAddress: pickUpAddr, pickUpAddressList: pickUpList,
        deliveryAddress: deliveryAddr, deliveryAddressList: deliveryList,
        warehouseAddress: m["wareHouseAddress"] ?? '',
        dropdownFW1: (m["forwarding"] ?? '') != '' ? m["forwarding"] as String : null,
        dropdownFW2: (m["forwarding2"] ?? '') != '' ? m["forwarding2"] as String : null,
        dropdownFW3: (m["forwarding3"] ?? '') != '' ? m["forwarding3"] as String : null,
        origin: m["origin"] ?? '', destination: m["destination"] ?? '',
        dropdownZB1: (m["zb"] ?? '') != '' ? m["zb"] as String : null,
        dropdownZB2: (m["zb2"] ?? '') != '' ? m["zb2"] as String : null,
        ptwNo: m["ptw"] ?? '',
        boardingOfficer1: empName(m["boardingOfficerRefid"]), boardOfficerId1: m["boardingOfficerRefid"] ?? 0,
        boardingOfficer2: empName(m["boardingOfficer1Refid"]), boardOfficerId2: m["boardingOfficer1Refid"] ?? 0,
        amount1: m["boardingAmount"]?.toString() ?? '', amount2: m["boardingAmount1"]?.toString() ?? '',
        enRef1: m["forwardingEnterRef"] ?? '', exRef1: m["forwardingExitRef"] ?? '',
        enRef2: m["forwardingEnterRef2"] ?? '', exRef2: m["forwardingExitRef2"] ?? '',
        enRef3: m["forwardingEnterRef3"] ?? '', exRef3: m["forwardingExitRef3"] ?? '',
        portChargeRef1: m["portChargesRef"] ?? '', portCharges: m["portCharges"]?.toString() ?? '',
        zbRef1: m["zbRef"] ?? '', zbRef2: m["zbRef2"] ?? '', lScn: m["lscn"] ?? '', cargo: m["cargo"] ?? '',
        disabledBillType: true, disabledAmount1: true, disabledAmount2: true,
        visibility: visibility,
        productViewList: [for (final d in order.details) SaleEditDetailModel.fromJava(d)],
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