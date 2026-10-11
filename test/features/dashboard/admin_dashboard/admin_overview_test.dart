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
  when(() => repo.sales()).thenAnswer((_) async => const SalesSummary(today: 18, month: 412, monthAmount: 98450));
  when(() => repo.jobOrders()).thenAnswer((_) async => const JobOrderSummary(open: 27, byStatus: {'New': 9, 'In Progress': 18}));
  when(() => repo.mail()).thenAnswer((_) async => MailSummary(
      summary: _mailSummary, mailboxes: [row(1, level: 'OVERDUE', unread: 22), row(2, unread: 0)]));
  when(() => repo.incidents())
      .thenAnswer((_) async => IrSummary(open: 5, totalAmount: 3200, latest: [incident(1, DateTime(2026, 10, 10))]));
  when(() => repo.truckPlanningToday()).thenAnswer((_) async => 34);
  when(() => repo.vesselPlanningNextWeek()).thenAnswer((_) async => 21);
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

    test('sales: the Java keys as the SO tab reads them', () {
      final s = SalesSummary.fromJava({'TodaySales': 2, 'MonthSales': '40', 'MonthAmount': 1250.5});
      expect((s.today, s.month, s.monthAmount), (2, 40, 1250.5));
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
      when(() => dashboard.planningJobs(6, fromDate: '2026-10-11', toDate: '2026-10-11'))
          .thenAnswer((_) async => [{'Id': 1}, {'Id': 2}]);
      when(() => dashboard.vesselPlanning(6, fromDate: '2026-10-11', toDate: '2026-10-18'))
          .thenAnswer((_) async => [{'id': 1}]);
      when(() => trucks.week('2026-10-11')).thenAnswer(
          (_) async => TruckLocationWeek(weekStart: '2026-10-11', days: const ['2026-10-11'], rows: [truck(1, today: 'PKG')]));

      expect((await repo.sales()).today, 1);
      expect(await repo.truckPlanningToday(), 2);
      expect(await repo.vesselPlanningNextWeek(), 1);
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
      expect(cubit.state.truckPlanning.data, 34);
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

    Future<List<String>> pump(WidgetTester tester, Size size, {List<MenuMasterModel> entries = const []}) async {
      final opened = <String>[];
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: AdminOverviewTab(onOpenTab: opened.add, repository: repo, menu: entries)),
      ));
      await tester.pump();
      return opened;
    }

    testWidgets('phone: numbers, sections, and the tab buttons switch tabs', (tester) async {
      final opened = await pump(tester, const Size(390, 1600));

      expect(find.text('18'), findsOneWidget);
      expect(find.text('27'), findsOneWidget);
      expect(find.text('64'), findsOneWidget);
      expect(find.text('1 overdue'), findsOneWidget);
      expect(find.text('34'), findsOneWidget);
      expect(find.text('Box 1 · 22 unread'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('JO'));
      await tester.tap(find.text('Mailbox'));
      expect(opened, ['JobOrders', 'Mailbox Monitor']);
    });

    testWidgets('screen buttons only for menu entries the user has', (tester) async {
      await pump(tester, const Size(390, 1600), entries: [menu('Truck Location')]);
      expect(find.text('Truck Location'), findsOneWidget);
      expect(find.text('Vessel Planning'), findsNothing);
      expect(find.text('Truck Planning'), findsNothing);
    });

    testWidgets('tablet: lays out without overflow', (tester) async {
      await pump(tester, const Size(1280, 1400),
          entries: [menu('Vessel Planning'), menu('Planning'), menu('Truck Location')]);
      expect(find.text('Vessel Planning'), findsOneWidget);
      expect(find.text('Truck Planning'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a failing area shows its message and Retry; the rest still show', (tester) async {
      when(() => repo.vesselPlanningNextWeek()).thenThrow(const ApiFailure('Vessel planning failed'));
      await pump(tester, const Size(390, 1600));

      expect(find.text('Vessel planning failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('34'), findsOneWidget);

      when(() => repo.vesselPlanningNextWeek()).thenAnswer((_) async => 21);
      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(find.text('21'), findsOneWidget);
    });
  });

  group('admin dashboard tabs', () {
    test('Super Admin: Overview first, Mailbox Monitor after Invoice; Admin: SO first, neither', () {
      final superAdmin = adminTabs(superAdmin: true, openTab: (_) {}).map((t) => t.label).toList();
      final admin = adminTabs(superAdmin: false, openTab: (_) {}).map((t) => t.label).toList();

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
}
