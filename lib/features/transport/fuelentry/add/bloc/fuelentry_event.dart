

abstract class FuelEntryEvent {}

// ── Startup — load max fuel no ────────────────────────────────────────────────
class FuelEntryStarted extends FuelEntryEvent {}

// ── Date ──────────────────────────────────────────────────────────────────────
class FuelEntryDateChanged extends FuelEntryEvent {
  final String date; // yyyy-MM-dd
  FuelEntryDateChanged(this.date);
}

// ── Text fields ───────────────────────────────────────────────────────────────
class FuelEntryLiterChanged extends FuelEntryEvent {
  final String value;
  FuelEntryLiterChanged(this.value);
}

class FuelEntryAmountChanged extends FuelEntryEvent {
  final String value;
  FuelEntryAmountChanged(this.value);
}

// ── Save ──────────────────────────────────────────────────────────────────────
class FuelEntrySaveRequested extends FuelEntryEvent {}