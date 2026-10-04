import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'job_orders_event.dart';
import 'job_orders_state.dart';
import '../models/job_order.dart';
import '../models/job_order_type.dart';
import '../models/job_order_detail.dart';
import '../../../../../core/job_order/job_order_api.dart';
import '../../../../../core/network/api_services/master_api.dart';
import '../../../../../core/models/shared/get_truck_model.dart';

/// The Job Orders tab, on the shared Java `/api/job-orders`
/// (change `job-orders-on-shared-java-api`).
class JobOrdersBloc extends Bloc<JobOrdersEvent, JobOrdersState> {
  final JobOrderApi _api;
  final Future<List<GetTruckModel>> Function() _loadTrucks;
  List<JobOrderType> _cachedJobTypes = [];
  List<GetTruckModel> _cachedTrucks = [];
  Map<int, String> _productNames = {};

  JobOrdersBloc({JobOrderApi? api, Future<List<GetTruckModel>> Function()? loadTrucks})
      : _api = api ?? GetIt.instance<JobOrderApi>(),
        _loadTrucks = loadTrucks ?? MasterApi.getTrucks,
        super(JobOrdersInitial()) {
    on<FetchJobOrders>(_onFetchJobOrders);
    on<UpdateJobOrderStatus>(_onUpdateJobOrderStatus);
  }

  Future<void> _onUpdateJobOrderStatus(UpdateJobOrderStatus event, Emitter<JobOrdersState> emit) async {
    final currentState = state;
    if (currentState is JobOrdersLoaded) {
      try {
        await _api.updateStatus(event.jobId, event.statusId);
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
      if (_cachedJobTypes.isEmpty) {
        try {
          _cachedJobTypes = (await _api.statuses()).map(JobOrderType.fromJava).toList();
        } catch (e) {
          debugPrint('Error fetching job statuses: $e');
        }
      }

      if (_cachedTrucks.isEmpty) {
        try {
          _cachedTrucks = await _loadTrucks();
        } catch (e) {
          debugPrint('Error fetching trucks: $e');
        }
      }

      if (_productNames.isEmpty) {
        try {
          _productNames = await _api.productNames();
        } catch (e) {
          debugPrint('Error fetching products: $e');
        }
      }

      final rows = await _api.list(statusId: event.jId, truckId: event.tId);

      final jobOrders = rows.map(JobOrder.fromJava).toList();
      final jobDetails = <JobOrderDetail>[
        for (final row in rows)
          for (final d in (row['details'] is List ? row['details'] as List : const []))
            if (d is Map) JobOrderDetail.fromJava(Map<String, dynamic>.from(d), productNames: _productNames),
      ].where((d) => d.active).toList();

      emit(JobOrdersLoaded(
        jobOrders,
        jobTypes: _cachedJobTypes,
        jobDetails: jobDetails,
        trucks: _cachedTrucks,
        selectedJId: event.jId,
        selectedTId: event.tId,
      ));
    } catch (e) {
      debugPrint('Job Orders Fetch Exception: $e');
      emit(JobOrdersError(e.toString()));
    }
  }
}
