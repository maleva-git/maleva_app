import 'package:maleva/features/troubleshoot/data/applog_api.dart';
import 'dart:async';

import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/auth/data/session_service.dart';

/// Manual login for the login page: signs in on the Java backend through
/// [SessionService], which writes the session where the rest of the app reads it.
///
/// Errors are [MobileAuthFailure]s whose `toString()` is the message to show:
/// invalid credentials, a connection problem, or the server's message.
class AuthRepository {
  AuthRepository({required this.sessionService});

  final SessionService sessionService;

  Future<bool> loginUser({
    required String username,
    required String password,
    required int driverId,
  }) async {
    // A push token is sent when one can be had quickly; sign-in never waits
    // long on it, and one that comes later is sent once it arrives.
    Future<void>? tokenFetch;
    if (AppPreferences.getFcmToken().isEmpty) {
      tokenFetch = Future(() => AppGlobals.getDeviceToken());
      try {
        await tokenFetch.timeout(const Duration(seconds: 5));
      } catch (_) {
        // no push token yet: sign in without it
      }
    }
    await sessionService.signIn(userName: username, password: password, driver: driverId == 1);
    // crash logs kept from before sign-in go to this user's Troubleshoot folder
    unawaited(AppLogApi.sendPending(recordId: AppPreferences.getEmpRefId()));
    if (tokenFetch != null) {
      unawaited(tokenFetch.then((_) => sessionService.syncDeviceToken(), onError: (_) {}));
    }
    return true;
  }
}
