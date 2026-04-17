

abstract class StockInEntryEvent {}

// ── Startup ───────────────────────────────────────────────────────────────────
class StockInEntryStarted extends StockInEntryEvent {
  final String? jobNo;
  final int?    jobId;
  StockInEntryStarted({this.jobNo, this.jobId});
}

// ── BillType radio ────────────────────────────────────────────────────────────
class StockInEntryBillTypeChanged extends StockInEntryEvent {
  final String billType;
  StockInEntryBillTypeChanged(this.billType);
}

// ── Job No autocomplete ───────────────────────────────────────────────────────
class StockInEntryJobNoTextChanged extends StockInEntryEvent {
  final String text;
  StockInEntryJobNoTextChanged(this.text);
}

class StockInEntryJobNoSelected extends StockInEntryEvent {
  final int    saleOrderId;
  final String jobNo;
  final bool   stockExistsConfirmed; // user already confirmed "remove and save"
  StockInEntryJobNoSelected({
    required this.saleOrderId,
    required this.jobNo,
    this.stockExistsConfirmed = false,
  });
}

class StockInEntryOverlayDismissed extends StockInEntryEvent {}

// ── Stock date ────────────────────────────────────────────────────────────────
class StockInEntryDateChanged extends StockInEntryEvent {
  final String date;
  StockInEntryDateChanged(this.date);
}

// ── Packages text ─────────────────────────────────────────────────────────────
class StockInEntryPackagesChanged extends StockInEntryEvent {
  final String value;
  StockInEntryPackagesChanged(this.value);
}

// ── Status search ─────────────────────────────────────────────────────────────
class StockInEntryStatusSelected extends StockInEntryEvent {
  final int    statusId;
  final String statusName;
  StockInEntryStatusSelected(
      {required this.statusId, required this.statusName});
}

class StockInEntryStatusCleared extends StockInEntryEvent {}

// ── Image ─────────────────────────────────────────────────────────────────────
class StockInEntryImageUploadToggled extends StockInEntryEvent {
  final bool value;
  StockInEntryImageUploadToggled(this.value);
}

class StockInEntryImagePicked extends StockInEntryEvent {
  final String imageUrl;
  StockInEntryImagePicked(this.imageUrl);
}

class StockInEntryImageDeleted extends StockInEntryEvent {
  final int index;
  StockInEntryImageDeleted(this.index);
}

// ── Save ──────────────────────────────────────────────────────────────────────
class StockInEntrySaveRequested extends StockInEntryEvent {}

// ── Clear / Reset ─────────────────────────────────────────────────────────────
class StockInEntryClearRequested extends StockInEntryEvent {}