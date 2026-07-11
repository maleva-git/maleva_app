import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';

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

      final Map<String, dynamic> body = {
        'Comid': AppGlobals.storagenew.getInt('Comid') ?? 0,
        'Fromdate': fromDate,
        'Todate': toDate,
        'Search': currentSearch,
        'Employeeid': 0,
        'ETAType': 0,
      };

      // ✅ REFACTORED: Calling repo without context
      final resultData = await repository.fetchVesselPlanningData(
        body: body,
      );

      if (resultData == null || resultData == "" || (resultData is List && resultData.isEmpty)) {
        emit(VesselLoadedState(
          vesselList: const [],
          isPlanToday: currentIsPlanToday,
          portName: currentPort,
          searchText: currentSearch,
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
          searchText: currentSearch,
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
}