

abstract class MaintenanceEvent {}

// ── Startup ───────────────────────────────────────────────────────────────────
// Loads current-month summary stats + default Pending list
class MaintenanceStarted extends MaintenanceEvent {}

// ── Pending button — load 6-month pending supplier list ───────────────────────
class MaintenancePendingRequested extends MaintenanceEvent {}

// ── Summary button — load 1-year summary description list ────────────────────
class MaintenanceSummaryRequested extends MaintenanceEvent {}