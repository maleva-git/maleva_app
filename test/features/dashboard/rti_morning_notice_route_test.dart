import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/firebase/local_notification_service.dart';
import 'package:maleva/features/dashboard/forwarding_agent_dashboard/push_route.dart';
import 'package:maleva/features/mail_monitor/mine/push_route.dart';

/// rti-morning-briefing: the forwarding agent's 06:00 notice opens RTI Activities.
void main() {
  test('the morning notice opens RTI Activities', () {
    expect(rtiActivitiesRouteForType('RTI_STOPS_TODAY'), rtiActivitiesPath);
    expect(routeForPush({'type': 'RTI_STOPS_TODAY'}), rtiActivitiesPath);
    expect(routeForPayload('RTI_STOPS_TODAY'), rtiActivitiesPath);
  });

  test('a stop change notice opens RTI Activities too', () {
    expect(rtiActivitiesRouteForType('RTI_STOPS_CHANGED'), rtiActivitiesPath);
    expect(routeForPayload('RTI_STOPS_CHANGED'), rtiActivitiesPath);
  });

  test('only the morning notice rings the alarm', () {
    expect(LocalNotificationService.isRtiAlarmPush({'type': 'RTI_STOPS_TODAY'}), isTrue);
    expect(LocalNotificationService.isRtiAlarmPush({'type': 'RTI_STOPS_CHANGED'}), isFalse);
    final alarm = LocalNotificationService.foregroundAndroidDetails({'type': 'RTI_STOPS_TODAY'}, body: 'b');
    expect(alarm.channelId, 'com.kassapos.maleva.rti.alarm');
    expect(alarm.audioAttributesUsage, AudioAttributesUsage.alarm);
    final changed = LocalNotificationService.foregroundAndroidDetails({'type': 'RTI_STOPS_CHANGED'}, body: 'b');
    expect(changed.channelId, 'com.kassapos.maleva.urgent');
  });

  test('other notices are not sent there', () {
    expect(rtiActivitiesRouteForType('FORWARDING_OVERDUE'), isNull);
    expect(rtiActivitiesRouteForType(null), isNull);
    expect(routeForPush({'type': 'SOMETHING_ELSE'}), isNull);
  });
}
