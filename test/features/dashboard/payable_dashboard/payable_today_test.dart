import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/dashboard/payable_dashboard/today/bloc/payable_today_cubit.dart';
import 'package:maleva/features/dashboard/payable_dashboard/today/data/payable_today_api.dart';
import 'package:maleva/features/dashboard/payable_dashboard/today/data/payable_today_models.dart';
import 'package:maleva/features/dashboard/payable_dashboard/today/view/payable_today_tab.dart';
import 'package:maleva/features/dashboard/payable_dashboard/view/payable_tabs.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/local_fonts.dart';

/// Answers by path, so parallel calls get the right body whatever their order.
class RouteAdapter implements HttpClientAdapter {
  final Map<String, (int, String)> replies = {};
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream, Future<void>? cancelFuture) async {
    requests.add(options);
    final key = options.path.startsWith('/api/common/checkFiles')
        ? 'checkFiles ${options.queryParameters['imageDirectory']}'
        : options.path;
    final (status, body) = replies[key] ?? (404, '{}');
    return ResponseBody.fromString(body, status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

class MockApi extends Mock implements PayableTodayApi {}

Map<String, dynamic> pendingRow(int id, String sub, double amount, int due, {String? date, int detailed = 0}) => {
      'Id': id,
      'ExpenseName': 'UTILITY',
      'SubExpenseName': sub,
      'Amount': amount,
      'DueDate': date,
      'DueReportId': due,
      'DetailedId': detailed,
      'BankName': 'MAYBANK',
      'AccountNo': '5140 1234 5678',
    };

PendingPayment pending(int id, DueState due, {double amount = 100, DateTime? date, String name = 'X'}) =>
    PendingPayment(
        id: id,
        expenseName: 'EXP',
        subExpenseName: name,
        amount: amount,
        dueDate: date,
        dueDateText: null,
        due: due,
        isVendor: false,
        bankName: 'MAYBANK',
        accountNo: '5140 1234 5678');

CompletedPayment paid(int id, {bool supplier = false, double amount = 50}) => CompletedPayment(
    id: id,
    date: '02/10/2026',
    number: 'PV-$id',
    paidTo: 'PAY $id',
    refNumber: null,
    amount: amount,
    remarks: null,
    isSupplier: supplier);

void main() {
  setUpAll(() async {
    await installLocalTestFonts();
  });

  group('rules', () {
    test('to pay: overdue, then due soon, then the rest; earliest date first, no date last', () {
      final rows = PayableRules.sortToPay([
        pending(1, DueState.scheduled, date: DateTime(2026, 11, 1)),
        pending(2, DueState.dueSoon, date: DateTime(2026, 11, 3)),
        pending(3, DueState.overdue),
        pending(4, DueState.overdue, date: DateTime(2026, 10, 20)),
        pending(5, DueState.dueSoon, date: DateTime(2026, 11, 2)),
      ]);
      expect(rows.map((r) => r.id), [4, 3, 5, 2, 1]);
    });

    test('card totals: two overdue of RM 100 and RM 250', () {
      final t = PayableRules.total([
        pending(1, DueState.overdue, amount: 100),
        pending(2, DueState.overdue, amount: 250),
        pending(3, DueState.dueSoon, amount: 999),
      ], DueState.overdue);
      expect(t.count, 2);
      expect(t.amount, 350);
    });

    test('document: a voucher looks in PaymentVoucher, a supplier payment in PayBills', () {
      const docs = DocumentIndex(payBills: {7}, paymentVoucher: {41});
      final rows = [paid(41), paid(42), paid(7, supplier: true), paid(41, supplier: true)];
      expect(PayableRules.withoutDocument(rows, docs).map((p) => '${p.id}${p.isSupplier ? 'S' : 'V'}'), ['42V', '41S']);
      expect(PayableRules.withoutDocument(rows, null), isEmpty, reason: 'unknown check marks nothing missing');
    });

    test('name: sub-expense, else expense, else Payment', () {
      expect(PendingPayment.fromJava({'SubExpenseName': ' ', 'ExpenseName': 'TNB'}).name, 'TNB');
      expect(PendingPayment.fromJava({}).name, 'Payment');
    });
  });

  group('api', () {
    late RouteAdapter adapter;
    late PayableTodayApi api;
    final today = DateTime(2026, 10, 30);

    setUp(() {
      adapter = RouteAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter;
      api = PayableTodayApi(dio, DashboardApi(dio));
    });

    test('pending: today + 5 days, Java fields read as sent', () async {
      adapter.replies['/api/dashboard/pending-payment/6'] = (
        200,
        jsonEncode({
          'success': true,
          'data': [pendingRow(9, 'KWANG HENG', 500, 2, date: '2026-10-20 00:00:00.0', detailed: 1)],
        })
      );
      final rows = await api.pending(6, today);
      expect(adapter.requests.single.uri.query, 'dueDate=2026-11-04&toDate=2026-10-30');
      final r = rows.single;
      expect(r.name, 'KWANG HENG');
      expect(r.due, DueState.overdue);
      expect(r.isVendor, isTrue);
      expect(r.dueDate, DateTime(2026, 10, 20));
      expect(r.accountNo, '5140 1234 5678');
    });

    test('completed: from the 1st of the month; legacy Data1 also read', () async {
      adapter.replies['/api/dashboard/completed-payment/6'] = (
        200,
        jsonEncode({
          'IsSuccess': true,
          'Data1': [
            {'Id': 41, 'SSaleDate': '02/10/2026', 'CNumberDisplay': 'PV-41', 'ExpenseName': 'TNB', 'Amount': 80, 'DetailedId': 0},
          ],
        })
      );
      final rows = await api.completed(6, today);
      expect(adapter.requests.single.uri.query, 'fromDate=2026-10-01&toDate=2026-10-30');
      expect(rows.single.number, 'PV-41');
      expect(rows.single.isSupplier, isFalse);
    });

    test('documents: one checkFiles per folder', () async {
      adapter.replies['checkFiles /6/PayBills'] = (200, jsonEncode({'ok': true, 'data': [7, 8]}));
      adapter.replies['checkFiles /6/PaymentVoucher'] = (200, jsonEncode({'ok': true, 'data': []}));
      final docs = await api.documents(6);
      expect(docs.payBills, {7, 8});
      expect(docs.paymentVoucher, isEmpty);
    });

    test('a refusal is an ApiFailure with the server message', () async {
      adapter.replies['/api/dashboard/pending-payment/6'] = (200, jsonEncode({'success': false, 'message': 'No access'}));
      expect(() => api.pending(6, today), throwsA(isA<ApiFailure>().having((e) => e.message, 'message', 'No access')));
    });

    test('expenses: month totals and top heads', () async {
      adapter.replies['/api/dashboard/expense/6'] = (
        200,
        jsonEncode({
          'success': true,
          'data': {
            'MonthSales': 40,
            'MonthAmount': 12500,
            'expenses': [
              {'ExpenseName': 'TOLL', 'ExpCount': 3, 'ExpAmount': 300},
              {'ExpenseName': 'FUEL', 'ExpCount': 9, 'ExpAmount': 9000},
            ],
          },
        })
      );
      final e = await api.expenses(6, today);
      expect(e.month.count, 40);
      expect(e.month.amount, 12500);
      expect(e.top(1).single.name, 'FUEL');
    });
  });

  group('cubit and tab', () {
    late MockApi api;
    final today = DateTime(2026, 10, 30, 9);
    const docs = DocumentIndex(payBills: {}, paymentVoucher: {41});
    const spent = ExpenseSummary(
      today: CountAmount(1, 10),
      yesterday: CountAmount(2, 20),
      week: CountAmount(5, 500),
      month: CountAmount(40, 12500),
      heads: [ExpenseHead(name: 'FUEL', count: 9, amount: 9000)],
    );

    setUp(() {
      api = MockApi();
      when(() => api.pending(any(), any())).thenAnswer((_) async => [
            pending(1, DueState.overdue, amount: 100, name: 'TNB'),
            pending(2, DueState.overdue, amount: 250, name: 'RENT'),
            pending(3, DueState.dueSoon, amount: 70, name: 'WATER'),
          ]);
      when(() => api.completed(any(), any())).thenAnswer((_) async => [paid(41), paid(42, amount: 30)]);
      when(() => api.documents(any())).thenAnswer((_) async => docs);
      when(() => api.expenses(any(), any())).thenAnswer((_) async => spent);
    });

    setUpAll(() => registerFallbackValue(DateTime(2026)));

    PayableTodayCubit cubit() => PayableTodayCubit(api, companyId: () => 6, clock: () => today);

    test('one section failing leaves the others loaded; retry reloads only it', () async {
      when(() => api.expenses(any(), any())).thenThrow(const ApiFailure('Server down'));
      final c = cubit();
      await c.load();
      expect(c.state.pending.data, hasLength(3));
      expect(c.state.expenses.error, 'Server down');
      when(() => api.expenses(any(), any())).thenAnswer((_) async => spent);
      await c.retry(PayableSection.expenses);
      expect(c.state.expenses.data, isNotNull);
      verify(() => api.pending(6, DateTime(2026, 10, 30))).called(1);
    });

    Future<List<PayableTab>> pump(WidgetTester tester, PayableTodayCubit c, {Size size = const Size(390, 2600)}) async {
      final opened = <PayableTab>[];
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await c.load();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: BlocProvider.value(value: c, child: PayableTodayView(onOpen: opened.add))),
      ));
      await tester.pump();
      return opened;
    }

    testWidgets('phone: cards, to-pay order, no-document list, Open switches tab', (tester) async {
      final opened = await pump(tester, cubit());

      final overdue = find.byKey(const ValueKey('card-overdue'));
      expect(find.descendant(of: overdue, matching: find.text('2')), findsOneWidget);
      expect(find.descendant(of: overdue, matching: find.text('RM 350.00')), findsOneWidget);
      final noDoc = find.byKey(const ValueKey('card-no-doc'));
      expect(find.descendant(of: noDoc, matching: find.text('1')), findsOneWidget);
      expect(find.text('PAY 42'), findsOneWidget);
      expect(find.text('PAY 41'), findsNothing);
      expect(find.text('RM 12,500.00'), findsOneWidget);

      final tnb = tester.getTopLeft(find.text('TNB')).dy;
      final water = tester.getTopLeft(find.text('WATER')).dy;
      expect(tnb, lessThan(water));

      await tester.tap(find.byKey(const ValueKey('open-records')));
      expect(opened, [PayableTab.records]);
    });

    testWidgets('expense failing: only Spent shows Retry', (tester) async {
      when(() => api.expenses(any(), any())).thenThrow(const ApiFailure('Server down'));
      await pump(tester, cubit());
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Server down'), findsOneWidget);
      expect(find.text('TNB'), findsOneWidget);
    });

    testWidgets('row sheet: Copy puts the account number on the clipboard', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String?;
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

      await pump(tester, cubit());
      await tester.tap(find.text('RENT'));
      await tester.pumpAndSettle();
      expect(find.text('MAYBANK'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('copy-account')));
      await tester.pump();
      expect(copied, '5140 1234 5678');
      expect(find.text('Copied'), findsOneWidget);
    });

    testWidgets('tablet: four cards in one row', (tester) async {
      await pump(tester, cubit(), size: const Size(1100, 1600));
      final y = [
        for (final k in ['card-overdue', 'card-due-soon', 'card-paid', 'card-no-doc'])
          tester.getTopLeft(find.byKey(ValueKey(k))).dy
      ];
      expect(y.toSet(), hasLength(1));
    });
  });
}
