

import '../../../../../../core/models/model.dart';

abstract class TruckDetailsState  {
  const TruckDetailsState();

  @override
  List<Object?> get props => [];
}

// ── Initial ────────────────────────────────────────────────────────────────────
class TruckInitial extends TruckDetailsState {
  const TruckInitial();
}

// ── Loading ────────────────────────────────────────────────────────────────────
class TruckLoadingState extends TruckDetailsState {
  const TruckLoadingState();
}

// ── Loaded ─────────────────────────────────────────────────────────────────────
class TruckLoadedState extends TruckDetailsState {
  final List<TruckDetailsModel> truckData;

  const TruckLoadedState({required this.truckData});

  @override
  List<Object?> get props => [truckData];
}

// ── Error ──────────────────────────────────────────────────────────────────────
class TruckErrorState extends TruckDetailsState {
  final String errorMessage;

  const TruckErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}