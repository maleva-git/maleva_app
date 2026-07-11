

abstract class StockUpdateEvent {}

// ── Startup ───────────────────────────────────────────────────────────────────
class StockUpdateStarted extends StockUpdateEvent {}

// ── Barcode scan ──────────────────────────────────────────────────────────────
class StockUpdateBarcodeScanRequested extends StockUpdateEvent {}

// ── Scanned item delete from list ─────────────────────────────────────────────
class StockUpdateScannedItemDeleted extends StockUpdateEvent {
  final int index;
  StockUpdateScannedItemDeleted(this.index);
}

// ── Warehouse selected / cleared ─────────────────────────────────────────────
class StockUpdateWarehouseSelected extends StockUpdateEvent {
  final int    warehouseId;
  final String warehouseName;
  StockUpdateWarehouseSelected(
      {required this.warehouseId, required this.warehouseName});
}

class StockUpdateWarehouseCleared extends StockUpdateEvent {}

// ── Status selected / cleared ─────────────────────────────────────────────────
class StockUpdateStatusSelected extends StockUpdateEvent {
  final int    statusId;
  final String statusName;
  StockUpdateStatusSelected(
      {required this.statusId, required this.statusName});
}

class StockUpdateStatusCleared extends StockUpdateEvent {}

// ── Image ─────────────────────────────────────────────────────────────────────
class StockUpdateImageUploadToggled extends StockUpdateEvent {
  final bool value;
  StockUpdateImageUploadToggled(this.value);
}

class StockUpdateImagePicked extends StockUpdateEvent {
  final String imageUrl;
  StockUpdateImagePicked(this.imageUrl);
}

class StockUpdateImageDeleted extends StockUpdateEvent {
  final int index;
  StockUpdateImageDeleted(this.index);
}

// ── Update stock status ───────────────────────────────────────────────────────
class StockUpdateSaveRequested extends StockUpdateEvent {}

// ── Clear / Reset ─────────────────────────────────────────────────────────────
class StockUpdateClearRequested extends StockUpdateEvent {}