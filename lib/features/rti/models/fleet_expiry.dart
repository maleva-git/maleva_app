import 'package:intl/intl.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/widgets/ui/picker_sheet.dart' show PickSeverity;
import 'package:maleva/features/rti/models/js_values.dart';
import 'package:maleva/features/rti/models/rti_dates.dart';

/// One expiry (or leave) warning of a truck or driver.
class FleetWarning {
  const FleetWarning({required this.label, required this.daysLeft, required this.dateText, required this.severity, this.isLeave = false});

  final String label;
  final int daysLeft;
  final String dateText;
  final PickSeverity severity;
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

/// The picker colours of the trucks and drivers (`FE/utils/truckExpiryWarnings.ts`,
/// `FE/utils/driverExpiryWarnings.ts`): truck red at 3 days or fewer, warning from 10 days
/// (Rotex, Puspakom) or 5 days (the rest); driver licence / GDL warning at 7, red at 3; a
/// pending or approved leave.
abstract final class FleetExpiry {
  static const _truckFields = [
    ('rotexMyExp', 'Rotex MY', 10), ('rotexSGExp', 'Rotex SG', 10), ('rotexMyExp1', 'Rotex MY 1', 10),
    ('rotexSGExp1', 'Rotex SG 1', 10), ('puspacomExp', 'Puspakom', 10), ('puspacomExp1', 'Puspakom 1', 10),
    ('serviceExp', 'Service', 5), ('alignmentExp', 'Alignment', 5), ('greeceExp', 'Greece', 5),
    ('gearOilExp', 'Gear Oil', 5), ('ptpStickerExp', 'PTP Sticker', 5),
  ];

  static const _driverFields = [('licenseExp', 'License', 7, 3), ('gdlExp', 'GDL', 7, 3)];

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static FleetWarning? _warning(dynamic raw, String label, int warnDays, int critDays, DateTime today) {
    final parsed = RtiDates.parse(raw);
    if (parsed == null) return null;
    final expiry = _day(parsed);
    final days = (expiry.difference(today).inHours / 24).ceil();
    if (days > warnDays) return null;
    return FleetWarning(
      label: label,
      daysLeft: days,
      dateText: DateFormat('dd/MM/yyyy').format(expiry),
      severity: days <= critDays ? PickSeverity.critical : PickSeverity.warning,
    );
  }

  static List<FleetWarning> truck(Map<String, dynamic>? t, {DateTime? now}) {
    if (t == null) return const [];
    final today = _day(now ?? DateTime.now());
    return [
      for (final (key, label, warn) in _truckFields)
        if (_warning(JsonRead.field(t, key), label, warn, 3, today) case final w?) w,
    ];
  }

  static List<FleetWarning> driver(Map<String, dynamic>? d, {DateTime? now}) {
    if (d == null) return const [];
    final today = _day(now ?? DateTime.now());
    final out = <FleetWarning>[
      for (final (key, label, warn, crit) in _driverFields)
        if (_warning(JsonRead.field(d, key), label, warn, crit, today) case final w?) w,
    ];
    final leaves = JsonRead.listOfMaps(JsonRead.field(d, 'leaves'));
    if (leaves.isNotEmpty) {
      final latest = leaves.first;
      final status = Js.fieldText(latest, ['StatusName']).toUpperCase();
      if (status == 'APPROVED' || status == 'PENDING') {
        final type = Js.fieldText(latest, ['LeaveTypeName']);
        out.add(FleetWarning(
          label: 'Leave ($status) - ${type.isEmpty ? 'General' : type}',
          daysLeft: 0,
          dateText: '${RtiDates.short(Js.field(latest, ['FromDate']))} to ${RtiDates.short(Js.field(latest, ['ToDate']))}',
          severity: status == 'APPROVED' ? PickSeverity.leaveApproved : PickSeverity.leavePending,
          isLeave: true,
        ));
      }
    }
    return out;
  }

  /// The row's overall colour: critical first, then (drivers) leave, then warning.
  static PickSeverity severityOf(List<FleetWarning> warnings) {
    bool any(PickSeverity s) => warnings.any((w) => w.severity == s);
    if (any(PickSeverity.critical)) return PickSeverity.critical;
    if (any(PickSeverity.leaveApproved)) return PickSeverity.leaveApproved;
    if (any(PickSeverity.leavePending)) return PickSeverity.leavePending;
    if (any(PickSeverity.warning)) return PickSeverity.warning;
    return PickSeverity.normal;
  }
}
