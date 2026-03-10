import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'enginehours_event.dart';
import 'enginehours_state.dart';

class EngineHoursBloc extends Bloc<EngineHoursEvent, EngineHoursState> {
  final BuildContext context;

  EngineHoursBloc(this.context) : super(EngineHoursInitial()) {
    on<LoadEngineHoursReport>(_onLoadEngineHoursReport);
  }

  Future<void> _onLoadEngineHoursReport(
      LoadEngineHoursReport event,
      Emitter<EngineHoursState> emit,
      ) async {
    emit(EngineHoursLoading());

    try {
      final DateTime today = DateTime.now();
      final DateTime startOfMonth = DateTime(today.year, today.month, 1);
      final DateTime endOfMonth = DateTime(today.year, today.month + 1, 0);

      final String fromDate = DateFormat('MM/dd/yyyy').format(startOfMonth);
      final String toDate = DateFormat('MM/dd/yyyy').format(endOfMonth);

      final Map<String, dynamic> requestBody = {
        'Todate': toDate,
        'Fromdate': fromDate,
        'Comid': objfun.Comid,
      };

      final Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      final resultData = await objfun.apiAllinoneSelectArray(
        objfun.apiSelectEangiehoursReport,
        requestBody,
        headers,
        context,
      );

      if (resultData != null && resultData.isNotEmpty) {
        final List<EngineHoursdata> records = (resultData as List)
            .map<EngineHoursdata>((e) => EngineHoursdata.fromJson(e))
            .toList();
        emit(EngineHoursLoaded(records));
      } else {
        emit(EngineHoursLoaded([]));
      }
    } catch (error) {
      emit(EngineHoursError(error.toString()));
    }
  }
}