import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/dashboard/payable_dashboard/expenses/expense_report_tab.dart';
import 'package:maleva/features/dashboard/payable_dashboard/records/data/payable_record.dart';
import 'package:maleva/features/dashboard/payable_dashboard/records/data/payable_records_api.dart';
import 'package:maleva/features/dashboard/payable_dashboard/today/data/payable_today_models.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/local_fonts.dart';

class MockApi extends Mock implements PayableRecordsApi {}

PayableRecord row(RecordKind kind, int id, String head, String status, double amount, {String party = 'X'}) =>
    PayableRecord(
        kind: kind, id: id, number: 'N$id', date: DateTime(2026, 10, id), party: party, amount: amount, status: status, head: head);

Map<String, dynamic> answer({bool withNewFields = true}) => {
      'MonthSales': 5,
      'MonthAmount': 15052.91,
      'expenses': [
        {'ExpenseName': 'VENDOR', 'ExpCount': 4, 'ExpAmount': 5052.91, if (withNewFields) 'ExpApproved': 3000},
        {'ExpenseName': 'FUEL', 'ExpCount': 1, 'ExpAmount': 10000, if (withNewFields) 'ExpApproved': 10000},
      ],
      if (withNewFields) 'RejectedCount': 2,
      if (withNewFields) 'RejectedAmount': 450,
    };

/// The payable expense report (change payable-expense-report): heads with count and amount, a Total row like the
/// team's sheet (Fuel 1 RM 10,000 · Vendor 4 RM 5,052.91 · Total), approved / waiting, rejected left out.
void main() {
  setUpAll(installLocalTestFonts);
  setUpAll(() {
    registerFallbackValue(RecordKind.po);
    registerFallbackValue(DateTime(2026));
  });

  test('reads the approved part and the rejected left out; an older server reads as 0', () {
    final s = ExpenseSummary.fromJava(answer());
    expect(s.headsTotal, closeTo(15052.91, 0.001));
    expect(s.headsApproved, 13000);
    expect(s.heads.first.waiting, closeTo(2052.91, 0.001));
    expect(s.rejected.count, 2);
    expect(s.rejected.amount, 450);

    final old = ExpenseSummary.fromJava(answer(withNewFields: false));
    expect(old.headsApproved, 0);
    expect(old.rejected.count, 0);
  });

  test('a head opens its vouchers and pay bills, never the rejected ones', () {
    final rows = recordsOfHead([
      row(RecordKind.voucher, 1, 'FUEL', 'ACCEPETED', 100),
      row(RecordKind.voucher, 2, 'fuel ', 'REJECTED', 50),
      row(RecordKind.payBill, 3, 'FUEL', 'SEND FOR APPROVAL', 300),
      row(RecordKind.voucher, 4, 'VENDOR', 'ACCEPETED', 70),
    ], 'FUEL');
    expect(rows.map((r) => r.id), [3, 1]);
  });

  Future<MockApi> pump(WidgetTester tester, {Map<String, dynamic>? json}) async {
    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final api = MockApi();
    when(() => api.list(RecordKind.voucher, any(), any())).thenAnswer((_) async => [
          row(RecordKind.voucher, 1, 'FUEL', 'ACCEPETED', 10000, party: 'PETRON'),
          row(RecordKind.voucher, 2, 'FUEL', 'REJECTED', 450, party: 'SHELL'),
        ]);
    when(() => api.list(RecordKind.payBill, any(), any())).thenAnswer((_) async => []);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ExpenseReportTab(
          load: (_, __) async => ExpenseSummary.fromJava(json ?? answer()),
          records: api,
          clock: () => DateTime(2026, 10, 30),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    return api;
  }

  testWidgets('heads biggest first, a Total row, the rejected note', (tester) async {
    await pump(tester);

    final fuel = tester.getTopLeft(find.byKey(const ValueKey('head-FUEL'))).dy;
    final vendor = tester.getTopLeft(find.byKey(const ValueKey('head-VENDOR'))).dy;
    expect(fuel, lessThan(vendor));
    expect(find.descendant(of: find.byKey(const ValueKey('expense-total-row')), matching: find.text('RM 15,052.91')),
        findsOneWidget);
    expect(find.descendant(of: find.byKey(const ValueKey('expense-total-row')), matching: find.text('5')), findsOneWidget);
    expect(find.textContaining('Left out: 2 rejected'), findsOneWidget);
    expect(find.text('RM 5,052.91'), findsOneWidget);
  });

  testWidgets('tap a head: its records, no rejected', (tester) async {
    final api = await pump(tester);

    await tester.tap(find.byKey(const ValueKey('head-FUEL')));
    await tester.pumpAndSettle();

    expect(find.text('PETRON'), findsOneWidget);
    expect(find.text('SHELL'), findsNothing);
    verify(() => api.list(RecordKind.voucher, DateTime(2026, 10, 1), DateTime(2026, 10, 30))).called(1);
  });

  testWidgets('last month asks its own days', (tester) async {
    DateTime? from, to;
    tester.view.physicalSize = const Size(390, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ExpenseReportTab(
          load: (f, t) async {
            from = f;
            to = t;
            return ExpenseSummary.fromJava(answer());
          },
          records: MockApi(),
          clock: () => DateTime(2026, 10, 30),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Last month'));
    await tester.pumpAndSettle();
    expect(from, DateTime(2026, 9, 1));
    expect(to, DateTime(2026, 9, 30));
  });
}
