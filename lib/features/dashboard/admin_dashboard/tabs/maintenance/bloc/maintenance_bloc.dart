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

  static const List<String> _monthNames = [
    'January', 'February', 'March',    'April',
    'May',      'June',     'July',     'August',
    'September','October',  'November', 'December',
  ];

  // ── Default empty stats ────────────────────────────────────────────────────
  MaintenanceLoaded _emptyLoaded(String monthName) => MaintenanceLoaded(
    currentMonthName: monthName,
    breakdownCount:   0,
    breakdownAmount:  0.0,
    repairCount:      0,
    repairAmount:     0.0,
    serviceCount:     0,
    serviceAmount:    0.0,
    sparePartsCount:  0,
    sparePartsAmount: 0.0,
    is6Months:        true,
    pendingList:      [],
    summaryList:      [],
  );

  Map<String, dynamic> _parseStats(List<dynamic> data) {
    int    breakdownCount   = 0;
    double breakdownAmount  = 0.0;
    int    repairCount      = 0;
    double repairAmount     = 0.0;
    int    serviceCount     = 0;
    double serviceAmount    = 0.0;
    int    sparePartsCount  = 0;
    double sparePartsAmount = 0.0;

    for (final item in data) {
      switch (item.Description.toString().toUpperCase()) {
        case 'BREAKDOWN':
          breakdownCount  = int.tryParse(item.PStatus.toString())  ?? 0;
          breakdownAmount = double.tryParse(item.Amount.toString()) ?? 0.0;
          break;
        case 'REPAIR':
          repairCount  = int.tryParse(item.PStatus.toString())  ?? 0;
          repairAmount = double.tryParse(item.Amount.toString()) ?? 0.0;
          break;
        case 'SERVICE':
          serviceCount  = int.tryParse(item.PStatus.toString())  ?? 0;
          serviceAmount = double.tryParse(item.Amount.toString()) ?? 0.0;
          break;
        case 'SPARE PARTS':
          sparePartsCount  = int.tryParse(item.PStatus.toString())  ?? 0;
          sparePartsAmount = double.tryParse(item.Amount.toString()) ?? 0.0;
          break;
      }
    }

    return {
      'breakdownCount':   breakdownCount,
      'breakdownAmount':  breakdownAmount,
      'repairCount':      repairCount,
      'repairAmount':     repairAmount,
      'serviceCount':     serviceCount,
      'serviceAmount':    serviceAmount,
      'sparePartsCount':  sparePartsCount,
      'sparePartsAmount': sparePartsAmount,
    };
  }

  // ── Startup ────────────────────────────────────────────────────────────────
  Future<void> _onStarted(
      MaintenanceStarted event, Emitter<MaintenanceState> emit) async {
    emit(MaintenanceLoading());
    try {
      final now        = DateTime.now();
      final monthName  = _monthNames[now.month - 1];
      final fromDate   = DateFormat('yyyy-MM-dd')
          .format(DateTime(now.year, now.month, 1));
      final toDate     = DateFormat('yyyy-MM-dd').format(now);

      final header = {'Content-Type': 'application/json; charset=UTF-8'};

      final statsResult = await objfun.apiAllinoneSelectArray(
          '${objfun.apiGetMaintenance2}${objfun.Comid}'
              '&Fromdate=$fromDate&Todate=$toDate',
          null,
          header,
          null);

      List<dynamic> statsData = [];
      if (statsResult != '' && statsResult.length != 0) {
        statsData = (statsResult as List)
            .map((e) => MaintenanceModel.fromJson(e))
            .toList();
      }
      final stats = _parseStats(statsData);

      // Load default Pending list (6 months)
      final pendingResult = await objfun.apiAllinoneSelectArray(
          '${objfun.apiGetMaintenance}${objfun.Comid}',
          null,
          header,
          null);

      List<dynamic> pendingData = [];
      if (pendingResult != '' && pendingResult.length != 0) {
        pendingData = (pendingResult as List)
            .map((e) => MaintenanceModel.fromJson(e))
            .toList();
      }

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

      List<dynamic> data = [];
      if (result != '' && result.length != 0) {
        data = (result as List)
            .map((e) => MaintenanceModel.fromJson(e))
            .toList();
      }
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
      final now      = DateTime.now();
      final fromDate = DateFormat('yyyy-MM-dd')
          .format(now.subtract(const Duration(days: 365)));
      final toDate   = DateFormat('yyyy-MM-dd').format(now);

      final header = {'Content-Type': 'application/json; charset=UTF-8'};
      final result = await objfun.apiAllinoneSelectArray(
          '${objfun.apiGetMaintenance1}${objfun.Comid}'
              '&Fromdate=$fromDate&Todate=$toDate',
          null,
          header,
          null);

      List<dynamic> data = [];
      if (result != '' && result.length != 0) {
        data = (result as List)
            .map((e) => MaintenanceModel.fromJson(e))
            .toList();
      }
      emit(s.copyWith(is6Months: false, summaryList: data));
    } catch (e) {
      emit(MaintenanceError(e.toString()));
    }
  }
}