part of 'speeding_bloc.dart';

abstract class SpeedingState {}

class SpeedingInitial extends SpeedingState {}

class SpeedingLoading extends SpeedingState {}

class SpeedingLoaded extends SpeedingState {
  final List<SpeedingView> speedingRecords;
  SpeedingLoaded(this.speedingRecords);
}

class SpeedingError extends SpeedingState {
  final String message;
  SpeedingError(this.message);
}