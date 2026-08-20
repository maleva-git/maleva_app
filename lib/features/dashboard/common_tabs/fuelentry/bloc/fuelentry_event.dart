
import 'package:equatable/equatable.dart';
import '../models/fuelentry_model.dart';

abstract class FuelEntryEvent extends Equatable {
  const FuelEntryEvent();
  @override
  List<Object?> get props => [];
}

class LoadFuelEntries extends FuelEntryEvent {
  final String fromDate;
  final String toDate;
  const LoadFuelEntries(this.fromDate, this.toDate);
  @override
  List<Object?> get props => [fromDate, toDate];
}

class SaveFuelEntry extends FuelEntryEvent {
  final FuelEntryModel model;
  const SaveFuelEntry(this.model);
  @override
  List<Object?> get props => [model];
}

class DeleteFuelEntry extends FuelEntryEvent {
  final int id;
  const DeleteFuelEntry(this.id);
  @override
  List<Object?> get props => [id];
}
