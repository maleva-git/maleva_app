import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/firebase/local_notification_service.dart';
import 'package:maleva/core/utils/app_globals.dart';

/// Vessel alerts must never be missed (owner, 2026-10-13): their own channel with a long vibration and no
/// sound ("only vibration is enough").
void main() {
  test('the vessel channel is the one the backend sends to: long vibration, no sound', () {
    final c = LocalNotificationService.vesselChannel;

    expect(c.id, 'com.kassapos.maleva.vessel.vibrate');
    expect(AppGlobals.oldVesselChannelIds, isNot(contains(c.id)),
        reason: 'a channel sound cannot change, so vibration-only needs a new id; the old ones are deleted');
    expect(c.playSound, isFalse);
    expect(c.sound, isNull);
    expect(AppGlobals.vesselChannelId, c.id);
    expect(c.importance, Importance.max);
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
    expect(d.playSound, isFalse);
    expect(d.sound, isNull);
  });

  test('no alarm tone is shipped in the app any more', () {
    expect(File('android/app/src/main/res/raw/vessel_alarm.wav').existsSync(), isFalse);
    expect(File('ios/Runner/vessel_alarm.wav').existsSync(), isFalse);
    expect(File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync(), isNot(contains('vessel_alarm.wav')));
  });

  test('the vessel push types use the vessel channel; every other push the normal one', () {
    for (final type in ['VESSEL_ETA_CHANGED', 'VESSEL_LINK_NEEDED', 'PTP_SCHEDULE_STALE', 'PHONE_PUSH_DOWN']) {
      expect(LocalNotificationService.usesVesselChannel({'type': type}), isTrue, reason: type);
    }
    expect(LocalNotificationService.usesVesselChannel({'type': 'MAIL_UNREAD'}), isFalse);
    expect(LocalNotificationService.usesVesselChannel({'type': 'FORWARDING_REQUESTED'}), isFalse);
    expect(LocalNotificationService.usesVesselChannel({}), isFalse);
  });

  test('the quiet vessel channel (Super Admins, 2026-10-16) is the one the backend sends to: no sound, no vibration', () {
    const c = LocalNotificationService.vesselQuietChannel;

    expect(c.id, 'com.kassapos.maleva.vessel.quiet');
    expect(AppGlobals.vesselQuietChannelId, c.id);
    expect(c.name, 'Vessel alerts (quiet)');
    expect(c.description, 'Vessel alerts without sound or vibration');
    expect(c.importance, Importance.high);
    expect(c.playSound, isFalse);
    expect(c.enableVibration, isFalse);
    expect(c.id, isNot(AppGlobals.vesselChannelId));
    expect(c.id, isNot(AppGlobals.channelId));
    expect(AppGlobals.oldVesselChannelIds, isNot(contains(c.id)));
  });

  test('a quiet vessel push shown with the app open: quiet channel, no sound, no vibration, not insistent', () {
    final d = LocalNotificationService.foregroundAndroidDetails(
        {'type': 'VESSEL_ETA_CHANGED', 'link': '/vessel-changes', 'quiet': '1'},
        body: 'B');

    expect(d.channelId, AppGlobals.vesselQuietChannelId);
    expect(d.playSound, isFalse);
    expect(d.enableVibration, isFalse);
    expect(d.vibrationPattern, isNull);
    expect(d.additionalFlags, isNull);
    expect(LocalNotificationService.isQuietVesselPush({'type': 'PTP_SCHEDULE_STALE', 'quiet': '1'}), isTrue);
    expect(LocalNotificationService.presentsSound({'type': 'VESSEL_ETA_CHANGED', 'quiet': '1'}), isFalse);
  });

  test('a vessel push without quiet stays on the vibrating, insistent vessel channel', () {
    for (final data in [
      {'type': 'VESSEL_ETA_CHANGED'},
      {'type': 'VESSEL_ETA_CHANGED', 'quiet': '0'},
    ]) {
      final d = LocalNotificationService.foregroundAndroidDetails(data, body: 'B');
      expect(d.channelId, AppGlobals.vesselChannelId);
      expect(d.enableVibration, isTrue);
      expect(d.vibrationPattern, LocalNotificationService.vesselVibration);
      expect(d.additionalFlags, [4]);
      expect(LocalNotificationService.isQuietVesselPush(data), isFalse);
      expect(LocalNotificationService.presentsSound(data), isTrue);
    }
  });

  test('a normal push uses the alert channel with a sound, even if it says quiet', () {
    for (final data in [
      {'type': 'MAIL_UNREAD'},
      {'type': 'FORWARDING_REQUESTED', 'quiet': '1'},
      <String, dynamic>{},
    ]) {
      final d = LocalNotificationService.foregroundAndroidDetails(data, body: 'B');
      expect(d.channelId, AppGlobals.channelId);
      expect(d.playSound, isTrue);
      expect(LocalNotificationService.isQuietVesselPush(data), isFalse);
      expect(LocalNotificationService.presentsSound(data), isTrue);
    }
  });
}
