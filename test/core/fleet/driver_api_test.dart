import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/fleet/driver_api.dart';
import 'package:maleva/core/models/shared/get_truck_model.dart';
import 'package:maleva/core/models/shared/license_view_model.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

/// The License tab off .NET DriverApp/SelectDriver (license-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late DriverApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = DriverApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  test('the first 100 drivers read as licences', () async {
    adapter.replies.add((200, jsonEncode({'IsSuccess': true, 'StatusCode': 200, 'Message': 'ok', 'Data1': {
      'items': [{'id': 7, 'driverName': 'RAVI', 'licenseNo': 'D123', 'licenseExp': '2026-11-01',
        'joiningDate': '2024-01-15', 'accountCode': 'DRV-7', 'active': 1, 'mobileNo': '0123'}],
      'totalCount': 1,
    }})));

    final rows = await api.search(pageCount: 100);

    expect(adapter.requests.single.uri.path, '/api/driver-masters/search');
    expect(adapter.requests.single.queryParameters,
        {'companyId': 6, 'startIndex': 0, 'pageCount': 100, 'keyword': '', 'column': 'All'});
    final licence = LicenseViewModel.fromJava(rows.single);
    expect([licence.Id, licence.DriverName, licence.licenseNo, licence.licenseExp, licence.AccountCode, licence.Active],
        [7, 'RAVI', 'D123', '2026-11-01', 'DRV-7', 1]);
  });

  test('a failure is the server message', () async {
    adapter.replies.add((400, jsonEncode({'IsSuccess': false, 'StatusCode': 400, 'Message': 'Company ID is required'})));

    expect(() => api.search(), throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Company ID is required')));
  });

  test('the driver picker is the combo rows', () async {
    adapter.replies.add((200, jsonEncode({'isSuccess': true, 'statusCode': 200, 'data1': [{'Id': 7, 'AccountName': 'RAVI-0123'}]})));

    final rows = await api.combo(type: 'PRIME');

    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/driver-combo?companyId=6&type=PRIME');
    final d = GetTruckModel.fromJava(rows.single);
    expect([d.Id, d.AccountName], [7, 'RAVI-0123']);
  });

  test('a refused driver list is the server message', () async {
    adapter.replies.add((400, jsonEncode({'status': 400, 'message': 'Company is required'})));

    expect(() => api.combo(), throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Company is required')));
  });
}
