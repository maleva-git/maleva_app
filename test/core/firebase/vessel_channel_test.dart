import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/firebase/local_notification_service.dart';
import 'package:maleva/core/utils/app_globals.dart';

/// Vessel ETA notices must never be missed (owner, 2026-10-13): their own channel, long vibration.
void main() {
  test('the vessel channel is the one the backend sends to, at maximum importance with a long vibration', () {
    final c = LocalNotificationService.vesselChannel;

    expect(c.id, 'com.kassapos.maleva.vessel');
    expect(AppGlobals.vesselChannelId, c.id);
    expect(c.importance, Importance.max);
    expect(c.playSound, isTrue);
    expect(c.enableVibration, isTrue);
    expect(c.vibrationPattern, [0, 1000, 500, 1000, 500, 1500, 500, 2000]);
    expect(c.id, isNot(AppGlobals.channelId), reason: 'a channel cannot change once made, so it needs its own id');
  });

  test('an open-app vessel notice repeats until it is opened (insistent) on the vessel channel', () {
    final d = LocalNotificationService.vesselDetails();

    expect(d.channelId, AppGlobals.vesselChannelId);
    expect(d.priority, Priority.max);
    expect(d.vibrationPattern, LocalNotificationService.vesselVibration);
    expect(d.additionalFlags, [4]);
  });

  test('the three vessel push types use the vessel channel; every other push the normal one', () {
    for (final type in ['VESSEL_ETA_CHANGED', 'VESSEL_LINK_NEEDED', 'PTP_SCHEDULE_STALE']) {
      expect(LocalNotificationService.usesVesselChannel({'type': type}), isTrue, reason: type);
    }
    expect(LocalNotificationService.usesVesselChannel({'type': 'MAIL_UNREAD'}), isFalse);
    expect(LocalNotificationService.usesVesselChannel({'type': 'FORWARDING_REQUESTED'}), isFalse);
    expect(LocalNotificationService.usesVesselChannel({}), isFalse);
  });
}
