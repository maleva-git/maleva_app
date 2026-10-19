/// How long a leave is (openspec change `leave-approval-rules`).
///
/// The server stores `totalDays` as calendar days, from the from-date to the
/// to-date, both counted: hours on one day are 1 day. Before, the app stored
/// minutes, hours or days in that one number, so the length shown here is read
/// from the dates and times, never from `totalDays`.
library;

/// Calendar days from [from] to [to], both counted (at least 1), as the server
/// stores `totalDays`.
int leaveCalendarDays(DateTime from, DateTime to) {
  final days = DateTime.utc(to.year, to.month, to.day)
          .difference(DateTime.utc(from.year, from.month, from.day))
          .inDays +
      1;
  return days < 1 ? 1 : days;
}

/// "45 Mins", "3 Hours", "1 Day", "4 Days": minutes or hours for timed leave
/// within one day, else calendar days.
String leaveDurationLabel(DateTime from, DateTime to) {
  final sameDay = from.year == to.year && from.month == to.month && from.day == to.day;
  final timed = !_midnight(from) || !_midnight(to);
  if (sameDay && timed && to.isAfter(from)) {
    final length = to.difference(from);
    if (length.inHours < 1) return '${length.inMinutes} Mins';
    final minutes = length.inMinutes % 60;
    final hours = '${length.inHours} ${length.inHours == 1 ? "Hour" : "Hours"}';
    return minutes == 0 ? hours : '$hours $minutes Mins';
  }
  final days = leaveCalendarDays(from, to);
  return '$days ${days == 1 ? "Day" : "Days"}';
}

bool _midnight(DateTime t) => t.hour == 0 && t.minute == 0 && t.second == 0;
