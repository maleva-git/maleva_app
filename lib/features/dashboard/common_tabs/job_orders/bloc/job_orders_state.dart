import 'package:equatable/equatable.dart';
import '../models/job_order.dart';
import '../models/job_order_type.dart';
import '../models/job_order_detail.dart';
import '../../../../../core/models/shared/get_truck_model.dart';

abstract class JobOrdersState extends Equatable {
  const JobOrdersState();
  @override
  List<Object?> get props => [];
}

class JobOrdersInitial extends JobOrdersState {}

class JobOrdersLoading extends JobOrdersState {}

class JobOrdersLoaded extends JobOrdersState {
  final List<JobOrder> jobOrders;
  final List<JobOrderType> jobTypes;
  final List<JobOrderDetail> jobDetails;
  final List<GetTruckModel> trucks;
  final int selectedJId;
  final int selectedTId;

  const JobOrdersLoaded(
    this.jobOrders, {
    this.jobTypes = const [],
    this.jobDetails = const [],
    this.trucks = const [],
    this.selectedJId = 1,
    this.selectedTId = 0,
  });

  @override
  List<Object?> get props => [jobOrders, jobTypes, jobDetails, trucks, selectedJId, selectedTId];
}

class JobOrdersError extends JobOrdersState {
  final String message;
  const JobOrdersError(this.message);
  @override
  List<Object?> get props => [message];
}
