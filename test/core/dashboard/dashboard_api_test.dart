import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/network/api_failure.dart';

import '../network/java_api_client_test.dart' show QueueAdapter;

/// Answers by request, for calls sent in parallel.
class RouteAdapter implements HttpClientAdapter {
  RouteAdapter(this.answer);

  final (int, Object) Function(RequestOptions options) answer;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream, Future<void>? cancelFuture) async {
    requests.add(options);
    final (status, body) = answer(options);
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> ok(Object? data) => {'success': true, 'statusCode': 200, 'message': 'ok', 'data': data};

void main() {
  late QueueAdapter adapter;
  late DashboardApi api;

  setUp(() {
    adapter = QueueAdapter();
    api = DashboardApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter);
  });

  String uri() => adapter.requests.last.uri.toString();

  test('sales answers the Java data as it is', () async {
    final data = {
      'TodaySales': 2, 'TodayAmount': 150.5, 'MonthSales': 9, 'MonthAmount': 900.0,
      'monthlySales': [{'SalesCount': 9, 'SalesAmount': 900.0, 'MonthName': 'Oct 2026'}],
    };
    adapter.replies.add((200, jsonEncode(ok(data))));

    expect(await api.sales(6, 2), data);
    expect(uri(), 'https://java.test/api/dashboard/sales/6?type=2');
    expect(adapter.requests.last.method, 'GET');
  });

  test('employee rows, unreleased numbers and rules are lists of the Java rows', () async {
    adapter.replies
      ..add((200, jsonEncode(ok([{'EmployeeName': 'ANNA', 'SalesCount': 3, 'Amount': 300.0}]))))
      ..add((200, jsonEncode(ok([{'EmployeeName': 'ANNA', 'SalesCount': 1, 'Amount': 90.0}]))))
      ..add((200, jsonEncode(ok([{'Id': 1, 'BillNoDisplay': 'K1-001', 'DayCount': 4, 'Remarks': ''}]))))
      ..add((200, jsonEncode(ok([]))))
      ..add((200, jsonEncode(ok([{'Id': 41, 'AccountName': 'ANNA'}]))));

    expect(await api.employeeSales(6, 18), [{'EmployeeName': 'ANNA', 'SalesCount': 3, 'Amount': 300.0}]);
    expect(uri(), 'https://java.test/api/dashboard/employee-sales/6?type=18');
    expect((await api.employeeInvoices(6, 3)).single['Amount'], 90.0);
    expect(uri(), 'https://java.test/api/dashboard/employee-invoice/6?type=3');
    expect((await api.unreleased(6)).single['BillNoDisplay'], 'K1-001');
    expect(uri(), 'https://java.test/api/dashboard/unreleased/6');
    expect(await api.k8Unreleased(6), isEmpty);
    expect(uri(), 'https://java.test/api/dashboard/k8-unreleased/6');
    expect(await api.employeeRules(6, 41), [{'Id': 41, 'AccountName': 'ANNA'}]);
    expect(uri(), 'https://java.test/api/dashboard/employee-rules/6?employeeId=41');
  });

  test('expenses and forwarding send the date range', () async {
    adapter.replies
      ..add((200, jsonEncode(ok({'TodaySales': 1, 'expenses': [{'ExpenseName': 'FUEL', 'ExpCount': 2, 'ExpAmount': 80.0}]}))))
      ..add((200, jsonEncode(ok({'todayCount': 5, 'k1Count': 2}))));

    expect((await api.expenses(6, '2026-10-01', '2026-10-02'))['expenses'], hasLength(1));
    expect(uri(), 'https://java.test/api/dashboard/expense/6?fromDate=2026-10-01&toDate=2026-10-02');
    expect(await api.forwarding(6, '2026-10-01', '2026-10-02'), {'todayCount': 5, 'k1Count': 2});
    expect(uri(), 'https://java.test/api/dashboard/forwarding/6?fromDate=2026-10-01&toDate=2026-10-02');
  });

  test('air freight posts the Java search model (flight time) and answers camelCase rows', () async {
    adapter.replies.add((200, jsonEncode(ok([{'id': 9, 'jobNo': 'AF-9', 'port': 'KUL', 'setb': ''}]))));

    final rows = await api.airFreight(6, fromDate: '2026-10-01', toDate: '2026-10-02', search: 'KUL', statusId: 3);

    expect(rows.single['jobNo'], 'AF-9');
    expect(uri(), 'https://java.test/api/dashboard/air-freight/6');
    expect(adapter.requests.last.data, {
      'comId': 6, 'employeeId': 0, 'etaType': 5, 'fromDate': '2026-10-01', 'toDate': '2026-10-02',
      'search': 'KUL', 'statusId': 3,
    });
  });

  test('a refusal is an ApiFailure with the server message', () async {
    adapter.replies.add((400, jsonEncode({'success': false, 'statusCode': 400, 'message': 'Invalid company ID'})));

    expect(() => api.sales(0, 1),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Invalid company ID')));
  });

  test('success false in a 200 answer is a failure too', () async {
    adapter.replies.add((200, jsonEncode({'success': false, 'message': 'Failed to fetch sales data'})));

    expect(() => api.sales(6, 1), throwsA(isA<ApiFailure>()));
  });

  test('the sales desk counts four invoice checks and lists the statuses', () async {
    final routes = RouteAdapter((o) {
      if (o.path.endsWith('/sales-order-status/6')) {
        return (200, ok([{'Id': 1, 'JobStatus': 'OPEN', 'DayCount': 2}]));
      }
      final body = o.data as Map;
      final rows = switch ((body['fromDate'], body['remarks'])) {
        ('2024-10-01', 2) => 5,
        ('2026-10-01', 0) => 4,
        ('2026-10-01', 1) => 3,
        ('2026-10-01', 2) => 1,
        _ => 0,
      };
      return (200, ok(List.generate(rows, (i) => {'id': i})));
    });
    api = DashboardApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = routes);

    final desk = await api.salesDesk(6, 41, today: DateTime(2026, 10, 2));

    expect([desk.withoutInvoice, desk.total, desk.billed, desk.unbilled], [5, 4, 3, 1]);
    expect(desk.statuses, [{'Id': 1, 'JobStatus': 'OPEN', 'DayCount': 2}]);
    final check = routes.requests.firstWhere((r) => r.path.endsWith('/check-invoice-count/6'));
    expect(check.data, containsPair('employeeId', 41));
    expect(check.data, containsPair('toDate', '2026-10-02'));
    expect(check.data, containsPair('invoice', false));
    expect(routes.requests.map((r) => r.uri.toString()),
        contains('https://java.test/api/dashboard/sales-order-status/6?employeeId=41'));
  });

  test('maintenance, top customers and vessel planning', () async {
    adapter.replies
      ..add((200, jsonEncode(ok([{'Description': 'REPAIR', 'PStatus': 2, 'Amount': 300.0}]))))
      ..add((200, jsonEncode(ok([{'Description': 'FUEL', 'Amount': 90.0}]))))
      ..add((200, jsonEncode(ok([{'Id': 1, 'SupplierName': 'ACME', 'PStatus': 2}]))))
      ..add((200, jsonEncode(ok([{'CustomerName': 'ACME', 'Revenue': 10.0, 'Volume': 1}]))))
      ..add((200, jsonEncode(ok([{'id': 9, 'port': 'PKG', 'lBoardingOfficerRefId': 4}]))));

    expect((await api.maintenanceStatus(6, '2026-10-01', '2026-10-02')).single['PStatus'], 2);
    expect(uri(), 'https://java.test/api/dashboard/maintenance-status/6?fromDate=2026-10-01&toDate=2026-10-02');
    expect((await api.runningExpenses(6, '2025-10-02', '2026-10-02')).single['Description'], 'FUEL');
    expect(uri(), 'https://java.test/api/dashboard/running-expenses/6?fromDate=2025-10-02&toDate=2026-10-02');
    expect((await api.supplierExpenses(6)).single['SupplierName'], 'ACME');
    expect(uri(), 'https://java.test/api/dashboard/supplier-expense/6');
    expect((await api.topCustomers(6, fromDate: '2026-09-01', toDate: '2026-10-01', filterType: 'RM')).single['Volume'], 1);
    expect(uri(), 'https://java.test/api/dashboard/top-customers/6?fromDate=2026-09-01&toDate=2026-10-01&filterType=RM');
    final vessels = await api.vesselPlanning(6, fromDate: '2024-10-01', toDate: '2026-10-02', search: 'PKG');
    expect(vessels.single['lBoardingOfficerRefId'], 4);
    expect(adapter.requests.last.data, containsPair('search', 'PKG'));
  });

  test('transport list: today is the pickups, tomorrow the planning list', () async {
    adapter.replies
      ..add((200, jsonEncode(ok([{'Id': 1, 'CustomerName': 'A'}]))))
      ..add((200, jsonEncode([{'Id': 2, 'CustomerName': 'B'}])));

    expect((await api.transportList(6, 0, today: DateTime(2026, 10, 2))).single['Id'], 1);
    expect(uri(), 'https://java.test/api/dashboard/planing-search');
    expect(adapter.requests.last.data, containsPair('fromdate', '2026-10-02'));
    expect((await api.transportList(6, 1, today: DateTime(2026, 10, 2))).single['Id'], 2);
    expect(uri(), 'https://java.test/api/planing/search');
    expect(adapter.requests.last.data, containsPair('todate', '2026-10-03'));
  });

  test('waiting invoices read the common wrapper', () async {
    adapter.replies.add((200, jsonEncode({'IsSuccess': true, 'Message': 'ok', 'Data1': [{'billNo': 7}]})));

    expect((await api.waitingInvoices(6)).single['billNo'], 7);
    expect(uri(), 'https://java.test/api/sale-orders/check-invoice');
    expect(adapter.requests.last.data, containsPair('invoice', true));
  });
}
