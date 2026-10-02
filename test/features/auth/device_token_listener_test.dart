import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/auth/data/device_token_listener.dart';
import 'package:maleva/features/auth/data/session_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSessionService extends Mock implements SessionService {}

void main() {
  test('a replaced push token is saved on the phone and sent to the server', () async {
    SharedPreferences.setMockInitialValues({'FcmToken': 'fcm-old'});
    await AppPreferences.init();
    final sessions = MockSessionService();
    when(() => sessions.syncDeviceToken(any())).thenAnswer((_) async {});
    final changes = StreamController<String>();

    final subscription = listenForDeviceTokenChanges(changes.stream, sessions);
    changes.add('fcm-new');
    await pumpEventQueue();

    expect(AppPreferences.getFcmToken(), 'fcm-new');
    expect(AppGlobals.mobiletoken, 'fcm-new');
    verify(() => sessions.syncDeviceToken('fcm-new')).called(1);

    await subscription.cancel();
    await changes.close();
  });
}
