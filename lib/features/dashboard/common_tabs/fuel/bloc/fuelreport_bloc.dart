import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/app_globals.dart';
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
      final Map<String, dynamic> requestBody = {
        'Comid': AppGlobals.storagenew.getInt('Comid') ?? 0,
        'Fromdate': current.fromDate,
        'Todate': current.toDate,
        'Employeeid': 0,
        'DId': 0,
        'TId': 0,
        'Search': '',
      };

      final resultData = await repository.fetchFuelDifference(body: requestBody);

      if (resultData != null && resultData is List && resultData.isNotEmpty) {
        final List<FuelselectModel> records = resultData
            .map((e) => FuelselectModel.fromJson(e as Map<String, dynamic>))
            .toList();

        emit(current.copyWith(records: records));
      } else {
        emit(current.copyWith(records: []));
      }
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