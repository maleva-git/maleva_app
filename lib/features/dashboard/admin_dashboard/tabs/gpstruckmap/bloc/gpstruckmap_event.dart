

import 'package:equatable/equatable.dart';

import 'gpstruckmap_state.dart';

abstract class GpsTruckMapEvent extends Equatable {
  const GpsTruckMapEvent();
  @override
  List<Object?> get props => [];
}

/// Opens the tab — login + fetch all truck live positions
class LoadTruckPositions extends GpsTruckMapEvent {
  const LoadTruckPositions();
}

/// 30-second poll timer — refresh live positions
class RefreshTruckPositions extends GpsTruckMapEvent {
  const RefreshTruckPositions();
}

/// User tapped a truck marker — show bottom sheet
class SelectTruck extends GpsTruckMapEvent {
  final TruckPosition truck;
  const SelectTruck(this.truck);
  @override
  List<Object?> get props => [truck];
}

/// User tapped "View Path" — fetch today's route for selected truck
class LoadTruckPath extends GpsTruckMapEvent {
  final TruckPosition truck;
  const LoadTruckPath(this.truck);
  @override
  List<Object?> get props => [truck];
}

/// User dismissed bottom sheet or tapped close on path view
class ClearSelection extends GpsTruckMapEvent {
  const ClearSelection();
}