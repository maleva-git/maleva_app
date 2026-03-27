import 'dart:io';

abstract class SpotSaleEvent {
  const SpotSaleEvent();
}

// ── Init ──────────────────────────────────────────────────────────────────────
class LoadSpotSaleListsEvent extends SpotSaleEvent {
  const LoadSpotSaleListsEvent();
}

// ── Selection Events ──────────────────────────────────────────────────────────
class SelectJobTypeEvent extends SpotSaleEvent {
  final String? id;
  const SelectJobTypeEvent(this.id);
}

class SelectJobStatusEvent extends SpotSaleEvent {
  final String? id;
  const SelectJobStatusEvent(this.id);
}

class SelectPortEvent extends SpotSaleEvent {
  final String? name;
  const SelectPortEvent(this.name);
}

// ── Text Field Events ─────────────────────────────────────────────────────────
class UpdateCargoQtyEvent extends SpotSaleEvent {
  final String value;
  const UpdateCargoQtyEvent(this.value);
}

class UpdateVehicleNameEvent extends SpotSaleEvent {
  final String value;
  const UpdateVehicleNameEvent(this.value);
}

class UpdateAWBNoEvent extends SpotSaleEvent {
  final String value;
  const UpdateAWBNoEvent(this.value);
}

class UpdateCargoWeightEvent extends SpotSaleEvent {
  final String value;
  const UpdateCargoWeightEvent(this.value);
}

class PickSpotSaleDocumentEvent extends SpotSaleEvent {
  final File? image;
  final File? pdf;
  const PickSpotSaleDocumentEvent({this.image, this.pdf});
}

class SubmitSpotSaleEvent extends SpotSaleEvent {
  const SubmitSpotSaleEvent();
}

class ResetSpotSaleFormEvent extends SpotSaleEvent {
  const ResetSpotSaleFormEvent();
}

// ── View Page Events ──────────────────────────────────────────────────────────
class SelectViewFromDateEvent extends SpotSaleEvent {
  final DateTime date;
  const SelectViewFromDateEvent(this.date);
}

class SelectViewToDateEvent extends SpotSaleEvent {
  final DateTime date;
  const SelectViewToDateEvent(this.date);
}

class LoadSpotSaleViewEvent extends SpotSaleEvent {
  const LoadSpotSaleViewEvent();
}