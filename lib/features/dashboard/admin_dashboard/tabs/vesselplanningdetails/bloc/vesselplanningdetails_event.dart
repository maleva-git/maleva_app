
import 'package:equatable/equatable.dart';

abstract class VesselPlanningDetailsEvent extends Equatable {
  const VesselPlanningDetailsEvent();
  @override
  List<Object?> get props => [];
}

/// Initial load on page entry
class VesselPlanningDetailsStartupRequested
    extends VesselPlanningDetailsEvent {
  const VesselPlanningDetailsStartupRequested();
}

/// Pull-to-refresh
class VesselPlanningDetailsRefreshRequested
    extends VesselPlanningDetailsEvent {
  const VesselPlanningDetailsRefreshRequested();
}