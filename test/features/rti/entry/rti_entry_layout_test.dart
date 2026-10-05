import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/theme/app_theme.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/view/phone/rti_entry_phone.dart';
import 'package:maleva/features/rti/view/tablet/rti_entry_tablet.dart';
import 'package:mocktail/mocktail.dart';

import 'rti_mocks.dart';

// The phone steps and the tablet layouts build without overflow, in light and dark.
void main() {
  Future<RtiEntryBloc> pump(WidgetTester t, Size size, Widget Function() child, {bool dark = false}) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final m = mockRepository();
    when(() => m.api.load(44)).thenAnswer((_) async => (
          master: <String, dynamic>{'id': 44, 'cnumberDisplay': 'RTI000000044', 'saleDate': '2026-10-02T00:00:00', 'driverRefId': 5, 'truckRefId': 72, 'routeActivities': [
            {'id': 3, 'sequenceNo': 1, 'activityType': 'SEAL', 'fullRoute': 'PTP', 'eta': '2026-10-03T08:30:00', 'createdDate': '2026-10-02T10:00:00'},
          ]},
          lines: [
            <String, dynamic>{'id': 9, 'saleOrderMasterRefId': 20498, 'salary': 120, 'jobNo': 'TR1', 'customerName': 'ACME', 'originD': 'PKG', 'destinationD': 'KL'},
            <String, dynamic>{'id': 10, 'saleOrderMasterRefId': 0, 'salary': 0, 'jobNo': 'TR404'},
          ],
        ));
    when(() => m.lookup.saleOrder(any())).thenThrow(Exception('offline'));
    final bloc = RtiEntryBloc(repository: m.repo, initialForm: () => const RtiForm(rtiDate: '2026-10-05'))..add(const RtiEntryStarted(rtiId: 44));
    await t.pumpWidget(MaterialApp(
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      home: BlocProvider.value(value: bloc, child: child()),
    ));
    await t.pump(const Duration(milliseconds: 100));
    await t.pump(const Duration(milliseconds: 100));
    return bloc;
  }

  for (final dark in [false, true]) {
    testWidgets('phone: every step (${dark ? 'dark' : 'light'})', (t) async {
      final bloc = await pump(t, const Size(390, 844), () => RtiEntryPhone(employeeName: 'Siti A.', onRetry: () {}), dark: dark);
      expect(find.text('RTI (Siti A.)'), findsOneWidget);
      expect(find.text('Edit Mode'), findsOneWidget);
      for (var step = 0; step < 5; step++) {
        bloc.add(RtiStepChanged(step));
        await t.pump(const Duration(milliseconds: 100));
        await t.pump(const Duration(milliseconds: 100));
        expect(t.takeException(), isNull, reason: 'step $step');
      }
      bloc.add(const RtiStepChanged(2));
      await t.pump(const Duration(milliseconds: 100));
      await t.pump(const Duration(milliseconds: 100));
      expect(find.text('Row 2: job TR404 was not found. Press Enter in Job No to look it up, or remove the row.'), findsOneWidget);
      await t.runAsync(bloc.close);
    });
  }

  for (final size in [const Size(800, 1280), const Size(1280, 800)]) {
    testWidgets('tablet ${size.width < size.height ? 'portrait' : 'landscape'}', (t) async {
      final bloc = await pump(t, size, () => RtiEntryTablet(employeeName: '', columns: size.width < size.height ? 2 : 3, onRetry: () {}));
      expect(t.takeException(), isNull);
      expect(find.text('Save  F1'), findsOneWidget);
      await t.scrollUntilVisible(find.text('JOB LINES'), 300, scrollable: find.byType(Scrollable).first);
      expect(find.text('JOB LINES'), findsOneWidget);
      await t.scrollUntilVisible(find.text('ROUTE ACTIVITIES'), 300, scrollable: find.byType(Scrollable).first);
      expect(t.takeException(), isNull);
      await t.runAsync(bloc.close);
    });
  }
}
