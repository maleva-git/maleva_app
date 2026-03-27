import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'invoice_event.dart';
import 'invoice_state.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final BuildContext context;

  InvoiceBloc(this.context) : super(InvoiceInitial()) {

    // ─────────────────────────────────────────────
    // LOAD SALES DATA
    // FIX: Already loaded-ஆ இருந்தா skip — re-mount-ல் API போகாது
    // ─────────────────────────────────────────────
    on<LoadInvoiceByType>((event, emit) async {
      // Already loaded-ஆ இருந்தா API call வேண்டாம்
      if (state is InvoiceLoaded) return;

      emit(InvoiceLoading());
      try {
        final header = {'Content-Type': 'application/json; charset=UTF-8'};
        final currentDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
        final master = {
          'Comid': objfun.storagenew.getInt('Comid') ?? 0,
          'Todate': currentDate,
        };

        final results = await Future.wait([
          objfun.apiAllinoneSelectArray(
            "${objfun.apiGetSalesData}${objfun.Comid}&type=${event.type}",
            null,
            header,
            context,
          ),
          objfun.apiAllinoneSelectArray(
            objfun.apiSelectSaleorderinvoicecheck,
            master,
            header,
            context,
          ),
        ]);

        final resultData = results[0];
        final waitingResult = results[1];

        if (resultData != null && resultData != "") {
          final saleMonthData = List<dynamic>.from(resultData["Data2"] ?? []);
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
            employeeData: null,
          ));
        } else {
          emit(InvoiceError("No data returned"));
        }
      } catch (e) {
        emit(InvoiceError(e.toString()));
      }
    });

    // ─────────────────────────────────────────────
    // MONTH RANGE TOGGLE
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
    on<LoadWaitingBills>((event, emit) async {
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
          master,
          header,
          context,
        );

        emit(current.copyWith(
          waitingBilling: List<dynamic>.from(resultData ?? []),
          showWaitingSheet: true,
          clearEmployeeData: true,
        ));
      } catch (_) {
        emit(current.copyWith(showWaitingSheet: true, clearEmployeeData: true));
      }
    });

    // ─────────────────────────────────────────────
    // EMPLOYEE INVOICE DATA
    // ─────────────────────────────────────────────
    on<LoadEmployeeInvData>((event, emit) async {
      if (state is! InvoiceLoaded) return;
      final current = state as InvoiceLoaded;

      try {
        final header = {'Content-Type': 'application/json; charset=UTF-8'};

        final resultData = await objfun.apiAllinoneSelectArray(
          "${objfun.apiGetEmployeeInvData}${objfun.Comid}&type=${event.type}",
          null,
          header,
          context,
        );

        final employeeData = List<dynamic>.from(resultData?["Data1"] ?? []);

        emit(current.copyWith(
          employeeData: employeeData,
          showWaitingSheet: false,
        ));
      } catch (_) {
        // Dashboard safe
      }
    });

    // ─────────────────────────────────────────────
    // FORCE REFRESH — manual refresh தேவைப்பட்டா
    // ─────────────────────────────────────────────
    on<RefreshInvoice>((event, emit) async {
      emit(InvoiceInitial());
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