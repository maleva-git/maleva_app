import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/job_order/job_order_api.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// The shared Java /api/job-orders, read as it answers (change job-orders-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late JobOrderApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = JobOrderApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  RequestOptions last() => adapter.requests.last;

  test('the list posts the company, status and truck', () async {
    adapter.replies.add((200, jsonEncode(ok([{'id': 10, 'statusRefId': 1, 'details': []}]))));

    final rows = await api.list(statusId: 1, truckId: 42);

    expect(rows.single['id'], 10);
    expect(last().method, 'POST');
    expect(last().uri.toString(), 'https://java.test/api/job-orders/list');
    expect(last().data, {'companyRefId': 6, 'statusRefId': 1, 'truckMasterRefId': 42});
  });

  test('statuses and product names', () async {
    adapter.replies
      ..add((200, jsonEncode(ok([{'id': 1, 'name': 'OPEN'}, {'id': 3, 'name': 'COMPLETED'}]))))
      ..add((200, jsonEncode([{'id': 5, 'pname': 'OIL FILTER'}, {'id': 6, 'pname': 'TYRE'}])));

    expect((await api.statuses()).map((s) => s['name']), ['OPEN', 'COMPLETED']);
    expect(last().uri.toString(), 'https://java.test/api/job-orders/statuses');
    expect(await api.productNames(), {5: 'OIL FILTER', 6: 'TYRE'});
    expect(last().uri.toString(), 'https://java.test/api/product-masters/company/6');
  });

  test('a status change sends only the status; a refusal is the server message', () async {
    adapter.replies
      ..add((200, jsonEncode(ok({'id': 10, 'statusRefId': 3}))))
      ..add((404, jsonEncode({'status': 404, 'error': 'Not Found', 'message': 'Job Order not found with ID 11'})));

    expect((await api.updateStatus(10, 3))['statusRefId'], 3);
    expect(last().method, 'PUT');
    expect(last().uri.toString(), 'https://java.test/api/job-orders/10/status?companyRefId=6&statusRefId=3');
    expect(() => api.updateStatus(11, 3),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Job Order not found with ID 11')));
  });
}
