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

/// The old lookup and fuel calls, answered by the shared Java APIs through every HTTP helper.
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

  test('it handles the lookup and fuel calls, any spelling, and nothing else', () {
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
      '${ApiConstants.apiMaxFuelEntryNo}6',
      ApiConstants.apiSelectFuelEntry,
      ApiConstants.apiInsertFuelEntry,
      '${ApiConstants.apiDeleteFuelEntry}5&Comid=6&Mobile=1',
      '${AppConfig.baseUrl}/api/fuelentryapp/SelectFuelEntry',
    ]) {
      expect(LegacyCallAdapter.handles(url), isTrue, reason: url);
    }
    for (final url in [
      '${ApiConstants.apiDriverViewRecords}6',
      ApiConstants.apiSelectAllInventory,
      '${ApiConstants.apiMaxStockNo}6',
      ApiConstants.apiSelectEnquiryMaster,
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
    adapter.replies.add((400, jsonEncode({'status': 400, 'message': 'No Truck Assigned! Please ask the office.'})));

    await expectLater(ApiClient.postRequest(ApiConstants.apiInsertFuelEntry, [{'Id': 0}], headers: {'Comid': '6'}),
        throwsA(predicate((e) => e.toString().contains('No Truck Assigned'))));
  });

  test('the legacy repository: the named helper parses the shared answer, and a save returns the envelope', () async {
    final repository = LegacyApiRepository(MockDioClient(), java: GetIt.instance<JavaApiClient>());
    adapter.replies
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': {'id': 71}})))
      ..add((400, jsonEncode({'status': 400, 'message': 'Truck is required'})))
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': 'FE000000072'})));

    final saved = await repository.apiAllinoneSelectArray(ApiConstants.apiInsertFuelEntry, [
      {'SaleDate': '2026-10-02T00:00:00.000', 'Id': 0, 'CompanyRefId': 6, 'TruckRefid': 3, 'DriverRefId': 7, 'Aliter': 50, 'FStatus': 1}
    ], {'Comid': '6'});
    final refused = await repository.apiAllinoneSelectArray(ApiConstants.apiInsertFuelEntry, [{'Id': 0}], {'Comid': '6'});
    final number = await repository.apiGetString('${ApiConstants.apiMaxFuelEntryNo}6');

    expect(saved['IsSuccess'], isTrue);
    expect(saved['Message'], 'FuelEntry Update Successfully..');
    expect(refused['IsSuccess'], isFalse);
    expect(refused['Message'], 'Truck is required');
    expect(number, 'FE000000072');
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
