import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class VesselPlanningWebEvent extends Equatable {
  const VesselPlanningWebEvent();

  @override
  List<Object> get props => [];
}

class FetchVesselPlanningSearch extends VesselPlanningWebEvent {
  final String fromDate;
  final String toDate;
  final int etaType;
  final String searchPorts;
  final bool deliveryDone;
  final int employeeId;

  const FetchVesselPlanningSearch({
    required this.fromDate,
    required this.toDate,
    required this.etaType,
    required this.searchPorts,
    required this.deliveryDone,
    required this.employeeId,
  });

  @override
  List<Object> get props => [fromDate, toDate, etaType, searchPorts, deliveryDone, employeeId];
}

class UpdateSpecificJobEvent extends VesselPlanningWebEvent {
  final Map<String, dynamic> updateData;
  final VoidCallback onSuccess;

  const UpdateSpecificJobEvent({required this.updateData, required this.onSuccess});

  @override
  List<Object> get props => [updateData];
}

class SaveVesselPlanningEvent extends VesselPlanningWebEvent {
  final List<Map<String, dynamic>> planningList;

  const SaveVesselPlanningEvent({required this.planningList});

  @override
  List<Object> get props => [planningList];
}

class FetchSavedPlanningsEvent extends VesselPlanningWebEvent {
  final String fromDate;
  final String toDate;
  final String search;
  final int employeeId;

  const FetchSavedPlanningsEvent({
    required this.fromDate,
    required this.toDate,
    required this.search,
    required this.employeeId,
  });

  @override
  List<Object> get props => [fromDate, toDate, search, employeeId];
}

class LoadPlanningForEditEvent extends VesselPlanningWebEvent {
  final Map<String, dynamic> planningMaster;

  const LoadPlanningForEditEvent({required this.planningMaster});

  @override
  List<Object> get props => [planningMaster];
}
