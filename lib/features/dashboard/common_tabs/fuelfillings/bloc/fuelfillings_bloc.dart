import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/app_globals.dart';
import '../../../../../core/models/model.dart';
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
      final String fromDate = DateFormat('MM/dd/yyyy').format(event.fromDate);
      final String toDate   = DateFormat('MM/dd/yyyy').format(event.toDate);

      final Map<String, dynamic> requestBody = {
        'Todate':   toDate,
        'Fromdate': fromDate,
        'Comid':    AppGlobals.Comid,
      };

      final resultData = await repository.fetchFuelFillingReport(body: requestBody);

      if (resultData != null && resultData is List && resultData.isNotEmpty) {
        final List<FuelFilling> records = resultData
            .map<FuelFilling>((e) => FuelFilling.fromJson(e))
            .toList();
        emit(FuelFillingLoaded(records));
      } else {
        emit(FuelFillingLoaded([]));
      }
    } catch (error) {
      emit(FuelFillingError(error.toString()));
    }
  }
}