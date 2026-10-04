import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../data/fuel_repository.dart';
import 'fuelreport_event.dart';
import 'fuelreport_state.dart';

class FuelDiffBloc extends Bloc<FuelDiffEvent, FuelDiffState> {
  final FuelRepository repository;

  FuelDiffBloc({required this.repository})
      : super(FuelDiffLoaded(
    records: [],
    fromDate: DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 30))),
    toDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
  )) {
    on<SelectFromDateEvent>(_onSelectFromDate);
    on<SelectToDateEvent>(_onSelectToDate);
    on<LoadFuelDiffEvent>(_onLoadFuelDiff);
    on<SelectFuelRecordEvent>(_onSelectRecord);
  }

  void _onSelectFromDate(
      SelectFromDateEvent event,
      Emitter<FuelDiffState> emit,
      ) {
    if (state is FuelDiffLoaded) {
      emit((state as FuelDiffLoaded).copyWith(fromDate: event.date));
    }
  }

  void _onSelectToDate(
      SelectToDateEvent event,
      Emitter<FuelDiffState> emit,
      ) {
    if (state is FuelDiffLoaded) {
      emit((state as FuelDiffLoaded).copyWith(toDate: event.date));
    }
  }

  Future<void> _onLoadFuelDiff(
      LoadFuelDiffEvent event,
      Emitter<FuelDiffState> emit,
      ) async {
    if (state is! FuelDiffLoaded) return;
    final current = state as FuelDiffLoaded;

    emit(const FuelDiffLoading());

    try {
      final records = await repository.fetchFuelDifference(
        fromDate: current.fromDate,
        toDate: current.toDate,
      );
      emit(current.copyWith(records: records));
    } catch (e) {
      emit(FuelDiffError(e.toString()));
      emit(current.copyWith(records: []));
    }
  }

  void _onSelectRecord(
      SelectFuelRecordEvent event,
      Emitter<FuelDiffState> emit,
      ) {
    if (state is FuelDiffLoaded) {
      emit((state as FuelDiffLoaded).copyWith(
        selectedRecord: event.record,
      ));
    }
  }
}