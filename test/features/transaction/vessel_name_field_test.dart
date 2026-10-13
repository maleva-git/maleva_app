import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/vessel_master/vessel_master_api.dart';
import 'package:maleva/core/vessel_master/vessel_master_models.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/vessel_suggest_cubit.dart';
import 'package:maleva/features/transaction/salesorder/add/view/vessel_name_field.dart';
import 'package:mocktail/mocktail.dart';

class _VesselMasters extends Mock implements VesselMasterApi {}

const _call = PtpCall(
  id: 412,
  vesselName: 'MAERSK RIO NEGRO',
  voyage: '641S',
  scn: '269EK6',
  arriveAt: '2026-10-10T06:30',
  arriveEstimated: true,
  departAt: '2026-10-11T17:00',
);

/// The sales form's vessel field with suggestions (vessel-master-and-ptp-schedule, task 2.2).
void main() {
  late _VesselMasters api;
  late VesselSuggestCubit cubit;
  late TextEditingController controller;
  late List<String> changes;
  late List<(VesselSuggestion, PtpCall?)> picks;
  late int leaves;

  setUp(() {
    api = _VesselMasters();
    cubit = VesselSuggestCubit(api, debounce: const Duration(milliseconds: 300));
    controller = TextEditingController();
    changes = [];
    picks = [];
    leaves = 0;
  });

  tearDown(() => cubit.close());

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(children: [
            VesselNameField(
              controller: controller,
              suggestions: cubit,
              leg: VesselLeg.off,
              port: () => 'PTP',
              enabled: true,
              onChanged: changes.add,
              onPicked: (v, c) => picks.add((v, c)),
              onLeave: () => leaves++,
              decoration: const InputDecoration(hintText: 'Off Vessel Name'),
            ),
            const TextField(key: Key('next_field')),
          ]),
        ),
      ));

  testWidgets('typing shows the vessels and calls for that leg and port, after the debounce', (tester) async {
    when(() => api.suggest('RIO', leg: 'OFF', port: 'PTP')).thenAnswer((_) async => const [
          VesselSuggestion(vesselMasterId: 88, vesselName: 'MAERSK RIO NEGRO', calls: [_call]),
          VesselSuggestion(vesselName: 'RIO GRANDE', matchedAlias: 'RIO GRAND'),
        ]);
    await pump(tester);

    await tester.enterText(find.byType(TextField).first, 'RIO');
    await tester.pump(const Duration(milliseconds: 100));
    verifyNever(() => api.suggest(any(), leg: any(named: 'leg'), port: any(named: 'port')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(changes, ['RIO']);
    expect(find.text('MAERSK RIO NEGRO 641S'), findsOneWidget);
    expect(find.text('ETA 10 Oct 06:30 est. · ETD 11 Oct 17:00 · SCN 269EK6'), findsOneWidget);
    expect(find.text('RIO GRANDE'), findsOneWidget);
    expect(find.text('was RIO GRAND'), findsOneWidget);

    await tester.tap(find.text('MAERSK RIO NEGRO 641S'));
    await tester.pump();

    expect(picks.single.$1.vesselMasterId, 88);
    expect(picks.single.$2?.id, 412);
    expect(find.text('RIO GRANDE'), findsNothing, reason: 'the list closes on a pick');
  });

  testWidgets('a failed request shows no rows and keeps the typed text', (tester) async {
    when(() => api.suggest(any(), leg: any(named: 'leg'), port: any(named: 'port')))
        .thenThrow(const ApiFailure('No internet connection. Check your network.'));
    await pump(tester);

    await tester.enterText(find.byType(TextField).first, 'CMA CGM PETRON');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.byType(ListTile), findsNothing);
    expect(controller.text, 'CMA CGM PETRON');
    expect(changes.last, 'CMA CGM PETRON');
  });

  testWidgets('one character asks nothing; at most five rows show; leaving the field closes the list', (tester) async {
    when(() => api.suggest('MA', leg: 'OFF', port: 'PTP')).thenAnswer((_) async => [
          for (var i = 0; i < 4; i++)
            VesselSuggestion(vesselName: 'VESSEL $i', calls: [
              PtpCall(id: i * 10 + 1, vesselName: 'VESSEL $i', voyage: 'A$i'),
              PtpCall(id: i * 10 + 2, vesselName: 'VESSEL $i', voyage: 'B$i'),
            ]),
        ]);
    await pump(tester);

    await tester.enterText(find.byType(TextField).first, 'M');
    await tester.pump(const Duration(milliseconds: 400));
    verifyNever(() => api.suggest(any(), leg: any(named: 'leg'), port: any(named: 'port')));

    await tester.enterText(find.byType(TextField).first, 'MA');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.byType(ListTile), findsNWidgets(5));

    await tester.tap(find.byKey(const Key('next_field')));
    await tester.pump();
    expect(find.byType(ListTile), findsNothing);
    expect(leaves, 1);
    expect(picks, isEmpty);
  });
}
