import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/config/app_config.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/network/java_route.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/session/session_token_store.dart';
import 'package:mocktail/mocktail.dart';

import '../session/session_token_store_test.dart' show MemoryStore;
import 'java_api_client_test.dart' show QueueAdapter;

class MockDioClient extends Mock implements DioClient {}

/// No .NET-shaped bridge (owner's rule, 2026-10-02): the app calls the shared
/// Java APIs; stock moved to `/api/stock-ins` (StockInApi).
void main() {
  test('nothing is bridged any more', () {
    expect(JavaRoute.moved, isEmpty);
    for (final url in [
      '${AppConfig.baseUrl}/api/StockApp/MaxStockInNo?Comid=6',
      ApiConstants.apiInsertForwarding,
      '${ApiConstants.apiGetTruckList}6',
    ]) {
      expect(JavaRoute.resolve(url), url, reason: url);
      expect(JavaRoute.resolve(url), isNot(contains('/api/mobile/app')), reason: url);
    }
  });

  test('isJava is the Java host', () {
    expect(JavaRoute.isJava('${AppConfig.javaBaseUrl}/api/stock-ins/jobs'), isTrue);
    expect(JavaRoute.isJava(ApiConstants.apiInsertForwarding), isFalse);
  });

  test('a .NET call still uses the legacy client', () async {
    final tokens = SessionTokenStore(MemoryStore());
    final javaAdapter = QueueAdapter();
    final legacy = MockDioClient();
    final legacyAdapter = QueueAdapter()..replies.add((200, '[]'));
    when(() => legacy.dio).thenReturn(Dio()..httpClientAdapter = legacyAdapter);
    final repository = LegacyApiRepository(legacy,
        java: JavaApiClient(tokens, dio: Dio()..httpClientAdapter = javaAdapter));

    await repository.apiAllinoneSelect(ApiConstants.apiInsertForwarding, {});

    expect(legacyAdapter.requests.single.uri.toString(), ApiConstants.apiInsertForwarding);
    expect(javaAdapter.requests, isEmpty);
    GetIt.instance.allowReassignment = true;
  });
}
