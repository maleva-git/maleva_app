import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/enginehours_repository.dart';
import 'enginehours_event.dart';
import 'enginehours_state.dart';

class EngineHoursBloc extends Bloc<EngineHoursEvent, EngineHoursState> {

  final EngineHoursRepository repository;

  EngineHoursBloc({required this.repository}) : super(const EngineHoursInitial()) {
    on<LoadEngineHoursReport>(_onLoadEngineHoursReport);
  }

  Future<void> _onLoadEngineHoursReport(
      LoadEngineHoursReport event,
      Emitter<EngineHoursState> emit,
      ) async {
    emit(const EngineHoursLoading());

    try {
      final records = await repository.fetchEngineHoursReport(fromDate: event.fromDate, toDate: event.toDate);
      emit(EngineHoursLoaded(records));
    } catch (error) {
      emit(EngineHoursError(error.toString()));
    }
  }
}