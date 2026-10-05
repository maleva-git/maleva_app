import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/config/app_config.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/network/legacy_call_adapter.dart';
import 'package:maleva/core/session/session_token_store.dart';
import 'package:maleva/core/utils/session_manager.dart';
import 'package:mocktail/mocktail.dart';

import '../session/session_token_store_test.dart' show MemoryStore;
import 'java_api_client_test.dart' show QueueAdapter;

class MockDioClient extends Mock implements DioClient {}

class MockSessionManager extends Mock implements SessionManager {}

/// The old lookup calls, answered by the shared Java APIs through every HTTP helper.
void main() {
  late QueueAdapter adapter;

  setUp(() async {
    adapter = QueueAdapter();
    final tokens = SessionTokenStore(MemoryStore());
    await tokens.save('jwt-1', DateTime.fromMillisecondsSinceEpoch(1800000000000));
    GetIt.instance.allowReassignment = true;
    GetIt.instance.registerSingleton<JavaApiClient>(
        JavaApiClient(tokens, dio: Dio()..httpClientAdapter = adapter, baseUrl: 'https://java.test'));
  });

  tearDown(() => GetIt.instance.unregister<JavaApiClient>());

  String combo(List<Map<String, dynamic>> rows) => jsonEncode({'isSuccess': true, 'data1': rows});

  test('it handles the lookup calls, any spelling, and nothing else', () {
    for (final url in [
      '${ApiConstants.apiGetTruckList}6&type=',
      '${ApiConstants.apiEditTruckDetails}6&Startindex=0&PageCount=0&Keyword=3&Column=Id&type=',
      '${ApiConstants.apiUpdateTruckDetails}6',
      '${ApiConstants.apiGetDriverList}6&type=',
      '${ApiConstants.apiSelectCustomer}6',
      '${ApiConstants.apiSelectAddressList}6',
      '${ApiConstants.apiSelectAddressDetails}6&KeyWord=',
      '${ApiConstants.apiSelectJobType}6',
      '${ApiConstants.apiSelectAllJobStatus}6&Jobid=2',
      '${ApiConstants.apiSelectJobStatus}6',
      '${ApiConstants.apiSelectAgentAll}6&Jobid=0',
      '${ApiConstants.apiSelectAgentCompany}6',
      '${ApiConstants.apiGetProductList}6',
    ]) {
      expect(LegacyCallAdapter.handles(url), isTrue, reason: url);
    }
    for (final url in [
      '${ApiConstants.apiDriverViewRecords}6',
      ApiConstants.apiSelectAllInventory,
      '${AppConfig.baseUrl}/api/StockApp/MaxStockInNo?Comid=6',
      // fuel calls go through FuelEntryApi now (fuel-entry-on-shared-java-api)
      '${AppConfig.baseUrl}/api/FuelEntryApp/SelectFuelEntry',
      ApiConstants.apiInsertForwarding,
      'https://elsewhere.test/api/TruckApp/GetTruck',
    ]) {
      expect(LegacyCallAdapter.handles(url), isFalse, reason: url);
    }
  });

  test('ApiClient: a lookup answers the old rows from the shared API', () async {
    adapter.replies.add((200, combo([{'Id': 3, 'AccountName': 'VBC 5521'}])));

    final rows = await ApiClient.postRequest('${ApiConstants.apiGetTruckList}6&type=', null);

    expect(rows, [{'Id': 3, 'AccountName': 'VBC 5521'}]);
    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/truck-combo?companyId=6');
    expect(adapter.sentAuthorization.single, 'Bearer jwt-1');
  });

  test('ApiClient: a refusal reads like the .NET message', () async {
    adapter.replies.add((400, jsonEncode({'status': 400, 'message': 'Company is required'})));

    await expectLater(ApiClient.postRequest('${ApiConstants.apiGetTruckList}6&type=', null),
        throwsA(predicate((e) => e.toString().contains('Company is required'))));
  });

  test('the legacy repository: the named helper parses the shared answer, and a refusal returns the envelope', () async {
    final repository = LegacyApiRepository(MockDioClient(), java: GetIt.instance<JavaApiClient>());
    adapter.replies
      ..add((200, combo([{'Id': 3, 'AccountName': 'VBC 5521'}])))
      ..add((400, jsonEncode({'status': 400, 'message': 'Company is required'})));

    final rows = await repository.apiAllinoneSelectArray('${ApiConstants.apiGetTruckList}6&type=', null, {}, null);
    final refused = await repository.apiAllinoneSelectArray('${ApiConstants.apiGetTruckList}6&type=', null, {}, null);

    expect(rows, [{'Id': 3, 'AccountName': 'VBC 5521'}]);
    expect(refused['IsSuccess'], isFalse);
    expect(refused['Message'], 'Company is required');
  });

  test('the legacy DioClient: a direct caller gets the old rows, with alias parameters', () async {
    final sessions = MockSessionManager();
    when(() => sessions.mobileToken).thenReturn('legacy-token');
    final client = DioClient(sessions, java: GetIt.instance<JavaApiClient>());
    adapter.replies.add((200, jsonEncode({'IsSuccess': true, 'Data1': [
      {'jobTypeDetails': [], 'jobStatusDetails': [{'id': 9, 'status': 3, 'statusName': 'ARRIVED', 'sort': 1}]}
    ]})));

    final res = await client.dio.post<dynamic>('${ApiConstants.apiSelectAllJobStatus}6&JobMasterRefId=2', data: {});

    expect(res.data[0]['JobStatusDetails'][0]['StatusName'], 'ARRIVED');
    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/job-type-master/select-all-data?companyId=6&jobId=2');
    expect(adapter.requests.single.headers.containsKey('Token'), isFalse);
  });
}
