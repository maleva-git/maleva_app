
abstract class FWSmkState {}

class FWSmkInitial extends FWSmkState {}

class FWSmkLoading extends FWSmkState {}

// ── Per-tab data model ────────────────────────────────────────────────────────
class FWSmkTabData {
  final String smkNo;
  final String enRef;
  final String s1;
  final String s2;
  final String? fwDropdown;   // K1/K2/K3/K8
  final String date;
  final bool dateEnabled;

  const FWSmkTabData({
    required this.smkNo,
    required this.enRef,
    required this.s1,
    required this.s2,
    required this.fwDropdown,
    required this.date,
    required this.dateEnabled,
  });

  static String _today() =>
      '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';

  factory FWSmkTabData.empty() => FWSmkTabData(
    smkNo:       '',
    enRef:       '',
    s1:          '',
    s2:          '',
    fwDropdown:  null,
    date:        _today(),
    dateEnabled: false,
  );

  FWSmkTabData copyWith({
    String? smkNo,
    String? enRef,
    String? s1,
    String? s2,
    Object? fwDropdown = _sentinel, // allows passing null explicitly
    String? date,
    bool? dateEnabled,
  }) {
    return FWSmkTabData(
      smkNo:       smkNo       ?? this.smkNo,
      enRef:       enRef       ?? this.enRef,
      s1:          s1          ?? this.s1,
      s2:          s2          ?? this.s2,
      fwDropdown:  fwDropdown == _sentinel
          ? this.fwDropdown
          : fwDropdown as String?,
      date:        date        ?? this.date,
      dateEnabled: dateEnabled ?? this.dateEnabled,
    );
  }
}

// Sentinel to distinguish "not passed" from null
const _sentinel = Object();

// ── Main loaded state ─────────────────────────────────────────────────────────
class FWSmkLoaded extends FWSmkState {
  final int currentTab;
  final String billType;
  final String jobNoText;
  final int saleOrderId;
  final List<dynamic> jobNoSuggestions;

  final FWSmkTabData tab1;
  final FWSmkTabData tab2;
  final FWSmkTabData tab3;

   FWSmkLoaded({
    required this.currentTab,
    required this.billType,
    required this.jobNoText,
    required this.saleOrderId,
    required this.jobNoSuggestions,
    required this.tab1,
    required this.tab2,
    required this.tab3,
  });

  FWSmkLoaded copyWith({
    int? currentTab,
    String? billType,
    String? jobNoText,
    int? saleOrderId,
    List<dynamic>? jobNoSuggestions,
    FWSmkTabData? tab1,
    FWSmkTabData? tab2,
    FWSmkTabData? tab3,
  }) {
    return FWSmkLoaded(
      currentTab:        currentTab        ?? this.currentTab,
      billType:          billType          ?? this.billType,
      jobNoText:         jobNoText         ?? this.jobNoText,
      saleOrderId:       saleOrderId       ?? this.saleOrderId,
      jobNoSuggestions:  jobNoSuggestions  ?? this.jobNoSuggestions,
      tab1:              tab1              ?? this.tab1,
      tab2:              tab2              ?? this.tab2,
      tab3:              tab3              ?? this.tab3,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  FWSmkTabData tabByIndex(int t) {
    if (t == 1) return tab1;
    if (t == 2) return tab2;
    return tab3;
  }

  FWSmkLoaded withTab(int t, FWSmkTabData data) {
    if (t == 1) return copyWith(tab1: data);
    if (t == 2) return copyWith(tab2: data);
    return copyWith(tab3: data);
  }
}

class FWSmkError extends FWSmkState {
  final String message;
  FWSmkError(this.message);
}

class FWSmkSaveSuccess extends FWSmkState {}