import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/app_globals.dart';

import '../data/paymentview_repository.dart';
import 'paymentview_event.dart';
import 'paymentview_state.dart';

class PaymentPendingBloc extends Bloc<PaymentPendingEvent, PaymentPendingState> {
  // ❌ REMOVED: final BuildContext context;
  final PaymentViewRepository repository; // ✅ Injected Repository

  PaymentPendingBloc({required this.repository})
      : super(PaymentPendingLoading(
    selectedFilter: 'All',
    selectedPaidFilter: 'All Payments',
    fromDate: DateTime.now(),
    toDate: DateTime.now().add(const Duration(days: 6)),
  )) {
    on<LoadPaymentPendingEvent>(_onLoad);
    on<SelectExpenseFilterEvent>(_onExpenseFilter);
    on<SelectPaidFilterEvent>(_onPaidFilter);
    on<SelectFromDateEvent>(_onFromDate);
    on<SelectToDateEvent>(_onToDate);
    on<SearchByDateEvent>(_onSearchByDate);
    on<SelectPaymentItemEvent>(_onSelectItem);

    // Auto-load on init
    add(const LoadPaymentPendingEvent());
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _currentExpenseFilter() {
    final s = state;
    if (s is PaymentPendingLoading) return s.selectedFilter;
    if (s is PaymentPendingLoaded) return s.selectedFilter;
    if (s is PaymentPendingError) return s.selectedFilter;
    return 'All';
  }

  void _onSelectItem(SelectPaymentItemEvent event, Emitter<PaymentPendingState> emit) {
    if (state is PaymentPendingLoaded) {
      emit((state as PaymentPendingLoaded).copyWith(selectedItem: event.item));
    }
  }

  String _currentPaidFilter() {
    final s = state;
    if (s is PaymentPendingLoading) return s.selectedPaidFilter;
    if (s is PaymentPendingLoaded) return s.selectedPaidFilter;
    if (s is PaymentPendingError) return s.selectedPaidFilter;
    return 'All Payments';
  }

  DateTime _currentFromDate() {
    final s = state;
    if (s is PaymentPendingLoading) return s.fromDate;
    if (s is PaymentPendingLoaded) return s.fromDate;
    if (s is PaymentPendingError) return s.fromDate;
    return DateTime.now();
  }

  DateTime _currentToDate() {
    final s = state;
    if (s is PaymentPendingLoading) return s.toDate;
    if (s is PaymentPendingLoaded) return s.toDate;
    if (s is PaymentPendingError) return s.toDate;
    return DateTime.now().add(const Duration(days: 6));
  }

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> _onLoad(LoadPaymentPendingEvent e, Emitter<PaymentPendingState> emit) async {
    final expFilter  = _currentExpenseFilter();
    final paidFilter = _currentPaidFilter();
    final fromDate   = _currentFromDate();
    final toDate     = _currentToDate();

    emit(PaymentPendingLoading(
      selectedFilter: expFilter,
      selectedPaidFilter: paidFilter,
      fromDate: fromDate,
      toDate: toDate,
    ));

    await _fetch(emit, expFilter, paidFilter, fromDate, toDate);
  }

  // ── Expense Filter chip tap ───────────────────────────────────────────────
  Future<void> _onExpenseFilter(SelectExpenseFilterEvent e, Emitter<PaymentPendingState> emit) async {
    final paidFilter = _currentPaidFilter();
    final fromDate   = _currentFromDate();
    final toDate     = _currentToDate();

    emit(PaymentPendingLoading(
      selectedFilter: e.filter,
      selectedPaidFilter: paidFilter,
      fromDate: fromDate,
      toDate: toDate,
    ));

    await _fetch(emit, e.filter, paidFilter, fromDate, toDate);
  }

  // ── Paid Filter chip tap ──────────────────────────────────────────────────
  Future<void> _onPaidFilter(SelectPaidFilterEvent e, Emitter<PaymentPendingState> emit) async {
    final expFilter = _currentExpenseFilter();
    final fromDate  = _currentFromDate();
    final toDate    = _currentToDate();

    emit(PaymentPendingLoading(
      selectedFilter: expFilter,
      selectedPaidFilter: e.filter,
      fromDate: fromDate,
      toDate: toDate,
    ));

    await _fetch(emit, expFilter, e.filter, fromDate, toDate);
  }

  // ── Date pickers (just update state, no reload) ───────────────────────────
  void _onFromDate(SelectFromDateEvent e, Emitter<PaymentPendingState> emit) {
    if (state is PaymentPendingLoaded) {
      emit((state as PaymentPendingLoaded).copyWith(fromDate: e.date));
    } else {
      emit(PaymentPendingLoading(
        selectedFilter: _currentExpenseFilter(),
        selectedPaidFilter: _currentPaidFilter(),
        fromDate: e.date,
        toDate: _currentToDate(),
      ));
    }
  }

  void _onToDate(SelectToDateEvent e, Emitter<PaymentPendingState> emit) {
    if (state is PaymentPendingLoaded) {
      emit((state as PaymentPendingLoaded).copyWith(toDate: e.date));
    } else {
      emit(PaymentPendingLoading(
        selectedFilter: _currentExpenseFilter(),
        selectedPaidFilter: _currentPaidFilter(),
        fromDate: _currentFromDate(),
        toDate: e.date,
      ));
    }
  }

  // ── Search button tap ─────────────────────────────────────────────────────
  Future<void> _onSearchByDate(SearchByDateEvent e, Emitter<PaymentPendingState> emit) async {
    final expFilter  = _currentExpenseFilter();
    final paidFilter = _currentPaidFilter();
    final fromDate   = _currentFromDate();
    final toDate     = _currentToDate();

    emit(PaymentPendingLoading(
      selectedFilter: expFilter,
      selectedPaidFilter: paidFilter,
      fromDate: fromDate,
      toDate: toDate,
    ));

    await _fetch(emit, expFilter, paidFilter, fromDate, toDate, isDateSearch: true);
  }

  // ── API Call ──────────────────────────────────────────────────────────────
  Future<void> _fetch(
      Emitter<PaymentPendingState> emit,
      String expFilter,
      String paidFilter,
      DateTime fromDate,
      DateTime toDate, {
        bool isDateSearch = false,
      }) async {
    try {
      final String fromStr;
      final String toStr;

      if (isDateSearch) {
        fromStr = DateFormat('yyyy-MM-dd').format(fromDate);
        toStr   = DateFormat('yyyy-MM-dd').format(toDate);
      } else {
        final now = DateTime.now();
        final next6 = now.add(const Duration(days: 6));
        fromStr = DateFormat('yyyy-MM-dd').format(next6);
        toStr   = DateFormat('yyyy-MM-dd').format(next6);
      }

      final Map<String, dynamic> body = {
        'Comid': AppGlobals.storagenew.getInt('Comid') ?? 0,
        'Fromdate': fromStr,
        'Todate': toStr,
        'SupplierId': expenseFilterToSid(expFilter),
        'SupplierId1': paidFilterToSid(paidFilter),
      };

      // ✅ REFACTORED: Call the injected repository
      final result = await repository.fetchPaymentPendingData(body);

      List<PaymentPendingModel> masters  = [];
      List<PaymentPendingModel> details  = [];

      if (result != null && result is List && result.isNotEmpty) {
        final first = result[0];
        if (first is Map &&
            (first.containsKey('ExpenseReportModel') ||
                first.containsKey('ExpenseReportDetailsModel'))) {
          final mJson = (first['ExpenseReportModel'] ?? []) as List;
          final dJson = (first['ExpenseReportDetailsModel'] ?? []) as List;
          masters = mJson.map((e) => PaymentPendingModel.fromJson(e as Map<String, dynamic>)).toList();
          details = dJson.map((e) => PaymentPendingModel.fromJson(e as Map<String, dynamic>)).toList();
        } else if (result.length >= 2 && result[1] is List) {
          masters = (result[0] as List)
              .map((e) => PaymentPendingModel.fromJson(e as Map<String, dynamic>))
              .toList();
          details = (result[1] as List)
              .map((e) => PaymentPendingModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else {
          masters = (result)
              .map((e) => PaymentPendingModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }

      emit(PaymentPendingLoaded(
        masterList: masters,
        detailsList: details,
        selectedFilter: expFilter,
        selectedPaidFilter: paidFilter,
        fromDate: fromDate,
        toDate: toDate,
      ));
    } catch (err) {
      emit(PaymentPendingError(
        message: err.toString(),
        selectedFilter: expFilter,
        selectedPaidFilter: paidFilter,
        fromDate: fromDate,
        toDate: toDate,
      ));
    }
  }
}