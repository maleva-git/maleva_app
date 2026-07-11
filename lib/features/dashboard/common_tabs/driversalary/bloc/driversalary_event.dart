

abstract class DriverSalaryEvent {}

// ── Startup — load with today's date range ────────────────────────────────────
class DriverSalaryStarted extends DriverSalaryEvent {}

// ── Date filter changes — auto reload after each pick ────────────────────────
class DriverSalaryFromDateChanged extends DriverSalaryEvent {
  final String date;
  DriverSalaryFromDateChanged(this.date);
}

class DriverSalaryToDateChanged extends DriverSalaryEvent {
  final String date;
  DriverSalaryToDateChanged(this.date);
}

// ── Show details dialog ───────────────────────────────────────────────────────
class DriverSalaryDetailRequested extends DriverSalaryEvent {
  final Map<String, dynamic> item;
  DriverSalaryDetailRequested(this.item);
}