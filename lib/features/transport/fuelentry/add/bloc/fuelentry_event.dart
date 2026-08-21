

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
class FuelEntryRemarksChanged extends FuelEntryEvent {
  final String value;
  FuelEntryRemarksChanged(this.value);
}
class FuelEntryPLiterChanged extends FuelEntryEvent {
  final String value;
  FuelEntryPLiterChanged(this.value);
}
class FuelEntryPRateChanged extends FuelEntryEvent {
  final String value;
  FuelEntryPRateChanged(this.value);
}
class FuelEntryPAmountChanged extends FuelEntryEvent {
  final String value;
  FuelEntryPAmountChanged(this.value);
}
class FuelEntryGLiterChanged extends FuelEntryEvent {
  final String value;
  FuelEntryGLiterChanged(this.value);
}
class FuelEntryGAmountChanged extends FuelEntryEvent {
  final String value;
  FuelEntryGAmountChanged(this.value);
}
class FuelEntryDPLiterChanged extends FuelEntryEvent {
  final String value;
  FuelEntryDPLiterChanged(this.value);
}
class FuelEntryDPAmountChanged extends FuelEntryEvent {
  final String value;
  FuelEntryDPAmountChanged(this.value);
}
class FuelEntryDGLiterChanged extends FuelEntryEvent {
  final String value;
  FuelEntryDGLiterChanged(this.value);
}
class FuelEntryDGAmountChanged extends FuelEntryEvent {
  final String value;
  FuelEntryDGAmountChanged(this.value);
}
