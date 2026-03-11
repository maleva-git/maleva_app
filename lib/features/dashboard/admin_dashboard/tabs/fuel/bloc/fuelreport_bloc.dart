import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import 'fuelreport_event.dart';
import 'fuelreport_state.dart';



class FuelDiffBloc extends Bloc<FuelDiffEvent, FuelDiffState> {
  final BuildContext context;

  FuelDiffBloc(this.context)
      : super(FuelDiffLoaded(
    records: [],
    fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  )) {
    on<SelectFromDateEvent>(_onSelectFromDate);
    on<SelectToDateEvent>(_onSelectToDate);
    on<LoadFuelDiffEvent>(_onLoadFuelDiff);
  }

  // ── 1. From Date Select ─────────────────────────────────────────────────────
  void _onSelectFromDate(
      SelectFromDateEvent event,
      Emitter<FuelDiffState> emit,
      ) {
    if (state is FuelDiffLoaded) {
      emit((state as FuelDiffLoaded).copyWith(fromDate: event.date));
    }
  }

  // ── 2. To Date Select ───────────────────────────────────────────────────────
  void _onSelectToDate(
      SelectToDateEvent event,
      Emitter<FuelDiffState> emit,
      ) {
    if (state is FuelDiffLoaded) {
      emit((state as FuelDiffLoaded).copyWith(toDate: event.date));
    }
  }

  // ── 3. Load Fuel Difference ─────────────────────────────────────────────────
  Future<void> _onLoadFuelDiff(
      LoadFuelDiffEvent event,
      Emitter<FuelDiffState> emit,
      ) async {
    if (state is! FuelDiffLoaded) return;
    final current = state as FuelDiffLoaded;

    emit(FuelDiffLoading());

    try {
      final Map<String, dynamic> requestBody = {
        'Comid': objfun.storagenew.getInt('Comid') ?? 0,
        'Fromdate': current.fromDate,
        'Todate': current.toDate,
        'Employeeid': 0,
        'DId': 0,
        'TId': 0,
        'Search': '',
      };

      final Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
      };

      final resultData = await objfun.apiAllinoneSelectArray(
        objfun.apiSelectFuelEntry,
        requestBody,
        headers,
        context,
      );

      if (resultData != null &&
          resultData is List &&
          resultData.isNotEmpty) {
        final List<FuelselectModel> records = resultData
            .map((e) => FuelselectModel.fromJson(e as Map<String, dynamic>))
            .toList();

        emit(current.copyWith(records: records));
      } else {
        emit(current.copyWith(records: []));
      }
    } catch (e) {
      emit(FuelDiffError(e.toString()));
    }
  }
}