import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:intl/intl.dart';

import 'salesorder_event.dart';
import 'salesorder_state.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class SalesOrderBloc extends Bloc<SalesOrderEvent, SalesOrderState> {
  final BuildContext context;

  // ─────────────────────────────────────────────
  // Guard flag — in-flight API call இருந்தா duplicate block பண்ணும்
  // ─────────────────────────────────────────────
  bool _isLoadingInvoice = false;

  SalesOrderBloc(this.context) : super(InvoiceInitial()) {

    // ─────────────────────────────────────────────
    // LOAD SALES DATA
    // Fix 1: _isLoadingInvoice guard → duplicate API call block
    // Fix 2: InvoiceTabSwitching state-லயும் same-tab check
    // Fix 3: transformer droppable() → concurrent events drop
    // ─────────────────────────────────────────────
    on<LoadInvoiceByType>(
          (event, emit) async {
        final newTabIndex = event.type == 0 ? 0 : event.type - 1;

        // ── Same tab guard — InvoiceLoaded state-ல ──
        if (state is InvoiceLoaded) {
          final current = state as InvoiceLoaded;
          if (current.selectedTabIndex == newTabIndex) return;
        }

        // ── Same tab guard — InvoiceTabSwitching state-லயும் ──
        if (state is InvoiceTabSwitching) {
          final switching = state as InvoiceTabSwitching;
          if (switching.targetTabIndex == newTabIndex) return;
        }

        // ── In-flight guard — already API running-ஆ? ──
        if (_isLoadingInvoice) return;
        _isLoadingInvoice = true;

        // ── Loading state emit ──
        if (state is InvoiceLoaded) {
          emit(InvoiceTabSwitching(
            previous: state as InvoiceLoaded,
            targetTabIndex: newTabIndex,
          ));
        } else if (state is InvoiceTabSwitching) {
          emit(InvoiceTabSwitching(
            previous: (state as InvoiceTabSwitching).previous,
            targetTabIndex: newTabIndex,
          ));
        } else {
          emit(InvoiceLoading());
        }

        try {
          final header = {'Content-Type': 'application/json; charset=UTF-8'};
          final currentDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
          final master = {
            'Comid': objfun.storagenew.getInt('Comid') ?? 0,
            'Todate': currentDate,
          };

          // Parallel API calls
          final results = await Future.wait([
            objfun.apiAllinoneSelectArray(
              "${objfun.apiGetSalesData}${objfun.Comid}&type=${event.type}",
              null, header, context,
            ),
            objfun.apiAllinoneSelectArray(
              objfun.apiSelectSaleorderinvoicecheck,
              master, header, context,
            ),
          ]);

          final resultData = results[0];
          final waitingResult = results[1];

          if (resultData != null && resultData != "") {
            final saleMonthData =
            List<dynamic>.from(resultData["Data2"] ?? []);
            final monthResult = _buildMonthData(saleMonthData, 6);

            emit(InvoiceLoaded(
              saleDataAll: List<dynamic>.from(resultData["Data1"] ?? []),
              saleMonthData: saleMonthData,
              waitingBilling: List<dynamic>.from(waitingResult ?? []),
              monthList: monthResult.$1,
              monthData: monthResult.$2,
              is6Months: true,
              currentMonthName: DateFormat('MMMM').format(DateTime.now()),
              showWaitingSheet: false,
              selectedTabIndex: newTabIndex,
              employeeData: null,
            ));
          } else {
            emit(InvoiceError("No data returned"));
          }
        } catch (e) {
          if (state is InvoiceTabSwitching) {
            emit((state as InvoiceTabSwitching).previous);
          } else {
            emit(InvoiceError(e.toString()));
          }
        } finally {
          // Always release — stuck ஆகாம இருக்கும்
          _isLoadingInvoice = false;
        }
      },
      transformer: droppable(), // concurrent duplicate events drop ஆகும்
    );

    // ─────────────────────────────────────────────
    // MONTH RANGE — local only, no API
    // ─────────────────────────────────────────────
    on<LoadMonthRange>((event, emit) {
      if (state is! InvoiceLoaded) return;
      final s = state as InvoiceLoaded;

      final alreadySelected =
          (event.months == 6 && s.is6Months) ||
              (event.months == 12 && !s.is6Months);
      if (alreadySelected) return;

      final monthResult = _buildMonthData(s.saleMonthData, event.months);
      emit(s.copyWith(
        monthList: monthResult.$1,
        monthData: monthResult.$2,
        is6Months: event.months == 6,
        showWaitingSheet: false,
        clearEmployeeData: true,
      ));
    });

    // ─────────────────────────────────────────────
    // WAITING BILLS
    // ─────────────────────────────────────────────
    on<LoadWaitingBills>(
          (event, emit) async {
        if (state is! InvoiceLoaded) return;
        final current = state as InvoiceLoaded;

        try {
          final header = {'Content-Type': 'application/json; charset=UTF-8'};
          final currentDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
          final master = {
            'Comid': objfun.storagenew.getInt('Comid') ?? 0,
            'Todate': currentDate,
          };

          final resultData = await objfun.apiAllinoneSelectArray(
            objfun.apiSelectSaleorderinvoicecheck,
            master, header, context,
          );

          emit(current.copyWith(
            waitingBilling: List<dynamic>.from(resultData ?? []),
            showWaitingSheet: true,
            clearEmployeeData: true,
          ));
        } catch (_) {
          emit(current.copyWith(
              showWaitingSheet: true, clearEmployeeData: true));
        }
      },
      transformer: droppable(),
    );

    // ─────────────────────────────────────────────
    // EMPLOYEE DATA
    // ─────────────────────────────────────────────
    on<LoadEmployeeInvData>(
          (event, emit) async {
        if (state is! InvoiceLoaded) return;
        final current = state as InvoiceLoaded;

        try {
          final header = {'Content-Type': 'application/json; charset=UTF-8'};

          final resultData = await objfun.apiAllinoneSelectArray(
            "${objfun.apiGetEmployeeInvData}${objfun.Comid}&type=${event.type}",
            null, header, context,
          );

          emit(current.copyWith(
            employeeData: List<dynamic>.from(resultData?["Data1"] ?? []),
            showWaitingSheet: false,
          ));
        } catch (_) {}
      },
      transformer: droppable(),
    );

    // ─────────────────────────────────────────────
    // TAB CHANGED (local only)
    // ─────────────────────────────────────────────
    on<TabChanged>((event, emit) {
      if (state is! InvoiceLoaded) return;
      final current = state as InvoiceLoaded;
      if (current.selectedTabIndex == event.index) return;
      emit(current.copyWith(
        selectedTabIndex: event.index,
        showWaitingSheet: false,
        clearEmployeeData: true,
      ));
    });

    // ─────────────────────────────────────────────
    // FORCE REFRESH
    // Fix: InvoiceInitial emit பண்ணா initState re-trigger ஆகும்
    //      InvoiceLoading emit பண்றோம் + guard release
    // ─────────────────────────────────────────────
    on<RefreshSalesOrder>((event, emit) async {
      _isLoadingInvoice = false; // stuck guard release
      emit(InvoiceLoading());
      add(LoadInvoiceByType(0));
    });
  }

  (List<String>, List<dynamic>) _buildMonthData(
      List<dynamic> saleMonthData, int count) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final monthIndex = DateTime.now().month;
    final monthList = <String>[];

    for (int i = 0; i < count; i++) {
      int idx = ((monthIndex - 1) - i) % 12;
      if (idx < 0) idx += 12;
      monthList.add(monthNames[idx]);
    }

    return (monthList, saleMonthData.take(count).toList());
  }
}