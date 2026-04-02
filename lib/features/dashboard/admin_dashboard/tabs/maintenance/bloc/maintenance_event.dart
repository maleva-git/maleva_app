

abstract class MaintenanceEvent {}

// ── Startup ───────────────────────────────────────────────────────────────────
class MaintenanceStarted extends MaintenanceEvent {}

// ── Toggle between Pending (6mo) and Summary (1yr) ───────────────────────────
class MaintenancePendingRequested extends MaintenanceEvent {}

class MaintenanceSummaryRequested extends MaintenanceEvent {}