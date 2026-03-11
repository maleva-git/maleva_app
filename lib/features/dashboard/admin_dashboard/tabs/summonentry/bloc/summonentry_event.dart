import 'dart:io';

abstract class SummonEvent {
  const SummonEvent();
}

// ── Entry Page Events ─────────────────────────────────────────────────────────
class SelectTruckEvent extends SummonEvent {
  final String? truckId;
  const SelectTruckEvent(this.truckId);
}

class SelectEntryDateEvent extends SummonEvent {
  final DateTime date;
  const SelectEntryDateEvent(this.date);
}

class SelectCountryEvent extends SummonEvent {
  final String country;
  const SelectCountryEvent(this.country);
}

class SelectSummonTypeEvent extends SummonEvent {
  final String? summonType;
  const SelectSummonTypeEvent(this.summonType);
}

class UpdateAmountEvent extends SummonEvent {
  final String value;
  const UpdateAmountEvent(this.value);
}

class UpdatePortPassEvent extends SummonEvent {
  final String value;
  const UpdatePortPassEvent(this.value);
}

class UpdateTruckLcnMntEvent extends SummonEvent {
  final String value;
  const UpdateTruckLcnMntEvent(this.value);
}

class UpdateLevyEvent extends SummonEvent {
  final String value;
  const UpdateLevyEvent(this.value);
}

class UpdateFuelEvent extends SummonEvent {
  final String value;
  const UpdateFuelEvent(this.value);
}

class PickDocumentEvent extends SummonEvent {
  final File? image;
  final File? pdf;
  const PickDocumentEvent({this.image, this.pdf});
}

class SubmitSummonEvent extends SummonEvent {
  const SubmitSummonEvent();
}

class ResetEntryFormEvent extends SummonEvent {
  const ResetEntryFormEvent();
}

// ── View Page Events ──────────────────────────────────────────────────────────
class SelectViewFromDateEvent extends SummonEvent {
  final DateTime date;
  const SelectViewFromDateEvent(this.date);
}

class SelectViewToDateEvent extends SummonEvent {
  final DateTime date;
  const SelectViewToDateEvent(this.date);
}

class LoadSummonViewEvent extends SummonEvent {
  const LoadSummonViewEvent();
}