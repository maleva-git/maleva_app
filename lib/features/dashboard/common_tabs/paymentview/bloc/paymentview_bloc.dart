import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maleva/core/session/legacy_feature_context.dart';

import '../data/paymentview_repository.dart';
import 'paymentview_event.dart';
import 'paymentview_state.dart';

class PaymentPendingBloc extends Bloc<PaymentPendingEvent, PaymentPendingState> {
  // ❌ REMOVED: final BuildContext context;
  final LegacyFeatureContext context;
  final PaymentViewRepository repository; // ✅ Injected Repository

  PaymentPendingBloc({required this.repository, this.context = const LegacyFeatureContext()})
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
      // The board is the current month, as .NET SelectPendingPayment was (it ignored the dates).
      final lists = await repository.fetchPaymentPending(
        comid: context.storedGlobalCompanyId,
        expenseFilter: expenseFilterToSid(expFilter),
        paidFilter: paidFilterToSid(paidFilter),
      );
      final masters = lists.masters;
      final details = lists.details;

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