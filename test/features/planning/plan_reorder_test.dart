import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
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

  List<PlanLine> rows([int count = 8]) => [
        for (var i = 1; i <= count; i++)
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
      {Set<String> actions = const {'VIEW', 'CREATE', 'EDIT', 'DELETE'}, bool dark = false, int count = 8}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = stubbedRepo(actions: actions);
    when(() => repo.search(any())).thenAnswer((_) async => rows(count));
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


  List<String> order(PlanCubit c) => [for (final r in c.state.rows) r.jobNo];

  testWidgets('tablet landscape: dragging the S.NO grip moves the row like the web grid', (tester) async {
    final cubit = await pump(tester, const Size(1366, 1024));
    expect(find.text('S.NO'), findsOneWidget);
    final grip = find.bySemanticsLabel(RegExp(r'^Drag TR0026-041 to reorder'));
    expect(grip, findsOneWidget);
    // Row 1 dragged down 2.6 rows lands as row 3.
    final g = await tester.startGesture(tester.getCenter(grip));
    await tester.pump();
    await g.moveBy(const Offset(0, 48 * 2.6));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.textContaining('TR0026-041 → row 3'), findsOneWidget);
    await g.up();
    await tester.pumpAndSettle();
    expect(order(cubit).take(3), ['TR0026-042', 'TR0026-043', 'TR0026-041']);
    expect(cubit.state.hasChanges, isTrue);
    expect(tester.takeException(), isNull);
    await cubit.close();
  });

  testWidgets('tablet landscape: a finger drags the grip on a long board with Android touch slop', (tester) async {
    // Android reports a touch slop near 8 dp; the board's scroll view must not win the finger.
    tester.view.gestureSettings = const ui.GestureSettings(physicalTouchSlop: 8);
    final cubit = await pump(tester, const Size(1366, 1024), count: 40);
    final grip = find.bySemanticsLabel(RegExp(r'^Drag TR0026-041 to reorder'));
    final g = await tester.startGesture(tester.getCenter(grip), kind: PointerDeviceKind.touch);
    await tester.pump(const Duration(milliseconds: 80));
    for (var moved = 0.0; moved < 48 * 2.6; moved += 3) {
      await g.moveBy(const Offset(0.3, 3));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.textContaining('TR0026-041 → row 3'), findsOneWidget);
    await g.up();
    await tester.pumpAndSettle();
    expect(order(cubit).take(3), ['TR0026-042', 'TR0026-043', 'TR0026-041']);
    await cubit.close();
  });

  testWidgets('tablet landscape: the row menu moves a job to the top and to the bottom', (tester) async {
    final cubit = await pump(tester, const Size(1366, 1024));
    cubit.reorder(4, 0);
    expect(order(cubit).first, 'TR0026-045');
    cubit.reorder(0, cubit.state.rows.length - 1);
    expect(order(cubit).last, 'TR0026-045');
    await cubit.close();
  });

  testWidgets('tablet landscape: no drag while a filter hides rows', (tester) async {
    final cubit = await pump(tester, const Size(1366, 1024));
    cubit.setFind('TR0026-04');
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp(r'^Drag TR0026-041 to reorder')), findsNothing);
    expect(find.textContaining('clear the filters to reorder'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('phone: the grip on a card drags it to a new place', (tester) async {
    final cubit = await pump(tester, const Size(390, 844));
    final grip = find.byIcon(Icons.drag_indicator).first;
    expect(find.byIcon(Icons.drag_indicator), findsWidgets);
    final g = await tester.startGesture(tester.getCenter(grip));
    await tester.pump(const Duration(milliseconds: 100));
    for (var i = 0; i < 10; i++) {
      await g.moveBy(const Offset(0, 30));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await g.up();
    await tester.pumpAndSettle();
    expect(order(cubit).first, isNot('TR0026-041'));
    expect(order(cubit), contains('TR0026-041'));
    expect(tester.takeException(), isNull);
    await cubit.close();
  });

  testWidgets('read-only: no grip and no reorder', (tester) async {
    final cubit = await pump(tester, const Size(1366, 1024), actions: const {'VIEW'});
    expect(find.bySemanticsLabel(RegExp(r'^Drag TR0026-041 to reorder')), findsNothing);
    cubit.reorder(0, 2);
    expect(order(cubit).first, 'TR0026-041');
    await cubit.close();
  });
}
