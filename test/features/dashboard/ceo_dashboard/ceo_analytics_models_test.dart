import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/data/ceo_analytics_api.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/data/ceo_analytics_models.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/data/ceo_period.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/data/ceo_super_reports_api.dart';

import 'ceo_fixtures.dart';

/// Answers every request with [status] and [body], and keeps the last request.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.status, this.body);

  final int status;
  final Object body;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    last = options;
    return ResponseBody.fromString(jsonEncode(body), status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('CeoOverview.fromJava', () {
    test('reads the contract names', () {
      final o = CeoOverview.fromJava(overviewJson());
      expect(o.period.previousFromDate, '2026-09-15');
      final r = o.revenue!;
      expect((r.saleOrders.count, r.saleOrders.amount, r.saleOrders.previousAmount), (412, 98450.0, 90100.0));
      expect(r.saleOrders.change!.toStringAsFixed(2), '9.27');
      expect(r.invoices.amount, 55000);
      expect(r.months, hasLength(12));
      expect((r.months.first.label, r.months.first.short, r.months.last.short), ('Nov 2025', 'Nov', 'Oct'));
      expect((r.topCustomers.first.id, r.topCustomers.first.name, r.topCustomers.first.jobs), (12, 'ACME SHIPPING', 30));

      final c = o.cash!;
      expect(c.receivableAgeing.map((b) => b.label), ['Current', '1-30', '31-60', '61-90', '90+']);
      expect(c.receivableAgeing.last.amount, 20000);
      // buckets the server left out read 0, always five in order
      expect(c.payableAgeing.map((b) => b.amount), [50000, 30000, 0, 0, 0]);
      expect((c.paidOutCount, c.paidOutAmount), (120, 64000.0));

      final e = o.expenses!;
      expect((e.count, e.total), (140, 72000.0));
      expect(e.categories[1].key, 'FUEL');
      expect(e.categories[1].count, 5);
      expect(e.running.map((g) => g.name), ['Fuel entries', 'Toll', 'Levi', 'Auto pass']);

      final op = o.operations!;
      expect(op.openJobs, 70);
      expect(op.openJobOrders, 9);
      expect((op.openIncidents, op.unreleasedForwarding, op.unreleasedK8, op.unreleasedTotal), (5, 14, 3, 17));
      expect(o.unavailable, isEmpty);
      expect((op.trucksActive, op.trucksWorkshop, op.trucksSold), (31, 3, 2));

      final p = o.people!;
      expect((p.activeEmployees, p.onLeaveToday, p.topSales.single.name), (86, 4, 'ALI'));
    });

    test('missing fields read 0 and missing sections read null', () {
      final o = CeoOverview.fromJava({
        'revenue': {
          'saleOrders': {'count': '7'},
          'months': [{'month': '2026-10'}],
        },
        'operations': {'saleOrderStatus': [{'key': '6'}]},
      });
      final r = o.revenue!;
      expect((r.saleOrders.count, r.saleOrders.amount, r.saleOrders.change), (7, 0.0, null));
      expect(r.invoices.count, 0);
      expect(r.topCustomers, isEmpty);
      expect((r.months.single.saleOrderAmount, r.months.single.short), (0.0, '2026-10'.substring(0, 3)));
      expect(o.operations!.saleOrderStatus.single.name, '6'); // no name: the key
      expect((o.operations!.openIncidents, o.operations!.trucksActive), (0, 0));
      expect(o.cash, isNull);
      expect(o.expenses, isNull);
      expect(o.people, isNull);
      expect(o.period.fromDate, '');
      // nothing at all
      expect(CeoOverview.fromJava(null).revenue, isNull);
    });

    test('unavailable parts by section', () {
      final o = CeoOverview.fromJava({
        'unavailable': ['cash.payable', 'operations.trucks', 'people', '', null],
      });
      expect(o.unavailable, ['cash.payable', 'operations.trucks', 'people']);
      expect(o.unavailableIn('cash'), ['payable']);
      expect(o.unavailableIn('people'), ['people']);
      expect(o.unavailableIn('revenue'), isEmpty);
    });

    test('details rows', () {
      final d = CeoDetails.fromJava(fuelDetailsJson(rows: 2, count: 140, truncated: true));
      expect((d.kind, d.key, d.count, d.total, d.truncated), ('EXPENSE_CATEGORY', 'FUEL', 140, 4200.0, true));
      expect(d.rows.first.reference, 'PO000001230');
      expect(d.rows.first.subtitle, 'WXY 1230 · INV-770');
      expect(d.rows.first.status, 'PAYMENT COMPLETED');
      final empty = CeoDetails.fromJava({'rows': [{'date': null}]});
      expect((empty.count, empty.truncated, empty.rows.single.amount, empty.rows.single.date), (0, false, 0.0, ''));
    });
  });

  group('CeoAnalyticsApi', () {
    test('reads Data1 (where ApiResponse.success puts it), then Data, then data', () {
      expect(CeoAnalyticsApi.payload({'IsSuccess': true, 'Data': null, 'Data1': 2}), 2);
      expect(CeoAnalyticsApi.payload({'IsSuccess': true, 'Data': 1}), 1);
      expect(CeoAnalyticsApi.payload({'success': true, 'data': 3}), 3);
    });

    test('IsSuccess false throws ApiFailure with the message and status', () {
      expect(
        () => CeoAnalyticsApi.payload({'IsSuccess': false, 'StatusCode': 403, 'Message': 'Only the CEO can open this dashboard'}),
        throwsA(isA<ApiFailure>()
            .having((f) => f.statusCode, 'statusCode', 403)
            .having((f) => f.message, 'message', 'Only the CEO can open this dashboard')),
      );
    });

    test('asks the overview with the dates and reads the answer', () async {
      final adapter = _Adapter(200, {'IsSuccess': true, 'StatusCode': 200, 'Message': 'OK', 'Data': null, 'Data1': overviewJson()});
      final api = CeoAnalyticsApi(Dio()..httpClientAdapter = adapter);
      final o = await api.overview(fromDate: '2026-10-01', toDate: '2026-10-16');
      expect(adapter.last!.path, '/api/ceo-dashboard/analytics/overview');
      expect(adapter.last!.queryParameters, {'fromDate': '2026-10-01', 'toDate': '2026-10-16'});
      expect(o.revenue!.saleOrders.count, 412);
    });

    test('details sends kind and key; a kind without key leaves it out', () async {
      final adapter = _Adapter(200, {'IsSuccess': true, 'Data1': fuelDetailsJson()});
      final api = CeoAnalyticsApi(Dio()..httpClientAdapter = adapter);
      await api.details(kind: 'EXPENSE_CATEGORY', key: 'FUEL', fromDate: '2026-10-01', toDate: '2026-10-16');
      expect(adapter.last!.path, '/api/ceo-dashboard/analytics/details');
      expect(adapter.last!.queryParameters['key'], 'FUEL');
      await api.details(kind: 'LEAVE_TODAY', fromDate: '2026-10-01', toDate: '2026-10-16');
      expect(adapter.last!.queryParameters.containsKey('key'), isFalse);
    });

    test('an employee\'s sale orders send key = id, and key 0 for no employee', () async {
      final adapter = _Adapter(200, {'IsSuccess': true, 'Data1': saleOrdersJson()});
      final api = CeoAnalyticsApi(Dio()..httpClientAdapter = adapter);
      await api.details(kind: 'SALE_ORDERS', key: '7', fromDate: '2026-10-16', toDate: '2026-10-16');
      expect(adapter.last!.queryParameters, {'kind': 'SALE_ORDERS', 'key': '7', 'fromDate': '2026-10-16', 'toDate': '2026-10-16'});
      await api.details(kind: 'SALE_ORDERS', key: '0', fromDate: '2026-10-16', toDate: '2026-10-16');
      expect(adapter.last!.queryParameters['key'], '0');
      await api.details(kind: 'SALE_ORDER_EMPLOYEES', fromDate: '2026-10-16', toDate: '2026-10-16');
      expect(adapter.last!.queryParameters.containsKey('key'), isFalse);
    });

    test('the invoice filter and customer go as parameters; the spend flow is read', () async {
      final adapter = _Adapter(200, {'IsSuccess': true, 'Data1': saleOrdersJson()});
      final api = CeoAnalyticsApi(Dio()..httpClientAdapter = adapter);
      await api.details(
          kind: 'SALE_ORDERS', fromDate: '2026-10-16', toDate: '2026-10-16', invoice: 'WITHOUT', customer: 101);
      expect(adapter.last!.queryParameters,
          {'kind': 'SALE_ORDERS', 'fromDate': '2026-10-16', 'toDate': '2026-10-16', 'invoice': 'WITHOUT', 'customer': 101});

      final spendAdapter = _Adapter(200, {'IsSuccess': true, 'Data1': spendJson()});
      final f = await CeoAnalyticsApi(Dio()..httpClientAdapter = spendAdapter)
          .spend(fromDate: '2026-10-01', toDate: '2026-10-16');
      expect(spendAdapter.last!.path, '/api/ceo-dashboard/analytics/spend');
      expect((f.paid.amount, f.paid.approved, f.paid.waiting), (12700.0, 1700.0, 11000.0));
      expect((f.paidParts.length, f.paidParts.last.isDirect, f.paidDirect), (4, true, 9000.0));
      expect((f.owed.amount, f.monthlyDues.amount, f.stillOwed), (1200.0, 3000.0, 4200.0));
      expect(f.checks.single.key, 'PO_PAID_TWICE');
      expect(CeoSpendFlow.fromJava({}).paidParts, isEmpty);
    });

    test('an HTTP 403 becomes ApiFailure 403 with the server message', () async {
      final api = CeoAnalyticsApi(Dio()
        ..httpClientAdapter =
            _Adapter(403, {'IsSuccess': false, 'StatusCode': 403, 'Message': 'Only the CEO can open this dashboard'}));
      await expectLater(
        api.overview(fromDate: '2026-10-01', toDate: '2026-10-16'),
        throwsA(isA<ApiFailure>().having((f) => f.statusCode, 'statusCode', 403)),
      );
    });
  });

  group('CeoSuperReportsApi (the web Super Admin reports)', () {
    test('forwarding: released = kNWithRelease (an exit reference), not released = kNRelease', () async {
      final adapter = _Adapter(200, {
        'success': true,
        'data': {'k1Count': 10, 'k1Release': 4, 'k1WithRelease': 6, 'k8Count': 3, 'k8Release': 1, 'k8WithRelease': 2},
      });
      final f = await CeoSuperReportsApi(Dio()..httpClientAdapter = adapter)
          .forwarding(6, fromDate: '2026-10-01', toDate: '2026-10-16');
      expect(adapter.last!.path, '/api/dashboard/forwarding/6');
      expect(adapter.last!.queryParameters, {'fromDate': '2026-10-01', 'toDate': '2026-10-16'});
      expect([for (final s in f.stages) s.name], ['K1', 'K2', 'K3', 'K8']);
      expect((f.stages.first.released, f.stages.first.notReleased), (6, 4));
      expect((f.count, f.released, f.notReleased), (13, 8, 5));
    });

    test('leaderboard reads the Java names; the month comes from baseDate', () async {
      final adapter = _Adapter(200, {
        'success': true,
        'data': {
          'totalSales': 9000,
          'period': '2026-10-16',
          'employees': [{'employeeName': 'ALI ', 'currentMonthSales': 6000, 'salesCount': 12}],
        },
      });
      final b = await CeoSuperReportsApi(Dio()..httpClientAdapter = adapter).leaderboard(6, baseDate: '2026-10-16');
      expect(adapter.last!.path, '/api/dashboard/employee-sales-current-month/6');
      expect(adapter.last!.queryParameters, {'baseDate': '2026-10-16'});
      expect((b.total, b.employees.single.name, b.employees.single.sales), (9000.0, 'ALI', 12));
    });

    test('driver salary posts the days; the server 404 "No records found" is an empty list', () async {
      final ok = _Adapter(200, {
        'IsSuccess': true,
        'Data1': [{'driverName': 'RAJ', 'salary': 100, 'amount': 300, 'exitAmount': 5}],
      });
      final rows = await CeoSuperReportsApi(Dio()..httpClientAdapter = ok)
          .driverSalary(6, fromDate: '2026-10-01', toDate: '2026-10-16');
      expect(ok.last!.path, '/api/rti/driver-report');
      expect(ok.last!.method, 'POST');
      expect(ok.last!.data, {'comid': 6, 'driverId': 0, 'truckId': 0, 'fromDate': '2026-10-01', 'toDate': '2026-10-16'});
      expect((rows.single.driverName, rows.single.amount, rows.single.emptyPickup), ('RAJ', 300.0, 5.0));

      final empty = _Adapter(404, {'IsSuccess': false, 'StatusCode': 404, 'Message': 'No records found'});
      expect(await CeoSuperReportsApi(Dio()..httpClientAdapter = empty)
          .driverSalary(6, fromDate: '2026-10-01', toDate: '2026-10-16'), isEmpty);
    });

    test('drivers are grouped with their totals, most RTIs first', () {
      final d = CeoDriverSalary.group([
        CeoRtiRow.fromJava({'driverName': 'MUTHU', 'amount': 200}),
        CeoRtiRow.fromJava({'driverName': 'RAJ', 'salary': 100, 'amount': 300}),
        CeoRtiRow.fromJava({'driverName': 'RAJ', 'salary': 80, 'amount': 0}),
      ]);
      expect([for (final x in d) x.driverName], ['RAJ', 'MUTHU']);
      expect((d.first.rtis, d.first.zeroRtis, d.first.salary, d.first.amount), (2, 1, 180.0, 300.0));
    });
  });

  group('CeoPeriod', () {
    final today = DateTime(2026, 10, 16, 15, 30);
    test('ranges from today', () {
      expect(CeoPeriod.thisMonth.range(today), ('2026-10-01', '2026-10-16'));
      expect(CeoPeriod.lastMonth.range(today), ('2026-09-01', '2026-09-30'));
      expect(CeoPeriod.thisQuarter.range(today), ('2026-10-01', '2026-10-16'));
      expect(CeoPeriod.thisYear.range(today), ('2026-01-01', '2026-10-16'));
      expect(CeoPeriod.lastMonth.range(DateTime(2026, 1, 5)), ('2025-12-01', '2025-12-31'));
      expect(CeoPeriod.thisQuarter.range(DateTime(2026, 5, 20)), ('2026-04-01', '2026-05-20'));
    });
  });
}
