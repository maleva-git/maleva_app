import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

import '../data/fuel_repository.dart';
import 'fuelreport_event.dart';
import 'fuelreport_state.dart';

class FuelDiffBloc extends Bloc<FuelDiffEvent, FuelDiffState> {
  // ❌ REMOVED: final BuildContext context;
  final FuelRepository repository; // ✅ Injected Repository

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

  // ── 1. From Date Select ─────────────────────────────────────────────────────
  void _onSelectFromDate(
      SelectFromDateEvent event,
      Emitter<FuelDiffState> emit,
      ) {
    if (state is FuelDiffLoaded) {
      emit((state as FuelDiffLoaded).copyWith(fromDate: event.date));
    }
  }

  // ── 2. To Date Select ───────────────────────────────────────────────────────
  void _onSelectToDate(
      SelectToDateEvent event,
      Emitter<FuelDiffState> emit,
      ) {
    if (state is FuelDiffLoaded) {
      emit((state as FuelDiffLoaded).copyWith(toDate: event.date));
    }
  }

  // ── 3. Load Fuel Difference ─────────────────────────────────────────────────
  Future<void> _onLoadFuelDiff(
      LoadFuelDiffEvent event,
      Emitter<FuelDiffState> emit,
      ) async {
    if (state is! FuelDiffLoaded) return;
    final current = state as FuelDiffLoaded;

    emit(const FuelDiffLoading());

    try {
      final Map<String, dynamic> requestBody = {
        'Comid': objfun.storagenew.getInt('Comid') ?? 0,
        'Fromdate': current.fromDate,
        'Todate': current.toDate,
        'Employeeid': 0,
        'DId': 0,
        'TId': 0,
        'Search': '',
      };

      // ✅ REFACTORED: Using the injected repository without context
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
      // Reset back to loaded state with empty records so the UI doesn't get stuck
      emit(current.copyWith(records: []));
    }
  }

  // ── 4. Select Record ────────────────────────────────────────────────────────
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