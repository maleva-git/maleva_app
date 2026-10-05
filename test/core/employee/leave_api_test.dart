import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/employee/leave_api.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/data/leave_request_model.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// Driver / employee leave off .NET LeaveRequestApp (leave-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late LeaveApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = LeaveApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
  });

  RequestOptions last() => adapter.requests.last;

  test('the types and the requests read the Java rows', () async {
    adapter.replies
      ..add((200, jsonEncode(ok([{'id': 3, 'name': 'ANNUAL'}]))))
      ..add((200, jsonEncode(ok([{'id': 12, 'applicantType': 2, 'applicantRefId': 7, 'applicantName': 'RAVI',
        'fromDate': '2026-10-06T00:00:00', 'toDate': '2026-10-07T00:00:00', 'totalDays': 2, 'reason': 'FAMILY',
        'statusRefId': 1, 'statusName': 'PENDING'}]))));

    final type = LeaveTypeModel.fromJava((await api.types()).single);
    expect([type.id, type.name], [3, 'ANNUAL']);
    expect(last().uri.toString(), 'https://java.test/api/leave/types');

    final rows = await api.search(applicantType: 2, applicantRefId: 7, fromDate: '2026-10-01', toDate: '2026-10-31');
    expect(last().uri.toString(), 'https://java.test/api/leave/search');
    expect(last().data, {'companyRefId': 6, 'applicantType': 2, 'applicantRefId': 7,
      'fromDate': '2026-10-01T00:00:00', 'toDate': '2026-10-31T00:00:00'});
    final leave = LeaveRequestModel.fromJava(rows.single);
    expect([leave.id, leave.applicantName, leave.totalDays, leave.statusRefId, leave.fromDate],
        [12, 'RAVI', 2, 1, DateTime(2026, 10, 6)]);
  });

  test('a request is a new pending one for the company', () async {
    adapter.replies.add((200, jsonEncode(ok({'id': 13}))));

    await api.request(applicantType: 2, applicantRefId: 7, leaveTypeRefId: 3, fromDate: DateTime(2026, 10, 6),
        toDate: DateTime(2026, 10, 7), totalDays: 2, reason: 'family', createdBy: 7);

    expect(last().uri.toString(), 'https://java.test/api/leave/save?companyId=6');
    expect(last().data, {'applicantType': 2, 'applicantRefId': 7, 'leaveTypeRefId': 3,
      'fromDate': '2026-10-06T00:00:00', 'toDate': '2026-10-07T00:00:00', 'totalDays': 2, 'reason': 'family',
      'statusRefId': 1, 'createdBy': 7});
  });

  test('approve / reject, and a refusal is the server reason', () async {
    adapter.replies
      ..add((200, jsonEncode(ok({'id': 12}))))
      ..add((403, jsonEncode({'IsSuccess': false, 'StatusCode': 403, 'Message': 'Reviewing leave is for employees'})));

    await api.setStatus(12, statusRefId: 2, reviewedBy: 15, reviewRemark: 'ok');
    expect(last().method, 'PUT');
    expect(last().uri.toString(), 'https://java.test/api/leave/12/status?companyId=6');
    expect(last().data, {'statusRefId': 2, 'reviewedBy': 15, 'reviewRemark': 'ok'});

    expect(() => api.setStatus(12, statusRefId: 3, reviewedBy: 7, reviewRemark: ''),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Reviewing leave is for employees')));
  });
}
