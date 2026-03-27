import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/paymentview/bloc/paymentview_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/paymentview/bloc/paymentview_state.dart';



class PaymentPendingBloc
    extends Bloc<PaymentPendingEvent, PaymentPendingState> {
  final BuildContext context;

  PaymentPendingBloc(this.context)
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
  void _onSelectItem(
      SelectPaymentItemEvent event,
      Emitter<PaymentPendingState> emit,
      ) {
    if (state is PaymentPendingLoaded) {
      emit((state as PaymentPendingLoaded)
          .copyWith(selectedItem: event.item));
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
  Future<void> _onLoad(
      LoadPaymentPendingEvent e, Emitter<PaymentPendingState> emit) async {
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
  Future<void> _onExpenseFilter(
      SelectExpenseFilterEvent e,
      Emitter<PaymentPendingState> emit) async {
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
  Future<void> _onPaidFilter(
      SelectPaidFilterEvent e,
      Emitter<PaymentPendingState> emit) async {
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
  void _onFromDate(
      SelectFromDateEvent e, Emitter<PaymentPendingState> emit) {
    if (state is PaymentPendingLoaded) {
      emit((state as PaymentPendingLoaded).copyWith(fromDate: e.date));
    } else {
      // Re-emit loading with new date
      emit(PaymentPendingLoading(
        selectedFilter: _currentExpenseFilter(),
        selectedPaidFilter: _currentPaidFilter(),
        fromDate: e.date,
        toDate: _currentToDate(),
      ));
    }
  }

  void _onToDate(
      SelectToDateEvent e, Emitter<PaymentPendingState> emit) {
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
  Future<void> _onSearchByDate(
      SearchByDateEvent e, Emitter<PaymentPendingState> emit) async {
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

    await _fetch(emit, expFilter, paidFilter, fromDate, toDate,
        isDateSearch: true);
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
        'Comid': objfun.storagenew.getInt('Comid') ?? 0,
        'Fromdate': fromStr,
        'Todate': toStr,
        'SupplierId': expenseFilterToSid(expFilter),
        'SupplierId1': paidFilterToSid(paidFilter),
      };

      final result = await objfun.apiAllinoneSelectArray(
        "${objfun.apiSelectPaymentPending}?Startindex=0&PageCount=400",
        body,
        {'Content-Type': 'application/json; charset=UTF-8'},
        context,
      );

      List<PaymentPendingModel> masters  = [];
      List<PaymentPendingModel> details  = [];

      if (result != null && result.isNotEmpty) {
        final first = result[0];
        if (first is Map &&
            (first.containsKey('ExpenseReportModel') ||
                first.containsKey('ExpenseReportDetailsModel'))) {
          final mJson = (first['ExpenseReportModel'] ?? []) as List;
          final dJson = (first['ExpenseReportDetailsModel'] ?? []) as List;
          masters = mJson.map((e) => PaymentPendingModel.fromJson(e)).toList();
          details = dJson.map((e) => PaymentPendingModel.fromJson(e)).toList();
        } else if (result.length >= 2 && result[1] is List) {
          masters = (result[0] as List)
              .map((e) => PaymentPendingModel.fromJson(e))
              .toList();
          details = (result[1] as List)
              .map((e) => PaymentPendingModel.fromJson(e))
              .toList();
        } else {
          masters = (result as List)
              .map((e) => PaymentPendingModel.fromJson(e))
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