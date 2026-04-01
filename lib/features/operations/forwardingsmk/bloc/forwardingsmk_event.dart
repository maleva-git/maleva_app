

abstract class FWSmkEvent {}

// ── Startup ──────────────────────────────────────────────────────────────────
class FWSmkStarted extends FWSmkEvent {}

// ── Tab ──────────────────────────────────────────────────────────────────────
class FWSmkTabChanged extends FWSmkEvent {
  final int index;
  FWSmkTabChanged(this.index);
}

// ── BillType radio (MY=0, TR=1) ───────────────────────────────────────────────
class FWSmkBillTypeChanged extends FWSmkEvent {
  final String billType;
  FWSmkBillTypeChanged(this.billType);
}

// ── Job No autocomplete ───────────────────────────────────────────────────────
class FWSmkJobNoTextChanged extends FWSmkEvent {
  final String text;
  FWSmkJobNoTextChanged(this.text);
}

class FWSmkJobNoSelected extends FWSmkEvent {
  final int saleOrderId;
  final String jobNo;
  FWSmkJobNoSelected({required this.saleOrderId, required this.jobNo});
}

class FWSmkOverlayDismissed extends FWSmkEvent {}

// ── Per-tab field changes ─────────────────────────────────────────────────────
// tab: 1,2,3  |  field key used in copyWith
class FWSmkFieldChanged extends FWSmkEvent {
  final int tab;
  final String field; // 'smkNo','enRef','s1','s2','fwDropdown'
  final String value;
  FWSmkFieldChanged({required this.tab, required this.field, required this.value});
}

// ── Date + checkbox ────────────────────────────────────────────────────────────
class FWSmkDateChanged extends FWSmkEvent {
  final int tab;   // 1,2,3
  final String date;
  FWSmkDateChanged({required this.tab, required this.date});
}

class FWSmkCheckboxChanged extends FWSmkEvent {
  final int tab;
  final bool value;
  FWSmkCheckboxChanged({required this.tab, required this.value});
}

// ── Save ──────────────────────────────────────────────────────────────────────
class FWSmkSaveRequested extends FWSmkEvent {}