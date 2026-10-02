import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/planning/planning_api.dart';
import 'package:maleva/core/planning/vessel_planning_api.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

/// The shared Java planning and vessel planning APIs, read as they answer
/// (change planning-on-shared-java-api).
void main() {
  late QueueAdapter adapter;
  late PlanningApi planning;
  late VesselPlanningApi vessels;

  setUp(() {
    adapter = QueueAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter;
    planning = PlanningApi(dio, companyId: () => 6);
    vessels = VesselPlanningApi(dio, companyId: () => 6);
  });

  RequestOptions last() => adapter.requests.last;
  String uri() => last().uri.toString();

  group('planning', () {
    test('next number, list, edit and the jobs search', () async {
      adapter.replies
        ..add((200, jsonEncode({'sequenceNumber': 'PL000000124', 'companyId': 6, 'success': true})))
        ..add((200, jsonEncode({
              'salemaster': [{'Id': 70, 'PLANINGNoDisplay': 'PL000000070', 'PLANINGDate': '02/10/2026'}],
              'saledetails': [{'PLANINGMasterRefId': 70, 'JobNo': 'TR00040', 'PickupDateD': '2026-10-02 08:00'}],
            })))
        ..add((200, jsonEncode({'Id': 70, 'CNumberDisplay': 'PL000000070', 'SaleDetails': [{'SaleOrderMasterRefId': 40}]})))
        ..add((200, jsonEncode([{'Id': 40, 'JobNo': 'TR00040', 'SaleOrderMasterRefId': 0}])));

      expect(await planning.nextNumber(), 'PL000000124');
      expect(uri(), 'https://java.test/api/planing/max-planning-no/6');

      final plans = await planning.list(from: DateTime(2026, 10, 1), to: DateTime(2026, 10, 2), search: ' PL000000070 ');
      expect(uri(), 'https://java.test/api/planing/select-planning');
      expect(last().data, {'comid': 6, 'employeeid': 0, 'search': 'PL000000070', 'fromdate': '2026-10-01', 'todate': '2026-10-02'});
      expect(plans.masters.single['PLANINGNoDisplay'], 'PL000000070');
      expect(plans.details.single['PickupDateD'], '2026-10-02 08:00');

      expect(((await planning.edit(70))['SaleDetails'] as List).single['SaleOrderMasterRefId'], 40);
      expect(uri(), 'https://java.test/api/planing/edit?id=70&companyId=6');

      expect((await planning.searchJobs(from: DateTime(2026, 10, 2), to: DateTime(2026, 10, 2), ports: 'PKG')).single['Id'], 40);
      expect(last().data, {'comid': 6, 'search': 'PKG', 'employeeid': '', 'fromdate': '2026-10-02', 'todate': '2026-10-02'});
    });

    test('save sends one plan with the company header; a refused item is the server message', () async {
      adapter.replies
        ..add((200, jsonEncode([{'ok': true, 'message': 'Saved', 'name': 'PL000000071', 'id': 71}])))
        ..add((200, jsonEncode([{'ok': false, 'message': 'Employee Not Found, id: 9'}])));

      expect((await planning.save({'id': 0}))['name'], 'PL000000071');
      expect(uri(), 'https://java.test/api/planing/save');
      expect(last().headers['Comid'], '6');
      expect(last().data, [{'id': 0}]);

      expect(() => planning.save({'id': 0}),
          throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Employee Not Found, id: 9')));
    });

    test('delete, and a plan that is not found', () async {
      adapter.replies
        ..add((200, jsonEncode({'ok': true, 'message': 'Planning deleted successfully', 'id': 70})))
        ..add((200, jsonEncode({'ok': false, 'message': 'Planning not found with id: 71'})));

      await planning.delete(70);
      expect(last().method, 'DELETE');
      expect(uri(), 'https://java.test/api/planing/70?companyId=6');
      expect(() => planning.delete(71), throwsA(isA<ApiFailure>()));
    });

    test('the report is a ticket path', () async {
      adapter.replies.add((200, jsonEncode({'IsSuccess': true, 'StatusCode': 200, 'Data1': {'Url': '/api/planning/reports/pdf/t1/PL000000070.pdf'}})));

      expect(await planning.reportPath(70, reportDate: DateTime(2026, 10, 2)), '/api/planning/reports/pdf/t1/PL000000070.pdf');
      expect(uri(), 'https://java.test/api/planning/reports/70/pdf-ticket?companyId=6&reportDate=2026-10-02');
    });
  });

  group('vessel planning', () {
    test('search sends the web filter', () async {
      adapter.replies.add((200, jsonEncode([{'Id': 40, 'SaleOrderMasterRefId': 40, 'LBoardingOfficerRefid': 11}])));

      final rows = await vessels.searchJobs(from: DateTime(2026, 10, 1), to: DateTime(2026, 10, 3), etaType: 2, ports: 'PKG,PGU');

      expect(uri(), 'https://java.test/api/vessel-plannings/search');
      expect(last().data, {
        'comid': 6,
        'search': 'PKG,PGU',
        'employeeid': 0,
        'fromdate': '2026-10-01',
        'todate': '2026-10-03',
        'etaType': 2,
        'DeliveryDone': true,
      });
      expect(rows.single['LBoardingOfficerRefid'], 11);
    });

    test('save sends the jobs in order with slash dates', () async {
      adapter.replies.add((200, jsonEncode([{'ok': true, 'message': 'Saved', 'name': 'VPL000000046', 'id': 46}])));

      final saved = await vessels.save(
          id: 0, from: DateTime(2026, 10, 1), to: DateTime(2026, 10, 3), planDate: DateTime(2026, 10, 2),
          saleOrderIds: [41, 40], remarks: 'R', employeeId: 7);

      expect(saved['id'], 46);
      expect(last().headers['Comid'], '6');
      final plan = (last().data as List).single as Map;
      expect(plan['FDate'], '2026/10/01');
      expect(plan['TDate'], '2026/10/03');
      expect(plan['SaleDate'], '2026/10/02');
      expect(plan['EmployeeRefId'], 7);
      expect(plan['SaleDetails'], [{'SaleOrderMasterRefId': 41}, {'SaleOrderMasterRefId': 40}]);
    });

    test('number, list, edit, delete and report', () async {
      adapter.replies
        ..add((200, jsonEncode({'sequenceNumber': 'VPL000000046'})))
        ..add((200, jsonEncode({'salemaster': [{'Id': 45}], 'saledetails': [{'VESSELPLANINGMasterRefId': 45}]})))
        ..add((200, jsonEncode({'Id': 45, 'SaleDetails': []})))
        ..add((200, jsonEncode({'ok': true, 'id': 45})))
        ..add((200, jsonEncode({'IsSuccess': true, 'Data1': {'Url': '/api/vessel-plannings/report/t1/VPL000000045.pdf'}})));

      expect(await vessels.nextNumber(), 'VPL000000046');
      expect(uri(), 'https://java.test/api/vessel-plannings/max-vessel-planning-no/6');
      expect((await vessels.list(from: DateTime(2026, 10, 1), to: DateTime(2026, 10, 2))).details.single['VESSELPLANINGMasterRefId'], 45);
      expect((await vessels.edit(45))['Id'], 45);
      expect(uri(), 'https://java.test/api/vessel-plannings/edit?id=45&companyId=6');
      await vessels.delete(45);
      expect(uri(), 'https://java.test/api/vessel-plannings/45?companyId=6');
      expect(await vessels.reportPath(45), '/api/vessel-plannings/report/t1/VPL000000045.pdf');
      expect(uri(), 'https://java.test/api/vessel-plannings/45/report-ticket?companyId=6');
    });
  });
}
