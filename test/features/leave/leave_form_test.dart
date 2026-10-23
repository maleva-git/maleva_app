import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/data/leave_form.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/data/leave_request_model.dart';

/// The Request Leave form stores whole days as days and hours as times (leave-dates-and-decisions).
void main() {
  final opened = DateTime(2026, 10, 21, 10, 23, 47);

  test('it opens on one whole day today, stored at 00:00, never the time it was opened', () {
    final form = LeaveForm.start(opened);
    expect(form.from, DateTime(2026, 10, 21));
    expect(form.to, DateTime(2026, 10, 21));
    expect(form.totalDays, 1);
    expect(form.durationLabel, '1 Day');
    expect(form.error, isNull);
  });

  test('whole days: tomorrow only is one day; a from day past the to day takes it along', () {
    var form = LeaveForm.start(opened).copyWith(fromDay: DateTime(2026, 10, 22), toDay: DateTime(2026, 10, 22));
    expect([form.from, form.to, form.totalDays], [DateTime(2026, 10, 22), DateTime(2026, 10, 22), 1]);
    form = form.copyWith(fromDay: DateTime(2026, 10, 25));
    expect(form.toDay, DateTime(2026, 10, 25));
    form = form.copyWith(toDay: DateTime(2026, 10, 27));
    expect([form.totalDays, form.durationLabel], [3, '3 Days']);
    expect(form.copyWith(toDay: DateTime(2026, 10, 24)).error, 'The to date is before the from date');
  });

  test('hours: one day with the times; the to time must be after the from time', () {
    final form = LeaveForm.start(opened).copyWith(
        hours: true,
        fromDay: DateTime(2026, 10, 22),
        fromTime: const TimeOfDay(hour: 9, minute: 0),
        toTime: const TimeOfDay(hour: 11, minute: 30));
    expect(form.from, DateTime(2026, 10, 22, 9));
    expect(form.to, DateTime(2026, 10, 22, 11, 30));
    expect([form.totalDays, form.durationLabel], [1, '2 Hours 30 Mins']);
    expect(form.copyWith(toTime: const TimeOfDay(hour: 9, minute: 0)).error, 'The to time must be after the from time');
  });

  test('status is read by name, the usual ids only without a name', () {
    LeaveRequestModel row(int id, String name) => LeaveRequestModel.fromJava({
          'id': 1, 'statusRefId': id, 'statusName': name,
          'fromDate': '2026-10-22T00:00:00', 'toDate': '2026-10-22T00:00:00'});
    expect(row(3, 'APPROVED').status, LeaveDecision.approved); // a company whose Approved is id 3
    expect(row(2, 'Pending').isPending, isTrue);
    expect(row(2, '').status, LeaveDecision.approved);
    expect(row(3, '').status, LeaveDecision.rejected);
    expect(row(0, '').isPending, isTrue);
  });
}
