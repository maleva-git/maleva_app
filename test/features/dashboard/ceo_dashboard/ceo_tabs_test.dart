import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/data/ceo_analytics_api.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/data/ceo_analytics_models.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/data/ceo_super_reports_api.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/view/ceo_dashboard_page.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/view/ceo_details_sheet.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/local_fonts.dart';
import 'ceo_fixtures.dart';

class _Api extends Mock implements CeoAnalyticsApi {}

class _Reports extends Mock implements CeoSuperReportsApi {}

final _now = DateTime(2026, 10, 16, 9, 30);

/// The CEO screen's tabs (app tabs 2026-10-17): Sale Orders, Invoices, Expenses money flow, the Super Admin
/// tabs after the CEO ones, and All reports.
void main() {
  setUpAll(installLocalTestFonts);

  late _Api api;
  late _Reports reports;

  /// Answers [kind] with or without the invoice / customer parameters.
  void answer(String kind, Map<String, dynamic> json) {
    when(() => api.details(
          kind: kind,
          key: any(named: 'key'),
          fromDate: any(named: 'fromDate'),
          toDate: any(named: 'toDate'),
        )).thenAnswer((_) async => CeoDetails.fromJava(json));
    when(() => api.details(
          kind: kind,
          key: any(named: 'key'),
          fromDate: any(named: 'fromDate'),
          toDate: any(named: 'toDate'),
          invoice: any(named: 'invoice'),
          customer: any(named: 'customer'),
        )).thenAnswer((_) async => CeoDetails.fromJava(json));
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({'Username': 'CEO'});
    AppGlobals.storagenew = await SharedPreferences.getInstance();
    api = _Api();
    reports = _Reports();
    when(() => reports.forwarding(any(), fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate')))
        .thenAnswer((_) async => CeoForwarding.fromJava({
              'k1Count': 10, 'k1Release': 4, 'k1WithRelease': 6,
              'k2Count': 5, 'k2Release': 5, 'k2WithRelease': 0,
              'k3Count': 0, 'k3Release': 0, 'k3WithRelease': 0,
              'k8Count': 3, 'k8Release': 1, 'k8WithRelease': 2,
            }));
    when(() => reports.leaderboard(any(), baseDate: any(named: 'baseDate'))).thenAnswer((_) async => CeoLeaderboard.fromJava({
          'totalSales': 9000,
          'period': '2026-10-16',
          'employees': [
            {'employeeName': 'ALI', 'currentMonthSales': 6000, 'salesCount': 12},
            {'employeeName': 'SITI', 'currentMonthSales': 3000, 'salesCount': 5},
          ],
        }));
    when(() => reports.driverSalary(any(), fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate')))
        .thenAnswer((_) async => [
              for (final m in [
                {'driverName': 'RAJ', 'salary': 100, 'pickupAmount': 50, 'amount': 300},
                {'driverName': 'RAJ', 'salary': 80, 'amount': 0},
                {'driverName': 'MUTHU', 'salary': 60, 'dropAmount': 20, 'amount': 200},
              ])
                CeoRtiRow.fromJava(m),
            ]);
    when(() => api.overview(fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate')))
        .thenAnswer((_) async => CeoOverview.fromJava(overviewJson()));
    when(() => api.spend(fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate')))
        .thenAnswer((_) async => CeoSpendFlow.fromJava(spendJson()));
    answer('EXPENSE_CATEGORY', fuelDetailsJson());
    answer('SALE_ORDERS', saleOrdersJson(count: 12, total: 98765.40));
    answer('SALE_ORDER_EMPLOYEES', saleOrderEmployeesJson());
    answer('CUSTOMERS', customersJson());
    answer('INVOICES', saleOrdersJson(count: 4, total: 5000));
    answer('INVOICE_EMPLOYEES', breakdownJson('INVOICE_EMPLOYEES', [(7, 'ALI', 3, 4000)], noun: 'invoices'));
    answer('INVOICE_CUSTOMERS', breakdownJson('INVOICE_CUSTOMERS', [(101, 'ACME', 4, 5000)], noun: 'invoices'));
    answer('SPEND_PART', fuelDetailsJson());
    answer('RECEIVABLE_CUSTOMERS', {
      ...breakdownJson('RECEIVABLE_CUSTOMERS', [(12, 'ACME', 3, 7000), (13, 'BETA', 1, 2000)], noun: 'invoices'),
      'rows': [
        {'id': 12, 'reference': '1', 'title': 'ACME', 'subtitle': '3 invoices · oldest 120 days', 'amount': 7000, 'status': 'OVER 90 DAYS'},
        {'id': 13, 'reference': '2', 'title': 'BETA', 'subtitle': '1 invoice · oldest 5 days', 'amount': 2000, 'status': '1-30 DAYS'},
      ],
    });
    answer('RECEIVABLE_CUSTOMER', fuelDetailsJson());
    answer('PAYABLE_PARTIES', {
      ...breakdownJson('PAYABLE_PARTIES', [(1, 'MAYBANK', 2, 3000)]),
      'rows': [
        {'id': 1, 'reference': '1', 'title': 'MAYBANK', 'subtitle': '2 monthly dues · up to 100 days late', 'amount': 3000, 'status': 'OVER 90 DAYS LATE'},
      ],
    });
    answer('PAYABLE_PARTY', fuelDetailsJson());
    when(() => api.received(fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate')))
        .thenAnswer((_) async => CeoReceived.fromJava(receivedJson()));
    answer('RECEIPT_CUSTOMERS', {
      ...breakdownJson('RECEIPT_CUSTOMERS', [(12, 'ACME', 6, 15000)], noun: 'receipts'),
      'rows': [
        {'id': 12, 'reference': '1', 'title': 'ACME', 'subtitle': '6 receipts', 'amount': 15000},
        {'id': 14, 'reference': '2', 'title': 'LION CITY PTE LTD', 'subtitle': '1 receipt', 'amount': 1035, 'foreignAmount': 'SGD 300.00'},
      ],
    });
    answer('RECEIPTS', fuelDetailsJson());
    when(() => api.fuel(fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate'))).thenAnswer((_) async =>
        CeoFuel.fromJava({
          'entries': 12, 'amount': 3350, 'trucks': 3,
          'previousEntries': 10, 'previousAmount': 3015,
        }));
    answer('FUEL_TRUCKS', {
      ...breakdownJson('FUEL_TRUCKS', [(21, 'WXY 1234', 12, 3350)]),
      'rows': [
        {'id': 21, 'reference': '1', 'title': 'WXY 1234', 'subtitle': '12 fills', 'amount': 3350, 'status': ''},
      ],
    });
    answer('FUEL_ENTRIES', fuelDetailsJson());
  });

  Future<void> pump(WidgetTester tester, {Size size = const Size(390, 2600)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
        home: CeoDashboardPage(api: api, reportsApi: reports, companyId: 6, clock: () => _now, onOpenAdmin: (_) {})));
    await tester.pumpAndSettle();
  }

  Finder inTabBar(String label) =>
      find.descendant(of: find.byKey(const Key('ceo_tab_bar')), matching: find.text(label));

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.ensureVisible(inTabBar(label));
    await tester.pumpAndSettle();
    await tester.tap(inTabBar(label));
    await tester.pumpAndSettle();
  }

  testWidgets('the tab bar is the web CEO page: CEO reports, then Forwarding, Performance, Driver Salary', (tester) async {
    await pump(tester);
    for (final label in [
      'Sale Orders', 'Invoices', 'Expenses', 'Cash', 'Money Received', 'Forwarding', 'Performance', 'Driver Salary',
    ]) {
      expect(inTabBar(label), findsOneWidget, reason: label);
    }
    // owner 2026-10-19: no Overview, no other admin tabs, no today pickups or vessel planning
    for (final label in ['Overview', 'Admin Overview', 'SO', 'JobOrders', 'PaymentView', 'TopCustomers', 'Revenue']) {
      expect(inTabBar(label), findsNothing, reason: label);
    }
    expect(find.textContaining('Pickup'), findsNothing);
    expect(find.textContaining('Vessel planning'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sale Orders: employees of today, the invoice filter goes to the server, a tap opens their orders',
      (tester) async {
    await pump(tester);
    await openTab(tester, 'Sale Orders');
    final hero = find.byKey(const Key('ceo_sale_hero'));
    expect(find.descendant(of: hero, matching: find.text('RM 98,765.40')), findsOneWidget);
    expect(find.descendant(of: hero, matching: find.text('12 sale orders')), findsOneWidget);
    expect(find.text('40 sale orders'), findsOneWidget); // ALI

    await tester.tap(find.text('Without invoice'));
    await tester.pumpAndSettle();
    verify(() => api.details(
          kind: 'SALE_ORDER_EMPLOYEES',
          key: null,
          fromDate: '2026-10-16',
          toDate: '2026-10-16',
          invoice: 'WITHOUT',
          customer: null,
        )).called(1);

    await tester.tap(find.byKey(const Key('ceo_sale_emp_7')));
    await tester.pumpAndSettle();
    verify(() => api.details(
          kind: 'SALE_ORDERS',
          key: '7',
          fromDate: '2026-10-16',
          toDate: '2026-10-16',
          invoice: 'WITHOUT',
          customer: null,
        )).called(1);
    expect(find.byType(CeoDetailsSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sale Orders: choosing This week asks that week', (tester) async {
    await pump(tester);
    await openTab(tester, 'Sale Orders');
    await tester.tap(find.byKey(const Key('ceo_sale_period_WEEK')));
    await tester.pumpAndSettle();
    verify(() => api.details(kind: 'SALE_ORDER_EMPLOYEES', key: null, fromDate: '2026-10-11', toDate: '2026-10-17'))
        .called(1);
  });

  testWidgets('Invoices: by customer, a tap opens that customer\'s invoices', (tester) async {
    await pump(tester);
    await openTab(tester, 'Invoices');
    await tester.tap(find.text('By customer'));
    await tester.pumpAndSettle();
    expect(find.text('ACME'), findsOneWidget);
    await tester.tap(find.byKey(const Key('ceo_invoice_cus_101')));
    await tester.pumpAndSettle();
    verify(() => api.details(
          kind: 'INVOICES',
          key: null,
          fromDate: '2026-10-16',
          toDate: '2026-10-16',
          invoice: null,
          customer: 101,
        )).called(1);
  });

  testWidgets('Expenses: the money flow in the screens\' words, the checks and the explanation', (tester) async {
    await pump(tester, size: const Size(390, 3200));
    await openTab(tester, 'Expenses');
    verify(() => api.spend(fromDate: '2026-10-01', toDate: '2026-10-16')).called(1);
    for (final text in ['Purchase Order', 'Bill', 'Paid out', 'Still owed today']) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('RM 12,700.00'), findsOneWidget); // paid, each payment once
    expect(find.text('RM 4,200.00'), findsOneWidget); // still owed = 1,200 bills + 3,000 dues
    expect(find.text('PAYMENT (PAY BILL)'), findsOneWidget);
    expect(find.text('PAYMENT VOUCHER'), findsOneWidget);
    expect(find.text('CASH BILL'), findsOneWidget);
    for (final text in ['Supplier bills', 'For a PO', 'HIRE PURCHASE', 'Paid when billed']) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('PO paid by Payment and by Payment Voucher'), findsOneWidget);

    await tester.tap(find.byKey(const Key('ceo_paid_DIRECT:HIRE PURCHASE')));
    await tester.pumpAndSettle();
    verify(() => api.details(kind: 'SPEND_PART', key: 'DIRECT:HIRE PURCHASE', fromDate: '2026-10-01', toDate: '2026-10-16'))
        .called(1);
    Navigator.of(tester.element(find.byType(CeoDetailsSheet))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ceo_spend_help')));
    await tester.pumpAndSettle();
    expect(find.text('Each payment counted once'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cash: who owes us and whom we owe, as of today; a name opens what is behind it', (tester) async {
    await pump(tester, size: const Size(390, 3600));
    await openTab(tester, 'Cash');
    expect(find.byKey(const Key('ceo_cash_currency_SGD')), findsOneWidget);
    expect(find.text('SGD 10,000.00'), findsOneWidget);
    expect(find.text('2 customers · 3 invoices · @ 3.4500'), findsOneWidget);
    expect(find.text('ACME'), findsOneWidget);
    expect(find.text('OVER 90 DAYS'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('ceo_owed_cus_12')));
    await tester.tap(find.byKey(const Key('ceo_owed_cus_12')));
    await tester.pumpAndSettle();
    verify(() => api.details(kind: 'RECEIVABLE_CUSTOMER', key: '12', fromDate: '2026-10-16', toDate: '2026-10-16'))
        .called(1);
    Navigator.of(tester.element(find.byType(CeoDetailsSheet))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Whom we owe').last);
    await tester.pumpAndSettle();
    expect(find.text('MAYBANK'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('ceo_owed_sup_1')));
    await tester.tap(find.byKey(const Key('ceo_owed_sup_1')));
    await tester.pumpAndSettle();
    verify(() => api.details(kind: 'PAYABLE_PARTY', key: 'MAYBANK', fromDate: '2026-10-16', toDate: '2026-10-16'))
        .called(1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Money Received: this month against the same days before, how it came in, who paid', (tester) async {
    await pump(tester, size: const Size(390, 3600));
    await openTab(tester, 'Money Received');
    verify(() => api.received(fromDate: '2026-10-01', toDate: '2026-10-16')).called(1);
    final hero = find.byKey(const Key('ceo_received_hero'));
    expect(find.descendant(of: hero, matching: find.text('RM 15,000.00')), findsOneWidget);
    expect(find.descendant(of: hero, matching: find.text('+50.0%')), findsOneWidget);
    expect(find.text('MAYBANK CURRENT'), findsOneWidget);
    expect(find.byKey(const Key('ceo_received_currencies')), findsOneWidget);
    expect(find.text('SGD 1,000.00'), findsOneWidget);
    expect(find.text('RM 3,450.00'), findsOneWidget); // its RM value
    // a foreign customer who paid: RM, and their own money under it
    final lion = find.byKey(const Key('ceo_received_customer_14'));
    await tester.ensureVisible(lion);
    expect(find.descendant(of: lion, matching: find.text('RM 1,035.00')), findsOneWidget);
    expect(find.descendant(of: lion, matching: find.text('SGD 300.00')), findsOneWidget);
    expect(find.text('Day by day'), findsNothing);

    await tester.ensureVisible(find.byKey(const Key('ceo_received_method_3')));
    await tester.tap(find.byKey(const Key('ceo_received_method_3')));
    await tester.pumpAndSettle();
    verify(() => api.details(kind: 'RECEIPT_CUSTOMERS', key: '3', fromDate: '2026-10-01', toDate: '2026-10-16')).called(1);


    await tester.ensureVisible(find.byKey(const Key('ceo_received_customer_12')));
    await tester.tap(find.byKey(const Key('ceo_received_customer_12')));
    await tester.pumpAndSettle();
    verify(() => api.details(
          kind: 'RECEIPTS',
          key: '3',
          fromDate: '2026-10-01',
          toDate: '2026-10-16',
          invoice: null,
          customer: 12,
        )).called(1);
    Navigator.of(tester.element(find.byType(CeoDetailsSheet))).pop();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('ceo_received_period')));
    await tester.tap(find.text('Last month'));
    await tester.pumpAndSettle();
    verify(() => api.received(fromDate: '2026-09-01', toDate: '2026-09-30')).called(1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Expenses Fuel: the saved PAmount only, by truck', (tester) async {
    await pump(tester, size: const Size(390, 3200));
    await openTab(tester, 'Expenses');
    await tester.tap(find.descendant(of: find.byKey(const Key('ceo_expense_view')), matching: find.text('Fuel')));
    await tester.pumpAndSettle();
    verify(() => api.fuel(fromDate: '2026-10-01', toDate: '2026-10-16')).called(1);
    final hero = find.byKey(const Key('ceo_fuel_hero'));
    expect(find.descendant(of: hero, matching: find.text('RM 3,350.00')), findsOneWidget);
    expect(find.descendant(of: hero, matching: find.text('12')), findsOneWidget); // fills
    expect(find.textContaining('/L'), findsNothing);
    expect(find.descendant(of: hero, matching: find.text('+11.1%')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('ceo_fuel_truck_21')));
    await tester.tap(find.byKey(const Key('ceo_fuel_truck_21')));
    await tester.pumpAndSettle();
    verify(() => api.details(kind: 'FUEL_ENTRIES', key: '21', fromDate: '2026-10-01', toDate: '2026-10-16')).called(1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow phone (360): the new tabs do not overflow', (tester) async {
    await pump(tester, size: const Size(360, 3200));
    for (final tab in ['Sale Orders', 'Invoices', 'Expenses', 'Cash', 'Money Received']) {
      await openTab(tester, tab);
      expect(tester.takeException(), isNull, reason: tab);
    }
  });

  testWidgets('All reports finds a tab by name and opens it', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('ceo_all_reports')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('ceo_reports_search')), 'forw');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ceo_report_Sale Orders')), findsNothing);
    await tester.tap(find.byKey(const Key('ceo_report_Forwarding')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ceo_fw_hero')), findsOneWidget);
  });

  testWidgets('Forwarding: K1 / K2 / K3 / K8, released = an exit reference, for the CEO period', (tester) async {
    await pump(tester);
    await openTab(tester, 'Forwarding');
    verify(() => reports.forwarding(6, fromDate: '2026-10-01', toDate: '2026-10-16')).called(1);
    final hero = find.byKey(const Key('ceo_fw_hero'));
    expect(find.descendant(of: hero, matching: find.text('18')), findsOneWidget);
    expect(find.descendant(of: hero, matching: find.text('8')), findsOneWidget); // released 6 + 0 + 0 + 2
    expect(find.descendant(of: hero, matching: find.text('44%')), findsOneWidget);
    final k1 = find.byKey(const Key('ceo_fw_K1'));
    expect(find.descendant(of: k1, matching: find.text('6')), findsOneWidget);
    expect(find.descendant(of: k1, matching: find.text('4')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Performance: the month leaderboard, and last month on a tap', (tester) async {
    await pump(tester);
    await openTab(tester, 'Performance');
    verify(() => reports.leaderboard(6, baseDate: '2026-10-16')).called(1);
    expect(find.descendant(of: find.byKey(const Key('ceo_perf_hero')), matching: find.text('RM 9,000.00')), findsOneWidget);
    expect(find.text('ALI'), findsWidgets);
    await tester.tap(find.descendant(of: find.byKey(const Key('ceo_perf_month')), matching: find.text('Last month')));
    await tester.pumpAndSettle();
    verify(() => reports.leaderboard(6, baseDate: '2026-09-01')).called(1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Driver Salary: totals, billed and no-amount RTIs, per driver with the breakdown', (tester) async {
    await pump(tester);
    await openTab(tester, 'Driver Salary');
    verify(() => reports.driverSalary(6, fromDate: '2026-10-01', toDate: '2026-10-16')).called(1);
    final hero = find.byKey(const Key('ceo_rti_hero'));
    expect(find.descendant(of: hero, matching: find.text('RM 500.00')), findsOneWidget);
    expect(find.descendant(of: hero, matching: find.text('3 RTIs · 2 drivers')), findsOneWidget);
    expect(find.descendant(of: hero, matching: find.text('2 · 67%')), findsOneWidget); // billed
    // most RTIs first
    expect(find.descendant(of: find.byKey(const Key('ceo_rti_driver_0')), matching: find.text('RAJ')), findsOneWidget);
    await tester.tap(find.byKey(const Key('ceo_rti_driver_0')));
    await tester.pumpAndSettle();
    expect(find.text('RM 180.00'), findsOneWidget); // RAJ's salary 100 + 80
    expect(find.text('1 RTI with no amount yet'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow phone (360): the Super Admin reports do not overflow', (tester) async {
    await pump(tester, size: const Size(360, 2400));
    for (final tab in ['Forwarding', 'Performance', 'Driver Salary']) {
      await openTab(tester, tab);
      expect(tester.takeException(), isNull, reason: tab);
    }
  });
}
