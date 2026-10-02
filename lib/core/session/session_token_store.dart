import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted key-value storage, as the session token store needs it.
///
/// An interface so tests can use an in-memory or failing store instead of the
/// platform Keychain / Keystore.
abstract interface class SecureKeyValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

/// [SecureKeyValueStore] on the iOS Keychain and the Android Keystore.
///
/// iOS uses first-unlock accessibility so a background notification handler
/// can still read the token while the phone is locked. On Android the files
/// are excluded from Auto Backup (res/xml/backup_rules.xml and
/// data_extraction_rules.xml): a restored copy cannot be decrypted anyway.
class PlatformSecureKeyValueStore implements SecureKeyValueStore {
  const PlatformSecureKeyValueStore([
    this._storage = const FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      aOptions: AndroidOptions(),
    ),
  ]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// The Java session token as stored on the device.
class StoredSession {
  const StoredSession({required this.token, required this.sessionExpiresAt});

  final String token;

  /// When the server stops refreshing this session; the user must sign in
  /// with the password again after it.
  final DateTime sessionExpiresAt;
}

/// Keeps the Java session token in encrypted storage - never the password.
///
/// A read that fails (no entry, a value that cannot be decrypted after a
/// backup restore, a platform error) means "no session": the user signs in.
class SessionTokenStore {
  SessionTokenStore(this._store);

  static const tokenKey = 'java_session_token';
  static const sessionExpiresAtKey = 'java_session_expires_at';

  final SecureKeyValueStore _store;

  /// The last value read or written, so each Java request does not go back
  /// to the platform store. Cleared by [clear].
  StoredSession? _cached;
  bool _loaded = false;

  Future<void> save(String token, DateTime sessionExpiresAt) async {
    await _store.write(tokenKey, token);
    await _store.write(sessionExpiresAtKey, sessionExpiresAt.millisecondsSinceEpoch.toString());
    _cached = StoredSession(token: token, sessionExpiresAt: sessionExpiresAt);
    _loaded = true;
  }

  /// The stored session, or null when there is none or it cannot be read.
  Future<StoredSession?> read() async {
    if (_loaded) return _cached;
    StoredSession? session;
    try {
      final token = await _store.read(tokenKey);
      final expiresAt = int.tryParse(await _store.read(sessionExpiresAtKey) ?? '');
      if (token != null && token.isNotEmpty && expiresAt != null) {
        session = StoredSession(
          token: token,
          sessionExpiresAt: DateTime.fromMillisecondsSinceEpoch(expiresAt),
        );
      }
    } catch (_) {
      session = null;
    }
    _cached = session;
    _loaded = true;
    return session;
  }

  /// The bearer token for a Java request, or null when signed out.
  Future<String?> token() async => (await read())?.token;

  /// Forgets the session. Never throws: a store that cannot delete still
  /// leaves the app signed out in memory.
  Future<void> clear() async {
    _cached = null;
    _loaded = true;
    try {
      await _store.delete(tokenKey);
      await _store.delete(sessionExpiresAtKey);
    } catch (_) {
      // nothing more to do: the token is gone from memory
    }
  }
}
