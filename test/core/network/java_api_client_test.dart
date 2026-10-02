import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/session/session_token_store.dart';

import '../session/session_token_store_test.dart' show MemoryStore;

/// Answers each request with the next queued (status, body) and records it.
class QueueAdapter implements HttpClientAdapter {
  final List<(int, String)> replies = [];
  final List<RequestOptions> requests = [];

  /// The Authorization header of each request as it was sent (a retry reuses the options object).
  final List<Object?> sentAuthorization = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream, Future<void>? cancelFuture) async {
    requests.add(options);
    sentAuthorization.add(options.headers['Authorization']);
    final (status, body) = replies.removeAt(0);
    return ResponseBody.fromString(body, status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late QueueAdapter adapter;
  late SessionTokenStore tokens;
  late JavaApiClient client;
  final expiry = DateTime.fromMillisecondsSinceEpoch(1800000000000);

  setUp(() async {
    adapter = QueueAdapter();
    tokens = SessionTokenStore(MemoryStore());
    client = JavaApiClient(tokens, dio: Dio()..httpClientAdapter = adapter, baseUrl: 'https://java.test');
  });

  test('sends the session token to Java as a bearer header', () async {
    await tokens.save('jwt-1', expiry);
    adapter.replies.add((200, '{"IsSuccess":true}'));

    await client.dio.post<dynamic>('/api/mobile/auth/logout');

    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/mobile/auth/logout');
    expect(adapter.requests.single.headers['Authorization'], 'Bearer jwt-1');
  });

  test('sign-in is sent without a token', () async {
    await tokens.save('jwt-1', expiry);
    adapter.replies.add((200, '{}'));

    await client.dio.post<dynamic>('/api/mobile/auth/login',
        data: {'userName': 'u', 'password': 'p'}, options: Options(extra: {JavaApiClient.publicRequest: true}));

    expect(adapter.requests.single.headers.containsKey('Authorization'), isFalse);
  });

  test('a 401 refreshes once and retries the request once with the new token', () async {
    await tokens.save('jwt-old', expiry);
    var refreshes = 0;
    client.onRefresh = () async {
      refreshes++;
      await tokens.save('jwt-new', expiry);
      return true;
    };
    adapter.replies..add((401, '{}'))..add((200, '{"ok":1}'));

    final response = await client.dio.get<dynamic>('/api/x');

    expect(response.data, {'ok': 1});
    expect(refreshes, 1);
    expect(adapter.sentAuthorization, ['Bearer jwt-old', 'Bearer jwt-new']);
  });

  test('a refused refresh ends the session and passes the 401 on', () async {
    await tokens.save('jwt-old', expiry);
    var ended = false;
    client.onRefresh = () async => false;
    client.onSessionEnded = () => ended = true;
    adapter.replies.add((401, '{}'));

    await expectLater(client.dio.get<dynamic>('/api/x'),
        throwsA(isA<DioException>().having((e) => e.response?.statusCode, 'status', 401)));
    expect(ended, isTrue);
    expect(adapter.requests, hasLength(1));
  });

  test('a second 401 after the retry is not retried again', () async {
    await tokens.save('jwt-old', expiry);
    var refreshes = 0;
    client.onRefresh = () async {
      refreshes++;
      return true;
    };
    adapter.replies..add((401, '{}'))..add((401, '{}'));

    await expectLater(client.dio.get<dynamic>('/api/x'), throwsA(isA<DioException>()));
    expect(refreshes, 1);
    expect(adapter.requests, hasLength(2));
  });

  test('a 401 on sign-in is never refreshed', () async {
    var refreshes = 0;
    client.onRefresh = () async {
      refreshes++;
      return true;
    };
    adapter.replies.add((401, '{"IsSuccess":false}'));

    await expectLater(
        client.dio.post<dynamic>('/api/mobile/auth/login', options: Options(extra: {JavaApiClient.publicRequest: true})),
        throwsA(isA<DioException>()));
    expect(refreshes, 0);
  });
}
