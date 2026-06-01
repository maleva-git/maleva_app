import 'package:equatable/equatable.dart';

abstract class VesselPlanningDetailsEvent extends Equatable {
  const VesselPlanningDetailsEvent();
  @override
  List<Object?> get props => [];
}

class VesselPlanningDetailsStartupRequested extends VesselPlanningDetailsEvent {
  final int masterRefId; // ✅ Define the variable

  // ✅ Accept it as a positional argument
  const VesselPlanningDetailsStartupRequested(this.masterRefId);

  @override
  List<Object?> get props => [masterRefId];
}

class VesselPlanningDetailsRefreshRequested extends VesselPlanningDetailsEvent {
  final int masterRefId; // ✅ Define the variable

  // ✅ Accept it as a positional argument
  const VesselPlanningDetailsRefreshRequested(this.masterRefId);

  @override
  List<Object?> get props => [masterRefId];
}

// Keep this if you have a search feature on this page, otherwise you can ignore it
class VesselPlanningDetailsSearchChanged extends VesselPlanningDetailsEvent {
  final String query;
  const VesselPlanningDetailsSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}