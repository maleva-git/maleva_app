import '../../../../../../core/models/model.dart';

abstract class InventoryEvent {
  const InventoryEvent();
}

// ── Init ──────────────────────────────────────────────────────────────────────
class LoadInventoryListsEvent extends InventoryEvent {
  const LoadInventoryListsEvent();
}

// ── Port Filter Chip ──────────────────────────────────────────────────────────
class SelectPortFilterEvent extends InventoryEvent {
  final int portId;
  const SelectPortFilterEvent(this.portId);
}

// ── Date Filter ───────────────────────────────────────────────────────────────
class SelectInventoryFromDateEvent extends InventoryEvent {
  final DateTime date;
  const SelectInventoryFromDateEvent(this.date);
}

class SelectInventoryToDateEvent extends InventoryEvent {
  final DateTime date;
  const SelectInventoryToDateEvent(this.date);
}
class SelectInventoryItemEvent extends InventoryEvent {
  final InventoryModel item;
  const SelectInventoryItemEvent(this.item);
}
class SearchInventoryByDateEvent extends InventoryEvent {
  const SearchInventoryByDateEvent();
}

// ── Customer Select (new page) ────────────────────────────────────────────────
class SelectInventoryCustomerEvent extends InventoryEvent {
  final int? customerId;
  const SelectInventoryCustomerEvent(this.customerId);
}

// ── Checkbox ──────────────────────────────────────────────────────────────────
class ToggleInventoryStatusEvent extends InventoryEvent {
  final bool isChecked;
  const ToggleInventoryStatusEvent(this.isChecked);
}