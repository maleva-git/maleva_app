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
  final String? planningNo;


  
  final Map<String, dynamic>? masterData;


  const VesselPlanningWebLoaded({required this.dataList, this.planningNo, this.masterData});

  @override
  List<Object> get props => [dataList, if (planningNo != null) planningNo!, if (masterData != null) masterData!];
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

class VesselPlanningPdfLaunchSuccess extends VesselPlanningWebState {
  final String url;

  const VesselPlanningPdfLaunchSuccess(this.url);

  @override
  List<Object> get props => [url];
}

class VesselPlanningPdfLaunchError extends VesselPlanningWebState {
  final String message;

  const VesselPlanningPdfLaunchError(this.message);

  @override
  List<Object> get props => [message];
}
