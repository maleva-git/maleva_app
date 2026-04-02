import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';

import 'maintenance_event.dart';
import 'maintenance_state.dart';


class MaintenanceBloc extends Bloc<MaintenanceEvent, MaintenanceState> {
  MaintenanceBloc() : super(MaintenanceInitial()) {
    on<MaintenanceStarted>(_onStarted);
    on<MaintenancePendingRequested>(_onPendingRequested);
    on<MaintenanceSummaryRequested>(_onSummaryRequested);
  }

  // ── Month names ────────────────────────────────────────────────────────────
  static const _monthNames = [
    'January', 'February', 'March',    'April',
    'May',     'June',     'July',     'August',
    'September','October', 'November', 'December',
  ];

  // ── Startup — load header stats + pending list ─────────────────────────────
  Future<void> _onStarted(
      MaintenanceStarted event,
      Emitter<MaintenanceState> emit) async {
    emit(MaintenanceLoading());
    try {
      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final monthName =
      _monthNames[DateTime.now().month - 1];

      // ── Load month summary stats ──────────────────────────────────────────
      // Reuse the pending endpoint to also get the header stats;
      // adjust apiGetMaintenance to whichever endpoint returns the stat rows.
      final statsResult = await objfun.apiAllinoneSelectArray(
          '${objfun.apiGetMaintenance}${objfun.Comid}',
          null,
          header,
          null);

      List<MaintenanceModel> pendingList = [];
      int    breakdownCount   = 0;
      double breakdownAmount  = 0;
      int    repairCount      = 0;
      double repairAmount     = 0;
      int    serviceCount     = 0;
      double serviceAmount    = 0;
      int    sparePartsCount  = 0;
      double sparePartsAmount = 0;

      if (statsResult != '' && statsResult.length != 0) {
        pendingList = (statsResult as List)
            .map((e) => MaintenanceModel.fromJson(e))
            .toList();

        // ── Compute header stats from pending list ────────────────────────
        for (final m in pendingList) {
          switch ((m.Description ?? '').toUpperCase()) {
            case 'BREAKDOWN':
              breakdownCount++;
              breakdownAmount += m.Amount ?? 0;
              break;
            case 'REPAIR':
              repairCount++;
              repairAmount += m.Amount ?? 0;
              break;
            case 'SERVICE':
              serviceCount++;
              serviceAmount += m.Amount ?? 0;
              break;
            case 'SPARE PARTS':
              sparePartsCount++;
              sparePartsAmount += m.Amount ?? 0;
              break;
          }
        }
      }

      emit(MaintenanceLoaded(
        currentMonthName: monthName,
        breakdownCount:   breakdownCount,
        breakdownAmount:  breakdownAmount,
        repairCount:      repairCount,
        repairAmount:     repairAmount,
        serviceCount:     serviceCount,
        serviceAmount:    serviceAmount,
        sparePartsCount:  sparePartsCount,
        sparePartsAmount: sparePartsAmount,
        is6Months:        true,
        pendingList:      pendingList,
        summaryList:      [],
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
      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final result = await objfun.apiAllinoneSelectArray(
          '${objfun.apiGetMaintenance}${objfun.Comid}',
          null,
          header,
          null);

      List<MaintenanceModel> pendingList = [];
      if (result != '' && result.length != 0) {
        pendingList = (result as List)
            .map((e) => MaintenanceModel.fromJson(e))
            .toList();
      }

      emit(s.copyWith(
        is6Months:   true,
        pendingList: pendingList,
      ));
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
      final fromDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 365)));
      final toDate =
      DateFormat('yyyy-MM-dd').format(DateTime.now());

      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final result = await objfun.apiAllinoneSelectArray(
          '${objfun.apiGetMaintenance1}${objfun.Comid}'
              '&Fromdate=$fromDate&Todate=$toDate',
          null,
          header,
          null);

      List<MaintenanceModel> summaryList = [];
      if (result != '' && result.length != 0) {
        summaryList = (result as List)
            .map((e) => MaintenanceModel.fromJson(e))
            .toList();
      }

      emit(s.copyWith(
        is6Months:   false,
        summaryList: summaryList,
      ));
    } catch (e) {
      emit(MaintenanceError(e.toString()));
    }
  }
}