

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/ExpenseReport/bloc/expensereport_event.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'expensereport_state.dart';

class ExpenseReportBloc extends Bloc<ExpenseReportEvent, ExpReportState>{
  final BuildContext context;
  ExpenseReportBloc(this.context) : super(ExpReportState(
    dtpFromDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
    dtpToDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
  )) {
    on<LoadExpReportEvent>(_onLoadExpData);
    on<ChangeFromDateEvent>(_onChangeFromDate);
    on<ChangeToDateEvent>(_onChangeToDate);
  }

  Future<void> _onLoadExpData (
      LoadExpReportEvent event,
      Emitter<ExpReportState> emit,
      ) async {
    emit(state.copyWith(status: ExpStatus.loading));

    try {
      Map<String, String> header = {
        'Content-Type' : 'application/json; charset=UTF-8',
      };

    final resultData = await objfun.apiAllinoneSelectArray (
        "${objfun.apiGetExpData}${objfun.Comid}&startDate=${event.fromDate}&endDate=${event.toDate}",
         null,
         header, context
      );

    if(resultData != "" && resultData.length != 0) {
      emit(state.copyWith(
        status: ExpStatus.success,
        saleExpReport: resultData["Data1"],
        saleExpReport2: resultData["Data2"],
      ));
    } else {
      emit(state.copyWith(status: ExpStatus.success));
    }
    } catch (error, stackTrace) {
      emit(state.copyWith(
        status: ExpStatus.failure,
        errorMessage: error.toString(),
      ));
    }
   }

   void _onChangeFromDate(
       ChangeFromDateEvent event,
       Emitter<ExpReportState> emit,
       ) {
     emit(state.copyWith(dtpFromDate: event.fromDate));
    add(LoadExpReportEvent(fromDate: event.fromDate, toDate: state.dtpToDate));
   }

  void _onChangeToDate(
      ChangeToDateEvent event,
      Emitter<ExpReportState> emit,
      ) {
    emit(state.copyWith(dtpToDate: event.toDate));
    add(LoadExpReportEvent(fromDate: state.dtpFromDate, toDate: event.toDate));
  }
}