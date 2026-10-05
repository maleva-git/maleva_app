import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/employee/employee_api.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

/// The shared Java employee lists for the pickers (change employee-lookups-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late EmployeeApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = EmployeeApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  List<String> uris() => adapter.requests.map((r) => r.uri.toString()).toList();

  test('no type is one call for every active employee, shown Name-Type', () async {
    adapter.replies.add((200, jsonEncode([
      {'id': 2, 'employeeName': 'ZARA', 'employeeType': 'SALES', 'active': 1},
      {'id': 1, 'employeeName': 'ANNA', 'employeeType': 'ADMIN', 'active': 1},
      {'id': 3, 'employeeName': 'OLD', 'employeeType': 'SALES', 'active': 0},
    ])));

    final list = await api.dropdown(type: '', type1: 'ALL');

    expect(uris(), ['https://java.test/api/employees/company/6/all']);
    expect(list.map((e) => [e.Id, e.AccountName]), [[1, 'ANNA-ADMIN'], [2, 'ZARA-SALES']],
        reason: 'by name, inactive left out as .NET did');
    expect(list.first.Password, '');
  });

  test('two types are two calls, merged once each', () async {
    adapter.replies
      ..add((200, jsonEncode([{'id': 2, 'employeeName': 'ZARA', 'employeeType': 'SALES', 'active': 1}])))
      ..add((200, jsonEncode([
        {'id': 1, 'employeeName': 'ANNA', 'employeeType': 'ADMIN', 'active': 1},
        {'id': 2, 'employeeName': 'ZARA', 'employeeType': 'SALES', 'active': 1},
      ])));

    final list = await api.dropdown(type: 'Sales', type1: 'admin');

    expect(uris(), ['https://java.test/api/employees/company/6/all?type=SALES',
      'https://java.test/api/employees/company/6/all?type=ADMIN']);
    expect(list.map((e) => e.Id), [1, 2]);
  });

  test('the same type twice is one call', () async {
    adapter.replies.add((200, jsonEncode([])));

    await api.dropdown(type: 'sales', type1: 'Sales');

    expect(uris(), ['https://java.test/api/employees/company/6/all?type=SALES']);
  });

  test('port names of the active assignments', () async {
    adapter.replies
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': [
        {'portRefId': 4, 'active': 1}, {'portRefId': 5, 'active': 0}, {'portRefId': 9, 'active': 1},
      ]})))
      ..add((200, jsonEncode([{'id': 4, 'portName': 'WESTPORT'}, {'id': 5, 'portName': 'NORTHPORT'}])));

    expect(await api.portNames(15), ['WESTPORT']);
    expect(uris(), ['https://java.test/api/employee-ports/company/6/employee/15', 'https://java.test/api/port-masters']);
  });

  test('a failure is the server message', () async {
    adapter.replies.add((500, jsonEncode({'status': 500, 'message': 'Database unavailable'})));

    expect(() => api.dropdown(),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Database unavailable')));
  });

  test('Employee Master: search, roles, save and a company-scoped delete', () async {
    adapter.replies
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': {'data1': [
        {'id': 15, 'employeeName': 'ANNA', 'employeeType': 'ADMIN', 'gstNo': 'G1', 'joiningDate': '2026-01-05',
         'roleId': 200, 'active': 1, 'accountCode': 'EMP-3'}
      ], 'data4': 1}})))
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': [{'id': 100, 'customerName': 'SUPERADMIN'}, {'id': 200, 'customerName': 'ADMIN'}]})))
      ..add((200, jsonEncode({'IsSuccess': true, 'Data1': 'ANNA', 'Data2': 15})))
      ..add((204, ''));

    final rows = await api.search();
    expect(adapter.requests.last.data,
        {'comid': 6, 'startindex': 0, 'pageCount': 100, 'keyword': '', 'column': 'All', 'type': ''});
    expect(rows.single['roleId'], 200);

    expect(await api.roles(), [{'id': 100, 'name': 'SUPERADMIN'}, {'id': 200, 'name': 'ADMIN'}]);
    expect(uris().last, 'https://java.test/api/employees/types');

    expect(await api.save({'id': 15, 'employeeName': 'ANNA'}), 15);
    expect(uris().last, 'https://java.test/api/employees/bulk/6');
    expect(adapter.requests.last.data, [{'id': 15, 'employeeName': 'ANNA'}]);

    await api.delete(15);
    expect(adapter.requests.last.method, 'DELETE');
    expect(uris().last, 'https://java.test/api/employees/15?companyRefId=6');
  });
}
