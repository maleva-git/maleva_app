import 'package:maleva/core/network/api_constants.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'custdashboard_event.dart';
import 'custdashboard_state.dart';
import 'package:maleva/features/transport/models/fuelselect_model.dart';
import 'package:maleva/core/models/shared/payment_pending_model.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/fuel/fuel_entry_api.dart';
import 'package:maleva/features/dashboard/common_tabs/paymentview/data/paymentview_repository.dart';


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


  String _offsetDate(int days) =>
      DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: days)));

  // ─── Startup ───────────────────────────────────────────────────────────────

  Future<void> _onStarted(
      CustDashboardStarted event, Emitter<CustDashboardState> emit) async {
    emit(state.copyWith(
      status: CustDashboardStatus.loading,
      selectedEmpId: AppGlobals.EmpRefId.toString(),
      empRefId: AppGlobals.EmpRefId,
    ));

    await Future.wait([
      _fetchRulesType(emit),
      _fetchSalesData(emit, empRefId: AppGlobals.EmpRefId),
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
    final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    final desk = await _safeApiCall(() => sl<DashboardApi>().salesDesk(comid, empRefId), emit);
    if (desk is! SalesDeskNumbers) return;

    emit(state.copyWith(
      withoutInvoiceCount: desk.withoutInvoice,
      totalCount: desk.total,
      totalBilledCount: desk.billed,
      totalUnBilledCount: desk.unbilled,
      salesReport: desk.statuses,
    ));
  }

  // ─── Rules Type ────────────────────────────────────────────────────────────

  Future<void> _fetchRulesType(Emitter<CustDashboardState> emit) async {
    final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;

    final result = await _safeApiCall(
        () => sl<DashboardApi>().employeeRules(comid, AppGlobals.EmpRefId), emit);

    if (result is List && result.isNotEmpty) {
      final rules = result
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();

      emit(state.copyWith(
        rulesTypeEmployee: rules,
        selectedEmpId: AppGlobals.EmpRefId.toString(),
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
    final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;

    String fromDate = _offsetDate(dayOffset);
    String toDate = _offsetDate(dayOffset);

    if (dayOffset == 0) {
      fromDate = '2024-10-01';
    }

    // shared Java POST /api/dashboard/vessel-planning/{comid}: camelCase rows
    final result = await _safeApiCall(() => sl<DashboardApi>().vesselPlanning(comid,
        fromDate: fromDate, toDate: toDate, search: portsText), emit);

    if (result is List && result.isNotEmpty) {
      final sorted = List<dynamic>.from(result)
        ..sort((a, b) {
          final nameA = (a['port'] ?? '').toString().toLowerCase();
          final nameB = (b['port'] ?? '').toString().toLowerCase();
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
    final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    final result = await _safeApiCall(() => sl<DashboardApi>().transportList(comid, dayOffset), emit);

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
    final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;

    await _safeApiCall(() => sl<LegacyApiRepository>().apiAllinoneSelectArray(
        '${ApiConstants.apiUpdateEnquiryMaster}${event.id}&Comid=$comid&StatusName=CANCEL',
        null,
        header,
        null), emit);

    await _fetchEnquiryData(emit);
    emit(state.copyWith(status: CustDashboardStatus.success));
  }

  Future<void> _fetchEnquiryData(Emitter<CustDashboardState> emit) async {
    final header = {'Content-Type': 'application/json; charset=UTF-8'};
    final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;

    final result = await _safeApiCall(() => sl<LegacyApiRepository>().apiAllinoneSelectArray(
        ApiConstants.apiSelectEnquiryMaster,
        {
          'Comid': comid,
          'Fromdate': null,
          'Todate': null,
          'Employeeid': AppGlobals.EmpRefId,
          'Invoice': false,
          'Id': 0,
          'JId': 0,
          'DashboardStatus': 2,
        },
        header,
        null), emit);

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

      AppGlobals.EnquiryMasterList = formatted;
      emit(state.copyWith(enquiryMasterList: formatted));
    } else {
      AppGlobals.EnquiryMasterList = [];
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
    final rows = await _safeApiCall(
        () => sl<FuelEntryApi>().list(fromDate: fromDate, toDate: toDate), emit);

    if (rows is List<Map<String, dynamic>>) {
      emit(state.copyWith(fuelRecords: rows.map(FuelselectModel.fromJava).toList()));
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
    final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    // the shared Java pending payments board (current month, as .NET SelectPendingPayment)
    final lists = await _safeApiCall(() => PaymentViewRepository()
        .fetchPaymentPending(comid: comid, expenseFilter: state.sid, paidFilter: state.pSid), emit);
    final masterList = lists is PaymentPendingLists ? lists.masters : <PaymentPendingModel>[];
    final detailsList = lists is PaymentPendingLists ? lists.details : <PaymentPendingModel>[];

    emit(state.copyWith(
      masterList: masterList,
      detailsList: detailsList,
    ));
  }

  // ─── Safe API call wrapper ─────────────────────────────────────────────────

  Future<dynamic> _safeApiCall(Future<dynamic> Function() call, Emitter<CustDashboardState> emit) async {
    try {
      return await call();
    } catch (e) {
      emit(state.copyWith(status: CustDashboardStatus.failure, errorMessage: e.toString()));
      return null;
    }
  }
}