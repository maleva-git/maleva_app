import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/data/leave_calendar.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/data/leave_form.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/data/leave_request_model.dart';

/// HR Sprint 2 (change `hr-leave-working-days`): the form's kinds and the working days shown before sending.
void main() {
  // 2026-10-23 is a Friday
  final opened = DateTime(2026, 10, 21, 10, 23);
  Map<String, dynamic> weeks(bool on) => {
        'ready': true,
        'leaveWorkingDays': on,
        'weeks': [
          {'kind': 'STAFF', 'mon': 'FULL', 'tue': 'FULL', 'wed': 'FULL', 'thu': 'FULL', 'fri': 'FULL', 'sat': 'HALF', 'sun': 'OFF'},
          {'kind': 'DRIVER', 'mon': 'FULL', 'tue': 'FULL', 'wed': 'FULL', 'thu': 'FULL', 'fri': 'FULL', 'sat': 'FULL', 'sun': 'OFF'},
        ],
      };
  final staff = LeaveCalendar.fromJava(weeks(true), [], driver: false);
  final driver = LeaveCalendar.fromJava(weeks(true), [], driver: true);
  final fridayToMonday = LeaveForm.start(opened).copyWith(fromDay: DateTime(2026, 10, 23), toDay: DateTime(2026, 10, 26));

  test('staff Friday to Monday is 2½ working days, drivers 3', () {
    expect(staff.enabled, isTrue);
    expect(staff.workingDays(fridayToMonday), 2.5);
    expect(driver.workingDays(fridayToMonday), 3);
  });

  test('a holiday Monday is not counted', () {
    final withHoliday = LeaveCalendar.fromJava(weeks(true), [
      {'date': '2026-10-26', 'name': 'Deepavali', 'halfDay': false},
    ], driver: false);
    expect(withHoliday.workingDays(fridayToMonday), 1.5);
  });

  test('a driver\'s Sunday counts 0', () {
    final sunday = LeaveForm.start(opened).copyWith(fromDay: DateTime(2026, 10, 25), toDay: DateTime(2026, 10, 25));
    expect(driver.workingDays(sunday), 0);
  });

  test('half days are one date stored as morning / afternoon, ½ each', () {
    final am = LeaveForm.start(opened).copyWith(kind: LeaveKind.am, fromDay: DateTime(2026, 10, 21), toDay: DateTime(2026, 10, 24));
    expect(am.toDay, DateTime(2026, 10, 21));
    expect([am.from, am.to], [DateTime(2026, 10, 21), DateTime(2026, 10, 21, 12)]);
    expect(staff.workingDays(am), 0.5);
    final pmSaturday = am.copyWith(kind: LeaveKind.pm, fromDay: DateTime(2026, 10, 24));
    expect([pmSaturday.from, pmSaturday.to], [DateTime(2026, 10, 24, 12), DateTime(2026, 10, 24, 23, 59)]);
    expect(staff.workingDays(pmSaturday), 0); // the staff Saturday afternoon is already off
    expect(am.durationLabel, '½ Day (morning)');
  });

  test('2 hours are 0.22 of a 9-hour day', () {
    final hours = LeaveForm.start(opened).copyWith(kind: LeaveKind.hours);
    expect(staff.workingDays(hours), 0.22);
  });

  test('without the switch the form keeps the old kinds and the server is not sent a part', () {
    final off = LeaveCalendar.fromJava(weeks(false), [], driver: false);
    expect(off.enabled, isFalse);
    expect(LeaveCalendar.off.enabled, isFalse);
  });

  test('days are written for people', () {
    expect([dayCount(2.5), dayCount(0.5), dayCount(3), dayCount(0.22)], ['2½', '½', '3', '0.22']);
  });

  test('a row shows the server\'s working days when sent', () {
    LeaveRequestModel row(Map<String, dynamic> extra) => LeaveRequestModel.fromJava({
          'id': 1, 'fromDate': '2026-10-23T00:00:00', 'toDate': '2026-10-26T00:00:00', ...extra});
    expect(row({}).lengthLabel, '4 Days');
    expect(row({'part': 'FULL', 'workingDays': 2.5}).lengthLabel, '2½ Days');
    expect(row({'part': 'PM', 'workingDays': 0.5}).lengthLabel, '½ Day (afternoon)');
  });
}
