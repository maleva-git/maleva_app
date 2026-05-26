import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/planning_details_repository.dart'; // Adjust path based on your folder structure
import 'planningdetails_event.dart';
import 'planningdetails_state.dart';

class PlanningDetailsBloc extends Bloc<PlanningDetailsEvent, PlanningDetailsState> {
  final PlanningDetailsRepository repository;

  PlanningDetailsBloc({required this.repository}) : super(const PlanningDetailsState()) {
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

  // ── Search — pure client-side filter ──────────────────────────────────────
  void _onSearchChanged(
      PlanningDetailsSearchChanged event,
      Emitter<PlanningDetailsState> emit,
      ) {
    final filtered = _applyFilter(state.planningList, event.query);
    emit(state.copyWith(
      searchQuery: event.query,
      filteredPlanningList: filtered,
    ));
  }

  // ── Core API fetch ────────────────────────────────────────────────────────
  Future<void> _fetchData(Emitter<PlanningDetailsState> emit) async {
    try {
      final list = await repository.fetchPlanningDetails();

      emit(state.copyWith(
        status: PlanningDetailsStatus.success,
        planningList: list,
        filteredPlanningList: list, // show all on initial load
        searchQuery: '',
      ));
    } catch (e, st) {
      emit(state.copyWith(
        status: PlanningDetailsStatus.failure,
        errorMessage: e.toString(),
      ));
      _log(e, st);
    }
  }

  // ── Client-side filter ────────────────────────────────────────────────────
  List<dynamic> _applyFilter(List<dynamic> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.toLowerCase();
    return list.where((item) {
      return _contains(item['JobNo'], q) ||
          _contains(item['Remarks'], q) ||
          _contains(item['EmployeeName'], q) ||
          _contains(item['SPickupDate'], q) ||
          _contains(item['SDeliveryDate'], q) ||
          _contains(item['Origin'], q) ||
          _contains(item['Destination'], q) ||
          _contains(item['VesselName'], q) ||
          _contains(item['CustomerName'], q) ||
          _contains(item['TruckName'], q) ||
          _contains(item['LETA'], q) ||
          _contains(item['OETA'], q);
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