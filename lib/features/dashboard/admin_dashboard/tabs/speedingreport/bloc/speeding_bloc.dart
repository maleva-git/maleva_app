import 'package:flutter/Material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/models/model.dart';

import 'package:maleva/core/utils/clsfunction.dart' as objfun;

part 'speeding_event.dart';
part 'speeding_state.dart';

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
        objfun.apiSelectSpeedingReport,
        requestBody,
        headers,
        context
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