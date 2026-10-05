import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/speeding_repository.dart';
import 'speeding_event.dart';
import 'speeding_state.dart';

class SpeedingBloc extends Bloc<SpeedingEvent, SpeedingState> {
  // ❌ REMOVED: final BuildContext context;
  final SpeedingRepository repository; // ✅ Injected Repository

  SpeedingBloc({required this.repository}) : super(SpeedingInitial()) {
    on<LoadSpeedingReport>(_onLoadSpeedingReport);
  }

  Future<void> _onLoadSpeedingReport(
      LoadSpeedingReport event,
      Emitter<SpeedingState> emit,
      ) async {
    emit(SpeedingLoading());

    try {
      final records = await repository.fetchSpeedingReport(fromDate: event.fromDate, toDate: event.toDate);
      emit(SpeedingLoaded(records));
    } catch (error) {
      emit(SpeedingError(error.toString()));
    }
  }
}