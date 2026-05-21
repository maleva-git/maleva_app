import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/planningdetailsview/bloc/planningdetails_event.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/planningdetailsview/bloc/planningdetails_state.dart';



class PlanningDetailsBloc
    extends Bloc<PlanningDetailsEvent, PlanningDetailsState> {
  PlanningDetailsBloc() : super(const PlanningDetailsState()) {
    on<PlanningDetailsStartupRequested>(_onStartup);
    on<PlanningDetailsRefreshRequested>(_onRefresh);
    on<PlanningDetailsSearchChanged>(_onSearchChanged);
  }

  // ── Startup ───────────────────────────────────────────────────────────────

  Future<void> _onStartup(
      PlanningDetailsStartupRequested event,
      Emitter<PlanningDetailsState> emit,
      ) async {
    emit(state.copyWith(status: PlanningDetailsStatus.loading));
    await _fetchData(emit);
  }

  Future<void> _onRefresh(
      PlanningDetailsRefreshRequested event,
      Emitter<PlanningDetailsState> emit,
      ) async {
    emit(state.copyWith(status: PlanningDetailsStatus.loading));
    await _fetchData(emit);
  }

  // ── Search — pure client-side filter, no API call ─────────────────────────

  void _onSearchChanged(
      PlanningDetailsSearchChanged event,
      Emitter<PlanningDetailsState> emit,
      ) {
    final filtered = _applyFilter(state.planningList, event.query);
    emit(state.copyWith(
      searchQuery:          event.query,
      filteredPlanningList: filtered,
    ));
  }

  // ── Core API fetch ────────────────────────────────────────────────────────

  Future<void> _fetchData(Emitter<PlanningDetailsState> emit) async {
    try {
      final int comid = AppPreferences.getComid();

      final Map<String, dynamic> body = {
        'Comid':      comid,
        'Employeeid': objfun.EmpRefId,
        'Fromdate':   null,
        'Todate':     null,
      };

      final headers = {'Content-Type': 'application/json; charset=UTF-8'};

      final resultData = await objfun.apiAllinoneSelectArray(
        ApiConstants.PLANINGSearch,
        body,
        headers,
        null, // context not needed in BLoC
      );

      if (resultData != null &&
          resultData is List &&
          resultData.isNotEmpty) {
        final list = List<dynamic>.from(resultData);

        // Keep global list in sync (other pages may read it)
        objfun.PlanningEditList = list;

        emit(state.copyWith(
          status:               PlanningDetailsStatus.success,
          planningList:         list,
          filteredPlanningList: list, // show all on initial load
          searchQuery:          '',
        ));
      } else {
        objfun.PlanningEditList = [];
        emit(state.copyWith(
          status:               PlanningDetailsStatus.success,
          planningList:         const [],
          filteredPlanningList: const [],
        ));
      }
    } catch (e, st) {
      emit(state.copyWith(
        status:       PlanningDetailsStatus.failure,
        errorMessage: e.toString(),
      ));
      _log(e, st);
    }
  }

  // ── Client-side filter ────────────────────────────────────────────────────
  // Matches the original searchPlanning logic:
  // "Search by Planning No / PIC / Date / Port"

  List<dynamic> _applyFilter(List<dynamic> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.toLowerCase();
    return list.where((item) {
      return _contains(item['JobNo'],          q) ||
          _contains(item['Remarks'],        q) ||
          _contains(item['EmployeeName'],   q) ||  // PIC
          _contains(item['SPickupDate'],    q) ||
          _contains(item['SDeliveryDate'],  q) ||
          _contains(item['Origin'],         q) ||
          _contains(item['Destination'],    q) ||
          _contains(item['VesselName'],     q) ||
          _contains(item['CustomerName'],   q) ||
          _contains(item['TruckName'],      q) ||
          _contains(item['LETA'],           q) ||
          _contains(item['OETA'],           q);
    }).toList();
  }

  bool _contains(dynamic field, String query) =>
      field?.toString().toLowerCase().contains(query) ?? false;

  void _log(Object e, StackTrace st) {
    assert(() {
      debugPrint('PlanningDetailsBloc error: $e\n$st');
      return true;
    }());
  }
}