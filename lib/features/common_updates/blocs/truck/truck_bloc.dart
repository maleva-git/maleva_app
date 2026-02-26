// truck_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'truck_event.dart';
import 'truck_state.dart';

class TruckBloc extends Bloc<TruckEvent, TruckState> {
  TruckBloc() : super(TruckInitial()) {
    on<LoadTruckList>((event, emit) async {
      try {
        // Replace this with your actual API call
        final List data = await fetchTruckList();
        emit(TruckLoaded(data));
      } catch (e) {
        emit(TruckError(e.toString()));
      }
    });
  }

  // Example async function for fetching truck list
  Future<List> fetchTruckList() async {
    await Future.delayed(const Duration(seconds: 1)); // simulate API delay
    return [
      {"id": 1, "name": "Truck A"},
      {"id": 2, "name": "Truck B"},
    ];
  }
}
