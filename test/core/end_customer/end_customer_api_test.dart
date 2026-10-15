import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/end_customer/end_customer_api.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

Map<String, dynamic> javaRow(int id, String name) => {'id': id, 'endCustomerName': name, 'remarks': null, 'active': 1};

/// The shared `/api/end-customers` as the sale order form uses it (change sale-order-end-customer).
void main() {
  late QueueAdapter adapter;
  late EndCustomerApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = EndCustomerApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter);
  });

  test("reads the customer's end customers as Java sends them", () async {
    adapter.replies.add((200, jsonEncode(ok([javaRow(11, 'Daikin'), javaRow(12, 'Panasonic')]))));

    final rows = await api.forCustomer(300);

    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/end-customers/customer/300');
    expect(rows.map((e) => e.name), ['Daikin', 'Panasonic']);
    expect(rows.first.id, 11);
  });

  test('quick add posts the trimmed name and returns the record', () async {
    adapter.replies.add((200, jsonEncode(ok(javaRow(13, 'Toshiba')))));

    final added = await api.quickAdd(300, '  Toshiba ');

    final req = adapter.requests.single;
    expect(req.uri.toString(), 'https://java.test/api/end-customers/customer/300/quick-add');
    expect(req.method, 'POST');
    expect(req.data, {'endCustomerName': 'Toshiba'});
    expect(added.id, 13);
  });

  test("a refusal carries the server's message", () async {
    adapter.replies.add((404, jsonEncode({'IsSuccess': false, 'StatusCode': 404, 'Message': 'No customer 999 in this company'})));

    expect(api.forCustomer(999), throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'No customer 999 in this company')));
  });
}
