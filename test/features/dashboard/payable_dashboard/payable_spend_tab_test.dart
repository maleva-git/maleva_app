import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/bloc/ceo_dashboard_cubit.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/data/ceo_analytics_api.dart';
import 'package:maleva/features/dashboard/ceo_dashboard/data/ceo_analytics_models.dart';
import 'package:maleva/features/dashboard/payable_dashboard/view/payable_spend_tab.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/local_fonts.dart';
import '../ceo_dashboard/ceo_fixtures.dart';

class _Api extends Mock implements CeoAnalyticsApi {}

/// PO & Vouchers on the Payable dashboard (change `payable-desk-today`): the CEO Expenses screens in spend-only mode.
/// The server opens only the spend part to roles 900 / 1100, so the CEO overview must never be asked.
void main() {
  setUpAll(installLocalTestFonts);

  late _Api api;

  void answer(String kind, Map<String, dynamic> json) => when(() => api.details(
        kind: kind,
        key: any(named: 'key'),
        fromDate: any(named: 'fromDate'),
        toDate: any(named: 'toDate'),
      )).thenAnswer((_) async => CeoDetails.fromJava(json));

  setUp(() {
    api = _Api();
    when(() => api.spend(fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate')))
        .thenAnswer((_) async => CeoSpendFlow.fromJava(spendJson()));
    answer('PO_SUPPLIERS', breakdownJson('PO_SUPPLIERS', [(9, 'KWANG HENG', 4, 3200), (11, 'PETRON', 2, 900)], noun: 'POs'));
    answer('PAYABLE_PARTIES', breakdownJson('PAYABLE_PARTIES', [(1, 'MAYBANK', 2, 3000)]));
  });

  Future<CeoDashboardCubit> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final cubit = CeoDashboardCubit(api, clock: () => DateTime(2026, 10, 16, 9));
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: PayableSpendTab(cubit: cubit))));
    await tester.pumpAndSettle();
    return cubit;
  }

  testWidgets('money flow from /spend; purchase orders as the headline; no CEO overview', (tester) async {
    await pump(tester);

    final hero = find.byKey(const Key('ceo_expenses_hero'));
    expect(find.descendant(of: hero, matching: find.text('RM 5,000.00')), findsOneWidget,
        reason: 'ordered.amount of the spend flow');
    expect(find.descendant(of: hero, matching: find.text('10 purchase orders')), findsOneWidget);
    expect(find.byKey(const Key('ceo_spend_help')), findsOneWidget);
    verify(() => api.spend(fromDate: '2026-10-01', toDate: '2026-10-16')).called(1);
    verifyNever(() => api.overview(fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate')));
  });

  testWidgets('only the spend views: no Fuel, no By category', (tester) async {
    await pump(tester);

    for (final label in ['Money flow', 'By supplier', 'By truck', '12 months', 'Whom we owe']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('Fuel'), findsNothing);
    expect(find.text('By category'), findsNothing);
  });

  testWidgets('by supplier and whom we owe read spend lists', (tester) async {
    await pump(tester);

    await tester.tap(find.text('By supplier'));
    await tester.pumpAndSettle();
    expect(find.text('KWANG HENG'), findsOneWidget);

    await tester.ensureVisible(find.text('Whom we owe'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Whom we owe'));
    await tester.pumpAndSettle();
    expect(find.text('MAYBANK'), findsOneWidget);
    expect(find.byKey(const Key('ceo_owed_side')), findsNothing, reason: 'no customer side');
    verifyNever(() => api.overview(fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate')));
  });

  testWidgets('a new period loads the spend flow of its days, still no overview', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Last month'));
    await tester.pumpAndSettle();

    verify(() => api.spend(fromDate: '2026-09-01', toDate: '2026-09-30')).called(1);
    verifyNever(() => api.overview(fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate')));
  });

  testWidgets('server refusal (backend not deployed yet) shows its message with Retry', (tester) async {
    when(() => api.spend(fromDate: any(named: 'fromDate'), toDate: any(named: 'toDate')))
        .thenThrow(Exception('Only the CEO can open this dashboard'));
    await pump(tester);

    expect(find.textContaining('Only the CEO can open this dashboard'), findsWidgets);
  });
}
