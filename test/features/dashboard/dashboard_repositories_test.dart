import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/dashboard/common_tabs/expensereport/data/expensereport_repository.dart';
import 'package:maleva/features/dashboard/common_tabs/forwardingreport/data/forwardingreport_repository.dart';
import 'package:maleva/features/dashboard/common_tabs/salesorder/data/salesorder_repository.dart';
import 'package:maleva/features/dashboard/common_tabs/unrelease/data/unrelease_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/java_api_client_test.dart' show QueueAdapter;

Map<String, dynamic> ok(Object? data) => {'success': true, 'statusCode': 200, 'message': 'ok', 'data': data};

/// The dashboard repositories read the Java answers (change `dashboard-on-shared-java-api`).
void main() {
  late QueueAdapter adapter;
  late DashboardApi api;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'Comid': 6});
    await AppPreferences.init();
    adapter = QueueAdapter();
    api = DashboardApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter);
  });

  test('sale-order desk: the summary and the employee rows', () async {
    adapter.replies
      ..add((200, jsonEncode(ok({'TodaySales': 2, 'monthlySales': []}))))
      ..add((200, jsonEncode(ok([{'EmployeeName': 'ANNA', 'SalesCount': 1, 'Amount': 10.0}]))));
    final repo = SalesOrderRepository(api: api, comid: () => 6);

    expect((await repo.fetchSalesData(3))['TodaySales'], 2);
    expect(adapter.requests.last.uri.toString(), 'https://java.test/api/dashboard/sales/6?type=3');
    expect(await repo.fetchEmployeeSalesData(33), hasLength(1));
    expect(adapter.requests.last.uri.toString(), 'https://java.test/api/dashboard/employee-sales/6?type=33');
  });

  test('expense report: totals row and breakdown rows', () async {
    adapter.replies.add((200, jsonEncode(ok({
      'TodaySales': 1, 'TodayAmount': 20.0,
      'expenses': [{'ExpenseName': 'FUEL', 'ExpCount': 1, 'ExpAmount': 20.0}],
    }))));

    final result = await ExpenseReportRepository(api: api).getExpenseReport(fromDate: '2026-10-01', toDate: '2026-10-02');

    expect(result!.data1, [{'TodaySales': 1, 'TodayAmount': 20.0}]);
    expect(result.data2, [{'ExpenseName': 'FUEL', 'ExpCount': 1, 'ExpAmount': 20.0}]);
  });

  test('forwarding report: one Java answer feeds both blocks', () async {
    adapter.replies.add((200, jsonEncode(ok({'todayCount': 3, 'k8Count': 1}))));

    final result = await ForwardingReportRepository(api: api).getForwardingReport(fromDate: '2026-10-01', toDate: '2026-10-02');

    expect(result!.data1.single['todayCount'], 3);
    expect(result.data2.single['k8Count'], 1);
  });

  test('unrelease: type 1 reads the K8 numbers', () async {
    adapter.replies
      ..add((200, jsonEncode(ok([{'BillNoDisplay': 'A', 'DayCount': 1}]))))
      ..add((200, jsonEncode(ok([{'BillNoDisplay': 'K8', 'DayCount': 2, 'Remarks': 'x'}]))));
    final repo = UnReleaseRepository(api: api);

    expect((await repo.fetchUnReleaseData(0)).single['BillNoDisplay'], 'A');
    expect(adapter.requests.last.uri.path, '/api/dashboard/unreleased/6');
    expect((await repo.fetchUnReleaseData(1)).single['BillNoDisplay'], 'K8');
    expect(adapter.requests.last.uri.path, '/api/dashboard/k8-unreleased/6');
  });
}
