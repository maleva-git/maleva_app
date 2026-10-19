import 'package:intl/intl.dart';
import 'package:maleva/core/utils/json_read.dart';

/// One pending or approved leave of a driver, as Planning and RTI warn with it.
class DriverLeaveNote {
  const DriverLeaveNote({required this.label, required this.dateText, required this.approved, required this.daysAway});

  /// "Leave (APPROVED) - ANNUAL".
  final String label;

  /// "20/10/2026 to 21/10/2026, starts tomorrow" or "19/10/2026 09:00 to 11:00, on leave today".
  final String dateText;
  final bool approved;
  final int daysAway;
}

/// Every pending or approved leave of the driver list's `leaves` (today and the next 3 days), by
/// start. Before, only the first row was read, so a rejected one hid an approved leave and a second
/// leave was never shown (openspec change `leave-approval-rules`, same as the web's
/// `driverExpiryWarnings.ts`). Warn only: the driver can still be chosen.
List<DriverLeaveNote> driverLeaveNotes(dynamic leaves, {DateTime? now}) {
  if (leaves is! List) return const [];
  final today = _day(now ?? DateTime.now());
  final rows = <(Map<String, dynamic>, String, DateTime?, DateTime?)>[];
  for (final row in leaves) {
    if (row is! Map) continue;
    final leave = Map<String, dynamic>.from(row);
    final status = JsonRead.string(JsonRead.field(leave, 'StatusName')).trim().toUpperCase();
    if (status != 'APPROVED' && status != 'PENDING') continue;
    rows.add((leave, status, JsonRead.date(JsonRead.field(leave, 'FromDate')), JsonRead.date(JsonRead.field(leave, 'ToDate'))));
  }
  rows.sort((a, b) => (a.$3 ?? DateTime(0)).compareTo(b.$3 ?? DateTime(0)));
  return [
    for (final (leave, status, from, to) in rows)
      DriverLeaveNote(
        label: 'Leave ($status) - ${_typeOf(leave)}',
        dateText: from == null || to == null ? '' : '${_dates(from, to)}, ${_when(from, today)}',
        approved: status == 'APPROVED',
        daysAway: from == null ? 0 : _daysBetween(today, _day(from)).clamp(0, 9999),
      ),
  ];
}

String _typeOf(Map<String, dynamic> leave) {
  final type = JsonRead.string(JsonRead.field(leave, 'LeaveTypeName')).trim();
  return type.isEmpty ? 'General' : type;
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

int _daysBetween(DateTime a, DateTime b) =>
    DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

bool _midnight(DateTime d) => d.hour == 0 && d.minute == 0;

final _dayFormat = DateFormat('dd/MM/yyyy');
final _timeFormat = DateFormat('HH:mm');

String _dates(DateTime from, DateTime to) {
  final sameDay = _day(from) == _day(to);
  if (sameDay && (!_midnight(from) || !_midnight(to))) {
    return '${_dayFormat.format(from)} ${_timeFormat.format(from)} to ${_timeFormat.format(to)}';
  }
  return '${_dayFormat.format(from)} to ${_dayFormat.format(to)}';
}

String _when(DateTime from, DateTime today) {
  final days = _daysBetween(today, _day(from));
  if (days <= 0) return 'on leave today';
  return days == 1 ? 'starts tomorrow' : 'starts in $days days';
}
