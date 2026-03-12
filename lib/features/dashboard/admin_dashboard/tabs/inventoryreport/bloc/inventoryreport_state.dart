import 'package:maleva/core/models/model.dart';

// ── Filter constants ──────────────────────────────────────────────────────────
const kInventoryPortFilters = [
  {"id": 1, "name": "PTP"},
  {"id": 2, "name": "WP"},
  {"id": 3, "name": "NP"},
  {"id": 4, "name": "SP"},
  {"id": 5, "name": "Klia"},
  {"id": 6, "name": "PasirGudang"},
];

// ─────────────────────────────────────────────────────────────────────────────
abstract class InventoryState {
  const InventoryState();
}

// ── Single state — copyWith pattern (Payment Pending மாதிரி) ─────────────────
class InventoryLoaded extends InventoryState {
  final int selectedPortId;        // chip filter
  final DateTime fromDate;
  final DateTime toDate;
  final int? selectedCustomerId;   // customer select
  final bool isChecked;            // checkbox
  final int status;                // 0 or 1
  final List<InventoryModel> records;
  final bool isLoading;

  const InventoryLoaded({
    this.selectedPortId = 1,
    required this.fromDate,
    required this.toDate,
    this.selectedCustomerId,
    this.isChecked = false,
    this.status = 0,
    this.records = const [],
    this.isLoading = false,
  });

  InventoryLoaded copyWith({
    int? selectedPortId,
    DateTime? fromDate,
    DateTime? toDate,
    int? selectedCustomerId,
    bool? isChecked,
    int? status,
    List<InventoryModel>? records,
    bool? isLoading,
    bool clearCustomer = false,
  }) {
    return InventoryLoaded(
      selectedPortId:    selectedPortId    ?? this.selectedPortId,
      fromDate:          fromDate          ?? this.fromDate,
      toDate:            toDate            ?? this.toDate,
      selectedCustomerId: clearCustomer
          ? null
          : (selectedCustomerId ?? this.selectedCustomerId),
      isChecked:         isChecked         ?? this.isChecked,
      status:            status            ?? this.status,
      records:           records           ?? this.records,
      isLoading:         isLoading         ?? this.isLoading,
    );
  }
}

class InventoryError extends InventoryState {
  final String message;
  final int selectedPortId;
  final DateTime fromDate;
  final DateTime toDate;
  final int? selectedCustomerId;
  final bool isChecked;
  final int status;

  const InventoryError({
    required this.message,
    required this.selectedPortId,
    required this.fromDate,
    required this.toDate,
    this.selectedCustomerId,
    this.isChecked = false,
    this.status = 0,
  });
}