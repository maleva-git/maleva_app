import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/session/session_token_store.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/auth/data/mobile_auth_api.dart';
import 'package:maleva/features/auth/data/mobile_session.dart';
import 'package:maleva/features/auth/data/session_writer.dart';

/// What happened when the app tried to restore the saved session at start.
sealed class RestoreResult {
  const RestoreResult();
}

/// Nothing stored (first start, signed out, or the update removed an old saved password).
class NoSession extends RestoreResult {
  const NoSession();
}

/// The session was refreshed; its fields and menu are written.
class Restored extends RestoreResult {
  const Restored(this.session);

  final MobileSession session;
}

/// The server refused the session (expired, revoked, account disabled); it is cleared.
class SessionExpired extends RestoreResult {
  const SessionExpired();
}

/// The server could not be reached; the stored token is kept for a retry.
class RestoreUnreachable extends RestoreResult {
  const RestoreUnreachable(this.message);

  final String message;
}

/// Sign-in, session restore and sign-out against the Java backend.
///
/// The one place that starts or ends a session, used by the login page, the
/// splash and logout, so all three leave the same state.
class SessionService {
  SessionService({
    required MobileAuthApi api,
    required SessionTokenStore tokens,
    required SessionWriter writer,
    String Function()? deviceToken,
    DateTime Function()? now,
  })  : _api = api,
        _tokens = tokens,
        _writer = writer,
        _deviceToken = deviceToken ?? AppPreferences.getFcmToken,
        _now = now ?? DateTime.now;

  final MobileAuthApi _api;
  final SessionTokenStore _tokens;
  final SessionWriter _writer;
  final String Function() _deviceToken;
  final DateTime Function() _now;

  /// The push token the server last recorded for this session, so a token is
  /// sent once, not on every start.
  String? _sentDeviceToken;

  /// Lets [client] refresh this session on a 401 and end it when that fails.
  void attachTo(JavaApiClient client, {required void Function() onSessionEnded}) {
    client
      ..onRefresh = _refreshForClient
      ..onSessionEnded = () async {
        await _clearLocal();
        onSessionEnded();
      };
  }

  /// Signs in and writes the session. Throws [MobileAuthFailure]
  /// ([InvalidCredentials], [ConnectionFailure], [ServerFailure]); on failure
  /// nothing is stored.
  Future<MobileSession> signIn({required String userName, required String password, required bool driver}) async {
    final deviceToken = _deviceToken();
    final session = await _api.signIn(
      userName: userName,
      password: password,
      driver: driver,
      deviceToken: deviceToken,
    );
    await _writer.write(session);
    _sentDeviceToken = deviceToken.isEmpty ? null : deviceToken;
    return session;
  }

  /// Sends this phone's push token ([deviceToken], or the saved one) to the
  /// server when a session is signed in and the server does not have it yet:
  /// after Firebase replaces the token, or when the token arrived only after
  /// sign-in. Never throws; a failed send is tried again on the next start.
  Future<void> syncDeviceToken([String? deviceToken]) async {
    final value = (deviceToken ?? _deviceToken()).trim();
    if (value.isEmpty || value == _sentDeviceToken) return;
    final token = await _tokens.token();
    if (token == null) return;
    try {
      await _api.updateDeviceToken(token, value);
      _sentDeviceToken = value;
    } on MobileAuthFailure {
      // offline or the session ended: the next start or token change sends it
    }
  }

  /// Restores the saved session at start. First deletes any user name and
  /// password an earlier version saved, so the password stops existing on
  /// the device.
  Future<RestoreResult> restore() async {
    await AppPreferences.setUsername('');
    await AppPreferences.setPassword('');

    final stored = await _tokens.read();
    if (stored == null) return const NoSession();
    if (!stored.sessionExpiresAt.isAfter(_now())) {
      await _clearLocal();
      return const SessionExpired();
    }
    try {
      final session = await _api.refresh(stored.token);
      await _writer.write(session);
      return Restored(session);
    } on SessionEnded {
      await _clearLocal();
      return const SessionExpired();
    } on MobileAuthFailure catch (e) {
      return RestoreUnreachable(e.message);
    }
  }

  /// Ends the session: tells the server (best effort), then forgets it here
  /// whatever the server said.
  Future<void> signOut() async {
    final token = await _tokens.token();
    if (token != null) {
      try {
        await _api.logout(token, deviceToken: _deviceToken());
      } on MobileAuthFailure {
        // offline or already ended: the local sign-out below still happens
      }
    }
    await _clearLocal();
  }

  Future<bool> _refreshForClient() async {
    final token = await _tokens.token();
    if (token == null) return false;
    try {
      await _writer.write(await _api.refresh(token));
      return true;
    } on MobileAuthFailure {
      return false;
    }
  }

  Future<void> _clearLocal() async {
    _sentDeviceToken = null;
    await _tokens.clear();
    await AppPreferences.clearOnLogout();
    AppGlobals.EmpRefId = 0;
    AppGlobals.Comid = 0;
    AppGlobals.DriverLogin = 0;
    AppGlobals.DriverTruckRefId = 0;
    AppGlobals.DriverTruckName = '';
    AppGlobals.objMenuMaster.clear();
    AppGlobals.parentclass.clear();
  }
}
