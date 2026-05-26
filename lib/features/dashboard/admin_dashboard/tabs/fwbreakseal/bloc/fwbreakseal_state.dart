

// ─── Overlay status ───────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

enum OverlayStatus { hidden, visible }

// ─── Screen status ────────────────────────────────────────────────────────────

enum FWScreenStatus { idle, loading, success, failure }

// ─── Per-SMK slot data ────────────────────────────────────────────────────────

/// Immutable data for one forwarding slot (SMK 1 / 2 / 3).
class SmkSlotData extends Equatable {
  final String smkNo;
  final String exRef;
  final String breakByEmpName;
  final int breakByEmpId;

  const SmkSlotData({
    this.smkNo = '',
    this.exRef = '',
    this.breakByEmpName = '',
    this.breakByEmpId = 0,
  });

  SmkSlotData copyWith({
    String? smkNo,
    String? exRef,
    String? breakByEmpName,
    int? breakByEmpId,
  }) {
    return SmkSlotData(
      smkNo: smkNo ?? this.smkNo,
      exRef: exRef ?? this.exRef,
      breakByEmpName: breakByEmpName ?? this.breakByEmpName,
      breakByEmpId: breakByEmpId ?? this.breakByEmpId,
    );
  }

  bool get isEmpty => smkNo.isEmpty;

  @override
  List<Object?> get props => [smkNo, exRef, breakByEmpName, breakByEmpId];
}

// ─── Main state ───────────────────────────────────────────────────────────────

class FWBreakSealState extends Equatable {
  // ── Tab ──────────────────────────────────────────────────
  final int activeTab;

  // ── Three forwarding slots ────────────────────────────────
  final SmkSlotData slot1;
  final SmkSlotData slot2;
  final SmkSlotData slot3;

  // ── Selected sale-order id ────────────────────────────────
  final int saleOrderId;

  // ── Auto-complete suggestions ─────────────────────────────
  final List<Map<String, dynamic>> suggestions;
  final OverlayStatus overlayStatus;

  /// Which SMK type is the overlay serving right now (1 | 2 | 3)
  final int overlayForType;

  // ── Screen-level status ───────────────────────────────────
  final FWScreenStatus screenStatus;
  final String? errorMessage;
  final String? successMessage;

  // ── Loading flag (replaces progress boolean) ─────────────
  final bool isLoading;

  // ── Logged-in user ────────────────────────────────────────
  final String userName;

  const FWBreakSealState({
    this.activeTab = 0,
    this.slot1 = const SmkSlotData(),
    this.slot2 = const SmkSlotData(),
    this.slot3 = const SmkSlotData(),
    this.saleOrderId = 0,
    this.suggestions = const [],
    this.overlayStatus = OverlayStatus.hidden,
    this.overlayForType = 1,
    this.screenStatus = FWScreenStatus.idle,
    this.errorMessage,
    this.successMessage,
    this.isLoading = false,
    this.userName = '',
  });

  // ── Convenience getters ───────────────────────────────────

  bool get isOverlayVisible => overlayStatus == OverlayStatus.visible;

  SmkSlotData slotFor(int type) {
    switch (type) {
      case 2:
        return slot2;
      case 3:
        return slot3;
      default:
        return slot1;
    }
  }

  // ── copyWith ─────────────────────────────────────────────
  FWBreakSealState copyWith({
    int? activeTab,
    SmkSlotData? slot1,
    SmkSlotData? slot2,
    SmkSlotData? slot3,
    int? saleOrderId,
    List<Map<String, dynamic>>? suggestions,
    OverlayStatus? overlayStatus,
    int? overlayForType,
    FWScreenStatus? screenStatus,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool? isLoading,
    String? userName,
  }) {
    return FWBreakSealState(
      activeTab: activeTab ?? this.activeTab,
      slot1: slot1 ?? this.slot1,
      slot2: slot2 ?? this.slot2,
      slot3: slot3 ?? this.slot3,
      saleOrderId: saleOrderId ?? this.saleOrderId,
      suggestions: suggestions ?? this.suggestions,
      overlayStatus: overlayStatus ?? this.overlayStatus,
      overlayForType: overlayForType ?? this.overlayForType,
      screenStatus: screenStatus ?? this.screenStatus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
      clearSuccess ? null : (successMessage ?? this.successMessage),
      isLoading: isLoading ?? this.isLoading,
      userName: userName ?? this.userName,
    );
  }

  // ── Reset helper ─────────────────────────────────────────
  FWBreakSealState get cleared => FWBreakSealState(
    userName: userName,
    screenStatus: FWScreenStatus.idle,
  );

  @override
  List<Object?> get props => [
    activeTab,
    slot1,
    slot2,
    slot3,
    saleOrderId,
    suggestions,
    overlayStatus,
    overlayForType,
    screenStatus,
    errorMessage,
    successMessage,
    isLoading,
    userName,
  ];
}