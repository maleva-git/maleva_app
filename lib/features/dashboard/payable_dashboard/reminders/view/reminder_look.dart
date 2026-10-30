import 'package:flutter/material.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';

import '../data/reminder_models.dart';

/// The colours and words of a reminder's day state (change `payable-reminders`).
Color stateColor(DayState s) => switch (s) {
      DayState.done => Palette.greenEco,
      DayState.missed || DayState.overdue => Palette.redDanger,
      DayState.sent || DayState.due => Palette.amberGold,
      DayState.paused => AppTokens.textMuted,
      DayState.upcoming => AppTokens.brandPrimary,
    };

String stateLabel(DayState s) => switch (s) {
      DayState.done => 'Done',
      DayState.missed => 'Missed',
      DayState.overdue => 'Not done',
      DayState.sent => 'Due now',
      DayState.due => 'Today',
      DayState.paused => 'Paused',
      DayState.upcoming => 'Coming',
    };

const _months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October',
  'November', 'December'];
const _short = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _shortMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String monthName(DateTime m) => '${_months[m.month - 1]} ${m.year}';
String dayName(DateTime d) => '${_short[d.weekday - 1]} ${d.day} ${_shortMonths[d.month - 1]}';
String ym(DateTime m) => '${m.year.toString().padLeft(4, '0')}-${m.month.toString().padLeft(2, '0')}';

/// "09:00" → "9:00 am".
String timeLabel(String hhmm) {
  final p = hhmm.split(':');
  if (p.length < 2) return hhmm;
  final h = int.tryParse(p[0]) ?? 0;
  final m = p[1].padLeft(2, '0');
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '$h12:$m ${h < 12 ? 'am' : 'pm'}';
}

/// The rule in words: "Every month on the 3rd at 9:00 am · off day → day before".
String ruleText(ReminderItem r) {
  final when = r.repeat == 'ONCE'
      ? 'Once on ${r.onDate == null ? '-' : dayName(r.onDate!)}'
      : 'Every month on ${r.dayOfMonth == 31 ? 'the last day' : 'the ${ordinal(r.dayOfMonth ?? 1)}'}';
  final off = switch (r.whenOffDay) {
    'SAME' => 'rings on weekends / holidays too',
    'AFTER' => 'weekend / holiday → next working day',
    _ => 'weekend / holiday → working day before',
  };
  return '$when at ${timeLabel(r.time)} · $off';
}

String ordinal(int n) {
  if (n >= 11 && n <= 13) return '${n}th';
  return switch (n % 10) { 1 => '${n}st', 2 => '${n}nd', 3 => '${n}rd', _ => '${n}th' };
}
