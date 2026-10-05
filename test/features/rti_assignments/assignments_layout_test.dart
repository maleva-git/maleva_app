import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/theme/app_theme.dart';
import 'package:maleva/features/rti_assignments/bloc/assignments_bloc.dart';
import 'package:maleva/features/rti_assignments/data/assignments_repository.dart';
import 'package:maleva/features/rti_assignments/models/employee_assignment.dart';
import 'package:maleva/features/rti_assignments/view/phone/assignments_phone_view.dart';
import 'package:maleva/features/rti_assignments/view/tablet/assignments_tablet_view.dart';
import 'package:mocktail/mocktail.dart';

class _Repo extends Mock implements AssignmentsRepository {}

void main() {
  final rows = [
    for (var i = 1; i <= 4; i++)
      EmployeeAssignment(
        id: i,
        rtiMasterRefId: i,
        rtiNumber: 'RTI00000000$i',
        saleOrderNumber: 'TR0026-041$i',
        customerName: 'Sample Trading Sdn Bhd',
        originD: 'Port Klang',
        destinationD: 'Shah Alam',
        pickupDateD: '2026-10-05T08:30:00',
        deliveryDateD: '2026-10-05T16:30:00',
        vesselNameRaw: 'MV Sample Star',
        commodity: 'Garments',
        quantity: '12 PKG',
        truckSize: '20FT',
        pickupCount: 1,
        dropCount: 2,
        employeeName: 'Siti A.',
        driverName: 'Ahmad R.',
        truckNumber: 'WXY 1234',
        truckType: 'Prime mover',
        remarks: i.isEven ? '' : 'Call before delivery',
      ),
  ];

  Future<void> pump(WidgetTester tester, Size size, Widget view, {bool dark = false}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final repo = _Repo();
    when(() => repo.companyId).thenReturn(6);
    when(() => repo.employeeId).thenReturn(42);
    when(() => repo.userName).thenReturn('Siti A.');
    when(() => repo.employees()).thenAnswer((_) async => const []);
    when(() => repo.fetch(from: any(named: 'from'), to: any(named: 'to'), employeeId: any(named: 'employeeId')))
        .thenAnswer((_) async => rows);
    final bloc = AssignmentsBloc(repository: repo, openUrl: (_) async {}, today: () => DateTime(2026, 10, 5))
      ..add(const AssignmentsStarted());
    await tester.pumpWidget(MaterialApp(
      // AppTheme loads Google Fonts over the network; the plain theme with the tokens is enough here.
      theme: ThemeData(
        useMaterial3: true,
        brightness: dark ? Brightness.dark : Brightness.light,
        extensions: [dark ? MalevaColors.dark : MalevaColors.light],
      ),
      home: BlocProvider.value(value: bloc, child: view),
    ));
    await tester.pumpAndSettle();
    expect(find.text('No Assignments Found'), findsOneWidget, reason: 'nothing loads until Search');
    bloc.add(const AssignmentsSearchRequested());
    await tester.pumpAndSettle();
  }

  testWidgets('phone: cards after Search', (tester) async {
    await pump(tester, const Size(390, 844), const AssignmentsPhoneView());
    expect(find.text('4 jobs'), findsOneWidget);
    expect(find.text('Active'), findsWidgets);
  });

  testWidgets('tablet portrait, dark: two columns of cards', (tester) async {
    await pump(tester, const Size(820, 1180), const AssignmentsTabletPortraitView(), dark: true);
    expect(find.text('RTI000000001'), findsOneWidget);
  });

  testWidgets('tablet landscape: filter panel and table with remarks rows', (tester) async {
    await pump(tester, const Size(1366, 1024), const AssignmentsTabletLandscapeView());
    expect(find.text('Filter assignments'), findsOneWidget);
    expect(find.textContaining('No remarks provided.', findRichText: true), findsWidgets);
  });
}
