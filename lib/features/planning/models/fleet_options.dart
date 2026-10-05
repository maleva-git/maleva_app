import 'package:intl/intl.dart';
import 'package:maleva/features/planning/data/js_values.dart';

/// Truck and driver lists with the web's expiry and leave colours
/// (`FE/utils/truckExpiryWarnings.ts`, `FE/utils/driverExpiryWarnings.ts`).
enum ExpirySeverity { normal, warning, critical, leaveApproved, leavePending }

class ExpiryWarning {
  const ExpiryWarning({required this.label, required this.daysLeft, required this.dateText, required this.severity, this.isLeave = false});

  final String label;
  final int daysLeft;
  final String dateText;
  final ExpirySeverity severity;
  final bool isLeave;

  /// `formatTruckExpiryMessage` / `formatDriverExpiryMessage`.
  String get message {
    if (isLeave) return '$label: $dateText';
    if (daysLeft < 0) {
      final overdue = daysLeft.abs();
      return '$label expired $overdue day${overdue == 1 ? '' : 's'} ago ($dateText)';
    }
    if (daysLeft == 0) return '$label expires today ($dateText)';
    return '$label expires in $daysLeft day${daysLeft == 1 ? '' : 's'} ($dateText)';
  }
}

class ExpiryState {
  const ExpiryState(this.severity, this.warnings);

  static const normal = ExpiryState(ExpirySeverity.normal, []);

  final ExpirySeverity severity;
  final List<ExpiryWarning> warnings;
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime? _expiryDate(dynamic v) {
  if (!Js.truthy(v)) return null;
  final d = DateTime.tryParse(Js.text(v));
  return d == null ? null : _day(d.isUtc ? d.toLocal() : d);
}

String _enGb(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

ExpiryWarning? _warn(Map<String, dynamic> m, String key, String label, int warningDays, int criticalDays, DateTime today) {
  final exp = _expiryDate(m[key]);
  if (exp == null) return null;
  final daysLeft = (exp.difference(_day(today)).inHours / 24).ceil();
  if (daysLeft > warningDays) return null;
  return ExpiryWarning(
      label: label, daysLeft: daysLeft, dateText: _enGb(exp), severity: daysLeft <= criticalDays ? ExpirySeverity.critical : ExpirySeverity.warning);
}

const _truckFields = [
  ('rotexMyExp', 'Rotex MY', 10),
  ('rotexSGExp', 'Rotex SG', 10),
  ('rotexMyExp1', 'Rotex MY 1', 10),
  ('rotexSGExp1', 'Rotex SG 1', 10),
  ('puspacomExp', 'Puspakom', 10),
  ('puspacomExp1', 'Puspakom 1', 10),
  ('serviceExp', 'Service', 5),
  ('alignmentExp', 'Alignment', 5),
  ('greeceExp', 'Greece', 5),
  ('gearOilExp', 'Gear Oil', 5),
  ('ptpStickerExp', 'PTP Sticker', 5),
];

/// `getTruckExpiryState`: red at 3 days or fewer.
ExpiryState truckExpiryState(Map<String, dynamic> truck, {DateTime? today}) {
  final now = today ?? DateTime.now();
  final warnings = [
    for (final f in _truckFields) _warn(truck, f.$1, f.$2, f.$3, 3, now),
  ].whereType<ExpiryWarning>().toList();
  final severity = warnings.any((w) => w.severity == ExpirySeverity.critical)
      ? ExpirySeverity.critical
      : warnings.isNotEmpty
          ? ExpirySeverity.warning
          : ExpirySeverity.normal;
  return ExpiryState(severity, warnings);
}

const _driverFields = [('licenseExp', 'License'), ('LicenseExp', 'License'), ('gdlExp', 'GDL'), ('GdlExp', 'GDL')];

/// `getDriverExpiryState`: licence and GDL (7 days, red at 3), then the latest leave.
ExpiryState driverExpiryState(Map<String, dynamic> driver, {DateTime? today}) {
  final now = today ?? DateTime.now();
  final seen = <String>{};
  final warnings = <ExpiryWarning>[];
  for (final f in _driverFields) {
    if (seen.contains(f.$2)) continue;
    if (_expiryDate(driver[f.$1]) == null) continue;
    seen.add(f.$2);
    final w = _warn(driver, f.$1, f.$2, 7, 3, now);
    if (w != null) warnings.add(w);
  }
  final leaves = driver['leaves'];
  if (leaves is List && leaves.isNotEmpty && leaves.first is Map) {
    final latest = Map<String, dynamic>.from(leaves.first as Map);
    final status = Js.text(latest['StatusName']).toUpperCase();
    if (status == 'APPROVED' || status == 'PENDING') {
      String day(dynamic v) {
        final d = DateTime.tryParse(Js.text(v));
        return d == null ? 'Invalid Date' : _enGb(d);
      }

      final type = Js.truthy(latest['LeaveTypeName']) ? Js.text(latest['LeaveTypeName']) : 'General';
      warnings.add(ExpiryWarning(
        label: 'Leave ($status) - $type',
        daysLeft: 0,
        dateText: '${day(latest['FromDate'])} to ${day(latest['ToDate'])}',
        severity: status == 'APPROVED' ? ExpirySeverity.leaveApproved : ExpirySeverity.leavePending,
        isLeave: true,
      ));
    }
  }
  var severity = ExpirySeverity.normal;
  if (warnings.any((w) => w.severity == ExpirySeverity.critical)) {
    severity = ExpirySeverity.critical;
  } else if (warnings.any((w) => w.severity == ExpirySeverity.leaveApproved)) {
    severity = ExpirySeverity.leaveApproved;
  } else if (warnings.any((w) => w.severity == ExpirySeverity.leavePending)) {
    severity = ExpirySeverity.leavePending;
  } else if (warnings.any((w) => w.severity == ExpirySeverity.warning)) {
    severity = ExpirySeverity.warning;
  }
  return ExpiryState(severity, warnings);
}

/// A truck of the picker (`normalizeTruckComboRow`, `FE/api/truckApi.ts`).
class TruckOption {
  const TruckOption({required this.id, required this.name, this.raw = const {}});

  final int id;
  final String name;
  final Map<String, dynamic> raw;

  static TruckOption? fromJava(Map<String, dynamic> row) {
    final id = Js.positiveInt(Js.nn(row, ['Id', 'id', 'truckId', 'TruckId']));
    final name = Js.text(Js.nn(row, ['AccountName', 'accountName', 'TruckName', 'truckName', 'name', 'truckNumber'])).trim();
    if (id == 0 || name.isEmpty) return null;
    return TruckOption(id: id, name: name, raw: row);
  }

  ExpiryState expiry({DateTime? today}) => truckExpiryState(raw, today: today);
}

/// A driver of the picker (`normalizeDriverComboRow` + `filterDrivers`, `FE/api/driverApi.ts`):
/// the name is `AccountName`, or `driverName-mobileNo`.
class DriverOption {
  const DriverOption({required this.id, required this.name, this.raw = const {}});

  final int id;
  final String name;
  final Map<String, dynamic> raw;

  static DriverOption? fromJava(Map<String, dynamic> row) {
    final id = Js.positiveInt(Js.nn(row, ['Id', 'id', 'DriverId', 'driverId']));
    if (id == 0) return null;
    final driverName = Js.text(Js.nn(row, ['DriverName', 'driverName', 'AccountName', 'accountName'])).trim();
    final mobile = Js.text(Js.nn(row, ['MobileNo', 'mobileNo'])).trim();
    final account =
        Js.text(Js.nn(row, ['AccountName', 'accountName']) ?? (driverName.isNotEmpty && mobile.isNotEmpty ? '$driverName-$mobile' : driverName))
            .trim();
    if (account.isEmpty) return null;
    return DriverOption(id: id, name: account, raw: row);
  }

  /// `filterDrivers`: active ones of the company, by name.
  static List<DriverOption> listFrom(List<Map<String, dynamic>> rows, int companyId) {
    bool active(dynamic v) {
      if (v is bool) return v;
      final t = Js.text(v ?? 1).trim().toLowerCase();
      if (t == 'false' || t == '0' || t == 'no') return false;
      return Js.number(v ?? 1) != 0;
    }

    final list = <DriverOption>[];
    for (final r in rows) {
      final o = fromJava(r);
      if (o == null) continue;
      final rowCompany = Js.positiveInt(Js.nn(r, ['CompanyId', 'companyId', 'CompanyRefId', 'companyRefId']));
      if (companyId > 0 && rowCompany > 0 && rowCompany != companyId) continue;
      if (!active(Js.nn(r, ['Active', 'active']) ?? 1)) continue;
      list.add(o);
    }
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  /// The OUTSIDE DRIVER entry (id 36 or that name, `DriverSelectModal.tsx:37-42`): picking it asks for a name.
  bool get isOutsideDriver => id == 36 || name.trim().toUpperCase() == 'OUTSIDE DRIVER';

  ExpiryState expiry({DateTime? today}) => driverExpiryState(raw, today: today);
}

/// An employee of the EMPLOYEE picker (`createEmployeeOptions`): `{value: id, label: name}`.
class EmployeeOption {
  const EmployeeOption(this.id, this.name);

  final int id;
  final String name;
}
