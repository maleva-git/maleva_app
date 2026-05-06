import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../../../../../../core/models/model.dart';

import '../tab/enginehours_repository.dart';
import 'enginehours_event.dart';
import 'enginehours_state.dart';

class EngineHoursBloc extends Bloc<EngineHoursEvent, EngineHoursState> {
  // ❌ REMOVED: final BuildContext context;
  final EngineHoursRepository repository; // ✅ Injected Repository

  EngineHoursBloc({required this.repository}) : super(const EngineHoursInitial()) {
    on<LoadEngineHoursReport>(_onLoadEngineHoursReport);
  }

  Future<void> _onLoadEngineHoursReport(
      LoadEngineHoursReport event,
      Emitter<EngineHoursState> emit,
      ) async {
    emit(const EngineHoursLoading());

    try {
      final String fromDate = DateFormat('MM/dd/yyyy').format(event.fromDate);
      final String toDate   = DateFormat('MM/dd/yyyy').format(event.toDate);

      final Map<String, dynamic> requestBody = {
        'Todate':   toDate,
        'Fromdate': fromDate,
        'Comid':    objfun.Comid,
      };

      // ✅ REFACTORED: Using the injected repository without context
      final resultData = await repository.fetchEngineHoursReport(body: requestBody);

      if (resultData != null && resultData is List && resultData.isNotEmpty) {
        final List<EngineHoursdata> records = resultData
            .map<EngineHoursdata>((e) => EngineHoursdata.fromJson(e))
            .toList();
        emit(EngineHoursLoaded(records));
      } else {
        emit(const EngineHoursLoaded([]));
      }
    } catch (error) {
      emit(EngineHoursError(error.toString()));
    }
  }
}