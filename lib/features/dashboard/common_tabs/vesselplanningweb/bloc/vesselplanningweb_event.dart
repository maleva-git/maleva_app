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

/// Saves the plan [id] (0 new) with the ticked jobs [saleOrderIds] in their order.
class SaveVesselPlanningEvent extends VesselPlanningWebEvent {
  final int id;
  final DateTime from;
  final DateTime to;
  final DateTime planDate;
  final List<int> saleOrderIds;
  final String remarks;
  final String search;
  final int employeeId;

  const SaveVesselPlanningEvent({
    required this.id,
    required this.from,
    required this.to,
    required this.planDate,
    required this.saleOrderIds,
    required this.remarks,
    required this.search,
    required this.employeeId,
  });

  @override
  List<Object> get props => [id, from, to, planDate, saleOrderIds, remarks, search, employeeId];
}

class LoadPlanningForEditEvent extends VesselPlanningWebEvent {
  final Map<String, dynamic> planningMaster;

  const LoadPlanningForEditEvent({required this.planningMaster});

  @override
  List<Object> get props => [planningMaster];
}

class DeleteVesselPlanningEvent extends VesselPlanningWebEvent {
  final int id;

  const DeleteVesselPlanningEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class FetchVesselPlanningPdfEvent extends VesselPlanningWebEvent {
  final String planningNo;
  final int id;

  const FetchVesselPlanningPdfEvent({required this.planningNo, required this.id});

  @override
  List<Object> get props => [planningNo, id];
}
