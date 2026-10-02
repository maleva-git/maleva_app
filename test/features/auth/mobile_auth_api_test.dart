import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/session/session_token_store.dart';
import 'package:maleva/features/auth/data/mobile_auth_api.dart';

import '../../core/session/session_token_store_test.dart' show MemoryStore;

/// Synthetic sessions only - no real users, companies or tokens.
Map<String, dynamic> session({String kind = 'EMPLOYEE', int truck = 0, List<Map<String, dynamic>>? menu}) => {
      'IsSuccess': true,
      'StatusCode': 200,
      'Message': 'Success',
      'Data1': {
        'token': 'synthetic.jwt',
        'expiresAt': 1790000000000,
        'sessionExpiresAt': 1800000000000,
        'principalKind': kind,
        'userId': 41,
        'companyId': 6,
        'mComid': 1,
        'companyName': 'FIXTURE CO',
        'rulesType': kind == 'DRIVER' ? '' : 'SALES',
        'roleId': kind == 'DRIVER' ? 0 : 300,
        'permissionId': 1,
        'truckRefId': truck,
        'truckName': truck == 0 ? '' : 'VBC 5521',
        'menu': menu ??
            [
              {'FormText': 'Transaction', 'Id': 1, 'CompanyRefid': 6, 'ParentId': 0, 'PageAdd': 1, 'PageEdit': 1, 'PageDelete': 1, 'PageView': 1},
              {'FormText': 'Sales Order', 'Id': 51, 'CompanyRefid': 1, 'ParentId': 1, 'PageAdd': 1, 'PageEdit': 0, 'PageDelete': 0, 'PageView': 1},
            ],
      },
    };

class Adapter implements HttpClientAdapter {
  int status = 200;
  Object body = session();
  DioExceptionType? fail;
  RequestOptions? last;
  String? lastBody;
  final List<String> paths = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream, Future<void>? cancelFuture) async {
    last = options;
    paths.add(options.uri.path);
    lastBody = stream == null ? null : utf8.decode(await stream.expand((c) => c).toList());
    if (fail != null) throw DioException(requestOptions: options, type: fail!);
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Adapter adapter;
  late MobileAuthApi api;

  setUp(() {
    adapter = Adapter();
    final client = JavaApiClient(SessionTokenStore(MemoryStore()),
        dio: Dio()..httpClientAdapter = adapter, baseUrl: 'https://java.test');
    api = MobileAuthApi(client);
  });

  test('employee sign-in: credentials in the body only, session parsed', () async {
    final s = await api.signIn(userName: 'fixture', password: 'p@ss', driver: false, deviceToken: 'fcm-1');

    expect(adapter.last!.uri.toString(), 'https://java.test/api/mobile/auth/login');
    expect(adapter.last!.uri.query, isEmpty);
    expect(jsonDecode(adapter.lastBody!), {'userName': 'fixture', 'password': 'p@ss', 'driver': false, 'deviceToken': 'fcm-1'});
    expect(adapter.last!.headers.containsKey('Authorization'), isFalse);
    expect(s.token, 'synthetic.jwt');
    expect(s.isDriver, isFalse);
    expect([s.userId, s.companyId, s.mComid, s.roleId, s.permissionId], [41, 6, 1, 300, 1]);
    expect(s.companyName, 'FIXTURE CO');
    expect(s.rulesType, 'SALES');
    expect(s.sessionExpiresAt, DateTime.fromMillisecondsSinceEpoch(1800000000000));
    expect(s.menu.map((m) => m.FormText), ['Transaction', 'Sales Order']);
    expect(s.menu[1].PageEdit, 0);
  });

  test('driver sign-in with and without a truck', () async {
    adapter.body = session(kind: 'DRIVER', truck: 12);
    final withTruck = await api.signIn(userName: 'd', password: 'p', driver: true);
    expect(jsonDecode(adapter.lastBody!), {'userName': 'd', 'password': 'p', 'driver': true});
    expect(withTruck.isDriver, isTrue);
    expect(withTruck.truckRefId, 12);
    expect(withTruck.truckName, 'VBC 5521');

    adapter.body = session(kind: 'DRIVER');
    final noTruck = await api.signIn(userName: 'd', password: 'p', driver: true);
    expect(noTruck.truckRefId, 0);
    expect(noTruck.truckName, '');
  });

  test('an empty menu is an empty list', () async {
    adapter.body = session(menu: []);
    expect((await api.signIn(userName: 'u', password: 'p', driver: false)).menu, isEmpty);
  });

  test('a 401 at sign-in is invalid credentials', () async {
    adapter
      ..status = 401
      ..body = {'IsSuccess': false, 'Message': 'Invalid Username & Password'};
    await expectLater(api.signIn(userName: 'u', password: 'bad', driver: false), throwsA(isA<InvalidCredentials>()));
  });

  test('no connection is a connection failure, not invalid credentials', () async {
    adapter.fail = DioExceptionType.connectionError;
    await expectLater(api.signIn(userName: 'u', password: 'p', driver: false), throwsA(isA<ConnectionFailure>()));
    adapter.fail = DioExceptionType.receiveTimeout;
    await expectLater(api.signIn(userName: 'u', password: 'p', driver: false), throwsA(isA<ConnectionFailure>()));
  });

  test('a 401 at refresh is the end of the session; refresh sends the stored token', () async {
    adapter.body = session();
    await api.refresh('stored.jwt');
    expect(adapter.last!.headers['Authorization'], 'Bearer stored.jwt');

    adapter.status = 401;
    await expectLater(api.refresh('stored.jwt'), throwsA(isA<SessionEnded>()));
  });

  test('a success without a session or token is a server failure', () async {
    adapter.body = {'IsSuccess': true, 'Data1': null};
    await expectLater(api.signIn(userName: 'u', password: 'p', driver: false), throwsA(isA<ServerFailure>()));
    adapter.body = {'IsSuccess': true, 'Data1': {'token': ''}};
    await expectLater(api.signIn(userName: 'u', password: 'p', driver: false), throwsA(isA<ServerFailure>()));
  });

  test('device token: the bearer token and the push token in the body', () async {
    adapter.body = {'IsSuccess': true};

    await api.updateDeviceToken('jwt-1', 'fcm-new');

    expect(adapter.last!.uri.toString(), 'https://java.test/api/mobile/auth/device-token');
    expect(adapter.last!.headers['Authorization'], 'Bearer jwt-1');
    expect(jsonDecode(adapter.lastBody!), {'deviceToken': 'fcm-new'});

    adapter.status = 401;
    await expectLater(api.updateDeviceToken('jwt-1', 'fcm-new'), throwsA(isA<SessionEnded>()));
  });
}
