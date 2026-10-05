import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/lookups/job_status_api.dart';
import 'package:maleva/features/operations/models/job_status_model.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

/// Job statuses and job-type steps read the shared Java APIs directly
/// (job-status-lookups-on-shared-java-api), not through the old .NET-shaped adapter (now removed).
void main() {
  late QueueAdapter adapter;
  late JobStatusApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = JobStatusApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  test("the company's statuses; none (404) is an empty list", () async {
    adapter.replies
      ..add((200, jsonEncode({'success': true, 'statusCode': 200, 'message': 'ok', 'data': [
        {'id': 4, 'name': 'IN WAREHOUSE', 'svalue': 2, 'dflag': 1, 'active': 1},
      ]})))
      ..add((404, jsonEncode({'success': false, 'statusCode': 404, 'message': 'No Job Statuses Found'})));

    final status = JobStatusModel.fromJava((await api.statuses()).single);
    expect(adapter.requests.first.uri.toString(), 'https://java.test/api/job-status-master/select/6/');
    expect([status.Id, status.Name, status.Svalue, status.DFlag, status.Active], [4, 'IN WAREHOUSE', 2, 1, 1]);
    expect(await api.statuses(), isEmpty);
  });

  test("a job type's steps and status order are typed, and name a status", () async {
    adapter.replies.add((200, jsonEncode({'IsSuccess': true, 'StatusCode': 200, 'Message': 'ok', 'Data1': [
      {
        'jobTypeDetails': [{'id': 1, 'jobMasterRefId': 2, 'description': 'OFF VESSEL NAME', 'status': 3, 'mandatory': 1}],
        'jobStatusDetails': [{'id': 9, 'jobMasterRefId': 2, 'status': 3, 'statusName': 'ARRIVED', 'minStatus': 1, 'sort': 1}],
      }
    ]})));

    final steps = await api.steps(2);

    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.uri.toString(), 'https://java.test/api/job-type-master/select-all-data?companyId=6&jobId=2');
    expect([steps.details.single.Description, steps.details.single.Mandatory], ['OFF VESSEL NAME', 1]);
    expect([steps.statuses.single.Status, steps.statuses.single.StatusName, steps.statuses.single.MinStatus], [3, 'ARRIVED', 1]);
    expect(steps.statusName(3), 'ARRIVED');
    expect(steps.statusName(4), '');
  });

  test('no job type asks nothing; a job type with none (404) is empty', () async {
    expect((await api.steps(0)).statuses, isEmpty);
    expect(adapter.requests, isEmpty);

    adapter.replies.add((404, jsonEncode({'IsSuccess': false, 'StatusCode': 404, 'Message': 'none'})));
    final steps = await api.steps(2);
    expect([steps.details, steps.statuses], [isEmpty, isEmpty]);
  });
}
