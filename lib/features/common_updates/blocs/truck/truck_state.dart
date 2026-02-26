// truck_state.dart
abstract class TruckState {}

class TruckInitial extends TruckState {}

class TruckLoaded extends TruckState {
  final List truckList;
  TruckLoaded(this.truckList);
}

class TruckError extends TruckState {
  final String message;
  TruckError(this.message);
}
