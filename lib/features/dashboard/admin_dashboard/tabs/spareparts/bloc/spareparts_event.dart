import 'dart:io';

abstract class SparePartsEvent {
  const SparePartsEvent();
}

// ── Entry Page Events ─────────────────────────────────────────────────────────
class LoadSparePartsTrucksEvent extends SparePartsEvent {
  const LoadSparePartsTrucksEvent();
}

class SelectSparePartsTruckEvent extends SparePartsEvent {
  final String? truckId;
  const SelectSparePartsTruckEvent(this.truckId);
}
class SelectSparePartsRecordEvent extends SparePartsEvent {
  final Map<String, dynamic> record;
  const SelectSparePartsRecordEvent(this.record);
}
class SelectSparePartsDateEvent extends SparePartsEvent {
  final DateTime date;
  const SelectSparePartsDateEvent(this.date);
}

class UpdateSparePartsTextEvent extends SparePartsEvent {
  final String value;
  const UpdateSparePartsTextEvent(this.value);
}

class UpdateSparePartsAmountEvent extends SparePartsEvent {
  final String value;
  const UpdateSparePartsAmountEvent(this.value);
}

class PickSparePartsDocumentEvent extends SparePartsEvent {
  final File? image;
  final File? pdf;
  const PickSparePartsDocumentEvent({this.image, this.pdf});
}

class SubmitSparePartsEvent extends SparePartsEvent {
  const SubmitSparePartsEvent();
}

class ResetSparePartsFormEvent extends SparePartsEvent {
  const ResetSparePartsFormEvent();
}

// ── View Page Events ──────────────────────────────────────────────────────────
class SelectSparePartsFromDateEvent extends SparePartsEvent {
  final DateTime date;
  const SelectSparePartsFromDateEvent(this.date);
}

class SelectSparePartsToDateEvent extends SparePartsEvent {
  final DateTime date;
  const SelectSparePartsToDateEvent(this.date);
}

class LoadSparePartsViewEvent extends SparePartsEvent {
  const LoadSparePartsViewEvent();
}