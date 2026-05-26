import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;

import 'custdashboard_event.dart';
import 'custdashboard_state.dart';


class CustDashboardBloc
    extends Bloc<CustDashboardEvent, CustDashboardState> {
  CustDashboardBloc() : super(CustDashboardState(
    fuelFromDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    fuelToDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  )) {
    on<CustDashboardStarted>(_onStarted);
    on<CustDashboardTabChanged>(_onTabChanged);
    on<CustDashboardEmployeeChanged>(_onEmployeeChanged);

    // Sales
    on<CustDashboardLoadSales>(_onLoadSales);

    // Vessel
    on<CustDashboardLoadVessel>(_onLoadVessel);
    on<CustDashboardPortFilterChanged>(_onPortFilterChanged);
    on<CustDashboardPortAdded>(_onPortAdded);
    on<CustDashboardPortCleared>(_onPortCleared);

    // Transport
    on<CustDashboardLoadPlanning>(_onLoadPlanning);

    // Enquiry
    on<CustDashboardLoadEnquiry>(_onLoadEnquiry);
    on<CustDashboardCancelEnquiry>(_onCancelEnquiry);

    // Fuel
    on<CustDashboardLoadFuel>(_onLoadFuel);
    on<CustDashboardFuelFromDateChanged>(_onFuelFromDateChanged);
    on<CustDashboardFuelToDateChanged>(_onFuelToDateChanged);

    // Payment
    on<CustDashboardLoadPayment>(_onLoadPayment);
    on<CustDashboardPaymentCategoryFilterChanged>(_onPaymentCategoryChanged);
    on<CustDashboardPaymentPaidFilterChanged>(_onPaymentPaidFilterChanged);
    on<CustDashboardPaymentFromDatePicked>(_onPaymentFromDatePicked);
    on<CustDashboardPaymentToDatePicked>(_onPaymentToDatePicked);
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  String get _firstDayOfMonth {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
  }

  String _offsetDate(int days) =>
      DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: days)));

  // ─── Startup ───────────────────────────────────────────────────────────────

  Future<void> _onStarted(
      CustDashboardStarted event, Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(
      status: CustDashboardStatus.loading,
      selectedEmpId: objfun.EmpRefId.toString(),
      empRefId: objfun.EmpRefId,
    ));

    await Future.wait([
      _fetchRulesType(emit),
      _fetchSalesData(emit, empRefId: objfun.EmpRefId),
    ]);

    emit(state.copyWith(status: CustDashboardStatus.success));
  }

  // ─── Tab changed ───────────────────────────────────────────────────────────

  Future<void> _onTabChanged(
      CustDashboardTabChanged event, Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(
      activeTabIndex: event.index,
      status: CustDashboardStatus.loading,
    ));

    switch (event.index) {
      case 0:
        await _fetchSalesData(emit, empRefId: state.empRefId);
        break;
      case 1:
        await _fetchVesselData(emit, dayOffset: 0, portsText: state.vesselPortsText);
        break;
      case 2:
        await _fetchPlanningData(emit, dayOffset: 0);
        break;
      case 3:
        await _fetchEnquiryData(emit);
        break;
      case 4:
        await _fetchFuelData(emit,
            fromDate: state.fuelFromDate, toDate: state.fuelToDate);
        break;
      case 5:
        await _fetchPaymentData(emit);
        break;
    }

    emit(state.copyWith(status: CustDashboardStatus.success));
  }

  // ─── Employee changed ──────────────────────────────────────────────────────

  Future<void> _onEmployeeChanged(
      CustDashboardEmployeeChanged event,
      Emitter<CustDashboardState> emit) async {
    final empId = int.tryParse(event.empId) ?? 0;
    emit(state.copyWith(
      selectedEmpId: event.empId,
      empRefId: empId,
      status: CustDashboardStatus.loading,
    ));
    await _fetchSalesData(emit, empRefId: empId);
    emit(state.copyWith(status: CustDashboardStatus.success));
  }

  // ─── Sales ─────────────────────────────────────────────────────────────────

  Future<void> _onLoadSales(
      CustDashboardLoadSales event, Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(status: CustDashboardStatus.loading));
    await _fetchSalesData(emit, empRefId: state.empRefId);
    emit(state.copyWith(status: CustDashboardStatus.success));
  }

  Future<void> _fetchSalesData(
      Emitter<CustDashboardState> emit, {required int empRefId}) async {
    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    final comid = objfun.storagenew.getInt('Comid') ?? 0;
    final fromDate = _firstDayOfMonth;
    final toDate = _today;

    // ── Without invoice count (from 2024-10-01) ───────────────────────────
    final withoutResult = await _safeApiCall(() => objfun.apiAllinoneSelectArray(
        objfun.SaleInvoiceCountDB,
        {
          'Comid': comid,
          'Fromdate': '2024-10-01',
          'Todate': toDate,
          'Statusid': 0,
          'Employeeid': empRefId,
          'Remarks': 2,
          'Search': '0',
          'completestatusnotshow': false,
          'Invoice': false,
        },
        header,
        null));

    // ── Total count ────────────────────────────────────────────────────────
    final totalResult = await _safeApiCall(() => objfun.apiAllinoneSelectArray(
        objfun.SaleInvoiceCountDB,
        {
          'Comid': comid,
          'Fromdate': fromDate,
          'Todate': toDate,
          'Statusid': 0,
          'Employeeid': empRefId,
          'Remarks': 0,
          'Search': '0',
          'completestatusnotshow': false,
          'Invoice': false,
        },
        header,
        null));

    // ── Billed count ───────────────────────────────────────────────────────
    final billedResult = await _safeApiCall(() => objfun.apiAllinoneSelectArray(
        objfun.SaleInvoiceCountDB,
        {
          'Comid': comid,
          'Fromdate': fromDate,
          'Todate': toDate,
          'Statusid': 0,
          'Employeeid': empRefId,
          'Remarks': 1,
          'Search': '0',
          'completestatusnotshow': false,
          'Invoice': false,
        },
        header,
        null));

    // ── Unbilled count ─────────────────────────────────────────────────────
    final unbilledResult =
    await _safeApiCall(() => objfun.apiAllinoneSelectArray(
        objfun.SaleInvoiceCountDB,
        {
          'Comid': comid,
          'Fromdate': fromDate,
          'Todate': toDate,
          'Statusid': 0,
          'Employeeid': empRefId,
          'Remarks': 2,
          'Search': '0',
          'completestatusnotshow': false,
          'Invoice': false,
        },
        header,
        null));

    // ── Sales order status ─────────────────────────────────────────────────
    final salesStatusResult =
    await _safeApiCall(() => objfun.apiAllinoneSelectArray(
        objfun.SelectSalesOrderStatus,
        {'Comid': comid, 'Employeeid': empRefId},
        header,
        null));

    emit(state.copyWith(
      withoutInvoiceCount: (withoutResult is List) ? withoutResult.length : 0,
      totalCount: (totalResult is List) ? totalResult.length : 0,
      totalBilledCount: (billedResult is List) ? billedResult.length : 0,
      totalUnBilledCount: (unbilledResult is List) ? unbilledResult.length : 0,
      salesReport: (salesStatusResult is List) ? salesStatusResult : [],
    ));
  }

  // ─── Rules Type ────────────────────────────────────────────────────────────

  Future<void> _fetchRulesType(Emitter<CustDashboardState> emit) async {
    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    final comid = objfun.storagenew.getInt('Comid') ?? 0;

    final result = await _safeApiCall(() => objfun.apiAllinoneSelectArray(
        objfun.LoadRulesType,
        {'Comid': comid, 'Employeeid': objfun.EmpRefId},
        header,
        null));

    if (result is List && result.isNotEmpty) {
      final rules = result
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();

      emit(state.copyWith(
        rulesTypeEmployee: rules,
        selectedEmpId: objfun.EmpRefId.toString(),
      ));
    }
  }

  // ─── Vessel ────────────────────────────────────────────────────────────────

  Future<void> _onLoadVessel(
      CustDashboardLoadVessel event, Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(
      status: CustDashboardStatus.loading,
      isVesselToday: event.dayOffset == 0,
    ));
    await _fetchVesselData(emit,
        dayOffset: event.dayOffset,
        portsText: event.portFilter.isNotEmpty
            ? event.portFilter
            : state.vesselPortsText);
    emit(state.copyWith(status: CustDashboardStatus.success));
  }

  Future<void> _onPortFilterChanged(
      CustDashboardPortFilterChanged event,
      Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(vesselPortFilter: event.port));
  }

  Future<void> _onPortAdded(
      CustDashboardPortAdded event, Emitter<CustDashboardState> emit) async {
    final existing = state.vesselPortsText;
    final newText = existing.isEmpty
        ? event.port
        : '$existing,${event.port}';
    emit(state.copyWith(
      vesselPortsText: newText,
      vesselPortFilter: '',
      status: CustDashboardStatus.loading,
    ));
    await _fetchVesselData(emit,
        dayOffset: state.isVesselToday ? 0 : 1, portsText: newText);
    emit(state.copyWith(status: CustDashboardStatus.success));
  }

  Future<void> _onPortCleared(
      CustDashboardPortCleared event, Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(
      vesselPortsText: '',
      status: CustDashboardStatus.loading,
    ));
    await _fetchVesselData(emit,
        dayOffset: state.isVesselToday ? 0 : 1, portsText: '');
    emit(state.copyWith(status: CustDashboardStatus.success));
  }

  Future<void> _fetchVesselData(
      Emitter<CustDashboardState> emit,
      {required int dayOffset, String portsText = ''}) async {
    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    final comid = objfun.storagenew.getInt('Comid') ?? 0;

    String fromDate = _offsetDate(dayOffset);
    String toDate = _offsetDate(dayOffset);

    if (dayOffset == 0) {
      fromDate = '2024-10-01';
    }

    final result = await _safeApiCall(() => objfun.apiAllinoneSelectArray(
        objfun.VESSELPLANINGDB,
        {
          'Comid': comid,
          'Fromdate': fromDate,
          'Todate': toDate,
          'Search': portsText,
          'Employeeid': null,
          'ETAType': 0,
        },
        header,
        null));

    if (result is List && result.isNotEmpty) {
      final sorted = List<dynamic>.from(result)
        ..sort((a, b) {
          final nameA = (a['Port'] as String? ?? '').toLowerCase();
          final nameB = (b['Port'] as String? ?? '').toLowerCase();
          return nameA.compareTo(nameB);
        });
      emit(state.copyWith(saleCustReport: sorted));
    } else {
      emit(state.copyWith(saleCustReport: []));
    }
  }

  // ─── Transport / Planning ──────────────────────────────────────────────────

  Future<void> _onLoadPlanning(
      CustDashboardLoadPlanning event, Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(
      status: CustDashboardStatus.loading,
      isPlanToday: event.dayOffset == 0,
    ));
    await _fetchPlanningData(emit, dayOffset: event.dayOffset);
    emit(state.copyWith(status: CustDashboardStatus.success));
  }

  Future<void> _fetchPlanningData(
      Emitter<CustDashboardState> emit, {required int dayOffset}) async {
    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    final comid = objfun.storagenew.getInt('Comid') ?? 0;

    final dateStr = _offsetDate(dayOffset);
    final url = dayOffset == 0 ? objfun.PLANINGSearchDB : objfun.PLANINGSearch;

    final result = await _safeApiCall(() => objfun.apiAllinoneSelectArray(
        url,
        {
          'Comid': comid,
          'Fromdate': dateStr,
          'Todate': dateStr,
          'Search': '',
          'Employeeid': null,
          'ETAType': 0,
        },
        header,
        null));

    emit(state.copyWith(
      saleTransReport: (result is List) ? result : [],
    ));
  }

  // ─── Enquiry ───────────────────────────────────────────────────────────────

  Future<void> _onLoadEnquiry(
      CustDashboardLoadEnquiry event, Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(status: CustDashboardStatus.loading));
    await _fetchEnquiryData(emit);
    emit(state.copyWith(status: CustDashboardStatus.success));
  }

  Future<void> _onCancelEnquiry(
      CustDashboardCancelEnquiry event,
      Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(status: CustDashboardStatus.loading));
    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    final comid = objfun.storagenew.getInt('Comid') ?? 0;

    await _safeApiCall(() => objfun.apiAllinoneSelectArray(
        '${objfun.apiUpdateEnquiryMaster}${event.id}&Comid=$comid&StatusName=CANCEL',
        null,
        header,
        null));

    await _fetchEnquiryData(emit);
    emit(state.copyWith(status: CustDashboardStatus.success));
  }

  Future<void> _fetchEnquiryData(Emitter<CustDashboardState> emit) async {
    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    final comid = objfun.storagenew.getInt('Comid') ?? 0;

    final result = await _safeApiCall(() => objfun.apiAllinoneSelectArray(
        objfun.apiSelectEnquiryMaster,
        {
          'Comid': comid,
          'Fromdate': null,
          'Todate': null,
          'Employeeid': objfun.EmpRefId,
          'Invoice': false,
          'Id': 0,
          'JId': 0,
          'DashboardStatus': 2,
        },
        header,
        null));

    if (result is List && result.isNotEmpty) {
      final formatted = result.map((item) {
        final map = Map<String, dynamic>.from(item);
        if (map['ForwardingDate'] == null) {
          map['SForwardingDate'] = '';
        } else {
          map['SForwardingDate'] = DateFormat('dd-MM-yyyy HH:mm')
              .format(DateTime.parse(map['ForwardingDate']));
        }
        return map;
      }).toList();

      objfun.EnquiryMasterList = formatted;
      emit(state.copyWith(enquiryMasterList: formatted));
    } else {
      objfun.EnquiryMasterList = [];
      emit(state.copyWith(enquiryMasterList: []));
    }
  }

  // ─── Fuel ──────────────────────────────────────────────────────────────────

  Future<void> _onLoadFuel(
      CustDashboardLoadFuel event, Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(
      status: CustDashboardStatus.loading,
      fuelFromDate: event.fromDate,
      fuelToDate: event.toDate,
      fuelRecords: [],
    ));
    await _fetchFuelData(emit,
        fromDate: event.fromDate, toDate: event.toDate);
    emit(state.copyWith(status: CustDashboardStatus.success));
  }

  Future<void> _onFuelFromDateChanged(
      CustDashboardFuelFromDateChanged event,
      Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(fuelFromDate: event.date));
  }

  Future<void> _onFuelToDateChanged(
      CustDashboardFuelToDateChanged event,
      Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(fuelToDate: event.date));
  }

  Future<void> _fetchFuelData(
      Emitter<CustDashboardState> emit,
      {required String fromDate, required String toDate}) async {
    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    final comid = objfun.storagenew.getInt('Comid') ?? 0;

    final result = await _safeApiCall(() => objfun.apiAllinoneSelectArray(
        objfun.apiSelectFuelEntry,
        {
          'Comid': comid,
          'Fromdate': fromDate,
          'Todate': toDate,
          'Employeeid': 0,
          'DId': 0,
          'TId': 0,
          'Search': '',
        },
        header,
        null));

    if (result is List && result.isNotEmpty) {
      final records = result
          .map((e) => FuelselectModel.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(state.copyWith(fuelRecords: records));
    } else {
      emit(state.copyWith(fuelRecords: []));
    }
  }

  // ─── Payment ───────────────────────────────────────────────────────────────

  Future<void> _onLoadPayment(
      CustDashboardLoadPayment event, Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(status: CustDashboardStatus.loading));
    await _fetchPaymentData(emit,
        isDateSearch: event.isDateSearch,
        fromDate: event.fromDate,
        toDate: event.toDate);
    emit(state.copyWith(status: CustDashboardStatus.success));
  }

  Future<void> _onPaymentCategoryChanged(
      CustDashboardPaymentCategoryFilterChanged event,
      Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(
      selectedCategoryFilter: event.filter,
      sid: event.sid,
      status: CustDashboardStatus.loading,
    ));
    await _fetchPaymentData(emit);
    emit(state.copyWith(status: CustDashboardStatus.success));
  }

  Future<void> _onPaymentPaidFilterChanged(
      CustDashboardPaymentPaidFilterChanged event,
      Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(
      selectedPaidFilter: event.filter,
      pSid: event.pSid,
      status: CustDashboardStatus.loading,
    ));
    await _fetchPaymentData(emit);
    emit(state.copyWith(status: CustDashboardStatus.success));
  }

  Future<void> _onPaymentFromDatePicked(
      CustDashboardPaymentFromDatePicked event,
      Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(paymentFromDate: event.date));
  }

  Future<void> _onPaymentToDatePicked(
      CustDashboardPaymentToDatePicked event,
      Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(paymentToDate: event.date));
  }

  Future<void> _fetchPaymentData(
      Emitter<CustDashboardState> emit, {
        bool isDateSearch = false,
        DateTime? fromDate,
        DateTime? toDate,
      }) async {
    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    final comid = objfun.storagenew.getInt('Comid') ?? 0;

    String fromDateStr;
    String toDateStr;

    if (isDateSearch && fromDate != null && toDate != null) {
      fromDateStr = DateFormat('yyyy-MM-dd').format(fromDate);
      toDateStr = DateFormat('yyyy-MM-dd').format(toDate);
    } else {
      fromDateStr = _offsetDate(6);
      toDateStr = _offsetDate(6);
    }

    final result = await _safeApiCall(() => objfun.apiAllinoneSelectArray(
        '${objfun.apiSelectPaymentPending}?Startindex=0&PageCount=400',
        {
          'Comid': comid,
          'Fromdate': fromDateStr,
          'Todate': toDateStr,
          'SupplierId': state.sid,
          'SupplierId1': state.pSid,
        },
        header,
        null));

    List<PaymentPendingModel> masterList = [];
    List<PaymentPendingModel> detailsList = [];

    if (result is List && result.isNotEmpty) {
      final first = result[0];
      List<dynamic>? masterJson;
      List<dynamic>? detailsJson;

      if (first is Map &&
          (first.containsKey('ExpenseReportModel') ||
              first.containsKey('ExpenseReportDetailsModel'))) {
        masterJson = (first['ExpenseReportModel'] ?? []) as List<dynamic>?;
        detailsJson =
        (first['ExpenseReportDetailsModel'] ?? []) as List<dynamic>?;
      } else if (result.length >= 2 && result[1] is List) {
        masterJson = result[0] as List<dynamic>?;
        detailsJson = result[1] as List<dynamic>?;
      } else {
        masterJson = result as List<dynamic>?;
        detailsJson = [];
      }

      if (masterJson != null) {
        masterList = masterJson
            .map<PaymentPendingModel>(
                (e) => PaymentPendingModel.fromJson(e))
            .toList();
      }
      if (detailsJson != null) {
        detailsList = detailsJson
            .map<PaymentPendingModel>(
                (e) => PaymentPendingModel.fromJson(e))
            .toList();
      }
    }

    emit(state.copyWith(
      masterList: masterList,
      detailsList: detailsList,
    ));
  }

  // ─── Safe API call wrapper ─────────────────────────────────────────────────

  Future<dynamic> _safeApiCall(Future<dynamic> Function() call) async {
    try {
      return await call();
    } catch (_) {
      return null;
    }
  }
}