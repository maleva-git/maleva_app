import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/rti/rti_api.dart';
import 'package:maleva/features/dashboard/forwarding_agent_dashboard/models/rti_route_activity.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'Success', 'Data1': data};

/// The shared Java RTI APIs, read as they answer (change rti-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late RtiApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = RtiApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter,
        companyId: () => 6, javaBaseUrl: 'https://java.test');
  });

  RequestOptions last() => adapter.requests.last;

  test('the RTI list sends the filters and maps masters and their jobs', () async {
    adapter.replies.add((200, jsonEncode(ok([
      {
        'id': 5, 'rtiNo': 12, 'rtiNoDisplay': 'RTI000012', 'rtiDate': '2026-10-01', 'driverRefId': 7,
        'driverName': 'RAVI', 'truckRefId': 3, 'truckName': 'VBC 5521', 'remarks': 'night run', 'amount': 150.0,
        'jobs': [
          {'id': 50, 'rtiMasterRefId': 5, 'saleOrderMasterRefId': 40, 'salary': 80, 'ppic': 'P', 'dpic': 'D',
           'jobNo': 'MY000040', 'jobDate': '2026-09-30', 'customerMasterRefId': 9, 'customerName': 'ACME'}
        ],
      }
    ]))));

    final list = await api.withJobs(fromDate: '2026-10-01', toDate: '2026-10-05', driverId: 7, search: '');

    expect(last().uri.toString(),
        'https://java.test/api/rti-masters/with-jobs?companyId=6&fromDate=2026-10-01&toDate=2026-10-05&driverId=7');
    final m = list.masters.single;
    expect([m.Id, m.RTINo, m.RTINoDisplay, m.RTIDate, m.DriverName, m.TruckName, m.TruckMasterRefId, m.Amount],
        [5, 12, 'RTI000012', '01/10/2026', 'RAVI', 'VBC 5521', 3, 150.0]);
    final d = list.details.single;
    expect([d.Id, d.RTIMasterRefId, d.SaleOrderMasterRefId, d.JobNo, d.JobDate, d.CustomerName, d.Salary, d.PPIC],
        [50, 5, 40, 'MY000040', '30/09/2026', 'ACME', 80.0, 'P']);
  });

  test('a searched RTI number is sent alone', () async {
    adapter.replies.add((200, jsonEncode(ok([]))));

    await api.withJobs(search: ' RTI000012 ');

    expect(last().uri.toString(), 'https://java.test/api/rti-masters/with-jobs?companyId=6&search=RTI000012');
  });

  test('the report link is the full Java URL', () async {
    adapter.replies.add((200, jsonEncode(ok({'Ticket': 't1', 'FileName': 'RTI000012.pdf',
      'Url': '/api/rti-masters/report/t1/RTI000012.pdf'}))));

    expect(await api.reportUrl(5), 'https://java.test/api/rti-masters/report/t1/RTI000012.pdf');
    expect(last().uri.toString(), 'https://java.test/api/rti-masters/5/report-ticket?companyId=6');
  });

  test('RTI numbers for the job pickers', () async {
    adapter.replies.add((200, jsonEncode([{'id': 5, 'cnumberDisplay': 'RTI000012'}, {'id': 6, 'cNumberDisplay': 'RTI000013'}])));

    expect(await api.numbers(), [{'CNumber': 'RTI000012', 'Id': 5}, {'CNumber': 'RTI000013', 'Id': 6}]);
    expect(last().uri.toString(), 'https://java.test/api/rti-masters/company/6');
  });

  test('a job status sends the status and photos; a refusal is the server message', () async {
    adapter.replies
      ..add((200, jsonEncode(ok(40))))
      ..add((404, jsonEncode({'status': 404, 'message': 'Sale order 41 was not found'})));

    await api.updateJobStatus(40, 'PICKUP Done', ['https://x/a.jpg']);
    expect(last().method, 'POST');
    expect(last().uri.toString(), 'https://java.test/api/rti-masters/jobs/40/status?companyId=6');
    expect(last().data, {'statusName': 'PICKUP Done', 'imageUrls': ['https://x/a.jpg']});

    expect(() => api.updateJobStatus(41, 'PICKUP Done', []),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Sale order 41 was not found')));
  });

  test('route stops are listed for the employee and their status set', () async {
    adapter.replies
      ..add((200, jsonEncode(ok([
        {'id': 3, 'rtiMasterRefId': 5, 'status': 0, 'lorryNo': 'VBC 5521', 'driverName': 'RAVI', 'driverNumber': '6012',
         'contact': '6019', 'eta': '2026-10-02T10:00:00', 'jobType': 'PICKUP', 'port': 'WESTPORT', 'remarks': 'gate 2',
         'fullRoute': 'A > B', 'marqisStatus': 1}
      ]))))
      ..add((200, jsonEncode(ok(3))));

    final rows = await api.routeActivities(fromDate: '2026-10-01', toDate: '2026-10-05', employeeId: 15);
    expect(last().uri.toString(),
        'https://java.test/api/rti-route-activities?companyRefId=6&fromDate=2026-10-01&toDate=2026-10-05&employeeRefId=15');
    final a = RtiRouteActivity.fromJava(rows.single);
    expect([a.id, a.status, a.locationName, a.activityType, a.eta, a.driverNumber, a.fullRoute, a.marqisStatus],
        [3, 0, 'WESTPORT', 'PICKUP', '2026-10-02T10:00:00', '6012', 'A > B', 1]);

    await api.setRouteActivityStatus(3, 1);
    expect(last().method, 'PUT');
    expect(last().uri.toString(), 'https://java.test/api/rti-route-activities/3/status?companyRefId=6&status=1');
  });

  test('PDO statuses go as multipart: the JSON list and a photo per line', () async {
    final dir = await Directory.systemTemp.createTemp('pdo');
    final photo = File('${dir.path}/a.jpg')..writeAsBytesSync([1, 2, 3]);
    adapter.replies.add((200, jsonEncode(ok(61))));

    expect(await api.saveStatuses([{'id': 0, 'rtiMasterRefId': 5, 'rtiDetailsRefId': 50, 'verify': 1}], photos: {50: photo}), 61);

    expect(last().uri.toString(), 'https://java.test/api/rti-masters/job-statuses?companyId=6');
    final form = last().data as FormData;
    expect(form.files.map((f) => f.key), ['statuses', 'photo_50']);
    await dir.delete(recursive: true);
  });

  test('a job line reads its latest status', () async {
    adapter.replies.add((200, jsonEncode(ok([
      {'id': 5, 'rtiNoDisplay': 'RTI1', 'jobs': [
        {'id': 50, 'rtiMasterRefId': 5, 'saleOrderMasterRefId': 40, 'statusId': 61, 'active': 1, 'verify': 0,
         'imagePath': '/Upload/6/RTIDetails/50/a.jpg'}
      ]}
    ]))));

    final d = (await api.withJobs(fromDate: '2026-10-01', toDate: '2026-10-05')).details.single;
    expect([d.StatusId, d.isChecked, d.isVerified, d.imagePath], [61, true, false, '/Upload/6/RTIDetails/50/a.jpg']);
  });
}
