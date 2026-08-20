
import 'package:equatable/equatable.dart';
import '../models/fuelentry_model.dart';

abstract class FuelEntryState extends Equatable {
  const FuelEntryState();
  @override
  List<Object?> get props => [];
}

class FuelEntryInitial extends FuelEntryState {}

class FuelEntryLoading extends FuelEntryState {}

class FuelEntryLoaded extends FuelEntryState {
  final List<FuelEntryModel> entries;
  const FuelEntryLoaded(this.entries);
  @override
  List<Object?> get props => [entries];
}

class FuelEntryError extends FuelEntryState {
  final String message;
  const FuelEntryError(this.message);
  @override
  List<Object?> get props => [message];
}

class FuelEntryActionSuccess extends FuelEntryState {
  final String message;
  const FuelEntryActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
