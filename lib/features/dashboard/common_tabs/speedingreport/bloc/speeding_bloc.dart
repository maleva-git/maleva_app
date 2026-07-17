import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';

import '../../../../../core/models/model.dart';
import '../data/speeding_repository.dart';
import 'speeding_event.dart';
import 'speeding_state.dart';
import 'package:maleva/core/models/shared/speeding_view.dart';

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
      final String fromDate = DateFormat('MM/dd/yyyy').format(event.fromDate);
      final String toDate   = DateFormat('MM/dd/yyyy').format(event.toDate);

      final Map<String, dynamic> requestBody = {
        'Todate':   toDate,
        'Fromdate': fromDate,
        'Comid':    AppGlobals.Comid,
      };

      // ✅ REFACTORED: Using the injected repository without context
      final resultData = await repository.fetchSpeedingReport(body: requestBody);

      if (resultData != null && resultData is List && resultData.isNotEmpty) {
        final List<SpeedingView> records = resultData
            .map<SpeedingView>((e) => SpeedingView.fromJson(e))
            .toList();
        emit(SpeedingLoaded(records));
      } else {
        emit(SpeedingLoaded([]));
      }
    } catch (error) {
      emit(SpeedingError(error.toString()));
    }
  }
}