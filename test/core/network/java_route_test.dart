import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/config/app_config.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/network/java_route.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/session/session_token_store.dart';
import 'package:maleva/core/utils/session_manager.dart';
import 'package:mocktail/mocktail.dart';

import '../session/session_token_store_test.dart' show MemoryStore;
import 'java_api_client_test.dart' show QueueAdapter;

class MockDioClient extends Mock implements DioClient {}

class MockSessionManager extends Mock implements SessionManager {}

/// The Java bridge (`/api/mobile/app`): only for features Java has no shared API for (Stock).
void main() {
  const java = '${AppConfig.javaBaseUrl}/api/mobile/app';

  group('resolve', () {
    test('every stock call goes to the bridge, any spelling of the controller', () {
      for (final url in [
        '${ApiConstants.apiMaxStockNo}6',
        '${ApiConstants.apiSelectStockJob}6',
        '${ApiConstants.apiWareHouseCombo}6',
        '${ApiConstants.apiSelectStockDetails}6&Id=40',
        '${ApiConstants.apiEditStockIn}0&barcodeLabel=MY00123&Comid=6',
        '${ApiConstants.apiUpdateStockIn}55&StatusId=4&Comid=6&PortRefid=3&ImageURL',
        '${ApiConstants.apiUpdateStockTransfer}55&PortId=3&Comid=6',
        '${ApiConstants.apiInsertStockIn}6',
        '${ApiConstants.apiPrintStock}55&Comid=6',
        '${AppConfig.baseUrl}/api/stockapp/MaxStockInNo?Comid=6',
      ]) {
        expect(JavaRoute.resolve(url), startsWith('$java/StockApp/'), reason: url);
      }
    });

    test('the moved list names whole controllers or single actions', () {
      for (final entry in JavaRoute.moved) {
        expect(entry, matches(RegExp(r'^\w+(/\w+)?$')), reason: entry);
      }
    });

    test('everything else is left alone, lookups included (they use the shared APIs)', () {
      expect(JavaRoute.resolve(ApiConstants.apiSelectEnquiryMaster), ApiConstants.apiSelectEnquiryMaster);
      expect(JavaRoute.resolve('${ApiConstants.apiGetTruckList}6'), '${ApiConstants.apiGetTruckList}6');
      expect(JavaRoute.resolve('https://elsewhere.test/api/StockApp/X'), 'https://elsewhere.test/api/StockApp/X');
    });
  });

  group('transport', () {
    late QueueAdapter adapter;
    late SessionTokenStore tokens;

    setUp(() async {
      adapter = QueueAdapter();
      tokens = SessionTokenStore(MemoryStore());
      await tokens.save('jwt-1', DateTime.fromMillisecondsSinceEpoch(1800000000000));
      GetIt.instance.allowReassignment = true;
      GetIt.instance.registerSingleton<JavaApiClient>(JavaApiClient(tokens, dio: Dio()..httpClientAdapter = adapter));
    });

    tearDown(() => GetIt.instance.unregister<JavaApiClient>());

    test('ApiClient sends a bridged call to Java with the session token and the caller header', () async {
      adapter.replies.add((200, '[{"Id":3,"PortName":"WH A"}]'));

      final result = await ApiClient.postRequest('${ApiConstants.apiWareHouseCombo}6', null,
          headers: {'Comid': '6', 'Authorization': 'Bearer legacy'});

      expect(result, [{'Id': 3, 'PortName': 'WH A'}]);
      expect(adapter.requests.single.uri.toString(), '$java/StockApp/SelectPortList?Comid=6');
      expect(adapter.sentAuthorization.single, 'Bearer jwt-1');
      expect(adapter.requests.single.headers['Comid'], '6');
    });

    test('ApiClient keeps the .NET error handling for a bridge 500', () async {
      adapter.replies.add((500, jsonEncode({'IsSuccess': false, 'StatusCode': 0, 'Message': 'Invalid Barcode !!!'})));

      await expectLater(ApiClient.postRequest('${ApiConstants.apiEditStockIn}0&barcodeLabel=X&Comid=6', null),
          throwsA(predicate((e) => e.toString().contains('Invalid Barcode !!!'))));
    });

    test('the legacy repository sends a bridged call to Java and returns the 500 body', () async {
      final repository = LegacyApiRepository(MockDioClient(), java: GetIt.instance<JavaApiClient>());
      adapter.replies.add((500, '{"IsSuccess":false,"Message":"Stock-in 9 was not found"}'));

      final refused = await repository.apiAllinoneSelectArray('${ApiConstants.apiPrintStock}9&Comid=6', {}, {});

      expect(refused['Message'], 'Stock-in 9 was not found');
      expect(adapter.requests.single.uri.path, '/api/mobile/app/StockApp/SelectStockPrint');
    });

    test('a bridged call made on the legacy DioClient goes to Java without the legacy token', () async {
      final sessions = MockSessionManager();
      when(() => sessions.mobileToken).thenReturn('legacy-token');
      final client = DioClient(sessions, java: GetIt.instance<JavaApiClient>());
      adapter.replies.add((200, '[{"MaxNo":"STI000000125"}]'));

      final ok = await client.dio.post<dynamic>('${ApiConstants.apiMaxStockNo}6', data: {});

      expect(ok.data, [{'MaxNo': 'STI000000125'}]);
      expect(adapter.requests.single.headers.containsKey('Token'), isFalse);
      expect(adapter.sentAuthorization, everyElement('Bearer jwt-1'));
    });

    test('a call that has not moved still uses the legacy client', () async {
      final legacy = MockDioClient();
      final legacyAdapter = QueueAdapter()..replies.add((200, '[]'));
      when(() => legacy.dio).thenReturn(Dio()..httpClientAdapter = legacyAdapter);
      final repository = LegacyApiRepository(legacy, java: GetIt.instance<JavaApiClient>());

      await repository.apiAllinoneSelect(ApiConstants.apiSelectEnquiryMaster, {});

      expect(legacyAdapter.requests.single.uri.toString(), ApiConstants.apiSelectEnquiryMaster);
      expect(adapter.requests, isEmpty);
    });
  });
}
