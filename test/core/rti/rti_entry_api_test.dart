import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/rti/rti_entry_api.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// The Add / Edit RTI form off the .NET /RTI/* web routes (rti-entry-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late RtiEntryApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = RtiEntryApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  RequestOptions last() => adapter.requests.last;

  test('the next number is the RTI sequence plus one', () async {
    adapter.replies.add((200, jsonEncode([
      {'sequenceName': 'SaleOrder', 'sequenceNo': 99},
      {'sequenceName': 'RTIMaster', 'sequenceNo': 8651},
    ])));

    expect(await api.nextNumberPreview(), 'RTI000008652');
    expect(last().uri.toString(), 'https://java.test/api/sequence-masters/company/6');
  });

  test('an RTI loads with its lines, for the company', () async {
    adapter.replies
      ..add((200, jsonEncode({'id': 40, 'cnumberDisplay': 'RTI000000040', 'elink': '1ST LINK', 'companyRefId': 6})))
      ..add((200, jsonEncode([{'id': 3, 'saleOrderMasterRefId': 9, 'jobNo': 'MY9', 'customerName': 'ACME'}])));

    final rti = await api.load(40);

    expect(adapter.requests.first.uri.toString(), 'https://java.test/api/rti-masters/40?companyId=6');
    expect(last().uri.toString(), 'https://java.test/api/rti-details/rti-master/40');
    expect(rti.master['cnumberDisplay'], 'RTI000000040');
    expect(rti.lines.single['jobNo'], 'MY9');
  });

  test('a new RTI is posted without an id; an edit is put for the company', () async {
    adapter.replies
      ..add((201, jsonEncode({'id': 41, 'cnumberDisplay': 'RTI000000041'})))
      ..add((200, jsonEncode({'id': 40, 'cnumberDisplay': 'RTI000000040'})));

    final added = await api.save({'id': 0, 'driverRefId': 7}, [{'saleOrderMasterRefId': 9}]);
    expect(added['id'], 41);
    expect(adapter.requests.first.method, 'POST');
    expect(adapter.requests.first.uri.toString(), 'https://java.test/api/rti-masters');
    final body = adapter.requests.first.data as Map;
    expect(body.containsKey('id'), isFalse);
    expect([body['companyRefId'], body['driverRefId'], body['rtiDetails']], [6, 7, [{'saleOrderMasterRefId': 9}]]);
    expect(body.containsKey('routeActivities'), isFalse);

    await api.save({'id': 40}, []);
    expect(last().method, 'PUT');
    expect(last().uri.toString(), 'https://java.test/api/rti-masters/40?companyId=6');
  });

  test('the job search, revise and delete', () async {
    adapter.replies
      ..add((200, jsonEncode(ok([{'id': 9, 'jobNo': 'MY9', 'jobDate': '2026-10-01T00:00:00', 'customerName': 'ACME'}]))))
      ..add((200, jsonEncode(ok({'id': 40, 'rtiDetails': [{'saleOrderMasterRefId': 9, 'originD': 'KL'}]}))))
      ..add((204, ''));

    expect((await api.searchJob('MY9')).single['id'], 9);
    expect(last().uri.toString(), 'https://java.test/api/rti-masters/company/6/job-search?jobNo=MY9');
    expect((await api.revise(40)).lines.single['originD'], 'KL');
    expect(last().uri.toString(), 'https://java.test/api/rti-masters/40/revise?companyRefId=6');
    await api.delete(40);
    expect(last().method, 'DELETE');
    expect(last().uri.toString(), 'https://java.test/api/rti-masters/40?companyId=6');
  });

  test("another company's RTI is the server's plain-text reason", () async {
    adapter.replies.add((404, jsonEncode('RTIMaster not found with ID: 40'))); // a plain-text body, read as a string

    expect(() => api.load(40), throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'RTIMaster not found with ID: 40')));
  });

  test("the amounts follow React's rule", () {
    final a = RtiEntryApi.amounts(salaries: [100, 50.5], sleeping: true, exitYN: 1, emptyDeliveryYN: 2, manpower: 2,
        pickup: true, pickupCount: 2, drop: false, dropCount: 3);

    expect(a, {'sleepingAmount': 50, 'exitAmount': 80, 'emptyDeliveryAmount': 50, 'manpwAmount': 100,
      'pickupAmount': 60, 'dropAmount': 0, 'amount': 490.5});
  });
}
