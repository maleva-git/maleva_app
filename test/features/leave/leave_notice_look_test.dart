import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/employee_notifications/employee_notifications_models.dart';
import 'package:maleva/features/notifications/notification_look.dart';
import 'package:maleva/features/notifications/notification_routes.dart';

/// Leave notices get their own look in the bell list (leave-notifications).
void main() {
  test('leave applied, approved and rejected notices look like leave and open nothing', () {
    for (final kind in ['LEAVE_APPLIED', 'LEAVE_APPROVED', 'LEAVE_REJECTED']) {
      final n = EmployeeNotification(id: 1, kind: kind, title: 'Leave request: RAVI (driver)', linkPath: '/dashboard/hr');
      expect(toneOf(n), NoticeTone.leave);
      expect(iconForTone(toneOf(n)), Icons.event_busy_rounded);
      expect(routeForNotice(n), isNull);
    }
    expect(toneOf(const EmployeeNotification(id: 2, kind: 'SOMETHING', title: 'x')), NoticeTone.other);
  });
}
