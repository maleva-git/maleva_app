import 'package:maleva/core/utils/json_read.dart';

import 'leave_form.dart';

/// The company calendar the leave form counts on (HR Sprints 1–2, change `hr-leave-working-days`),
/// read from the shared `/api/hr/work-week` and `/api/hr/holidays`. The server is the truth; this only
/// shows the person what will be counted. A staff working day is 9 hours.
class LeaveCalendar {
  const LeaveCalendar({required this.enabled, required this.week, required this.holidays});

  /// The server counts working days (maleva.hr.leave.working-days.enabled): offer half days.
  final bool enabled;

  /// Monday = index 0 … Sunday = 6: 1, 0.5 or 0.
  final List<double> week;

  /// `yyyy-MM-dd` → half-day holiday?
  final Map<String, bool> holidays;

  static const hoursPerDay = 9;

  static const off = LeaveCalendar(enabled: false, week: [1, 1, 1, 1, 1, 0.5, 0], holidays: {});

  /// From the work-week answer (`ready`, `weeks`, `leaveWorkingDays`) and the holiday lists.
  factory LeaveCalendar.fromJava(Map<String, dynamic> weeks, List<Map<String, dynamic>> holidays, {required bool driver}) {
    final list = JsonRead.listOfMaps(weeks['weeks']);
    final mine = list.firstWhere((w) => JsonRead.string(w['kind']).toUpperCase() == (driver ? 'DRIVER' : 'STAFF'),
        orElse: () => const {});
    double v(String day) => switch (JsonRead.string(mine[day]).toUpperCase()) {
          'FULL' => 1,
          'HALF' => 0.5,
          'OFF' => 0,
          _ => day == 'sun' ? 0 : (day == 'sat' && !driver ? 0.5 : 1),
        };
    return LeaveCalendar(
      enabled: weeks['leaveWorkingDays'] == true,
      week: [v('mon'), v('tue'), v('wed'), v('thu'), v('fri'), v('sat'), v('sun')],
      holidays: {for (final h in holidays) JsonRead.string(h['date']): h['halfDay'] == true},
    );
  }

  double dayValue(DateTime d) {
    final part = week[d.weekday - 1];
    final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final half = holidays[key];
    if (half == null || part == 0) return part;
    if (!half) return 0;
    return part == 1 ? 0.5 : 0;
  }

  /// The working days the server will count for [form].
  double workingDays(LeaveForm form) {
    switch (form.kind) {
      case LeaveKind.am:
        return dayValue(form.fromDay) == 0 ? 0 : 0.5;
      case LeaveKind.pm:
        return dayValue(form.fromDay) == 1 ? 0.5 : 0;
      case LeaveKind.hours:
        final value = dayValue(form.fromDay);
        if (value == 0) return 0;
        final hours = form.to.difference(form.from).inMinutes / 60;
        final days = (hours / hoursPerDay * 100).round() / 100;
        return days.clamp(0, value).toDouble();
      case LeaveKind.full:
        var total = 0.0;
        for (var d = form.fromDay; !d.isAfter(form.toDay); d = DateTime(d.year, d.month, d.day + 1)) {
          total += dayValue(d);
        }
        return total;
    }
  }
}

/// "2½", "½", "3", "0.22".
String dayCount(double days) {
  final rounded = (days * 100).round() / 100;
  final whole = rounded.floor();
  final rest = ((rounded - whole) * 100).round() / 100;
  if (rest == 0) return '$whole';
  if (rest == 0.5) return whole == 0 ? '½' : '$whole½';
  return '$rounded';
}
