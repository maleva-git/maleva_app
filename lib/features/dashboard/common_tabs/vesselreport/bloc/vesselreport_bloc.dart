import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;

import '../data/vessel_report_repository.dart';
import 'vesselreport_event.dart';
import 'vesselreport_state.dart';

class VesselBloc extends Bloc<VesselEvent, VesselState> {
  final VesselReportRepository repository;

  VesselBloc({required this.repository}) : super(const VesselInitial()) {
    on<LoadVesselDataEvent>(_onLoadVesselData);
    on<UpdatePortEvent>(_onUpdatePort);
    on<ClearPortEvent>(_onClearPort);
    on<AddPortToSearchEvent>(_onAddPortToSearch);
    on<ClearSearchEvent>(_onClearSearch);
    on<UpdateVesselDateEvent>(_onUpdateVesselDate);
  }

  Future<void> _onLoadVesselData(
      LoadVesselDataEvent event,
      Emitter<VesselState> emit,
      ) async {
    String currentPort = '';
    String currentSearch = '';
    bool currentIsPlanToday = event.type == 0;

    if (state is VesselLoadedState) {
      final s = state as VesselLoadedState;
      currentPort = s.portName;
      currentSearch = s.searchText;
    } else if (state is VesselFieldUpdatedState) {
      final s = state as VesselFieldUpdatedState;
      currentPort = s.portName;
      currentSearch = s.searchText;
    }

    emit(const VesselLoadingState());

    try {
      DateTime now = DateTime.now();
      DateTime newDate = now.add(Duration(days: event.type));
      String fromDate = DateFormat('yyyy-MM-dd').format(newDate);
      String toDate = DateFormat('yyyy-MM-dd').format(newDate);

      if (event.type == 0) {
        fromDate = "2025-02-01";
      }

      // ✅ If Boarding role (600), auto-load employee ports as Search
      String searchValue = currentSearch;
      if ((AppPreferences.getRoleId() == 600 || AppPreferences.getRoleId() == 500) && currentSearch.isEmpty) {
        List<String> employeePorts = await OnlineApi.GetEmployeeport(null);
        if (employeePorts.isEmpty) {
          // If no ports are assigned to this user, do not load all ports. Just return empty.
          emit(VesselLoadedState(
            vesselList: const [],
            isPlanToday: currentIsPlanToday,
            portName: currentPort,
            searchText: '',
          ));
          return;
        }
        searchValue = employeePorts.join(',');
      }

      final Map<String, dynamic> body = {
        'Comid': AppGlobals.storagenew.getInt('Comid') ?? 0,
        'Fromdate': fromDate,
        'Todate': toDate,
        'Search': searchValue,
        'Employeeid': 0,
        'ETAType': 0,
      };

      // ✅ REFACTORED: Calling repo without context
      final resultData = await repository.fetchVesselPlanningData(
        body: body,
      );

      // 🔍 DEBUG: Print the API response data in console
      debugPrint('🔍 VESSELPLANINGDB Response: $resultData');

      if (resultData == null || resultData == "" || (resultData is List && resultData.isEmpty)) {
        emit(VesselLoadedState(
          vesselList: const [],
          isPlanToday: currentIsPlanToday,
          portName: currentPort,
          searchText: searchValue,
        ));
        return;
      }

      if (resultData != null && resultData != "" && resultData.length != 0) {
        List<Map<String, dynamic>> list =
        List<Map<String, dynamic>>.from(resultData);

        list.sort((a, b) {
          String nameA = a['Port']?.toLowerCase() ?? '';
          String nameB = b['Port']?.toLowerCase() ?? '';
          return nameA.compareTo(nameB);
        });

        emit(VesselLoadedState(
          vesselList: list,
          isPlanToday: currentIsPlanToday,
          portName: currentPort,
          searchText: searchValue,
        ));
      }
    } catch (error) {
      // ApiClient throws clear exceptions, we emit them directly to the UI
      emit(VesselErrorState(errorMessage: error.toString()));
    }
  }

  void _onUpdatePort(UpdatePortEvent event, Emitter<VesselState> emit) {
    String currentSearch = _getCurrentSearch();
    emit(VesselFieldUpdatedState(portName: event.portName, searchText: currentSearch));
  }

  void _onClearPort(ClearPortEvent event, Emitter<VesselState> emit) {
    String currentSearch = _getCurrentSearch();
    emit(VesselFieldUpdatedState(portName: '', searchText: currentSearch));
  }

  Future<void> _onAddPortToSearch(AddPortToSearchEvent event, Emitter<VesselState> emit) async {
    String newSearch = event.currentSearch.isEmpty
        ? event.portName
        : '${event.currentSearch},${event.portName}';
    emit(VesselFieldUpdatedState(portName: '', searchText: newSearch));
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<VesselState> emit) {
    String currentPort = _getCurrentPort();
    emit(VesselFieldUpdatedState(portName: currentPort, searchText: ''));
  }

  String _getCurrentSearch() {
    if (state is VesselLoadedState) return (state as VesselLoadedState).searchText;
    if (state is VesselFieldUpdatedState) return (state as VesselFieldUpdatedState).searchText;
    return '';
  }

  String _getCurrentPort() {
    if (state is VesselLoadedState) return (state as VesselLoadedState).portName;
    if (state is VesselFieldUpdatedState) return (state as VesselFieldUpdatedState).portName;
    return '';
  }

  Future<void> _onUpdateVesselDate(UpdateVesselDateEvent event, Emitter<VesselState> emit) async {
    final currentState = state;
    emit(const VesselUpdateActionLoading());
    try {
      final message = await repository.updateVesselPlanningDates(event.updateData);
      // Wait for 1 second before showing success to ensure UI has time to load
      await Future.delayed(const Duration(milliseconds: 500));
      emit(VesselUpdateActionSuccess(message: message?.toString() ?? 'Success'));
      event.onSuccess();
      if (currentState is VesselLoadedState) {
        emit(currentState); // Restore the loaded state so list remains visible
      }
    } catch (e) {
      emit(VesselUpdateActionError(message: e.toString()));
      if (currentState is VesselLoadedState) {
        emit(currentState);
      }
    }
  }
}