import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/lookups/customer_api.dart';
import 'package:maleva/core/lookups/job_type_api.dart';
import 'package:maleva/core/models/shared/customer_model.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/operations/models/job_type_model.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

/// Customer and job type pickers read the shared Java APIs directly
/// (lookups-on-shared-java-api), not through the old .NET-shaped adapter (now removed).
void main() {
  late QueueAdapter adapter;
  late Dio dio;

  setUp(() {
    adapter = QueueAdapter();
    dio = Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter;
  });

  test('customers are the options with their label', () async {
    adapter.replies.add((200, jsonEncode({'success': true, 'statusCode': 200, 'message': '1 customer(s)', 'data': [
      {'id': 4, 'customerName': 'ACME', 'companyCode': 'C01', 'label': 'ACME-C01'},
    ]})));

    final rows = await CustomerApi(dio, companyId: () => 6).options();

    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/customers/options?companyId=6');
    final customer = CustomerModel.fromJava(rows.single);
    expect([customer.Id, customer.AccountName], [4, 'ACME-C01']);
  });

  test('job types; a company with none (404) is an empty list', () async {
    adapter.replies
      ..add((200, jsonEncode({'success': true, 'statusCode': 200, 'message': 'ok', 'data': [
        {'id': 2, 'name': 'TRANSPORT', 'dfLag': 1, 'active': 1},
      ]})))
      ..add((404, jsonEncode({'success': false, 'statusCode': 404, 'message': 'No job types found'})));
    final api = JobTypeApi(dio, companyId: () => 6);

    final type = JobTypeModel.fromJava((await api.jobTypes()).single);
    expect(adapter.requests.first.uri.toString(), 'https://java.test/api/job-type-master/jobtypes/6');
    expect([type.Id, type.Name, type.DFlag, type.Active], [2, 'TRANSPORT', 1, 1]);
    expect(await api.jobTypes(), isEmpty);
  });

  test('another refusal is the server message', () async {
    adapter.replies.add((500, jsonEncode({'success': false, 'statusCode': 500, 'message': 'Database unavailable'})));

    expect(() => CustomerApi(dio, companyId: () => 6).options(),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Database unavailable')));
  });
}
