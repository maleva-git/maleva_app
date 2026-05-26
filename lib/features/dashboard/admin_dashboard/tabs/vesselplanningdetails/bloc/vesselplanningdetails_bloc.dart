import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/vesselplanningdetails_repository.dart'; // Adjust path based on your folder structure
import 'vesselplanningdetails_event.dart';
import 'vesselplanningdetails_state.dart';

class VesselPlanningDetailsBloc extends Bloc<VesselPlanningDetailsEvent, VesselPlanningDetailsState> {
  final VesselPlanningDetailsRepository repository;

  VesselPlanningDetailsBloc({required this.repository}) : super(const VesselPlanningDetailsState()) {
    on<VesselPlanningDetailsStartupRequested>(_onStartup);
    on<VesselPlanningDetailsRefreshRequested>(_onRefresh);
  }

  // ── Startup ───────────────────────────────────────────────────────────────
  Future<void> _onStartup(
      VesselPlanningDetailsStartupRequested event,
      Emitter<VesselPlanningDetailsState> emit,
      ) async {
    // Check repository for pre-loaded list
    final preloadedList = repository.getPreloadedData();

    if (preloadedList.isNotEmpty) {
      emit(state.copyWith(
        status: VesselPlanningDetailsStatus.success,
        vesselPlanningList: List<dynamic>.from(preloadedList),
      ));
      return;
    }

    emit(state.copyWith(status: VesselPlanningDetailsStatus.loading));
    await _fetchData(emit);
  }

  Future<void> _onRefresh(
      VesselPlanningDetailsRefreshRequested event,
      Emitter<VesselPlanningDetailsState> emit,
      ) async {
    emit(state.copyWith(status: VesselPlanningDetailsStatus.loading));
    await _fetchData(emit);
  }

  // ── Core fetch ────────────────────────────────────────────────────────────
  Future<void> _fetchData(Emitter<VesselPlanningDetailsState> emit) async {
    try {
      final list = await repository.fetchVesselPlanningData();

      emit(state.copyWith(
        status: VesselPlanningDetailsStatus.success,
        vesselPlanningList: list,
      ));
    } catch (e, st) {
      emit(state.copyWith(
        status: VesselPlanningDetailsStatus.failure,
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