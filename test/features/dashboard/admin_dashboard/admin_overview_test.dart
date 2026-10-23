import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/job_order/job_order_api.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_models.dart';
import 'package:maleva/core/models/shared/menu_master_model.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/session/app_session.dart';
import 'package:maleva/features/dashboard/admin_dashboard/overview/bloc/admin_overview_cubit.dart';
import 'package:maleva/features/dashboard/admin_dashboard/overview/data/admin_overview_models.dart';
import 'package:maleva/features/dashboard/admin_dashboard/overview/data/admin_overview_repository.dart';
import 'package:maleva/features/dashboard/admin_dashboard/overview/view/admin_overview_tab.dart';
import 'package:maleva/features/dashboard/admin_dashboard/view/admin_dashboard_ui.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_filter.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_list_result.dart';
import 'package:maleva/features/ir_report/domain/entities/ir_report.dart';
import 'package:maleva/features/ir_report/domain/repositories/ir_repository.dart';
import 'package:maleva/features/truck_location/domain/entities/truck_location_week.dart';
import 'package:maleva/features/truck_location/domain/repositories/truck_location_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../../features/mail_monitor/mail_monitor_cubits_test.dart' show row;
import '../../../support/local_fonts.dart';

class _Dashboard extends Mock implements DashboardApi {}

class _JobOrders extends Mock implements JobOrderApi {}

class _Mail extends Mock implements MailMonitorApi {}

class _Ir extends Mock implements IrRepository {}

class _Trucks extends Mock implements TruckLocationRepository {}

class _Session extends Mock implements AppSession {}

class _Repo extends Mock implements AdminOverviewRepository {}

final _today = DateTime(2026, 10, 11, 9, 30);

TruckLocationRow truck(int id, {String status = 'ACTIVE', String today = '', bool done = false}) => TruckLocationRow(
      truckRefId: id,
      truckName: 'T$id',
      truckNumber: 'WXY $id',
      truckType: 'PRIME',
      truckStatus: status,
      // Week of Sun 2026-10-11: today is the first day.
      locations: [today, '', '', '', '', '', ''],
      lastKnownLocation: '',
      done: done,
    );

IrReport incident(int id, DateTime date) => IrReport(
      id: id,
      irDate: date,
      statusId: 1,
      statusName: 'Open',
      description: 'Damage $id',
      departmentId: 1,
      departmentName: 'Ops',
      truckNo: 'WXY $id',
    );

const _mailSummary = MailMonitorSummary(totalUnread: 64, withUnread: 2, overdue: 1, errors: 0, mailboxes: 3, lastFullCheckAt: null);

/// Stubs every area of [repo] with data.
void stubAll(AdminOverviewRepository repo) {
  when(() => repo.sales()).thenAnswer((_) async => const SalesSummary(
        today: 18,
        month: 412,
        monthAmount: 98450,
        yesterday: 15,
        week: 77,
        months: [MonthSales(name: 'October', count: 412, amount: 98450), MonthSales(name: 'September', count: 380, amount: 90100)],
      ));
  when(() => repo.invoices()).thenAnswer((_) async => const SalesSummary(today: 7, month: 205, monthAmount: 55000));
  when(() => repo.jobOrders()).thenAnswer((_) async => const JobOrderSummary(open: 27, byStatus: {'New': 9, 'In Progress': 18}));
  when(() => repo.mail()).thenAnswer((_) async => MailSummary(
      summary: _mailSummary, mailboxes: [row(1, level: 'OVERDUE', unread: 22), row(2, unread: 0)]));
  when(() => repo.incidents())
      .thenAnswer((_) async => IrSummary(open: 5, totalAmount: 3200, latest: [incident(1, DateTime(2026, 10, 10))]));
  when(() => repo.truckLocation())
      .thenAnswer((_) async => const TruckLocationSummary(filled: 31, notFilled: 6, workshop: 3));
}

MenuMasterModel menu(String name) => MenuMasterModel(name, 1, 6, 0, 1, 1, 1, 1);

void main() {
  setUpAll(() async {
    await installLocalTestFonts();
    registerFallbackValue(const IrFilter());
  });

  group('counting rules', () {
    test('job orders: completed (3), cancelled and closed are not open; the rest counted by status', () {
      final s = JobOrderSummary.fromRows([
        {'statusRefId': 1, 'statusName': 'New'},
        {'statusRefId': 1, 'statusName': 'New'},
        {'statusRefId': 2, 'statusName': 'In Progress'},
        {'statusRefId': 3, 'statusName': 'Done'},
        {'statusRefId': 4, 'statusName': 'Cancelled'},
        {'statusRefId': 5, 'statusName': 'Closed'},
      ]);
      expect(s.open, 3);
      expect(s.byStatus, {'New': 2, 'In Progress': 1});
    });

    test('truck location: sold left out, workshop apart, done never "not filled"', () {
      final week = TruckLocationWeek(
        weekStart: '2026-10-11',
        days: const ['2026-10-11', '2026-10-12', '2026-10-13', '2026-10-14', '2026-10-15', '2026-10-16', '2026-10-17'],
        rows: [
          truck(1, today: 'Westport'),
          truck(2),
          truck(3, done: true),
          truck(4, status: 'WORKSHOP'),
          truck(5, status: 'SOLD'),
        ],
      );
      final s = TruckLocationSummary.of(week, '2026-10-11');
      expect((s.filled, s.notFilled, s.workshop), (1, 1, 1));
    });

    test('sales: the Java keys as the SO tab and the web report card read them', () {
      final s = SalesSummary.fromJava({
        'TodaySales': 2,
        'TodayAmount': 80,
        'YesterdaySales': 3,
        'WeekSales': 9,
        'WeekAmount': '410.5',
        'MonthSales': '40',
        'MonthAmount': 1250.5,
        'monthlySales': [
          {'MonthName': 'October', 'SalesCount': 40, 'SalesAmount': 1250.5},
          {'MonthName': 'September', 'SalesCount': '12', 'SalesAmount': 300},
        ],
      });
      expect((s.today, s.month, s.monthAmount), (2, 40, 1250.5));
      expect((s.todayAmount, s.yesterday, s.week, s.weekAmount), (80, 3, 9, 410.5));
      expect(s.months.map((m) => (m.name, m.count, m.amount)), [('October', 40, 1250.5), ('September', 12, 300)]);
    });

  });

  group('AdminOverviewRepository', () {
    late _Dashboard dashboard;
    late _Ir ir;
    late _Trucks trucks;
    late AdminOverviewRepository repo;

    setUp(() {
      dashboard = _Dashboard();
      ir = _Ir();
      trucks = _Trucks();
      final session = _Session();
      when(() => session.companyId).thenReturn(6);
      repo = AdminOverviewRepository(
        dashboard: dashboard,
        jobOrders: _JobOrders(),
        mail: _Mail(),
        incidents: ir,
        trucks: trucks,
        session: session,
        clock: () => _today,
      );
    });

    test('asks the existing endpoints for the right company and dates', () async {
      when(() => dashboard.sales(6, 1)).thenAnswer((_) async => {'TodaySales': 1});
      when(() => dashboard.sales(6, 0)).thenAnswer((_) async => {'TodaySales': 4});
      when(() => trucks.week('2026-10-11')).thenAnswer(
          (_) async => TruckLocationWeek(weekStart: '2026-10-11', days: const ['2026-10-11'], rows: [truck(1, today: 'PKG')]));

      expect((await repo.sales()).today, 1);
      expect((await repo.invoices()).today, 4);
      expect((await repo.truckLocation()).filled, 1);
    });

    test('incidents: open only, the last 30 days, newest three', () async {
      when(() => ir.search(any())).thenAnswer((_) async => IrListResult(
            items: [for (var d = 1; d <= 5; d++) incident(d, DateTime(2026, 10, d))],
            totalAmount: 900,
            count: 5,
          ));
      final s = await repo.incidents();
      final filter = verify(() => ir.search(captureAny())).captured.single as IrFilter;
      expect(filter.openOnly, isTrue);
      expect(filter.fromDate, DateTime(2026, 9, 11));
      expect(filter.toDate, DateTime(2026, 10, 11));
      expect((s.open, s.totalAmount), (5, 900));
      expect(s.latest.map((r) => r.id), [5, 4, 3]);
    });
  });

  group('AdminOverviewCubit', () {
    test('one area failing leaves the others loaded; Retry reloads only it', () async {
      final repo = _Repo();
      stubAll(repo);
      when(() => repo.mail()).thenThrow(const ApiFailure('Mail monitor is down'));
      final cubit = AdminOverviewCubit(repo, clock: () => _today);

      await cubit.load();
      expect(cubit.state.mail.error, 'Mail monitor is down');
      expect(cubit.state.sales.data!.today, 18);
      expect(cubit.state.invoices.data!.today, 7);
      expect(cubit.state.updatedAt, _today);

      when(() => repo.mail()).thenAnswer((_) async => const MailSummary(summary: _mailSummary, mailboxes: []));
      await cubit.retry(OverviewArea.mail);
      expect(cubit.state.mail.error, isNull);
      expect(cubit.state.mail.data!.summary.totalUnread, 64);
      verify(() => repo.sales()).called(1);
      await cubit.close();
    });
  });

  group('Overview tab', () {
    late _Repo repo;
    setUp(() {
      repo = _Repo();
      stubAll(repo);
    });

    Future<List<String>> pump(WidgetTester tester, Size size,
        {List<MenuMasterModel> entries = const [], bool salesAllowed = true}) async {
      final opened = <String>[];
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: AdminOverviewTab(
                onOpenTab: opened.add, repository: repo, menu: entries, salesAllowed: salesAllowed)),
      ));
      await tester.pump();
      return opened;
    }

    testWidgets('phone: numbers, sections, and the tab buttons switch tabs', (tester) async {
      final opened = await pump(tester, const Size(390, 2400));

      // Today's sale orders: in the header and on the report card's Today tile.
      expect(find.text('18'), findsNWidgets(2));
      expect(find.text('27'), findsOneWidget);
      expect(find.text('64'), findsOneWidget);
      expect(find.text('1 overdue'), findsOneWidget);
      // The web's pickup and vessel side panels are not on the app Overview.
      expect(find.text("TODAY'S PICKUP"), findsNothing);
      expect(find.text('VESSEL PLANNING'), findsNothing);
      expect(find.text('October'), findsOneWidget);
      expect(find.text('22 unread'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('JO'));
      await tester.tap(find.text('Mailbox'));
      expect(opened, ['JobOrders', 'Mailbox Monitor']);
    });

    testWidgets('header numbers open their tab; months show as a chart with the best month', (tester) async {
      final opened = await pump(tester, const Size(390, 2400));
      await tester.tap(find.text('Open job orders'));
      await tester.tap(find.text('Unread mail'));
      expect(opened, ['JobOrders', 'Mailbox Monitor']);

      expect(find.byType(BarChart), findsOneWidget);
      expect(find.text('Oct'), findsOneWidget);
      expect(find.text('October'), findsOneWidget); // best month
      expect(find.text('RM 188,550.00'), findsOneWidget); // total of the months
      expect(tester.takeException(), isNull);
    });

    testWidgets('Sale Order / Invoice switches the report numbers', (tester) async {
      await pump(tester, const Size(390, 2200));
      expect(find.text('412'), findsWidgets);
      await tester.tap(find.text('Invoice').first);
      await tester.pump();
      expect(find.text('205'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a six-digit unread count with its overdue pill fits a narrow phone', (tester) async {
      when(() => repo.mail()).thenAnswer((_) async => MailSummary(
            summary: const MailMonitorSummary(
                totalUnread: 109910, withUnread: 18, overdue: 10, errors: 0, mailboxes: 20, lastFullCheckAt: null),
            mailboxes: [row(1, level: 'OVERDUE', unread: 12328)],
          ));
      await pump(tester, const Size(360, 1600));
      expect(find.text('109,910'), findsOneWidget);
      expect(find.text('10 overdue'), findsOneWidget);
      expect(find.text('12,328 unread'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('screen buttons only for menu entries the user has', (tester) async {
      await pump(tester, const Size(390, 1600), entries: [menu('Truck Location')]);
      expect(find.text('Truck Location'), findsOneWidget);
      expect(find.text('Vessel Planning'), findsNothing);
      expect(find.text('Truck Planning'), findsNothing);
    });

    testWidgets('tablet portrait: lays out without overflow', (tester) async {
      await pump(tester, const Size(800, 2000),
          entries: [menu('Vessel Planning'), menu('Planning'), menu('Truck Location')]);
      expect(find.text('Vessel Planning'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('wide: lays out without overflow', (tester) async {
      await pump(tester, const Size(1280, 1400),
          entries: [menu('Vessel Planning'), menu('Planning'), menu('Truck Location')]);
      expect(find.text('Vessel Planning'), findsOneWidget);
      expect(find.text('Truck Planning'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a failing area shows its message and Retry; the rest still show', (tester) async {
      when(() => repo.truckLocation()).thenThrow(const ApiFailure('Truck location failed'));
      await pump(tester, const Size(390, 2200));

      expect(find.text('Truck location failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('22 unread'), findsOneWidget);

      when(() => repo.truckLocation())
          .thenAnswer((_) async => const TruckLocationSummary(filled: 31, notFilled: 6, workshop: 3));
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(find.text('Truck location failed'), findsNothing);
      expect(find.text('31'), findsOneWidget);
    });
  });

  group('admin dashboard tabs', () {
    test('CEO with this dashboard: Overview first, SO, Mailbox Monitor after Invoice', () {
      final superAdmin = adminTabs(superAdmin: true, ceo: true, openTab: (_) {}).map((t) => t.label).toList();
      final admin = adminTabs(superAdmin: false, ceo: true, openTab: (_) {}).map((t) => t.label).toList();

      expect(superAdmin.take(6), ['Overview', 'SO', 'JobOrders', 'Invoice', 'Mailbox Monitor', 'Mail Response']);
      expect(superAdmin, hasLength(35));
      expect(admin.first, 'SO');
      expect(admin, hasLength(32));
      expect(admin, isNot(contains('Overview')));
      expect(admin, isNot(contains('Mail Response')));
      for (final label in [
        OverviewTabLinks.salesOrders,
        OverviewTabLinks.jobOrders,
        OverviewTabLinks.mailboxMonitor,
        OverviewTabLinks.irReport,
      ]) {
        expect(superAdmin, contains(label));
      }
    });
  });

  // change ceo-only-sale-order-numbers: sale order numbers are the CEO's only
  group('sale order numbers for the CEO only', () {
    test('Super Admin and Admin have no SO tab', () {
      final superAdmin = adminTabs(superAdmin: true, openTab: (_) {}).map((t) => t.label).toList();
      final admin = adminTabs(superAdmin: false, openTab: (_) {}).map((t) => t.label).toList();

      expect(superAdmin.take(5), ['Overview', 'JobOrders', 'Invoice', 'Mailbox Monitor', 'Mail Response']);
      expect(superAdmin, hasLength(34));
      expect(admin, isNot(contains('SO')));
      expect(admin, hasLength(31));
    });

    test('the cubit never loads the sale order numbers without the CEO', () async {
      final repo = _Repo();
      stubAll(repo);
      final cubit = AdminOverviewCubit(repo, clock: () => _today, salesAllowed: false);

      await cubit.load();
      await cubit.retry(OverviewArea.sales);
      expect(cubit.state.invoices.data!.today, 7);
      verifyNever(() => repo.sales());
      await cubit.close();
    });

    testWidgets('Overview without the CEO: no sale order tile, SO button or Sale Order switch', (tester) async {
      final repo = _Repo();
      stubAll(repo);
      tester.view.physicalSize = const Size(390, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: AdminOverviewTab(onOpenTab: (_) {}, repository: repo, salesAllowed: false)),
      ));
      await tester.pump();

      expect(find.text('Sale orders today'), findsNothing);
      expect(find.text('SO'), findsNothing);
      expect(find.text('Sale Order'), findsNothing);
      expect(find.text('Invoicing metrics'), findsOneWidget); // the report card shows invoices
      expect(tester.takeException(), isNull);
      verifyNever(() => repo.sales());
    });
  });
}
