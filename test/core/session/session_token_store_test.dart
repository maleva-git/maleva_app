import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/session/session_token_store.dart';

class MemoryStore implements SecureKeyValueStore {
  final Map<String, String> values = {};
  int reads = 0;

  @override
  Future<String?> read(String key) async {
    reads++;
    return values[key];
  }

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

class FailingStore implements SecureKeyValueStore {
  @override
  Future<String?> read(String key) => throw Exception('cannot decrypt');

  @override
  Future<void> write(String key, String value) => throw Exception('locked');

  @override
  Future<void> delete(String key) => throw Exception('locked');
}

void main() {
  final expiry = DateTime.fromMillisecondsSinceEpoch(1800000000000);

  test('saves the token and session expiry and reads them back from a new store', () async {
    final platform = MemoryStore();
    await SessionTokenStore(platform).save('jwt-1', expiry);

    final session = await SessionTokenStore(platform).read();

    expect(session?.token, 'jwt-1');
    expect(session?.sessionExpiresAt, expiry);
    expect(platform.values.keys, containsAll([SessionTokenStore.tokenKey, SessionTokenStore.sessionExpiresAtKey]));
  });

  test('nothing stored means no session', () async {
    expect(await SessionTokenStore(MemoryStore()).read(), isNull);
    expect(await SessionTokenStore(MemoryStore()).token(), isNull);
  });

  test('a token without its expiry is not a session', () async {
    final platform = MemoryStore()..values[SessionTokenStore.tokenKey] = 'jwt-1';
    expect(await SessionTokenStore(platform).read(), isNull);
  });

  test('a read failure means no session instead of an error', () async {
    expect(await SessionTokenStore(FailingStore()).read(), isNull);
  });

  test('clear deletes both values and never throws', () async {
    final platform = MemoryStore();
    final store = SessionTokenStore(platform);
    await store.save('jwt-1', expiry);

    await store.clear();

    expect(platform.values, isEmpty);
    expect(await store.token(), isNull);
    await SessionTokenStore(FailingStore()).clear();
  });

  test('repeated reads are served from memory', () async {
    final platform = MemoryStore();
    final store = SessionTokenStore(platform);
    await store.save('jwt-1', expiry);
    platform.reads = 0;

    await store.token();
    await store.token();

    expect(platform.reads, 0);
  });
}
