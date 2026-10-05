import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/fuelfillings_repository.dart';
import 'fuelfillings_event.dart';
import 'fuelfillings_state.dart';

class FuelFillingBloc extends Bloc<FuelFillingEvent, FuelFillingState> {

  final FuelFillingsRepository repository;

  FuelFillingBloc({required this.repository}) : super(FuelFillingInitial()) {
    on<LoadFuelFillingReport>(_onLoadFuelFillingReport);
  }

  Future<void> _onLoadFuelFillingReport(
      LoadFuelFillingReport event,
      Emitter<FuelFillingState> emit,
      ) async {
    emit(FuelFillingLoading());

    try {
      final records = await repository.fetchFuelFillingReport(fromDate: event.fromDate, toDate: event.toDate);
      emit(FuelFillingLoaded(records));
    } catch (error) {
      emit(FuelFillingError(error.toString()));
    }
  }
}