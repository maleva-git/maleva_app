

abstract class BoardingStatusEvent {}

// ── Startup ───────────────────────────────────────────────────────────────────
// Optional pre-fill from dashboard (JobNo + JobId passed as widget params)
class BoardingStatusStarted extends BoardingStatusEvent {
  final String? jobNo;
  final int?    jobId;
  BoardingStatusStarted({this.jobNo, this.jobId});
}

// ── BillType radio ────────────────────────────────────────────────────────────
class BoardingStatusBillTypeChanged extends BoardingStatusEvent {
  final String billType;
  BoardingStatusBillTypeChanged(this.billType);
}

// ── Job No autocomplete ───────────────────────────────────────────────────────
class BoardingStatusJobNoTextChanged extends BoardingStatusEvent {
  final String text;
  BoardingStatusJobNoTextChanged(this.text);
}

class BoardingStatusJobNoSelected extends BoardingStatusEvent {
  final int    saleOrderId;
  final String jobNo;
  BoardingStatusJobNoSelected({required this.saleOrderId, required this.jobNo});
}

class BoardingStatusOverlayDismissed extends BoardingStatusEvent {}

// ── Status search field ───────────────────────────────────────────────────────
class BoardingStatusStatusSelected extends BoardingStatusEvent {
  final int    statusId;
  final String statusName;
  BoardingStatusStatusSelected(
      {required this.statusId, required this.statusName});
}

class BoardingStatusStatusCleared extends BoardingStatusEvent {}

// ── DateTime + checkbox ───────────────────────────────────────────────────────
class BoardingStatusStartTimeChanged extends BoardingStatusEvent {
  final String dateTime;
  BoardingStatusStartTimeChanged(this.dateTime);
}

class BoardingStatusStartTimeCheckboxChanged extends BoardingStatusEvent {
  final bool value;
  BoardingStatusStartTimeCheckboxChanged(this.value);
}

class BoardingStatusEndTimeChanged extends BoardingStatusEvent {
  final String dateTime;
  BoardingStatusEndTimeChanged(this.dateTime);
}

class BoardingStatusEndTimeCheckboxChanged extends BoardingStatusEvent {
  final bool value;
  BoardingStatusEndTimeCheckboxChanged(this.value);
}

// ── Image ─────────────────────────────────────────────────────────────────────
class BoardingStatusImageUploadToggled extends BoardingStatusEvent {
  final bool value;
  BoardingStatusImageUploadToggled(this.value);
}

class BoardingStatusImagePicked extends BoardingStatusEvent {
  final String imageUrl;
  BoardingStatusImagePicked(this.imageUrl);
}

class BoardingStatusImageDeleted extends BoardingStatusEvent {
  final int index;
  BoardingStatusImageDeleted(this.index);
}

// ── Save ──────────────────────────────────────────────────────────────────────
class BoardingStatusSaveRequested extends BoardingStatusEvent {}

// ── Reset ─────────────────────────────────────────────────────────────────────
class BoardingStatusResetRequested extends BoardingStatusEvent {}