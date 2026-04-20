import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/speedingreport/bloc/speeding_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/speedingreport/bloc/speeding_state.dart';
import '../../../../../../core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class SpeedingBloc extends Bloc<SpeedingEvent, SpeedingState> {
  final BuildContext context;

  SpeedingBloc(this.context) : super(SpeedingInitial()) {
    on<LoadSpeedingReport>(_onLoadSpeedingReport);
  }

  Future<void> _onLoadSpeedingReport(
      LoadSpeedingReport event,
      Emitter<SpeedingState> emit,
      ) async {
    emit(SpeedingLoading());

    try {
      final String fromDate = DateFormat('MM/dd/yyyy').format(event.fromDate);
      final String toDate   = DateFormat('MM/dd/yyyy').format(event.toDate);

      final Map<String, dynamic> requestBody = {
        'Todate':   toDate,
        'Fromdate': fromDate,
        'Comid':    objfun.Comid,
      };

      final Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      final resultData = await objfun.apiAllinoneSelectArray(
        objfun.apiSelectSpeedingReport,
        requestBody,
        headers,
        context,
      );

      if (resultData != null && resultData.isNotEmpty) {
        final List<SpeedingView> records = (resultData as List)
            .map<SpeedingView>((e) => SpeedingView.fromJson(e))
            .toList();
        emit(SpeedingLoaded(records));
      } else {
        emit(SpeedingLoaded([]));
      }
    } catch (error) {
      emit(SpeedingError(error.toString()));
    }
  }
}