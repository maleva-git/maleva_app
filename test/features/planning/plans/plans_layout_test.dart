import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/theme/app_theme.dart';
import 'package:maleva/features/planning/plans/bloc/plans_bloc.dart';
import 'package:maleva/features/planning/plans/data/plans_repository.dart';
import 'package:maleva/features/planning/plans/models/plan_row.dart';
import 'package:maleva/features/planning/plans/view/phone/plans_phone_view.dart';
import 'package:maleva/features/planning/plans/view/tablet/plans_tablet_view.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements PlansRepository {}

void main() {
  final rows = [
    for (var i = 1; i <= 5; i++)
      PlanRow(
        id: i,
        planningNo: 'PL00000000$i',
        planningDate: '05 Oct 2026',
        employeeName: 'An employee with a long name $i',
        totalOrders: 3,
        remarks: 'Remarks long enough to be cut on a phone screen, line after line',
        jobs: [for (var j = 0; j < 3; j++) PlanJob(id: j, planningId: i, jobNo: 'TR0026-04$j', truckName: 'WXY $j', jobStatus: 'Pending', rtiNo: 'RTI$j')],
      ),
  ];

  Future<PlansBloc> pump(WidgetTester tester, Size size, Widget Function() view, {bool dark = false}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _Repo();
    when(() => repo.companyId).thenReturn(6);
    when(() => repo.employeeId).thenReturn(42);
    when(() => repo.employees()).thenAnswer((_) async => const []);
    when(() => repo.list(from: any(named: 'from'), to: any(named: 'to'), search: any(named: 'search'), employeeId: any(named: 'employeeId')))
        .thenAnswer((_) async => rows);
    final bloc = PlansBloc(repository: repo, openUrl: (_) async {}, today: () => DateTime(2026, 10, 5))..add(const PlansStarted());
    await tester.pumpWidget(MaterialApp(
      // AppTheme loads Google Fonts over the network; the plain theme with the tokens is enough here.
      theme: ThemeData(
        useMaterial3: true,
        brightness: dark ? Brightness.dark : Brightness.light,
        extensions: [dark ? MalevaColors.dark : MalevaColors.light],
      ),
      home: BlocProvider.value(value: bloc, child: view()),
    ));
    await tester.pumpAndSettle();
    return bloc;
  }

  testWidgets('phone: plan cards with Report and Edit', (tester) async {
    await pump(tester, const Size(390, 844), () => PlansPhoneView(onNewPlan: () {}));
    expect(find.text('Rows: 5'), findsOneWidget);
    expect(find.text('Report'), findsWidgets);
  });

  testWidgets('phone, dark: the filter sheet', (tester) async {
    await pump(tester, const Size(390, 844), () => PlansPhoneView(onNewPlan: () {}), dark: true);
    await tester.tap(find.byTooltip('Filters'));
    await tester.pumpAndSettle();
    expect(find.text('Login Employee'), findsWidgets);
    expect(find.text('Report Date'), findsOneWidget);
  });

  testWidgets('tablet portrait: list and preview with the plan\'s jobs', (tester) async {
    await pump(tester, const Size(820, 1180), () => PlansTabletPortraitView(onNewPlan: () {}));
    expect(find.text('Open plan'), findsOneWidget);
    expect(find.text('TR0026-040'), findsOneWidget);
  });

  testWidgets('tablet landscape: filter panel, table, preview', (tester) async {
    await pump(tester, const Size(1366, 1024), () => PlansTabletLandscapeView(onNewPlan: () {}));
    expect(find.text('Filter plans'), findsOneWidget);
    expect(find.text('Total Logs: 5'), findsOneWidget);
  });
}
