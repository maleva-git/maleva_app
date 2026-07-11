import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../data/maintenance_repository.dart'; // Adjust path if needed
import 'maintenance_event.dart';
import 'maintenance_state.dart';

class MaintenanceBloc extends Bloc<MaintenanceEvent, MaintenanceState> {
  final MaintenanceRepository repository;

  MaintenanceBloc({required this.repository}) : super(MaintenanceInitial()) {
    on<MaintenanceStarted>(_onStarted);
    on<MaintenancePendingRequested>(_onPendingRequested);
    on<MaintenanceSummaryRequested>(_onSummaryRequested);
  }

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August',
    'September','October', 'November', 'December',
  ];

  // ── Startup ────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      MaintenanceStarted event, Emitter<MaintenanceState> emit) async {
    emit(MaintenanceLoading());
    try {
      final now = DateTime.now();
      final monthName = _monthNames[now.month - 1];
      final fromDate = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
      final toDate = DateFormat('yyyy-MM-dd').format(now);

      // Fetch stats and default pending list concurrently
      final stats = await repository.fetchCurrentMonthStats(fromDate, toDate);
      final pendingData = await repository.fetchPendingMaintenance();

      emit(MaintenanceLoaded(
        currentMonthName: monthName,
        breakdownCount:   stats['breakdownCount'],
        breakdownAmount:  stats['breakdownAmount'],
        repairCount:      stats['repairCount'],
        repairAmount:     stats['repairAmount'],
        serviceCount:     stats['serviceCount'],
        serviceAmount:    stats['serviceAmount'],
        sparePartsCount:  stats['sparePartsCount'],
        sparePartsAmount: stats['sparePartsAmount'],
        is6Months:        true,
        pendingList:      pendingData,
        summaryList:      const [],
      ));
    } catch (e) {
      emit(MaintenanceError(e.toString()));
    }
  }

  // ── Pending (6 months) ─────────────────────────────────────────────────────
  Future<void> _onPendingRequested(
      MaintenancePendingRequested event,
      Emitter<MaintenanceState> emit) async {
    if (state is! MaintenanceLoaded) return;
    final s = state as MaintenanceLoaded;

    emit(MaintenanceLoading());
    try {
      final data = await repository.fetchPendingMaintenance();
      emit(s.copyWith(is6Months: true, pendingList: data));
    } catch (e) {
      emit(MaintenanceError(e.toString()));
    }
  }

  // ── Summary (1 year) ───────────────────────────────────────────────────────
  Future<void> _onSummaryRequested(
      MaintenanceSummaryRequested event,
      Emitter<MaintenanceState> emit) async {
    if (state is! MaintenanceLoaded) return;
    final s = state as MaintenanceLoaded;

    emit(MaintenanceLoading());
    try {
      final now = DateTime.now();
      final fromDate = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 365)));
      final toDate = DateFormat('yyyy-MM-dd').format(now);

      final data = await repository.fetchSummaryMaintenance(fromDate, toDate);
      emit(s.copyWith(is6Months: false, summaryList: data));
    } catch (e) {
      emit(MaintenanceError(e.toString()));
    }
  }
}