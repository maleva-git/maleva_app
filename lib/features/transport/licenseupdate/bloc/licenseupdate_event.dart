

abstract class LicenseUpdateEvent {}

// ── Startup ───────────────────────────────────────────────────────────────────
class LicenseUpdateStarted extends LicenseUpdateEvent {}

// ── Truck selector ────────────────────────────────────────────────────────────
class LicenseUpdateTruckSelected extends LicenseUpdateEvent {
  final int    truckId;
  final String truckName;
  LicenseUpdateTruckSelected(
      {required this.truckId, required this.truckName});
}

class LicenseUpdateTruckCleared extends LicenseUpdateEvent {}

// ── Text field changes ────────────────────────────────────────────────────────
// field keys: 'truckNo','truckNo2','truckName','longitude','latitude','truckType'
class LicenseUpdateTextChanged extends LicenseUpdateEvent {
  final String field;
  final String value;
  LicenseUpdateTextChanged({required this.field, required this.value});
}

// ── Date + checkbox per expiry field ─────────────────────────────────────────
// key: 'rotexMyExp','rotexSGExp','puspacomExp','rotexMyExp1','rotexSGExp1',
//       'puspacomExp1','insuratnceExp','bonamExp','apadExp',
//       'serviceExp','alignmentExp','greeceExp'
class LicenseUpdateDateChanged extends LicenseUpdateEvent {
  final String key;
  final String date; // yyyy-MM-dd
  LicenseUpdateDateChanged({required this.key, required this.date});
}

class LicenseUpdateCheckboxChanged extends LicenseUpdateEvent {
  final String key;
  final bool   value;
  LicenseUpdateCheckboxChanged({required this.key, required this.value});
}

// ── Save ──────────────────────────────────────────────────────────────────────
class LicenseUpdateSaveRequested extends LicenseUpdateEvent {}

// ── Clear / Reset ─────────────────────────────────────────────────────────────
class LicenseUpdateClearRequested extends LicenseUpdateEvent {}