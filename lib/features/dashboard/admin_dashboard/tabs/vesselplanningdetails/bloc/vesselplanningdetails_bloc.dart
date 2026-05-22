import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/vesselplanningdetails/bloc/vesselplanningdetails_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/vesselplanningdetails/bloc/vesselplanningdetails_state.dart';



class VesselPlanningDetailsBloc extends Bloc<VesselPlanningDetailsEvent,
    VesselPlanningDetailsState> {
  VesselPlanningDetailsBloc()
      : super(const VesselPlanningDetailsState()) {
    on<VesselPlanningDetailsStartupRequested>(_onStartup);
    on<VesselPlanningDetailsRefreshRequested>(_onRefresh);
  }

  // ── Startup ───────────────────────────────────────────────────────────────

  Future<void> _onStartup(
      VesselPlanningDetailsStartupRequested event,
      Emitter<VesselPlanningDetailsState> emit,
      ) async {
    // If VesselPlanningEditList was pre-loaded by the previous page
    // (dashboard / vessel planning list), use it immediately so the
    // page renders without a spinner.
    if (objfun.VesselPlanningEditList.isNotEmpty) {
      emit(state.copyWith(
        status:             VesselPlanningDetailsStatus.success,
        vesselPlanningList: List<dynamic>.from(
            objfun.VesselPlanningEditList),
      ));
      return;
    }

    emit(state.copyWith(
        status: VesselPlanningDetailsStatus.loading));
    await _fetchData(emit);
  }

  Future<void> _onRefresh(
      VesselPlanningDetailsRefreshRequested event,
      Emitter<VesselPlanningDetailsState> emit,
      ) async {
    emit(state.copyWith(
        status: VesselPlanningDetailsStatus.loading));
    await _fetchData(emit);
  }

  // ── Core fetch ────────────────────────────────────────────────────────────

  Future<void> _fetchData(
      Emitter<VesselPlanningDetailsState> emit) async {
    try {
      final int comid = AppPreferences.getComid();

      final Map<String, dynamic> body = {
        'Comid':      comid,
        'Employeeid': objfun.EmpRefId,
        'Fromdate':   null,
        'Todate':     null,
      };

      final headers = {
        'Content-Type': 'application/json; charset=UTF-8'
      };

      final resultData = await objfun.apiAllinoneSelectArray(
        ApiConstants.VESSELPLANINGDB,
        body,
        headers,
        null, // context not passed into BLoC
      );

      if (resultData != null &&
          resultData is List &&
          resultData.isNotEmpty) {
        final list = List<dynamic>.from(resultData);

        // Keep global list in sync for pages that still read it
        objfun.VesselPlanningEditList = list;

        emit(state.copyWith(
          status:             VesselPlanningDetailsStatus.success,
          vesselPlanningList: list,
        ));
      } else {
        objfun.VesselPlanningEditList = [];
        emit(state.copyWith(
          status:             VesselPlanningDetailsStatus.success,
          vesselPlanningList: const [],
        ));
      }
    } catch (e, st) {
      emit(state.copyWith(
        status:       VesselPlanningDetailsStatus.failure,
        errorMessage: e.toString(),
      ));
      _log(e, st);
    }
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  void _log(Object e, StackTrace st) {
    assert(() {
      debugPrint('VesselPlanningDetailsBloc error: $e\n$st');
      return true;
    }());
  }
}