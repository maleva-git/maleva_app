

abstract class FuelEntryViewEvent {}

// ── Startup — load with today's date range ────────────────────────────────────
class FuelEntryViewStarted extends FuelEntryViewEvent {}

// ── Date filter ───────────────────────────────────────────────────────────────
class FuelEntryViewFromDateChanged extends FuelEntryViewEvent {
  final String date;
  FuelEntryViewFromDateChanged(this.date);
}

class FuelEntryViewToDateChanged extends FuelEntryViewEvent {
  final String date;
  FuelEntryViewToDateChanged(this.date);
}

// ── Load list ─────────────────────────────────────────────────────────────────
class FuelEntryViewLoadRequested extends FuelEntryViewEvent {}

// ── Delete ────────────────────────────────────────────────────────────────────
class FuelEntryViewDeleteRequested extends FuelEntryViewEvent {
  final Map<String, dynamic> item;
  FuelEntryViewDeleteRequested(this.item);
}