import 'dart:async';

import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/auth/data/session_service.dart';

/// Keeps the server's TokenId current: Firebase replaces a phone's push token
/// now and then (reinstall, restore, token expiry), and notifications sent to
/// the old one are lost. [changes] is `FirebaseMessaging.instance.onTokenRefresh`.
StreamSubscription<String> listenForDeviceTokenChanges(Stream<String> changes, SessionService sessions) {
  return changes.listen((token) async {
    await AppPreferences.setFcmToken(token);
    AppGlobals.mobiletoken = token;
    await sessions.syncDeviceToken(token);
  });
}
