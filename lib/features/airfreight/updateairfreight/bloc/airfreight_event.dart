

abstract class AirFreightEvent {}

// ── Startup ───────────────────────────────────────────────────────────────────
class AirFreightStarted extends AirFreightEvent {
  final String? jobNo;
  final int?    jobId;
  AirFreightStarted({this.jobNo, this.jobId});
}

// ── BillType radio ────────────────────────────────────────────────────────────
class AirFreightBillTypeChanged extends AirFreightEvent {
  final String billType;
  AirFreightBillTypeChanged(this.billType);
}

// ── Job No autocomplete ───────────────────────────────────────────────────────
class AirFreightJobNoTextChanged extends AirFreightEvent {
  final String text;
  AirFreightJobNoTextChanged(this.text);
}

class AirFreightJobNoSelected extends AirFreightEvent {
  final int    saleOrderId;
  final String jobNo;
  AirFreightJobNoSelected(
      {required this.saleOrderId, required this.jobNo});
}

class AirFreightOverlayDismissed extends AirFreightEvent {}

// ── Status search ─────────────────────────────────────────────────────────────
class AirFreightStatusSelected extends AirFreightEvent {
  final int    statusId;
  final String statusName;
  AirFreightStatusSelected(
      {required this.statusId, required this.statusName});
}

class AirFreightStatusCleared extends AirFreightEvent {}

// ── AWB No text ───────────────────────────────────────────────────────────────
class AirFreightAwbNoChanged extends AirFreightEvent {
  final String value;
  AirFreightAwbNoChanged(this.value);
}

// ── Image upload ──────────────────────────────────────────────────────────────
class AirFreightImageUploadToggled extends AirFreightEvent {
  final bool value;
  AirFreightImageUploadToggled(this.value);
}

class AirFreightImagePicked extends AirFreightEvent {
  final String imageUrl;
  AirFreightImagePicked(this.imageUrl);
}

class AirFreightImageDeleted extends AirFreightEvent {
  final int index;
  AirFreightImageDeleted(this.index);
}

// ── Save ──────────────────────────────────────────────────────────────────────
class AirFreightSaveRequested extends AirFreightEvent {}

// ── Clear / Reset ─────────────────────────────────────────────────────────────
class AirFreightClearRequested extends AirFreightEvent {}