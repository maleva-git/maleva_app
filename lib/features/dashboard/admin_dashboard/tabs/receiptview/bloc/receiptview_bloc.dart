import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/receiptview/bloc/receiptview_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/receiptview/bloc/receiptview_state.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {

  final BuildContext context;

  ReceiptBloc({ required this.context})
      : super(const ReceiptState()) {
    on<SelectFromDateEvent>(_onSelectFromDate);
    on<SelectToDateEvent>(_onSelectToDate);
    on<LoadReceiptEvent>(_onLoadReceipt);
  }

  /// From Date select ஆனா
  void _onSelectFromDate(
      SelectFromDateEvent event, Emitter<ReceiptState> emit) {
    emit(state.copyWith(fromDate: event.date));
  }

  /// To Date select ஆனா
  void _onSelectToDate(SelectToDateEvent event, Emitter<ReceiptState> emit) {
    emit(state.copyWith(toDate: event.date));
  }

  /// API call பண்ணி receipt load பண்ண
  Future<void> _onLoadReceipt(
      LoadReceiptEvent event, Emitter<ReceiptState> emit) async {
    // Loading start — progress false
    emit(state.copyWith(progress: false));

    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8',
    };

    String fromDateStr;
    String toDateStr;

    if (event.isDateSearch &&
        state.fromDate != null &&
        state.toDate != null) {
      fromDateStr = DateFormat('yyyy-MM-dd').format(state.fromDate!);
      toDateStr = DateFormat('yyyy-MM-dd').format(state.toDate!);
    } else {
      DateTime now = DateTime.now();
      DateTime before30 = now.subtract(const Duration(days: 900));
      fromDateStr = DateFormat('yyyy-MM-dd').format(before30);
      toDateStr = DateFormat('yyyy-MM-dd').format(now);
    }

    var master = {
      "tilldate": toDateStr,
      "fromdate": fromDateStr,
      "CompanyRefId": objfun.Comid,
    };

    try {
      var resultData = await objfun.apiAllinoneSelectArray(
        "${objfun.apiSelectReceipt}",
        master,
        header,
        context,
      );

      if (resultData != null && resultData.isNotEmpty) {
        List<Map<String, dynamic>> masterList = [];
        List<Map<String, dynamic>> detailList = [];

        if (resultData["Data1"] is List &&
            resultData["Data1"].isNotEmpty) {
          masterList =
          List<Map<String, dynamic>>.from(resultData["Data1"]);
        }

        if (resultData["Data2"] is List &&
            resultData["Data2"].isNotEmpty) {
          detailList =
          List<Map<String, dynamic>>.from(resultData["Data2"]);
        }

        // Total calculate பண்ணு
        double totalAmount = 0;
        double totalBalance = 0;

        for (int i = 0; i < masterList.length; i++) {
          totalAmount +=
              double.tryParse(masterList[i]["BillAmount"].toString()) ?? 0;
          totalBalance +=
              double.tryParse(masterList[i]["Balance"].toString()) ?? 0;
        }

        totalBalance =
            double.parse(totalBalance.toStringAsFixed(2));
        totalAmount =
            double.parse(totalAmount.toStringAsFixed(2));

        emit(state.copyWith(
          progress: true,
          receiptMaster: masterList,
          receiptDetails: detailList,
          totalAmount: totalAmount,
          totalBalance: totalBalance,
          errorMessage: null,
        ));
      } else {
        emit(state.copyWith(progress: true));
      }
    } catch (error, stackTrace) {
      print("🔥 ERROR OCCURRED:");
      print(error);
      print(stackTrace);

      objfun.msgshow(
        error.toString(),
        stackTrace.toString(),
        Colors.white,
        Colors.red,
        null,
        18.00 - objfun.reducesize,
        objfun.tll,
        objfun.tgc,
        context,
        2,
      );

      emit(state.copyWith(
        progress: true,
        errorMessage: error.toString(),
      ));
    }
  }

  /// Date picker — from or to
  Future<void> pickDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      if (isFrom) {
        add(SelectFromDateEvent(picked));
      } else {
        add(SelectToDateEvent(picked));
      }
    }
  }
}