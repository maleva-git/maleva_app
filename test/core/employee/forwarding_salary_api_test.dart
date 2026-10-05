import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/employee/forwarding_salary_api.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// Forwarding salaries off .NET ForwardingSalaryApp (forwarding-salary-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late ForwardingSalaryApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = ForwardingSalaryApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter,
        companyId: () => 6);
  });

  test('an RTI reads its first forwarding salary, or none', () async {
    adapter.replies
      ..add((200, jsonEncode(ok([
        {'id': 9, 'rtiMasterRefId': 40, 'employeeMasterRefId': 15, 'employeeMasterRefId1': null,
          'salary1': 50.0, 'salary2': 0.0},
      ]))))
      ..add((200, jsonEncode(ok([]))));

    final row = await api.forRti(40);
    expect(adapter.requests.last.uri.toString(),
        'https://java.test/api/forwarding-salaries/entries?companyId=6&rtiId=40');
    expect([row!['id'], row['employeeMasterRefId'], row['salary1']], [9, 15, 50.0]);
    expect(await api.forRti(41), isNull);
  });

  test('a save sends the Java fields, no employee as null, and answers the id', () async {
    adapter.replies.add((200, jsonEncode(ok(81))));

    final id = await api.save(id: 0, rtiId: 40, sealEmployeeId: 15, breakSealEmployeeId: 0, salary1: 50, salary2: 0);

    expect(id, 81);
    expect(adapter.requests.last.uri.toString(), 'https://java.test/api/forwarding-salaries/entries?companyId=6');
    expect(adapter.requests.last.data, {'id': 0, 'rtiMasterRefId': 40, 'employeeMasterRefId': 15,
      'employeeMasterRefId1': null, 'salary1': 50.0, 'salary2': 0.0});
  });

  test('a refused save is the server reason', () async {
    adapter.replies.add((400, jsonEncode({'IsSuccess': false, 'StatusCode': 400, 'Message': 'Select the RTI'})));

    expect(() => api.save(id: 0, rtiId: 0, sealEmployeeId: 0, breakSealEmployeeId: 0, salary1: 0, salary2: 0),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Select the RTI')));
  });
}
