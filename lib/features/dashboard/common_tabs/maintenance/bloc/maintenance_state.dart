

abstract class MaintenanceState {}

class MaintenanceInitial extends MaintenanceState {}

class MaintenanceLoading extends MaintenanceState {}

class MaintenanceLoaded extends MaintenanceState {
  // ── Current-month summary stats ───────────────────────────────────────────
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
  final bool is6Months; // true = Pending (6-month), false = Summary (1-year)

  // ── List data ─────────────────────────────────────────────────────────────
  final List<dynamic> pendingList;  // MaintenanceModel items for Pending
  final List<dynamic> summaryList;  // MaintenanceModel items for Summary

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
    String? currentMonthName,
    int?    breakdownCount,
    double? breakdownAmount,
    int?    repairCount,
    double? repairAmount,
    int?    serviceCount,
    double? serviceAmount,
    int?    sparePartsCount,
    double? sparePartsAmount,
    bool?   is6Months,
    List<dynamic>? pendingList,
    List<dynamic>? summaryList,
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