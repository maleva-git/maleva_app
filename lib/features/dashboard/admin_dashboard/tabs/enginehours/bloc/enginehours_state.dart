import 'package:maleva/core/models/model.dart';

abstract class EngineHoursState {
  const EngineHoursState();

  @override
  List<Object?> get props => [];
}

class EngineHoursInitial extends EngineHoursState {
  const EngineHoursInitial();
}

class EngineHoursLoading extends EngineHoursState {
  const EngineHoursLoading();
}

class EngineHoursLoaded extends EngineHoursState {
  final List<EngineHoursdata> engineHoursRecords;
  const EngineHoursLoaded(this.engineHoursRecords);

  @override
  List<Object?> get props => [engineHoursRecords];
}

class EngineHoursError extends EngineHoursState {
  final String message;
  const EngineHoursError(this.message);

  @override
  List<Object?> get props => [message];
}