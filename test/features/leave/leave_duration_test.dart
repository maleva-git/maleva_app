import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/data/leave_duration.dart';

/// Leave length read from the dates, stored as calendar days (leave-approval-rules).
void main() {
  test('totalDays is calendar days, both counted, whatever the times', () {
    expect(leaveCalendarDays(DateTime(2026, 10, 6, 9), DateTime(2026, 10, 6, 9, 30)), 1);
    expect(leaveCalendarDays(DateTime(2026, 10, 6, 9), DateTime(2026, 10, 6, 17)), 1);
    expect(leaveCalendarDays(DateTime(2026, 10, 6), DateTime(2026, 10, 7)), 2);
    expect(leaveCalendarDays(DateTime(2026, 10, 6, 15), DateTime(2026, 10, 7, 9)), 2);
    expect(leaveCalendarDays(DateTime(2026, 10, 30), DateTime(2026, 11, 2)), 4);
    expect(leaveCalendarDays(DateTime(2026, 10, 7), DateTime(2026, 10, 6)), 1);
  });

  test('the label shows minutes or hours for timed leave on one day, else days', () {
    expect(leaveDurationLabel(DateTime(2026, 10, 6, 9), DateTime(2026, 10, 6, 9, 30)), '30 Mins');
    expect(leaveDurationLabel(DateTime(2026, 10, 6, 9), DateTime(2026, 10, 6, 10)), '1 Hour');
    expect(leaveDurationLabel(DateTime(2026, 10, 6, 9), DateTime(2026, 10, 6, 11, 30)), '2 Hours 30 Mins');
    expect(leaveDurationLabel(DateTime(2026, 10, 6), DateTime(2026, 10, 6)), '1 Day');
    expect(leaveDurationLabel(DateTime(2026, 10, 6), DateTime(2026, 10, 8)), '3 Days');
    expect(leaveDurationLabel(DateTime(2026, 10, 6, 15), DateTime(2026, 10, 7, 9)), '2 Days');
  });
}
