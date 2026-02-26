import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'invoice_event.dart';
import 'invoice_state.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  final BuildContext context;
  InvoiceBloc(this.context) : super(InvoiceInitial()) {

    /// 🔹 LOAD SALES DATA
    on<LoadInvoiceByType>((   LoadInvoiceByType event,
        Emitter<InvoiceState> emit) async {
      emit(InvoiceLoading());

      try {
        Map<String, String> header = {
          'Content-Type': 'application/json; charset=UTF-8',
        };

        final resultData = await objfun.apiAllinoneSelectArray(
          "${objfun.apiGetSalesData}${objfun.Comid}&type=${event.type}",
          null,
          header,
          context, // ✅ use global context if already defined
        );

        if (resultData != "") {
          final saleDataAll = resultData["Data1"] ?? [];
          final saleMonthData = resultData["Data2"] ?? [];

          final monthResult = _buildMonthData(saleMonthData, 6);

          emit(InvoiceLoaded(
            saleDataAll: saleDataAll,
            saleMonthData: saleMonthData,
            waitingBilling: [],
            monthList: monthResult.$1,
            monthData: monthResult.$2,
            is6Months: true,
            currentMonthName: DateFormat('MMMM').format(DateTime.now()),
            showWaitingSheet: false,

          ));
        }
      } catch (e) {
        emit(InvoiceError(e.toString()));
      }
    });

    /// 🔹 MONTH RANGE
    on<LoadMonthRange>((event, emit) {
      if (state is InvoiceLoaded) {
        final s = state as InvoiceLoaded;
        final monthResult =
        _buildMonthData(s.saleMonthData, event.months);

        emit(InvoiceLoaded(
          saleDataAll: s.saleDataAll,
          saleMonthData: s.saleMonthData,
          waitingBilling: s.waitingBilling,
          monthList: monthResult.$1,
          monthData: monthResult.$2,
          is6Months: event.months == 6,
          currentMonthName: s.currentMonthName,
          showWaitingSheet: false,
        ));
      }
    });

    //loadEmployeedata
    on<LoadWaitingBills>((event, emit) async {
      if (state is InvoiceLoaded) {
        final current = state as InvoiceLoaded;

        try {
          Map<String, String> header = {
            'Content-Type': 'application/json; charset=UTF-8',
          };

          String currentDate =
          DateFormat("yyyy-MM-dd").format(DateTime.now());

          Map<String, dynamic> master = {
            'Comid': objfun.storagenew.getInt('Comid') ?? 0,
            'Todate': currentDate,
          };

          final resultData = await objfun.apiAllinoneSelectArray(
            objfun.apiSelectSaleorderinvoicecheck,
            master,
            header,
            context,
          );

          final waitingList = resultData ?? [];

          emit(InvoiceLoaded(
            saleDataAll: current.saleDataAll,
            saleMonthData: current.saleMonthData,
            waitingBilling: waitingList,
            monthList: current.monthList,
            monthData: current.monthData,
            is6Months: current.is6Months,
            currentMonthName: current.currentMonthName,
            showWaitingSheet: true,
          ));

        } catch (e) {
          emit(current);
        }
      }
    });


    on<LoadEmployeeInvData>((event, emit) async {
      if (state is InvoiceLoaded) {
        final current = state as InvoiceLoaded;
        Map<String, String> header = {
          'Content-Type': 'application/json; charset=UTF-8',
        };
        try {
          final resultData = await objfun.apiAllinoneSelectArray(
            "${objfun.apiGetEmployeeInvData}${objfun.Comid}&type=${event.type}",
            null,
            header,
            context,
          );

          final employeeData = resultData["Data1"] ?? [];

          emit(InvoiceLoaded(
            saleDataAll: current.saleDataAll,
            saleMonthData: current.saleMonthData,
            waitingBilling: current.waitingBilling,
            monthList: current.monthList,
            monthData: current.monthData,
            is6Months: current.is6Months,
            currentMonthName: current.currentMonthName,
            showWaitingSheet: false,
            employeeData: employeeData,  // 👈 pass here
          ));

        } catch (e) {
          emit(current); // keep dashboard safe
        }
      }
    });


  }

  /// 🔹 monthdata logic
  (List<String>, List<dynamic>) _buildMonthData(
      List<dynamic> saleMonthData, int index) {

    List<String> loadMonthsList = [];
    List<dynamic> listMonthData = [];

    final monthNames = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];

    int monthIndex = DateTime.now().month;

    for (int i = 0; i < index; i++) {
      int currentIndex = ((monthIndex - 1) - i) % 12;
      if (currentIndex < 0) currentIndex += 12;
      loadMonthsList.add(monthNames[currentIndex]);
    }

    for (int i = 0; i < index && i < saleMonthData.length; i++) {
      listMonthData.add(saleMonthData[i]);
    }

    return (loadMonthsList, listMonthData);
  }


}
