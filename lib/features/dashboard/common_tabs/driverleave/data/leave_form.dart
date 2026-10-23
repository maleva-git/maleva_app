import 'package:flutter/material.dart';

import 'leave_duration.dart';

/// The kinds of leave (HR Sprint 2, change `hr-leave-working-days`): whole days, half day morning /
/// afternoon (½ day each, no fixed clock), or part of one day by the hour (office staff only).
enum LeaveKind {
  full('FULL', 'Whole days'),
  am('AM', 'Morning'),
  pm('PM', 'Afternoon'),
  hours('HOURS', 'Hours');

  const LeaveKind(this.part, this.label);

  /// What the server's `part` field takes.
  final String part;
  final String label;
}

/// What the Request Leave form holds (openspec changes `leave-dates-and-decisions`, `hr-leave-working-days`).
///
/// Whole days (the default) are stored from the first day 00:00 to the last day 00:00, so the server,
/// the lists and every day count read them as days. Hours are one day with a from and a to time. A half
/// day is one date, stored morning 00:00–12:00 / afternoon 12:00–23:59 (labels, not office hours).
@immutable
class LeaveForm {
  const LeaveForm({
    required this.kind,
    required this.fromDay,
    required this.toDay,
    required this.fromTime,
    required this.toTime,
  });

  /// Today, one whole day; hours default to 09:00 to 11:00 when switched on.
  factory LeaveForm.start(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return LeaveForm(
      kind: LeaveKind.full,
      fromDay: today,
      toDay: today,
      fromTime: const TimeOfDay(hour: 9, minute: 0),
      toTime: const TimeOfDay(hour: 11, minute: 0),
    );
  }

  final LeaveKind kind;
  final DateTime fromDay;
  final DateTime toDay;
  final TimeOfDay fromTime;
  final TimeOfDay toTime;

  /// Part of one day by the hour.
  bool get hours => kind == LeaveKind.hours;

  /// One date only (half day or hours).
  bool get oneDay => kind != LeaveKind.full;

  /// The leave's start.
  DateTime get from => switch (kind) {
        LeaveKind.hours => _at(fromDay, fromTime),
        LeaveKind.pm => DateTime(fromDay.year, fromDay.month, fromDay.day, 12),
        _ => _day(fromDay),
      };

  /// The leave's end.
  DateTime get to => switch (kind) {
        LeaveKind.hours => _at(fromDay, toTime),
        LeaveKind.am => DateTime(fromDay.year, fromDay.month, fromDay.day, 12),
        LeaveKind.pm => DateTime(fromDay.year, fromDay.month, fromDay.day, 23, 59),
        _ => _day(toDay),
      };

  /// Calendar days, both counted, as the server stores them.
  int get totalDays => leaveCalendarDays(from, to);

  /// "1 Day", "3 Days", "2 Hours", "45 Mins", "½ Day (morning)".
  String get durationLabel => switch (kind) {
        LeaveKind.am => '½ Day (morning)',
        LeaveKind.pm => '½ Day (afternoon)',
        _ => leaveDurationLabel(from, to),
      };

  /// What is wrong, or null when it can be sent.
  String? get error {
    if (hours) {
      return to.isAfter(from) ? null : 'The to time must be after the from time';
    }
    if (oneDay) return null;
    return toDay.isBefore(fromDay) ? 'The to date is before the from date' : null;
  }

  LeaveForm copyWith({
    LeaveKind? kind,
    bool? hours,
    DateTime? fromDay,
    DateTime? toDay,
    TimeOfDay? fromTime,
    TimeOfDay? toTime,
  }) {
    final nextKind = kind ?? (hours == null ? this.kind : (hours ? LeaveKind.hours : LeaveKind.full));
    var next = LeaveForm(
      kind: nextKind,
      fromDay: _day(fromDay ?? this.fromDay),
      toDay: _day(toDay ?? this.toDay),
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
    );
    // moving the from day past the to day takes the to day along; one-day kinds keep both the same
    if ((fromDay != null && next.toDay.isBefore(next.fromDay)) || (next.oneDay && next.toDay != next.fromDay)) {
      next = LeaveForm(
          kind: next.kind, fromDay: next.fromDay, toDay: next.fromDay, fromTime: next.fromTime, toTime: next.toTime);
    }
    return next;
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _at(DateTime day, TimeOfDay t) => DateTime(day.year, day.month, day.day, t.hour, t.minute);
}
