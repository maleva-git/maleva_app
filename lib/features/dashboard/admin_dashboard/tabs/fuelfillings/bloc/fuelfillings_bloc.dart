import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import 'fuelfillings_event.dart';
import 'fuelfillings_state.dart';

class FuelFillingBloc extends Bloc<FuelFillingEvent, FuelFillingState> {
  final BuildContext context;

  FuelFillingBloc(this.context) : super(FuelFillingInitial()) {
    on<LoadFuelFillingReport>(_onLoadFuelFillingReport);
  }

  Future<void> _onLoadFuelFillingReport(
      LoadFuelFillingReport event,
      Emitter<FuelFillingState> emit,
      ) async {
    emit(FuelFillingLoading());

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
        objfun.apiSelectFuelFillingReport,
        requestBody,
        headers,
        context,
      );

      if (resultData != null && resultData.isNotEmpty) {
        final List<FuelFilling> records = (resultData as List)
            .map<FuelFilling>((e) => FuelFilling.fromJson(e))
            .toList();
        emit(FuelFillingLoaded(records));
      } else {
        emit(FuelFillingLoaded([]));
      }
    } catch (error) {
      emit(FuelFillingError(error.toString()));
    }
  }
}