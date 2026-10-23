import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'rti_activities_event.dart';
import 'rti_activities_state.dart';
import '../../models/rti_route_activity.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/network/api_failure.dart';
import '../../../../../core/rti/rti_api.dart';
import '../../../../../core/utils/app_preferences.dart';

/// The forwarding agent's route stops, on the shared Java
/// `/api/rti-route-activities` (change `rti-on-shared-java-api`).
class RtiActivitiesBloc extends Bloc<RtiActivitiesEvent, RtiActivitiesState> {
  final RtiApi _api;
  int _failures = 0;

  RtiActivitiesBloc({RtiApi? api})
      : _api = api ?? GetIt.instance<RtiApi>(),
        super(RtiActivitiesInitial()) {

    on<FetchRtiActivities>(_onFetchRtiActivities);
    on<UpdateRtiStatus>(_onUpdateRtiStatus);
  }

  Future<void> _onFetchRtiActivities(FetchRtiActivities event, Emitter<RtiActivitiesState> emit) async {
    emit(RtiActivitiesLoading());
    try {
      final rows = await _api.routeActivities(
        fromDate: DateFormat('yyyy-MM-dd').format(event.fromDate),
        toDate: DateFormat('yyyy-MM-dd').format(event.toDate),
        employeeId: AppPreferences.getEmpRefId(),
      );
      emit(RtiActivitiesLoaded(rows.map(RtiRouteActivity.fromJava).toList()));
    } catch (e) {
      debugPrint('RTI Fetch Exception: $e');
      emit(RtiActivitiesError(e.toString()));
    }
  }

  Future<void> _onUpdateRtiStatus(UpdateRtiStatus event, Emitter<RtiActivitiesState> emit) async {
    // We only want to update if we currently have loaded activities
    if (state is RtiActivitiesLoaded) {
      final currentState = state as RtiActivitiesLoaded;
      try {
        await _api.setRouteActivityStatus(event.id, event.newStatus);

        // Optimistically update the UI
        final updatedActivities = currentState.activities.map((activity) {
          if (activity.id == event.id) {
            return RtiRouteActivity(
              id: activity.id,
              companyRefId: activity.companyRefId,
              rtiMasterRefId: activity.rtiMasterRefId,
              sequenceNo: activity.sequenceNo,
              locationName: activity.locationName,
              activityType: activity.activityType,
              employeeRefId: activity.employeeRefId,
              status: event.newStatus, // Updated Status
              plannedDateTime: activity.plannedDateTime,
              eta: activity.eta,
              remarks: activity.remarks,
              active: activity.active,
              createdDate: activity.createdDate,
              createdBy: activity.createdBy,
              modifiedDate: activity.modifiedDate,
              modifiedBy: activity.modifiedBy,
              agentMobileNo: activity.agentMobileNo,
              fullRoute: activity.fullRoute,
              driverNumber: activity.driverNumber,
              rtiNumber: activity.rtiNumber,
              employeeName: activity.employeeName,
              rtiMasterRemarks: activity.rtiMasterRemarks,
              marqisStatus: activity.marqisStatus,
            );
          }
          return activity;
        }).toList();

        final statusStr = event.newStatus == 1 ? 'COMPLETED' : 'PENDING';
        emit(RtiActivitiesActionSuccess("RTI Job Status successfully updated to $statusStr!", updatedActivities));
      } catch (e) {
        // Not saved: keep the list as it was and tell the agent, so they do not think it is done.
        debugPrint('Failed to update status: $e');
        final wanted = event.newStatus == 1 ? 'COMPLETED' : 'PENDING';
        var reason = e is ApiFailure && e.message.trim().isNotEmpty ? e.message.trim() : 'Something went wrong.';
        if (!RegExp(r'[.!?]$').hasMatch(reason)) reason = '$reason.';
        _failures++;
        emit(RtiActivitiesActionFailure(
          'Status not changed to $wanted. $reason Please try again.',
          currentState.activities,
          attempt: _failures,
        ));
      }
    }
  }
}
