import 'package:maleva/core/network/api_legacy_helper.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'air_frieghtvessel_dashboard_event.dart';
import 'air_frieghtvessel_dashboard_state.dart';


class VesselDashboardBloc extends Bloc<VesselDashboardEvent, VesselDashboardState> {
  VesselDashboardBloc() : super(VesselDashboardState.initial()) {
    on<VesselDashboardStarted>(_onStarted);
    on<VesselDatesChanged>(_onDatesChanged);
    on<VesselStatusSelected>(_onStatusSelected);
    on<VesselStatusCleared>(_onStatusCleared);
    on<VesselPortAdded>(_onPortAdded);
    on<VesselRemarksCleared>(_onRemarksCleared);
    on<VesselLoadRequested>(_onLoadRequested);
  }

  void _onStarted(VesselDashboardStarted event, Emitter<VesselDashboardState> emit) {
    add(VesselLoadRequested());
  }

  void _onDatesChanged(VesselDatesChanged event, Emitter<VesselDashboardState> emit) {
    emit(state.copyWith(fromDate: event.fromDate, toDate: event.toDate));
  }

  void _onStatusSelected(VesselStatusSelected event, Emitter<VesselDashboardState> emit) {
    emit(state.copyWith(statusId: event.statusId, statusName: event.statusName));
  }

  void _onStatusCleared(VesselStatusCleared event, Emitter<VesselDashboardState> emit) {
    emit(state.copyWith(statusId: 0, statusName: ''));
  }

  void _onPortAdded(VesselPortAdded event, Emitter<VesselDashboardState> emit) {
    String newRemarks = state.remarks.isNotEmpty ? "${state.remarks},${event.port}" : event.port;
    emit(state.copyWith(remarks: newRemarks));
  }

  void _onRemarksCleared(VesselRemarksCleared event, Emitter<VesselDashboardState> emit) {
    emit(state.copyWith(remarks: ''));
  }

  Future<void> _onLoadRequested(VesselLoadRequested event, Emitter<VesselDashboardState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    try {
      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;

      final master = {
        'Comid': comid,
        'Fromdate': state.fromDate,
        'Todate': state.toDate,
        'Search': state.remarks,
        'Employeeid': 0,
        'ETAType': 5,
        'StatusId': state.statusId
      };

      final result = await ApiLegacyHelper.apiAllinoneSelectArray(ApiConstants.AirFrieghtDB, master, header, null);

      if (result != null && result is List) {
        result.sort((a, b) => (a['Port'] ?? '').toString().toLowerCase().compareTo((b['Port'] ?? '').toString().toLowerCase()));
        emit(state.copyWith(vesselList: result, isLoading: false));
      } else {
        emit(state.copyWith(vesselList: [], isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}