import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'rti_activities_event.dart';
import 'rti_activities_state.dart';
import '../../models/rti_route_activity.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/app_preferences.dart';
import '../../../../../core/config/app_config.dart';

class RtiActivitiesBloc extends Bloc<RtiActivitiesEvent, RtiActivitiesState> {
  RtiActivitiesBloc() : super(RtiActivitiesInitial()) {

    on<FetchRtiActivities>(_onFetchRtiActivities);
    on<UpdateRtiStatus>(_onUpdateRtiStatus);
  }

  Future<void> _onFetchRtiActivities(FetchRtiActivities event, Emitter<RtiActivitiesState> emit) async {
    emit(RtiActivitiesLoading());
    try {
      final comid = AppPreferences.getComid();
      final employeeRefId = AppPreferences.getEmpRefId();
      final fromDateStr = DateFormat('yyyy-MM-dd').format(event.fromDate);
      final toDateStr = DateFormat('yyyy-MM-dd').format(event.toDate);
      
      final String url = '${AppConfig.baseUrl}/api/RTIApp/SelectRTIRouteActivities?Comid=$comid&Fromdate=$fromDateStr&Todate=$toDateStr&Employeerefid=$employeeRefId';
      
      final response = await ApiClient.postRequest(url, null);

      if (kDebugMode) {
        debugPrint('🔍 RTI API RESPONSE: $response');
      }

      if (response != null && response is List) {
        final activities = response.map((e) => RtiRouteActivity.fromJson(e)).toList();
        emit(RtiActivitiesLoaded(activities));
      } else {
        emit(const RtiActivitiesLoaded([]));
      }
    } catch (e) {
      if (e.toString().contains('No Data Found') || e.toString().contains('404')) {
        emit(const RtiActivitiesLoaded([]));
      } else {
        print('RTI Fetch Exception: $e');
        emit(RtiActivitiesError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateRtiStatus(UpdateRtiStatus event, Emitter<RtiActivitiesState> emit) async {
    // We only want to update if we currently have loaded activities
    if (state is RtiActivitiesLoaded) {
      final currentState = state as RtiActivitiesLoaded;
      try {
        final url = '${AppConfig.baseUrl}/api/RTIApp/UpdateRootactivity?Id=${event.id}&StatusId=${event.newStatus}';
        final response = await ApiClient.postRequest(url, null);
        
        if (kDebugMode) {
          debugPrint('🔍 UPDATE RTI STATUS RESPONSE: $response');
        }
        
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
        // On error, we could rollback or just emit error
        debugPrint('Failed to update status: $e');
      }
    }
  }
}
