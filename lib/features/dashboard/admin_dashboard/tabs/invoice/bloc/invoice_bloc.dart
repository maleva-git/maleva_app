// lib/features/dashboard/admin_dashboard/tabs/invoice/bloc/invoice_bloc.dart
//
// ── What changed from original ─────────────────────────────────────
//  BEFORE                              AFTER
//  InvoiceBloc()                       InvoiceBloc({required this._invoiceRepo})
//  objfun.storagenew.getInt('Comid')   AppPreferences.getComid()
//  ApiClient.postRequest(objfun.url)   _invoiceRepo.getWaitingBills()
//  no transformers                     droppable() on all async events
//  RefreshInvoice → blank screen       RefreshInvoice → InvoiceRefreshing (keeps data)
//  no Equatable on state               sealed + Equatable — no extra rebuilds
// ───────────────────────────────────────────────────────────────────

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_preferences.dart';

import '../data/invoice_repository.dart';
import 'invoice_event.dart';
import 'invoice_state.dart';

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final InvoiceRepository _invoiceRepo;

  // ✅ Injected — no objfun, no ApiClient direct call
  InvoiceBloc({required InvoiceRepository invoiceRepo})
      : _invoiceRepo = invoiceRepo,
        super(InvoiceInitial()) {

    // ── Load initial data ──────────────────────────────────────
    // droppable(): if user triggers twice quickly, second is dropped
    on<LoadInvoiceByType>(_onLoad, transformer: droppable());

    // ── Month range toggle (local, no API) ─────────────────────
    on<LoadMonthRange>(_onMonthRange);

    // ── Waiting bills (lazy load then cache) ───────────────────
    on<LoadWaitingBills>(_onLoadWaiting, transformer: droppable());

    // ── Employee breakdown per month ───────────────────────────
    // droppable(): rapid month taps — only last one matters
    on<LoadEmployeeInvData>(_onLoadEmployee, transformer: droppable());

    // ── Pull-to-refresh ────────────────────────────────────────
    // restartable(): new refresh cancels in-flight one
    on<RefreshInvoice>(_onRefresh, transformer: restartable());

    // ── Dismiss waiting sheet ──────────────────────────────────
    on<DismissWaitingSheet>(_onDismissWaiting);
  }

  // ─────────────────────────────────────────────────────────────
  // LOAD
  // ─────────────────────────────────────────────────────────────
  Future<void> _onLoad(
      LoadInvoiceByType event,
      Emitter<InvoiceState> emit,
      ) async {
    // Guard: already loaded with same type — skip
    if (state is InvoiceLoaded) return;

    emit(InvoiceLoading());
    await _fetchAndEmit(event.type, emit);
  }

  // ─────────────────────────────────────────────────────────────
  // REFRESH — no blank screen, shows stale data + spinner
  // ─────────────────────────────────────────────────────────────
  Future<void> _onRefresh(
      RefreshInvoice event,
      Emitter<InvoiceState> emit,
      ) async {
    final current = state;

    // Keep old data visible while refreshing
    if (current is InvoiceLoaded) {
      emit(InvoiceRefreshing(current));
    } else {
      emit(InvoiceLoading());
    }

    await _fetchAndEmit(0, emit);
  }

  // ─────────────────────────────────────────────────────────────
  // MONTH RANGE — pure local, no API
  // ─────────────────────────────────────────────────────────────
  void _onMonthRange(LoadMonthRange event, Emitter<InvoiceState> emit) {
    final s = _loadedState;
    if (s == null) return;

    final alreadySelected =
        (event.months == 6 && s.is6Months) ||
            (event.months == 12 && !s.is6Months);
    if (alreadySelected) return;

    final (monthList, monthData) = _buildMonthData(s.saleMonthData, event.months);

    emit(s.copyWith(
      monthList:        monthList,
      monthData:        monthData,
      is6Months:        event.months == 6,
      showWaitingSheet: false,
      clearEmployeeData: true,
    ));
  }

  // ─────────────────────────────────────────────────────────────
  // WAITING BILLS — lazy load, then cache
  // ─────────────────────────────────────────────────────────────
  Future<void> _onLoadWaiting(
      LoadWaitingBills event,
      Emitter<InvoiceState> emit,
      ) async {
    final s = _loadedState;
    if (s == null) return;

    // Already cached — just show the sheet
    if (s.waitingBilling.isNotEmpty) {
      emit(s.copyWith(showWaitingSheet: true, clearEmployeeData: true));
      return;
    }

    try {
      final bills = await _invoiceRepo.getWaitingBills();
      emit(s.copyWith(
        waitingBilling:   bills,
        showWaitingSheet: true,
        clearEmployeeData: true,
      ));
    } catch (_) {
      // Sheet still opens — just without data
      emit(s.copyWith(showWaitingSheet: true, clearEmployeeData: true));
    }
  }

  // ─────────────────────────────────────────────────────────────
  // EMPLOYEE DATA per month
  // ─────────────────────────────────────────────────────────────
  Future<void> _onLoadEmployee(
      LoadEmployeeInvData event,
      Emitter<InvoiceState> emit,
      ) async {
    final s = _loadedState;
    if (s == null) return;

    try {
      final data = await _invoiceRepo.getEmployeeInvData(type: event.type);
      emit(s.copyWith(
        employeeData:    data,
        showWaitingSheet: false,
      ));
    } catch (_) {
      // Silent — dashboard should not crash on secondary data load
    }
  }

  // ─────────────────────────────────────────────────────────────
  // DISMISS WAITING SHEET
  // ─────────────────────────────────────────────────────────────
  void _onDismissWaiting(
      DismissWaitingSheet event,
      Emitter<InvoiceState> emit,
      ) {
    final s = _loadedState;
    if (s == null) return;
    emit(s.copyWith(showWaitingSheet: false));
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────

  /// Safe cast — returns loaded state from any variant
  InvoiceLoaded? get _loadedState => switch (state) {
    InvoiceLoaded s      => s,
    InvoiceRefreshing s  => s.previous,
    _                    => null,
  };

  Future<void> _fetchAndEmit(int type, Emitter<InvoiceState> emit) async {
    try {
      final (salesData, waitingBills) = await _invoiceRepo.loadDashboard(type: type);

      if (salesData == null) {
        emit( InvoiceError('No data returned from server'));
        return;
      }

      final saleMonthData = List<dynamic>.from(salesData['Data2'] ?? []);
      final (monthList, monthData) = _buildMonthData(saleMonthData, 6);

      emit(InvoiceLoaded(
        saleDataAll:      List<dynamic>.from(salesData['Data1'] ?? []),
        saleMonthData:    saleMonthData,
        waitingBilling:   waitingBills,
        monthList:        monthList,
        monthData:        monthData,
        is6Months:        true,
        currentMonthName: DateFormat('MMMM').format(DateTime.now()),
        showWaitingSheet: false,
        employeeData:     null,
      ));
    } catch (e) {
      final msg = e.toString().replaceAll('Exception: ', '');
      emit(InvoiceError(msg));
    }
  }

  (List<String>, List<dynamic>) _buildMonthData(
      List<dynamic> saleMonthData,
      int count,
      ) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final now = DateTime.now();
    final monthList = <String>[];

    for (var i = 0; i < count; i++) {
      final idx = ((now.month - 1) - i) % 12;
      monthList.add(monthNames[idx < 0 ? idx + 12 : idx]);
    }

    return (monthList, saleMonthData.take(count).toList());
  }
}