import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/view/plan_page.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/local_fonts.dart';
import 'plan_test_support.dart';

void main() {
  setUpAll(() async {
    registerFallbackValue(<String, dynamic>{});
    await installLocalTestFonts();
  });

  List<PlanLine> rows() => [
        for (var i = 1; i <= 8; i++)
          PlanLine(
            saleOrderMasterRefId: i,
            jobNo: 'TR0026-04$i',
            customerName: 'Customer with a rather long trading name $i',
            origin: 'NORTHPORT',
            destination: 'SHAH ALAM INDUSTRIAL PARK',
            sPickupDate: '2026-10-05 08:30:00',
            sDeliveryDate: '2026-10-05 17:00:00',
            truckName: i.isEven ? 'WA 1234' : '',
            truckRefid: i.isEven ? 64 : 0,
            driverName: i % 3 == 0 ? 'ALI-0123' : '',
            status: i.isEven ? 'Pending' : 'Delivered',
            rtiNo: i == 2 ? 'RTI000000040' : '',
            pickupAddress: 'WESTPORT GATE 3{@}NORTHPORT WHARF 5',
          ),
      ];

  Future<PlanCubit> pump(WidgetTester tester, Size size,
      {Set<String> actions = const {'VIEW', 'CREATE', 'EDIT', 'DELETE'}, bool dark = false}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = stubbedRepo(actions: actions);
    when(() => repo.search(any())).thenAnswer((_) async => rows());
    final cubit = PlanCubit(repo: repo, rtiFromPlanning: FakeRtiFromPlanning(), clock: () => DateTime(2026, 10, 5, 9));
    await cubit.start();
    await cubit.search();
    await tester.pumpWidget(MaterialApp(
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      home: BlocProvider.value(value: cubit, child: const PlanScreen()),
    ));
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('phone: tiles, find bar, cards; a long press starts multi-select', (tester) async {
    final cubit = await pump(tester, const Size(390, 844));
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Unassigned'), findsWidgets);
    expect(find.text('TR0026-041'), findsOneWidget);
    expect(find.text('New plan'), findsOneWidget);
    await tester.longPress(find.text('TR0026-041'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);
    expect(find.text('Create RTI'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await cubit.close();
  });

  testWidgets('phone: the job opens full screen with its six sections', (tester) async {
    final cubit = await pump(tester, const Size(390, 844), dark: true);
    await tester.tap(find.text('TR0026-042'));
    await tester.pumpAndSettle();
    expect(find.text('Job 2 of 8'), findsOneWidget);
    expect(find.text('ASSIGNMENT'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('NOTES'), 300);
    expect(find.text('NOTES'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await cubit.close();
  });

  testWidgets('phone, view only: the notice and no select button', (tester) async {
    final cubit = await pump(tester, const Size(390, 844), actions: const {'VIEW'});
    expect(find.textContaining('View only. You can open'), findsOneWidget);
    expect(find.text('Read-only'), findsOneWidget);
    expect(find.byTooltip('Select jobs'), findsNothing);
    await cubit.close();
  });

  testWidgets('tablet portrait: list beside the detail pane', (tester) async {
    final cubit = await pump(tester, const Size(820, 1180));
    expect(find.text('Pick a job'), findsOneWidget);
    await tester.tap(find.text('TR0026-043'));
    await tester.pumpAndSettle();
    expect(find.text('Job 3 of 8'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await cubit.close();
  });

  testWidgets('tablet landscape: filter panel, board, views', (tester) async {
    final cubit = await pump(tester, const Size(1280, 800));
    expect(find.text('Search & filters'), findsOneWidget);
    expect(find.text('JOB NO'), findsOneWidget);
    expect(find.text('TRUCK'), findsOneWidget);
    await tester.tap(find.text('By truck'));
    await tester.pumpAndSettle();
    expect(find.text('WA 1234'), findsWidgets);
    await tester.tap(find.text('By status'));
    await tester.pumpAndSettle();
    expect(find.text('Waiting'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await cubit.close();
  });

  for (final size in const [Size(360, 640), Size(600, 960), Size(901, 700)]) {
    testWidgets('no overflow at the smallest width of each layout: $size', (tester) async {
      final cubit = await pump(tester, size);
      cubit.setTicks({for (final r in cubit.state.rows.take(2)) r.uid}, true);
      cubit.editRemarks(cubit.state.rows.first.uid, 'changed');
      cubit.selectRow(cubit.state.rows.first.uid);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await cubit.close();
    });
  }
}
