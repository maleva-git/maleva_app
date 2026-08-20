
import 'package:flutter_bloc/flutter_bloc.dart';
import 'fuelentry_event.dart';
import 'fuelentry_state.dart';
import '../data/fuelentry_repository.dart';

class FuelEntryBloc extends Bloc<FuelEntryEvent, FuelEntryState> {
  final FuelEntryRepository repository;
  String currentFromDate = '';
  String currentToDate = '';

  FuelEntryBloc({required this.repository}) : super(FuelEntryInitial()) {
    on<LoadFuelEntries>((event, emit) async {
      emit(FuelEntryLoading());
      try {
        currentFromDate = event.fromDate;
        currentToDate = event.toDate;
        final list = await repository.getFuelEntries(event.fromDate, event.toDate);
        emit(FuelEntryLoaded(list));
      } catch (e) {
        emit(FuelEntryError(e.toString()));
      }
    });

    on<SaveFuelEntry>((event, emit) async {
      emit(FuelEntryLoading());
      try {
        await repository.saveFuelEntry(event.model);
        emit(const FuelEntryActionSuccess("Saved successfully"));
        add(LoadFuelEntries(currentFromDate, currentToDate));
      } catch (e) {
        emit(FuelEntryError(e.toString()));
        add(LoadFuelEntries(currentFromDate, currentToDate));
      }
    });

    on<DeleteFuelEntry>((event, emit) async {
      emit(FuelEntryLoading());
      try {
        await repository.deleteFuelEntry(event.id);
        emit(const FuelEntryActionSuccess("Deleted successfully"));
        add(LoadFuelEntries(currentFromDate, currentToDate));
      } catch (e) {
        emit(FuelEntryError(e.toString()));
        add(LoadFuelEntries(currentFromDate, currentToDate));
      }
    });
  }
}
