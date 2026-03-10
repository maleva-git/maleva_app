import 'package:maleva/core/models/model.dart';

abstract class EngineHoursState {}

class EngineHoursInitial extends EngineHoursState {}

class EngineHoursLoading extends EngineHoursState {}

class EngineHoursLoaded extends EngineHoursState {
  final List<EngineHoursdata> engineHoursRecords;
  EngineHoursLoaded(this.engineHoursRecords);

  @override
  List<Object?> get props => [engineHoursRecords];
}

class EngineHoursError extends EngineHoursState {
  final String message;
  EngineHoursError(this.message);

  @override
  List<Object?> get props => [message];
}