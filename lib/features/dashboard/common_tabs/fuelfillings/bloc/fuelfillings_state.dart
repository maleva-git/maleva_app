import 'package:maleva/features/transport/models/fuel_filling.dart';

abstract class FuelFillingState {}

class FuelFillingInitial extends FuelFillingState {}

class FuelFillingLoading extends FuelFillingState {}

class FuelFillingLoaded extends FuelFillingState {
  final List<FuelFilling> fuelFillingRecords;
  FuelFillingLoaded(this.fuelFillingRecords);

  @override
  List<Object?> get props => [fuelFillingRecords];
}

class FuelFillingError extends FuelFillingState {
  final String message;
  FuelFillingError(this.message);

  @override
  List<Object?> get props => [message];
}