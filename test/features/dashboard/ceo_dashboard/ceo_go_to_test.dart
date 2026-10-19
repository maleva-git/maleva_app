import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/view/ceo_go_to.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../support/local_fonts.dart';

/// The CEO screen's "Go to" (owner 2026-10-19) and the one-screen Mail Monitor.
void main() {
  setUpAll(installLocalTestFonts);

  setUp(() async {
    SharedPreferences.setMockInitialValues({'Username': 'CEO'});
    AppGlobals.storagenew = await SharedPreferences.getInstance();
  });

  test('the places are the web quick access ones, in its order', () {
    expect([for (final p in ceoGoToPlaces()) p.label],
        ['Truck Planning', 'Truck Location', 'Vessel Planning', 'Incident Report', 'Mail Monitor']);
  });

  testWidgets('the quick access row shows every place as a button; a tap opens it', (tester) async {
    final opened = <String>[];
    final places = [
      for (final p in ceoGoToPlaces())
        CeoGoTo(
            id: p.id,
            label: p.label,
            caption: p.caption,
            icon: p.icon,
            color: p.color,
            live: p.live,
            open: (_) => opened.add(p.id)),
    ];
    tester.view.physicalSize = const Size(1200, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: CeoQuickAccess(places: places))));
    for (final p in places) {
      expect(find.byKey(Key('ceo_go_${p.id}')), findsOneWidget, reason: p.label);
      expect(find.text(p.label), findsOneWidget);
    }
    expect(find.text('LIVE'), findsNWidgets(2)); // truck location and mail monitor
    await tester.tap(find.byKey(const Key('ceo_go_mail_monitor')));
    await tester.tap(find.byKey(const Key('ceo_go_truck_planning')));
    expect(opened, ['mail_monitor', 'truck_planning']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a narrow phone scrolls the row sideways without overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: CeoQuickAccess())));
    expect(find.byKey(const Key('ceo_go_truck_planning')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Mail Monitor shows the mailboxes and the response report in one screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CeoMailScreen(mailboxes: Text('MAILBOXES BODY'), responseReport: Text('RESPONSE REPORT BODY')),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Mail Monitor'), findsWidgets);
    expect(find.text('MAILBOXES BODY'), findsOneWidget);
    await tester.tap(find.text('Response report'));
    await tester.pumpAndSettle();
    expect(find.text('RESPONSE REPORT BODY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
