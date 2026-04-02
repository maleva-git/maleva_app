

import '../../../../../../core/models/model.dart';

abstract class MaintenanceState {}

class MaintenanceInitial extends MaintenanceState {}

class MaintenanceLoading extends MaintenanceState {}

class MaintenanceLoaded extends MaintenanceState {
  // ── Month summary header ──────────────────────────────────────────────────
  final String currentMonthName;
  final int    breakdownCount;
  final double breakdownAmount;
  final int    repairCount;
  final double repairAmount;
  final int    serviceCount;
  final double serviceAmount;
  final int    sparePartsCount;
  final double sparePartsAmount;

  // ── List toggle ───────────────────────────────────────────────────────────
  final bool is6Months; // true = Pending list, false = Summary list

  // ── List data ─────────────────────────────────────────────────────────────
  final List<MaintenanceModel> pendingList;   // 6-month pending
  final List<MaintenanceModel> summaryList;   // 1-year summary

   MaintenanceLoaded({
    required this.currentMonthName,
    required this.breakdownCount,
    required this.breakdownAmount,
    required this.repairCount,
    required this.repairAmount,
    required this.serviceCount,
    required this.serviceAmount,
    required this.sparePartsCount,
    required this.sparePartsAmount,
    required this.is6Months,
    required this.pendingList,
    required this.summaryList,
  });

  MaintenanceLoaded copyWith({
    String?                 currentMonthName,
    int?                    breakdownCount,
    double?                 breakdownAmount,
    int?                    repairCount,
    double?                 repairAmount,
    int?                    serviceCount,
    double?                 serviceAmount,
    int?                    sparePartsCount,
    double?                 sparePartsAmount,
    bool?                   is6Months,
    List<MaintenanceModel>? pendingList,
    List<MaintenanceModel>? summaryList,
  }) {
    return MaintenanceLoaded(
      currentMonthName: currentMonthName ?? this.currentMonthName,
      breakdownCount:   breakdownCount   ?? this.breakdownCount,
      breakdownAmount:  breakdownAmount  ?? this.breakdownAmount,
      repairCount:      repairCount      ?? this.repairCount,
      repairAmount:     repairAmount     ?? this.repairAmount,
      serviceCount:     serviceCount     ?? this.serviceCount,
      serviceAmount:    serviceAmount    ?? this.serviceAmount,
      sparePartsCount:  sparePartsCount  ?? this.sparePartsCount,
      sparePartsAmount: sparePartsAmount ?? this.sparePartsAmount,
      is6Months:        is6Months        ?? this.is6Months,
      pendingList:      pendingList      ?? this.pendingList,
      summaryList:      summaryList      ?? this.summaryList,
    );
  }
}

class MaintenanceError extends MaintenanceState {
  final String message;
  MaintenanceError(this.message);
}