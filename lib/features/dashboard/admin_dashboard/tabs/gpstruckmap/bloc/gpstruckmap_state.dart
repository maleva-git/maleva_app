

// ─────────────────────────────────────────────────────────────────────────────
//  Models
// ─────────────────────────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class TruckPosition extends Equatable {
  final int      unitId;
  final String   truckName;
  final double   lat;
  final double   lng;
  final double   speedKmh;
  final String   lastUpdate;  // formatted "08 May 14:32"
  final DateTime lastSeen;

  const TruckPosition({
    required this.unitId,
    required this.truckName,
    required this.lat,
    required this.lng,
    required this.speedKmh,
    required this.lastUpdate,
    required this.lastSeen,
  });

  bool get isMoving  => speedKmh > 2.0;
  bool get isOffline => DateTime.now().difference(lastSeen).inMinutes > 60;

  @override
  List<Object?> get props => [unitId, lat, lng, speedKmh];
}

/// A single GPS breadcrumb in today's path
class PathPoint extends Equatable {
  final double lat;
  final double lng;
  final double speedKmh;
  final DateTime time;

  const PathPoint({
    required this.lat,
    required this.lng,
    required this.speedKmh,
    required this.time,
  });

  @override
  List<Object?> get props => [lat, lng];
}

// ─────────────────────────────────────────────────────────────────────────────
//  States
// ─────────────────────────────────────────────────────────────────────────────

abstract class GpsTruckMapState extends Equatable {
  const GpsTruckMapState();
  @override
  List<Object?> get props => [];
}

class GpsTruckMapInitial  extends GpsTruckMapState { const GpsTruckMapInitial(); }
class GpsTruckMapLoading  extends GpsTruckMapState { const GpsTruckMapLoading(); }

class GpsTruckMapError extends GpsTruckMapState {
  final String message;
  const GpsTruckMapError(this.message);
  @override
  List<Object?> get props => [message];
}

class GpsTruckMapLoaded extends GpsTruckMapState {
  final List<TruckPosition> trucks;
  final TruckPosition?      selected;       // non-null = bottom sheet open
  final List<PathPoint>     path;           // non-empty = polyline drawn
  final bool                isRefreshing;
  final bool                isLoadingPath;

  const GpsTruckMapLoaded({
    required this.trucks,
    this.selected,
    this.path            = const [],
    this.isRefreshing    = false,
    this.isLoadingPath   = false,
  });

  // Summary counts for the top bar
  int get total   => trucks.length;
  int get moving  => trucks.where((t) =>  t.isMoving && !t.isOffline).length;
  int get idle    => trucks.where((t) => !t.isMoving && !t.isOffline).length;
  int get offline => trucks.where((t) =>  t.isOffline).length;

  bool get hasPath => path.isNotEmpty;

  GpsTruckMapLoaded copyWith({
    List<TruckPosition>? trucks,
    TruckPosition?       selected,
    List<PathPoint>?     path,
    bool?                isRefreshing,
    bool?                isLoadingPath,
    bool                 clearSelected = false,
    bool                 clearPath     = false,
  }) =>
      GpsTruckMapLoaded(
        trucks:        trucks        ?? this.trucks,
        selected:      clearSelected ? null   : (selected      ?? this.selected),
        path:          clearPath     ? const [] : (path         ?? this.path),
        isRefreshing:  isRefreshing  ?? this.isRefreshing,
        isLoadingPath: isLoadingPath ?? this.isLoadingPath,
      );

  @override
  List<Object?> get props => [trucks, selected, path, isRefreshing, isLoadingPath];
}