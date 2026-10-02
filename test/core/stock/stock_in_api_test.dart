import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/stock/stock_in_api.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// The shared Java /api/stock-ins, read as it answers (change stock-in-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late StockInApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = StockInApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter);
  });

  String uri() => adapter.requests.last.uri.toString();

  test('next number, stock jobs and a job', () async {
    adapter.replies
      ..add((200, jsonEncode(ok('STI000000124'))))
      ..add((200, jsonEncode(ok([40, 41]))))
      ..add((200, jsonEncode(ok([{'id': 40, 'jobMasterRefId': 1, 'jStatus': 3, 'customerName': 'ACME'}]))));

    expect(await api.nextNumber(6), 'STI000000124');
    expect(uri(), 'https://java.test/api/stock-ins/next-number?companyId=6');
    expect(await api.stockJobs(6), [40, 41]);
    expect((await api.saleOrders(6, saleOrderId: 40)).single['jStatus'], 3);
    expect(uri(), 'https://java.test/api/stock-ins/sale-orders?companyId=6&id=40');
  });

  test('a label is found; an unknown one is the server message', () async {
    adapter.replies
      ..add((200, jsonEncode(ok({'id': 901, 'numberOfPackages': 3, 'barcodeLabelDisplay': 'MY00123'}))))
      ..add((404, jsonEncode({'IsSuccess': false, 'StatusCode': 404, 'Message': 'Invalid StockMaster No !!!'})));

    expect((await api.byLabel(6, 'MY00123-1/3'))['id'], 901);
    expect(uri(), 'https://java.test/api/stock-ins/entries/by-label?companyId=6&label=MY00123-1%2F3');
    expect(() => api.byLabel(6, 'X'),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Invalid StockMaster No !!!')));
  });

  test('save, arrival and transfer send the Java bodies', () async {
    adapter.replies
      ..add((200, jsonEncode(ok(901))))
      ..add((200, jsonEncode(ok(901))))
      ..add((200, jsonEncode(ok(901))));

    expect(await api.save(6, [{'id': 0, 'saleOrderMasterRefId': 40}]), 901);
    expect(adapter.requests.last.method, 'POST');
    expect(uri(), 'https://java.test/api/stock-ins/entries?companyId=6');

    await api.arrival(6, 901, statusId: 4, portId: 3, imageUrls: ['u']);
    expect(adapter.requests.last.method, 'PUT');
    expect(uri(), 'https://java.test/api/stock-ins/entries/901/arrival?companyId=6');
    expect(adapter.requests.last.data, {'statusId': 4, 'portId': 3, 'imageUrls': ['u']});

    await api.transfer(6, 901, 5);
    expect(uri(), 'https://java.test/api/stock-ins/entries/901/transfer?companyId=6');
    expect(adapter.requests.last.data, {'portId': 5});
  });

  test('a refused save throws the server message', () async {
    adapter.replies.add((400, jsonEncode({'IsSuccess': false, 'StatusCode': 400, 'Message': 'Number of packages must be more than 0'})));

    expect(() => api.save(6, [{}]),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Number of packages must be more than 0')));
  });
}
