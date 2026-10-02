import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/ir_report/data/datasources/ir_remote_data_source.dart';

import '../../core/network/java_api_client_test.dart' show QueueAdapter;

String ok(Object? data) => jsonEncode({'IsSuccess': true, 'StatusCode': 200, 'Message': 'ok', 'Data1': data});

void main() {
  late QueueAdapter adapter;
  late IrRemoteDataSource remote;

  setUp(() {
    adapter = QueueAdapter();
    remote = IrRemoteDataSource(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter);
  });

  test('search is a GET of /api/ir with the query and answers Data1', () async {
    adapter.replies.add((200, ok({'items': [], 'count': 0, 'totalAmount': 0})));

    final data = await remote.search({'companyRefId': 6, 'fromDate': '2026-09-01'});

    expect(adapter.requests.single.method, 'GET');
    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/ir?companyRefId=6&fromDate=2026-09-01');
    expect(data, {'items': [], 'count': 0, 'totalAmount': 0});
  });

  test('one report, save and delete use the REST paths', () async {
    adapter.replies
      ..add((200, ok({'id': 12})))
      ..add((200, ok({'id': 13})))
      ..add((200, ok(null)));

    expect(await remote.getById(12, 6), {'id': 12});
    expect(await remote.save({'companyRefId': 6, 'description': 'x'}), {'id': 13});
    await remote.delete(13, 6);

    expect(adapter.requests.map((r) => '${r.method} ${r.uri}'), [
      'GET https://java.test/api/ir/12?companyRefId=6',
      'POST https://java.test/api/ir',
      'DELETE https://java.test/api/ir/13?companyRefId=6',
    ]);
    expect(adapter.requests[1].data, {'companyRefId': 6, 'description': 'x'});
  });

  test('the pickers: statuses, departments, employees, trucks and drivers all on the shared Java APIs', () async {
    adapter.replies
      ..add((200, ok([{'id': 1}])))
      ..add((200, ok([{'id': 1000, 'name': 'TRANSPORTATION'}])))
      ..add((200, jsonEncode([{'id': 3, 'employeeName': 'ANNA'}])))
      ..add((200, jsonEncode({'isSuccess': true, 'data1': [{'Id': 5, 'AccountName': 'WLN 1234'}]})))
      ..add((200, jsonEncode({'isSuccess': true, 'data1': [{'Id': 7, 'AccountName': 'ALI'}]})));

    expect(await remote.statuses(6), [{'id': 1}]);
    expect(await remote.departments(), [{'id': 1000, 'name': 'TRANSPORTATION'}]);
    expect(await remote.employees(6), [{'id': 3, 'employeeName': 'ANNA'}]);
    expect(await remote.trucks(6), [{'Id': 5, 'AccountName': 'WLN 1234'}]);
    expect(await remote.drivers(6), [{'Id': 7, 'AccountName': 'ALI'}]);

    expect(adapter.requests.map((r) => r.uri.toString()), [
      'https://java.test/api/ir/statuses?companyRefId=6',
      'https://java.test/api/ir/departments',
      'https://java.test/api/employees/company/6/all',
      'https://java.test/api/truck-combo?companyId=6',
      'https://java.test/api/driver-combo?companyId=6',
    ]);
  });

  test('a refused save carries the server message', () async {
    adapter.replies.add((400, jsonEncode({
      'status': 400,
      'error': 'Bad Request',
      'message': 'Status 9 was not found for this company',
      'path': '/api/ir',
    })));

    await expectLater(remote.save({}), throwsA(isA<ApiFailure>()
        .having((e) => e.message, 'message', 'Status 9 was not found for this company')
        .having((e) => e.statusCode, 'status', 400)));
  });
}
