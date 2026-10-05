import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/employee/boarding_salary_api.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

/// Boarding salary off .NET BoardingSalaryApp (boarding-salary-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late BoardingSalaryApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = BoardingSalaryApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter,
        companyId: () => 6);
  });

  test('an officer reads their own rows for the company', () async {
    adapter.replies.add((200, jsonEncode({'IsSuccess': true, 'StatusCode': 200, 'Message': 'ok', 'Data1': [
      {'employeeRefId': 15, 'employeeName': 'ALI', 'vesselName': 'MV SEA PRIDE', 'boardingDate': '2026-10-03',
        'calculatedRate': 50.0},
    ]})));

    final rows = await api.monthly(fromDate: '2026-10-01', toDate: '2026-10-05', employeeId: 15);

    expect(adapter.requests.single.uri.path, '/api/boarding-settlement/monthly-salary');
    expect(adapter.requests.single.queryParameters,
        {'fromDate': '2026-10-01', 'toDate': '2026-10-05', 'employeeId': 15, 'companyId': 6});
    expect(rows.single['calculatedRate'], 50.0);
  });

  test('an admin asks for every officer', () async {
    adapter.replies.add((200, jsonEncode({'IsSuccess': true, 'StatusCode': 200, 'Message': 'ok', 'Data1': []})));

    expect(await api.monthly(fromDate: '2026-10-01', toDate: '2026-10-05'), isEmpty);
    expect(adapter.requests.single.queryParameters.containsKey('employeeId'), isFalse);
  });

  test('a failure is the server message', () async {
    adapter.replies.add((500, jsonEncode({'IsSuccess': false, 'StatusCode': 500, 'Message': 'Boom'})));

    expect(() => api.monthly(fromDate: '2026-10-01', toDate: '2026-10-05'),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Boom')));
  });
}
