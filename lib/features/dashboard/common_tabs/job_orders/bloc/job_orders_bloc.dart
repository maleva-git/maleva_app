import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'job_orders_event.dart';
import 'job_orders_state.dart';
import '../models/job_order.dart';
import '../models/job_order_type.dart';
import '../models/job_order_detail.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_services/master_api.dart';
import '../../../../../core/models/shared/get_truck_model.dart';
import '../../../../../core/utils/app_preferences.dart';
import '../../../../../core/config/app_config.dart';

class JobOrdersBloc extends Bloc<JobOrdersEvent, JobOrdersState> {
  List<JobOrderType> _cachedJobTypes = [];
  List<GetTruckModel> _cachedTrucks = [];

  JobOrdersBloc() : super(JobOrdersInitial()) {
    on<FetchJobOrders>(_onFetchJobOrders);
    on<UpdateJobOrderStatus>(_onUpdateJobOrderStatus);
  }

  Future<void> _onUpdateJobOrderStatus(UpdateJobOrderStatus event, Emitter<JobOrdersState> emit) async {
    final currentState = state;
    if (currentState is JobOrdersLoaded) {
      try {
        final url = '${AppConfig.baseUrl}/api/JobOrderMasterApp/Updatejoborderstatus?StatusId=${event.statusId}&id=${event.jobId}';
        await ApiClient.postRequest(url, null);
        // Refetch job orders using the current filter after updating status
        add(FetchJobOrders(jId: currentState.selectedJId, tId: currentState.selectedTId));
      } catch (e) {
        debugPrint('Error updating job status: $e');
      }
    }
  }

  Future<void> _onFetchJobOrders(FetchJobOrders event, Emitter<JobOrdersState> emit) async {
    emit(JobOrdersLoading());
    try {
      final comid = AppPreferences.getComid();
      
      if (_cachedJobTypes.isEmpty) {
        final typesUrl = '${AppConfig.baseUrl}/api/JobOrderMasterApp/SelectJoborderType?Comid=$comid';
        try {
          // The API expects a POST request.
          final typesResponse = await ApiClient.postRequest(typesUrl, null);
          if (typesResponse != null && typesResponse is List) {
            _cachedJobTypes = typesResponse.map((e) => JobOrderType.fromJson(e)).toList();
          }
        } catch(e) {
          debugPrint('Error fetching job types: $e');
        }
      }

      if (_cachedTrucks.isEmpty) {
        try {
          _cachedTrucks = await MasterApi.getTrucks();
        } catch(e) {
          debugPrint('Error fetching trucks: $e');
        }
      }

      final String url = '${AppConfig.baseUrl}/api/JobOrderMasterApp/SelectJoborder';
      
      final body = {
        "Comid": comid,
        "DId": 0,
        "JId": event.jId,
        "TID": event.tId
      };

      final response = await ApiClient.postRequest(url, body);

      if (kDebugMode) {
        debugPrint('🔍 JOB ORDERS API RESPONSE: $response');
      }

      if (response != null && response is List && response.isNotEmpty) {
        // The API wraps the list in an array containing an object with "JobOrderList" and "JobOrderDetailList"
        final firstItem = response[0];
        if (firstItem is Map<String, dynamic>) {
          List<JobOrder> jobOrders = [];
          List<JobOrderDetail> jobDetails = [];

          if (firstItem.containsKey('JobOrderList')) {
            final List list = firstItem['JobOrderList'];
            jobOrders = list.map((e) => JobOrder.fromJson(e)).toList();
          }

          if (firstItem.containsKey('JobOrderDetailList')) {
            final List detailsList = firstItem['JobOrderDetailList'];
            jobDetails = detailsList.map((e) => JobOrderDetail.fromJson(e)).toList();
          }

          emit(JobOrdersLoaded(
            jobOrders,
            jobTypes: _cachedJobTypes,
            jobDetails: jobDetails,
            trucks: _cachedTrucks,
            selectedJId: event.jId,
            selectedTId: event.tId,
          ));
        } else {
          emit(JobOrdersLoaded(const [], jobTypes: _cachedJobTypes, jobDetails: const [], selectedJId: event.jId));
        }
      } else {
        emit(JobOrdersLoaded(const [], jobTypes: _cachedJobTypes, jobDetails: const [], selectedJId: event.jId));
      }
    } catch (e) {
      if (e.toString().contains('No Data Found') || e.toString().contains('404')) {
        emit(JobOrdersLoaded(const [], jobTypes: _cachedJobTypes, jobDetails: const [], selectedJId: event.jId));
      } else {
        debugPrint('Job Orders Fetch Exception: $e');
        emit(JobOrdersError(e.toString()));
      }
    }
  }
}
