import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/session/session_token_store.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/auth/data/mobile_auth_api.dart';
import 'package:maleva/features/auth/data/session_service.dart';
import 'package:maleva/features/auth/data/session_writer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/session/session_token_store_test.dart' show MemoryStore;
import 'mobile_auth_api_test.dart' show Adapter;

void main() {
  late Adapter adapter;
  late MemoryStore platform;
  late SessionTokenStore tokens;
  late SessionService service;
  final now = DateTime.fromMillisecondsSinceEpoch(1795000000000);
  final future = DateTime.fromMillisecondsSinceEpoch(1800000000000);

  Future<void> build(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    await AppPreferences.init();
    adapter = Adapter();
    platform = MemoryStore();
    tokens = SessionTokenStore(platform);
    final client = JavaApiClient(tokens, dio: Dio()..httpClientAdapter = adapter, baseUrl: 'https://java.test');
    service = SessionService(
      api: MobileAuthApi(client),
      tokens: tokens,
      writer: SessionWriter(tokens),
      now: () => now,
    );
  }

  setUp(() => build({}));

  group('sign-in', () {
    test('sends the push token when there is one and stores the session', () async {
      await build({'FcmToken': 'fcm-1'});

      final s = await service.signIn(userName: 'fixture', password: 'p@ss', driver: false);

      expect(adapter.last!.uri.query, isEmpty);
      expect(jsonDecode(adapter.lastBody!)['deviceToken'], 'fcm-1');
      expect(s.companyId, 6);
      expect(await tokens.token(), 'synthetic.jwt');
      expect(AppPreferences.getPassword(), isEmpty);
    });

    test('signs in without a push token when there is none', () async {
      await service.signIn(userName: 'fixture', password: 'p', driver: true);
      expect((jsonDecode(adapter.lastBody!) as Map).containsKey('deviceToken'), isFalse);
    });

    test('a rejected sign-in stores nothing', () async {
      adapter
        ..status = 401
        ..body = {'IsSuccess': false};
      await expectLater(service.signIn(userName: 'u', password: 'bad', driver: false), throwsA(isA<InvalidCredentials>()));
      expect(await tokens.token(), isNull);
      expect(AppPreferences.getComid(), 0);
    });
  });

  group('restore', () {
    test('nothing stored opens login, without a request', () async {
      expect(await service.restore(), isA<NoSession>());
      expect(adapter.last, isNull);
    });

    test('an upgrade from a saved-password version deletes the saved credentials', () async {
      await build({'Username': 'old-user', 'Password': 'old-pass'});

      expect(await service.restore(), isA<NoSession>());
      expect(AppPreferences.getUsername(), isEmpty);
      expect(AppPreferences.getPassword(), isEmpty);
    });

    test('a stored session is refreshed and rewritten', () async {
      await tokens.save('stored.jwt', future);

      final result = await service.restore();

      expect(result, isA<Restored>());
      expect(adapter.last!.uri.path, '/api/mobile/auth/refresh');
      expect(adapter.last!.headers['Authorization'], 'Bearer stored.jwt');
      expect(await tokens.token(), 'synthetic.jwt');
      expect(AppPreferences.getRoleId(), 300);
    });

    test('a refused refresh clears the session and the login fields', () async {
      await build({'Comid': 6, 'role_id': 300});
      await tokens.save('stored.jwt', future);
      adapter.status = 401;

      expect(await service.restore(), isA<SessionExpired>());
      expect(await SessionTokenStore(platform).token(), isNull);
      expect(platform.values, isEmpty);
      expect(AppPreferences.getComid(), 0);
      expect(AppPreferences.getRoleId(), 0);
    });

    test('no connection keeps the token for a retry', () async {
      await tokens.save('stored.jwt', future);
      adapter.fail = DioExceptionType.connectionError;

      expect(await service.restore(), isA<RestoreUnreachable>());
      expect(platform.values[SessionTokenStore.tokenKey], 'stored.jwt');
    });

    test('a session past its expiry is cleared without asking the server', () async {
      await tokens.save('stored.jwt', now.subtract(const Duration(minutes: 1)));

      expect(await service.restore(), isA<SessionExpired>());
      expect(adapter.last, isNull);
      expect(platform.values, isEmpty);
    });
  });

  group('sign-out', () {
    test('tells the server, then clears the token and login fields', () async {
      await build({'Comid': 6, 'loadmenu': '[]', 'FcmToken': 'fcm-1'});
      await tokens.save('stored.jwt', future);
      adapter.body = {'IsSuccess': true};

      await service.signOut();

      expect(adapter.last!.uri.path, '/api/mobile/auth/logout');
      expect(adapter.last!.headers['Authorization'], 'Bearer stored.jwt');
      // this phone's push token, so the server clears it only if it is still this phone's
      expect(jsonDecode(adapter.lastBody!), {'deviceToken': 'fcm-1'});
      expect(platform.values, isEmpty);
      expect(AppPreferences.getComid(), 0);
    });

    test('still signs out locally when the server cannot be reached', () async {
      await tokens.save('stored.jwt', future);
      adapter.fail = DioExceptionType.connectionError;

      await service.signOut();

      expect(platform.values, isEmpty);
    });
  });

  test('a 401 on a Java call refreshes through the service; a refused refresh ends the session', () async {
    await tokens.save('stored.jwt', future);
    final client = JavaApiClient(tokens, dio: Dio()..httpClientAdapter = adapter, baseUrl: 'https://java.test');
    var ended = false;
    service.attachTo(client, onSessionEnded: () => ended = true);
    adapter.status = 401;

    await expectLater(client.dio.get<dynamic>('/api/anything'), throwsA(isA<DioException>()));
    expect(ended, isTrue);
    expect(platform.values, isEmpty);
  });

  group('push token', () {
    test('a token sent at sign-in is not sent again', () async {
      await build({'FcmToken': 'fcm-1'});
      await service.signIn(userName: 'fixture', password: 'p', driver: false);
      adapter.paths.clear();

      await service.syncDeviceToken();

      expect(adapter.paths, isEmpty);
    });

    test('a token that arrives after sign-in is sent once', () async {
      await service.signIn(userName: 'fixture', password: 'p', driver: false);
      adapter.paths.clear();
      adapter.body = {'IsSuccess': true};
      await AppPreferences.setFcmToken('fcm-late');

      await service.syncDeviceToken();
      await service.syncDeviceToken();

      expect(adapter.paths, ['/api/mobile/auth/device-token']);
      expect(adapter.last!.headers['Authorization'], 'Bearer synthetic.jwt');
      expect(jsonDecode(adapter.lastBody!), {'deviceToken': 'fcm-late'});
    });

    test('a replaced token is sent for the restored session', () async {
      await build({'FcmToken': 'fcm-1'});
      await tokens.save('stored.jwt', future);
      await service.restore();
      adapter.paths.clear();
      adapter.body = {'IsSuccess': true};

      await service.syncDeviceToken('fcm-2');

      expect(adapter.paths, ['/api/mobile/auth/device-token']);
      expect(jsonDecode(adapter.lastBody!), {'deviceToken': 'fcm-2'});
    });

    test('nothing is sent without a session or without a token', () async {
      await service.syncDeviceToken('fcm-1');
      await tokens.save('stored.jwt', future);
      await service.syncDeviceToken('  ');

      expect(adapter.paths, isEmpty);
    });

    test('a failed send never throws and is tried again', () async {
      await tokens.save('stored.jwt', future);
      adapter.fail = DioExceptionType.connectionError;

      await service.syncDeviceToken('fcm-1');
      adapter.fail = null;
      adapter.body = {'IsSuccess': true};
      await service.syncDeviceToken('fcm-1');

      expect(adapter.paths, ['/api/mobile/auth/device-token', '/api/mobile/auth/device-token']);
    });

    test('after sign-out the same token is sent again for the next session', () async {
      await build({'FcmToken': 'fcm-1'});
      await service.signIn(userName: 'first', password: 'p', driver: false);
      adapter.body = {'IsSuccess': true};
      await service.signOut();
      await tokens.save('next.jwt', future);
      adapter.paths.clear();

      await service.syncDeviceToken('fcm-1');

      expect(adapter.paths, ['/api/mobile/auth/device-token']);
      expect(adapter.last!.headers['Authorization'], 'Bearer next.jwt');
    });
  });
}
