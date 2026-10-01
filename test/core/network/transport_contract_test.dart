import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/local_storage_service.dart';
import 'package:maleva/core/utils/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FixtureHttpOverrides extends HttpOverrides {}

class RecordingAdapter implements HttpClientAdapter {
  RequestOptions? request;
  int status = 200;
  String body = '[]';
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream,
      Future<void>? cancelFuture) async {
    request = options;
    return ResponseBody.fromString(body, status,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
  }
  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'Tokenkey': 'synthetic-token', 'Userid': 'fixture-user', 'Profile': 'fixture',
    });
    await AppPreferences.init();
  });

  test('HTTP preserves POST, headers, override and JSON body', () async {
    // A loopback fixture server, never the configured application backend.
    await HttpOverrides.runZoned(() async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final received = server.first.then((request) async {
        expect(request.method, 'POST');
        expect(request.uri.toString(), '/fixture?Startindex=0');
        expect(request.headers.value('Authorization'), 'Bearer synthetic-token');
        expect(request.headers.value('Userid'), 'override');
        expect(jsonDecode(await utf8.decoder.bind(request).join()), {'Id': null, 'Count': 0});
        request.response.write('[]');
        await request.response.close();
      });
      try {
        expect(await ApiClient.postRequest(
          'http://127.0.0.1:${server.port}/fixture?Startindex=0',
          {'Id': null, 'Count': 0}, headers: {'Userid': 'override'}), isEmpty);
        await received;
      } finally { await server.close(force: true); }
    }, createHttpClient: (_) => FixtureHttpOverrides().createHttpClient(null));
  });

  for (final status in [200, 401, 406]) {
    test('HTTP empty response/status $status retains existing outcome', () async {
      await HttpOverrides.runZoned(() async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final received = server.first.then((request) async {
          expect(await utf8.decoder.bind(request).join(), '');
          expect(request.headers.value('Authorization'), isNull);
          request.response.statusCode = status;
          await request.response.close();
        });
        try {
          final result = ApiClient.postRequest('http://127.0.0.1:${server.port}/fixture', null, skipAuth: true);
          if (status == 200) {
            expect(await result, isEmpty);
          } else {
            await expectLater(result, throwsA(predicate((e) => e.toString().contains(
              status == 401 ? 'Authentication failed' : 'Already logged in'))));
          }
          await received;
        } finally { await server.close(force: true); }
      }, createHttpClient: (_) => FixtureHttpOverrides().createHttpClient(null));
    });
  }

  test('legacy Dio keeps Token, language mutation, null-to-object and error body', () async {
    final client = DioClient(SessionManager(LocalStorageService(AppPreferences.raw)));
    final adapter = RecordingAdapter();
    client.dio.httpClientAdapter = adapter;
    client.dio.interceptors.removeWhere((i) => i is LogInterceptor);
    final repository = LegacyApiRepository(client);
    final headers = <String, String>{'Content-Type': 'application/json; charset=UTF-8'};
    expect(await repository.apiAllinoneSelectArray('https://fixture.invalid/read', null, headers), []);
    expect(adapter.request!.method, 'POST');
    expect(adapter.request!.data, {});
    expect(adapter.request!.headers['Token'], 'synthetic-token');
    expect(adapter.request!.headers['Authorization'], isNull);
    expect(headers['Accept-Language'], 'en-GB');
    expect(client.dio.options.connectTimeout, const Duration(seconds: 15));
    adapter.status = 500;
    adapter.body = '{"Message":"fixture failure"}';
    expect(await repository.post('https://fixture.invalid/read'), {'Message': 'fixture failure'});
    client.dio.close();
  });
}
