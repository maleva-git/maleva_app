import 'package:equatable/equatable.dart';
import '../models/vesselplanningweb_model.dart';

abstract class VesselPlanningWebState extends Equatable {
  const VesselPlanningWebState();
  
  @override
  List<Object> get props => [];
}

class VesselPlanningWebInitial extends VesselPlanningWebState {}

class VesselPlanningWebLoading extends VesselPlanningWebState {}

class VesselPlanningWebLoaded extends VesselPlanningWebState {
  final List<VesselPlanningWebModel> dataList;

  const VesselPlanningWebLoaded({required this.dataList});

  @override
  List<Object> get props => [dataList];
}

class VesselPlanningWebActionLoading extends VesselPlanningWebState {}

class VesselPlanningWebActionSuccess extends VesselPlanningWebState {
  final String message;

  const VesselPlanningWebActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class VesselPlanningWebError extends VesselPlanningWebState {
  final String message;

  const VesselPlanningWebError({required this.message});

  @override
  List<Object> get props => [message];
}
