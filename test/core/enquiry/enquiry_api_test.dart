import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/enquiry/enquiry_api.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/transaction/enquirytrmaster/models/enquiry_master_model.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// Enquiries on the shared Java API (enquiry-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late EnquiryApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = EnquiryApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  RequestOptions last() => adapter.requests.last;

  final row = {
    'id': 40, 'customerRefId': 9, 'customerName': 'ACME', 'jobMasterRefId': 2, 'jobType': 'IMPORT',
    'forwardingDate': '2026-10-05T10:30:00', 'pickupDate': null, 'sport': 'PKG', 'oport': 'PEN',
    'origin': 'KL', 'destination': 'PG', 'quantity': '3', 'totalWeight': '120', 'jstatus': 4,
  };

  test('the team list and the TR list send their filters', () async {
    adapter.replies
      ..add((200, jsonEncode(ok([row]))))
      ..add((200, jsonEncode(ok([]))));

    final rows = await api.search(employeeId: 15, team: true);
    expect(last().uri.toString(), 'https://java.test/api/enquiry-masters/search?companyId=6');
    expect(last().data, {'customerId': 0, 'jobTypeId': 0, 'employeeId': 15, 'team': true, 'invoice': false});
    expect(EnquiryApi.display(rows.single['forwardingDate']), '05-10-2026 10:30');

    await api.search(employeeId: 15, customerId: 9, jobTypeId: 2, invoice: true,
        fromDate: DateTime(2026, 10, 1), toDate: DateTime(2026, 10, 5));
    expect(last().data, {'customerId': 9, 'jobTypeId': 2, 'employeeId': 15, 'team': false, 'invoice': true,
      'fromDate': '2026-10-01', 'toDate': '2026-10-05'});
  });

  test('cancel and confirm; a refusal is the server message', () async {
    adapter.replies
      ..add((200, jsonEncode(ok(40))))
      ..add((404, jsonEncode({'status': 404, 'message': 'Enquiry 41 was not found'})));

    await api.setStatus(40, 'CANCEL');
    expect(last().method, 'PUT');
    expect(last().uri.toString(), 'https://java.test/api/enquiry-masters/40/status?companyId=6&status=CANCEL');
    expect(() => api.setStatus(41, 'CONFIRMED'),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Enquiry 41 was not found')));
  });

  test('a Java enquiry row reads into the TR model and opens as a sale order', () {
    final m = EnquiryMasterModel.fromJava(row);
    expect([m.id, m.customerName, m.jobType, m.sPort, m.oPort, m.origin, m.totalWeight, m.sForwardingDate],
        [40, 'ACME', 'IMPORT', 'PKG', 'PEN', 'KL', '120', '05-10-2026 10:30']);

    final so = EnquiryApi.asSaleOrder(row);
    expect([so['sPort'], so['oPort'], so['jStatus'], so['customerRefId']], ['PKG', 'PEN', 4, 9]);
    expect(so.containsKey('sport'), isFalse);
  });

  test('a transport enquiry saves the form fields to the Java entries endpoint', () async {
    adapter.replies.add((200, jsonEncode(ok(81))));

    final id = await api.save(id: 0, billType: 'TR', customerId: 9, jobTypeId: 2, employeeId: 0,
        forwardingDate: DateTime(2026, 10, 5, 9), quantity: '3', totalWeight: '120', originId: 4, origin: 'KL',
        pickupDate: DateTime(2026, 10, 6, 8, 30));

    expect(id, 81);
    expect(last().uri.toString(), 'https://java.test/api/enquiry-masters/entries?companyId=6');
    final body = last().data as Map;
    expect([body['billType'], body['customerRefId'], body['jobTypeId'], body['employeeRefId']], ['TR', 9, 2, null]);
    expect([body['forwardingDate'], body['pickupDate'], body['eta']], ['2026-10-05T09:00:00', '2026-10-06T08:30:00', null]);
    expect([body['quantity'], body['originRefId'], body['origin']], ['3', 4, 'KL']);
  });

  test('a refused save is the server reason', () async {
    adapter.replies.add((400, jsonEncode({'IsSuccess': false, 'StatusCode': 400, 'Message': 'Select the job type'})));

    expect(() => api.save(id: 0, billType: 'MY', customerId: 9, jobTypeId: 0, forwardingDate: DateTime(2026, 10, 5)),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Select the job type')));
  });
}
