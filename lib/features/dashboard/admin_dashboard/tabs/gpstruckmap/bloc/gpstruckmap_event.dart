

import 'package:equatable/equatable.dart';

import 'gpstruckmap_state.dart';

abstract class GpsTruckMapEvent extends Equatable {
  const GpsTruckMapEvent();
  @override
  List<Object?> get props => [];
}

/// Fired once when the tab opens — logs in to Wialon and loads all units
class LoadTruckPositions extends GpsTruckMapEvent {
  const LoadTruckPositions();
}

/// Fired by the 30-second polling timer to refresh positions
class RefreshTruckPositions extends GpsTruckMapEvent {
  const RefreshTruckPositions();
}

/// User tapped a truck marker — load that truck's active sale-order jobs
class SelectTruck extends GpsTruckMapEvent {
  final TruckPosition truck;
  const SelectTruck(this.truck);
  @override
  List<Object?> get props => [truck];
}

/// User dismissed the bottom sheet
class ClearSelection extends GpsTruckMapEvent {
  const ClearSelection();
}