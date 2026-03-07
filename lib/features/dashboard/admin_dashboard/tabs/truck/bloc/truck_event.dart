part of 'truck_bloc.dart';

abstract class TruckDetailsEvent  {
  const TruckDetailsEvent();

  @override
  List<Object?> get props => [];
}

// ── Load truck data ────────────────────────────────────────────────────────────
class LoadTruckDetailsEvent extends TruckDetailsEvent {
  const LoadTruckDetailsEvent();
}