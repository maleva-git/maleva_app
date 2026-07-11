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
  final List<Map<String, dynamic>> updateList;
  final Function() onSuccess;

  const UpdateSpecificJobEvent({required this.updateList, required this.onSuccess});

  @override
  List<Object> get props => [updateList];
}

class SaveVesselPlanningEvent extends VesselPlanningWebEvent {
  final List<Map<String, dynamic>> planningList;

  const SaveVesselPlanningEvent({required this.planningList});

  @override
  List<Object> get props => [planningList];
}
