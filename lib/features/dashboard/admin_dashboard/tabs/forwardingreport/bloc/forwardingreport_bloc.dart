

import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/forwardingreport/bloc/forwardingreport_event.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/colors/colors.dart' as colour;
import 'forwardingreport_state.dart';

class ForwardingReportBloc
    extends Bloc<ForwardingReportEvent, ForwardingReportState> {
 // your utility class
  final BuildContext context;
  ForwardingReportBloc(this.context)
      : super(ForwardingReportState(
    dtpFromDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
    dtpToDate: DateFormat("yyyy-MM-dd").format(DateTime.now()),
  )) {
    on<LoadFWDataEvent>(_onLoadFWData);
    on<ChangFromDateEvent>(_onChangeFromDate);
    on<ChangeToDateEvent>(_onChangeToDate);
  }

  Future<void> _onLoadFWData(
      LoadFWDataEvent event,
      Emitter<ForwardingReportState> emit,
      ) async {
    emit(state.copyWith(status: FWStatus.loading));

    try {
      Map<String, String> header = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      final resultData = await objfun.apiAllinoneSelectArray(
        "${objfun.apiGetFWData}${objfun.Comid}&startDate=${event.fromDate}&endDate=${event.toDate}",
        null,
        header,context
      );

      if (resultData != "" && resultData.length != 0) {
        emit(state.copyWith(
          status: FWStatus.success,
          saleFWReport: resultData["Data1"],
          saleFWReport2: resultData["Data2"],
        ));
      } else {
        emit(state.copyWith(status: FWStatus.success));
      }
    } catch (error, stackTrace) {
      emit(state.copyWith(
        status: FWStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void _onChangeFromDate(
      ChangFromDateEvent event,
      Emitter<ForwardingReportState> emit,
      ) {
    emit(state.copyWith(dtpFromDate: event.fromDate));
    add(LoadFWDataEvent(fromDate: event.fromDate, toDate: state.dtpToDate));
  }

  void _onChangeToDate(
      ChangeToDateEvent event,
      Emitter<ForwardingReportState> emit,
      ) {
    emit(state.copyWith(dtpToDate: event.toDate));
    add(LoadFWDataEvent(fromDate: state.dtpFromDate, toDate: event.toDate));
  }
}