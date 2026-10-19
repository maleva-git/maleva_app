import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
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

void main() {
  setUpAll(installLocalTestFonts);

  late _Api api;
  late int adminOpened;

  void answerOverview(Future<CeoOverview> Function() answer) =>
      when(() => api.overview(fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate')))
          .thenAnswer((_) => answer());

  /// Answers one details kind (the later stub wins over the catch-all).
  void answerKind(String kind, Map<String, dynamic> Function() json) => when(() => api.details(
        kind: kind,
        key: any(named: 'key'),
        fromDate: any(named: 'fromDate'),
        toDate: any(named: 'toDate'),
      )).thenAnswer((_) async => CeoDetails.fromJava(json()));

  setUp(() async {
    SharedPreferences.setMockInitialValues({'Username': 'CEO'});
    // the app bar shows the signed-in name
    AppGlobals.storagenew = await SharedPreferences.getInstance();
    api = _Api();
    adminOpened = 0;
    answerOverview(() async => CeoOverview.fromJava(overviewJson()));
    when(() => api.details(
          kind: any(named: 'kind'),
          key: any(named: 'key'),
          fromDate: any(named: 'fromDate'),
          toDate: any(named: 'toDate'),
        )).thenAnswer((_) async => CeoDetails.fromJava(fuelDetailsJson(rows: 5, count: 7, truncated: true)));
    answerKind('SALE_ORDERS', () => saleOrdersJson());
    answerKind('CUSTOMERS', () => customersJson());
    answerKind('SALE_ORDER_EMPLOYEES', () => saleOrderEmployeesJson());
  });

  Future<void> pump(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: CeoDashboardPage(
          api: api, reportsApi: _Reports(), companyId: 6, clock: () => _now, onOpenAdmin: (_) => adminOpened++),
    ));
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

  testWidgets('opens on Sale Orders, with the web tabs and no Overview', (tester) async {
    await pump(tester, const Size(390, 2400));
    expect(find.byKey(const Key('ceo_sale_hero')), findsOneWidget);
    expect(inTabBar('Overview'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow phone (360) and tablet: no overflow', (tester) async {
    await pump(tester, const Size(360, 2400));
    expect(tester.takeException(), isNull);
    await pump(tester, const Size(800, 2000));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping an expense category opens its purchase orders', (tester) async {
    await pump(tester, const Size(390, 2600));
    await openTab(tester, 'Expenses');
    await tester.tap(find.descendant(of: find.byKey(const Key('ceo_expense_view')), matching: find.text('By category')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('FUEL').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('FUEL').last);
    await tester.pumpAndSettle();

    verify(() => api.details(kind: 'EXPENSE_CATEGORY', key: 'FUEL', fromDate: '2026-10-01', toDate: '2026-10-16'))
        .called(1);
    expect(find.text('FUEL purchase orders'), findsOneWidget);
    expect(find.text('PO000001230'), findsOneWidget);
    expect(find.text('WXY 1230 · INV-770'), findsOneWidget);
    expect(find.text('PAYMENT COMPLETED'), findsOneWidget);
    await tester.drag(find.text('PO000001230'), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Showing 5 of 7'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the sheet shows the error with Retry, then the rows', (tester) async {
    await pump(tester, const Size(390, 2600));
    await openTab(tester, 'Expenses');
    await tester.tap(find.descendant(of: find.byKey(const Key('ceo_expense_view')), matching: find.text('By category')));
    await tester.pumpAndSettle();
    when(() => api.details(
          kind: any(named: 'kind'),
          key: any(named: 'key'),
          fromDate: any(named: 'fromDate'),
          toDate: any(named: 'toDate'),
        )).thenThrow(const ApiFailure('Details failed'));
    await tester.ensureVisible(find.text('FUEL').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('FUEL').last);
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byType(CeoDetailsSheet), matching: find.text('Details failed')), findsOneWidget);

    when(() => api.details(
          kind: any(named: 'kind'),
          key: any(named: 'key'),
          fromDate: any(named: 'fromDate'),
          toDate: any(named: 'toDate'),
        )).thenAnswer((_) async => const CeoDetails(kind: 'EXPENSE_CATEGORY', key: 'FUEL', title: 'FUEL purchase orders'));
    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pumpAndSettle();
    expect(find.text('FUEL purchase orders'), findsOneWidget);
    expect(find.text('Nothing to show for this period'), findsOneWidget);
  });

  testWidgets('403 shows the CEO-only page with a way to the admin dashboard', (tester) async {
    answerOverview(() async => throw const ApiFailure('Only the CEO can open this dashboard', statusCode: 403));
    await pump(tester, const Size(390, 900));
    expect(find.text('This dashboard is for the CEO only'), findsOneWidget);
    expect(find.byKey(const Key('ceo_tab_bar')), findsNothing);
    await tester.tap(find.text('Open admin dashboard'));
    expect(adminOpened, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the app bar opens the admin dashboard', (tester) async {
    await pump(tester, const Size(390, 900));
    await tester.tap(find.byKey(const Key('ceo_more')));
    await tester.pumpAndSettle();
    expect(find.text('Log out'), findsOneWidget);
    await tester.tap(find.byKey(const Key('ceo_open_admin')));
    await tester.pumpAndSettle();
    expect(adminOpened, 1);
    expect(find.byTooltip('Notifications'), findsOneWidget);
    expect(find.byTooltip('More'), findsOneWidget);
  });

  testWidgets('the quick access buttons are on the screen, as on the web', (tester) async {
    await pump(tester, const Size(1200, 900));
    expect(find.byKey(const Key('ceo_quick_access')), findsOneWidget);
    for (final id in ['truck_planning', 'truck_location', 'vessel_planning', 'incident_report', 'mail_monitor']) {
      expect(find.byKey(Key('ceo_go_$id')), findsOneWidget, reason: id);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cash: a failed load shows Retry; Retry loads', (tester) async {
    answerOverview(() async => throw const ApiFailure('Server error occurred. (500)', statusCode: 500));
    await pump(tester, const Size(390, 2400));
    await openTab(tester, 'Cash');
    expect(find.text('Server error occurred. (500)'), findsWidgets);

    answerOverview(() async => CeoOverview.fromJava(overviewJson()));
    await tester.tap(find.text('Retry').first);
    await tester.pumpAndSettle();
    expect(find.text('RM 250,000.00'), findsWidgets);
  });

  testWidgets('Cash: a missing or unavailable part shows a note on its section', (tester) async {
    answerOverview(() async => CeoOverview.fromJava(overviewJson()..remove('cash')));
    await pump(tester, const Size(390, 2400));
    await openTab(tester, 'Cash');
    expect(find.text('This part did not load'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Cash: figures the server could not load are named', (tester) async {
    answerOverview(() async => CeoOverview.fromJava(overviewJson()..['unavailable'] = ['cash.payable']));
    await pump(tester, const Size(390, 2400));
    await openTab(tester, 'Cash');
    expect(find.textContaining('Some figures are unavailable: payable'), findsOneWidget);
  });

  testWidgets('switching the period asks that range', (tester) async {
    await pump(tester, const Size(390, 2400));
    await openTab(tester, 'Cash');
    await tester.tap(find.descendant(of: find.byKey(const Key('ceo_period_bar')), matching: find.text('This year')));
    await tester.pumpAndSettle();
    verify(() => api.overview(fromDate: '2026-01-01', toDate: '2026-10-16')).called(1);
  });
}
