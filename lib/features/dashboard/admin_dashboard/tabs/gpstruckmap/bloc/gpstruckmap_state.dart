

import 'package:equatable/equatable.dart';

/// A single truck's live position from Wialon
class TruckPosition extends Equatable {
  final int    unitId;
  final String truckName;  // matches TruckNumber in your DB
  final double lat;
  final double lng;
  final double speedKmh;
  final String lastUpdate; // human-readable

  const TruckPosition({
    required this.unitId,
    required this.truckName,
    required this.lat,
    required this.lng,
    required this.speedKmh,
    required this.lastUpdate,
  });

  bool get isMoving => speedKmh > 2.0;

  @override
  List<Object?> get props => [unitId, lat, lng, speedKmh];
}

abstract class GpsTruckMapState extends Equatable {
  const GpsTruckMapState();
  @override
  List<Object?> get props => [];
}

class GpsTruckMapInitial extends GpsTruckMapState {
  const GpsTruckMapInitial();
}

class GpsTruckMapLoading extends GpsTruckMapState {
  const GpsTruckMapLoading();
}

class GpsTruckMapLoaded extends GpsTruckMapState {
  final List<TruckPosition> trucks;
  final TruckPosition?      selected;  // non-null when bottom sheet is open
  final bool                isRefreshing;

  const GpsTruckMapLoaded({
    required this.trucks,
    this.selected,
    this.isRefreshing = false,
  });

  GpsTruckMapLoaded copyWith({
    List<TruckPosition>? trucks,
    TruckPosition?       selected,
    bool?                isRefreshing,
    bool                 clearSelected = false,
  }) {
    return GpsTruckMapLoaded(
      trucks:        trucks       ?? this.trucks,
      selected:      clearSelected ? null : (selected ?? this.selected),
      isRefreshing:  isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [trucks, selected, isRefreshing];
}

class GpsTruckMapError extends GpsTruckMapState {
  final String message;
  const GpsTruckMapError(this.message);
  @override
  List<Object?> get props => [message];
}