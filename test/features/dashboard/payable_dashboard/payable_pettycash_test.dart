import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/dashboard/payable_dashboard/pettycash/data/petty_cash_ai.dart';
import 'package:maleva/features/dashboard/payable_dashboard/pettycash/data/petty_cash_api.dart';
import 'package:maleva/features/dashboard/payable_dashboard/pettycash/data/petty_cash_draft.dart';
import 'package:maleva/features/dashboard/payable_dashboard/pettycash/view/petty_cash_form_page.dart';
import 'package:maleva/features/dashboard/payable_dashboard/po/data/po_draft.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/local_fonts.dart';

class RouteAdapter implements HttpClientAdapter {
  final Map<String, (int, String)> replies = {};
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream, Future<void>? cancelFuture) async {
    requests.add(options);
    final (status, body) = replies[options.path] ?? (404, '{}');
    return ResponseBody.fromString(body, status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

class MockApi extends Mock implements PettyCashApi {}

class MockFiles extends Mock implements AttachmentsApi {}

const lim = Option(15, 'LIM AH KOW');
const mei = Option(16, 'LIM MEI');
const toll = PettyCashAccount(502, 'TOLL', sub: '6100-05 · EXPENSES', code: '6100-05', extra: 7, classificationName: 'Travel');
const parking = PettyCashAccount(503, 'PARKING', sub: '6100-06', code: '6100-06');

PettyCashLastBalance last({bool ready = true, bool found = true, double? after = 15.99}) => PettyCashLastBalance(
    ready: ready, found: found, sheetId: found ? 74 : null, number: found ? 'PTC000000074' : '', date: DateTime(2026, 9, 12), balanceAfter: found ? after : null);

Map<String, dynamic> editJson({double? expected}) => {
      'id': 80,
      'cNumberDisplay': 'PTC000000080',
      'employeeRefId': 15,
      'sPettyCashDate': '28/10/2026',
      'department': 'ACCOUNTS',
      'paymentStatus': 'SEND FOR APPROVAL',
      'remark': 'October',
      'balancesReady': true,
      'balanceBefore': 100,
      'cashReceived': 50,
      'balanceAfter': 120,
      'balanceBeforeTyped': false,
      if (expected != null) 'expectedBalanceBefore': expected,
      'pettyCashDetails': [
        {'id': 3, 'items': 'PLUS', 'notes': 'toll', 'amount': 30, 'accountGroupRefId': 502, 'accountCode': '6100-05', 'accountName': 'TOLL', 'classification': 7, 'classificationName': 'Travel'},
      ],
    };

void main() {
  setUpAll(installLocalTestFonts);
  setUpAll(() {
    registerFallbackValue(File('x'));
    registerFallbackValue(<File>[]);
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(DateTime(2026));
  });

  group('draft maths and rules (web pettyCashBalance.ts, pettyCashLines.ts, buildSavePayload)', () {
    test('money rounding, blanks as 0, This balance', () {
      expect(roundMoney(1.005), 1.01);
      expect(roundMoney(-1.005), -1.01);
      expect(roundMoney(-0.001), 0);
      expect(moneyOf(' 1,200.50 '), 1200.5);
      expect(moneyOf('abc'), 0);
      expect(toMoneyOrNull(''), isNull);
      expect(moneyText(15.999), '16.00');
      expect(computeThisBalance('15.99', '2000', 1739.91), 276.08);
      expect(computeThisBalance('10', '', 25), -15);
    });

    test('Last balance follows the server, the pencil, or the saved sheet; This balance is live', () {
      final d = PettyCashDraft(lastBalance: last(), lines: [PettyCashLine(items: 'A', amount: '1739.91')], cashReceived: '2000');
      expect(d.ready, isTrue);
      expect(d.balanceBefore, '15.99');
      expect(d.sourceNote, 'from PTC000000074, 12/09/2026');
      expect(d.thisBalance, 276.08);
      d.typedBefore = '20';
      expect(d.thisBalance, 280.09);
      expect(d.sourceNote, 'Typed by hand — last sheet says RM 15.99');
      d.lastBalance = last(found: false);
      d.typedBefore = null;
      expect(d.balanceBefore, '');
      expect(d.sourceNote, 'No earlier sheet: type the opening balance');
      expect(d.thisBalance, 260.09);

      final e = PettyCashDraft.fromEdit(editJson());
      expect(e.thisBalance, 120, reason: 'an opened sheet shows what was signed until an amount changes');
      e.dirty = true;
      expect(e.thisBalance, 120.0); // 100 + 50 − 30
      e.lines.first.amount = '200';
      expect(e.thisBalance, -50);
      expect(e.short, isTrue);
    });

    test('problems in the web order', () {
      final d = PettyCashDraft();
      expect(d.problems(), ['Choose the employee type']);
      d.department = 'ACCOUNTS';
      expect(d.problems(), ['Add at least one item']);
      d.lines = [PettyCashLine(amount: '5')];
      expect(d.problems(), ['Each row needs an item and a valid amount']);
      d.lines = [PettyCashLine(items: 'A', amount: 'x')];
      expect(d.problems(), ['Each row needs an item and a valid amount']);
      d.lines = [PettyCashLine(items: 'A', amount: '-5'), PettyCashLine()];
      expect(d.problems(), isEmpty, reason: 'negative passes, a blank row is left out');
    });

    test('save body as the web sends it; no balances when not ready', () {
      final d = PettyCashDraft(
        date: DateTime(2026, 10, 30),
        department: 'ACCOUNTS',
        remark: 'Oct',
        lastBalance: last(),
        cashReceived: '2,000',
        lines: [PettyCashLine(items: 'PLUS', notes: 'toll', amount: '12.5', account: toll), PettyCashLine(items: 'X', amount: '3'), PettyCashLine()],
      );
      final j = d.toJson(employeeId: 9);
      expect(j['id'], 0);
      expect(j['employeeRefId'], 9, reason: 'no Requested by: the signed-in employee');
      expect(j['pettyCashDate'], '2026-10-30');
      expect(j['paymentStatus'], '');
      expect(j['balanceBefore'], 15.99);
      expect(j['cashReceived'], 2000);
      expect(j['balanceBeforeTyped'], false);
      expect(j['pettyCashDetails'], [
        {'items': 'PLUS', 'amount': 12.5, 'notes': 'toll', 'accountGroupRefId': 502, 'classification': 7},
        {'items': 'X', 'amount': 3.0, 'notes': '', 'accountGroupRefId': 0, 'classification': 0},
      ]);
      d.employee = lim;
      d.lastBalance = last(ready: false);
      final n = d.toJson(employeeId: 9);
      expect(n['employeeRefId'], 15);
      expect((n['balanceBefore'], n['cashReceived'], n['balanceBeforeTyped']), (null, null, false));
    });

    test('fromEdit keeps the saved line account and classification, the typed flag and the chain note', () {
      final j = editJson(expected: 90)..['balanceBeforeTyped'] = true;
      final d = PettyCashDraft.fromEdit(j, employees: const [lim]);
      expect(d.id, 80);
      expect(d.number, 'PTC000000080');
      expect(d.date, DateTime(2026, 10, 28));
      expect(d.employee, lim);
      expect(d.employee!.name, 'LIM AH KOW');
      expect(d.typedBefore, '100.00');
      expect(d.cashReceived, '50.00');
      expect(d.saved!.expectedBefore, 90);
      final l = d.lines.single;
      expect((l.id, l.items, l.amount, l.account!.id, l.account!.classification), (3, 'PLUS', '30', 502, 7));
    });
  });

  group('api reads the Java answers as they are', () {
    late RouteAdapter adapter;
    late PettyCashApi api;
    setUp(() {
      adapter = RouteAdapter();
      api = PettyCashApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: 6);
    });

    test('next number, edit, save in the PascalCase wrapper; a refusal is an ApiFailure', () async {
      adapter.replies['/api/petty-cash-masters/next-number'] = (200, jsonEncode({'IsSuccess': true, 'Data1': 'PTC000000081'}));
      adapter.replies['/api/petty-cash-masters/edit'] = (200, jsonEncode({'IsSuccess': true, 'Message': 'ok', 'Data1': editJson()}));
      adapter.replies['/api/petty-cash-masters/save'] =
          (200, jsonEncode({'IsSuccess': true, 'Data1': {'success': true, 'message': 'Saved', 'id': 81, 'cnumberDisplay': 'PTC000000081'}}));
      expect(await api.nextNumber(), 'PTC000000081');
      expect(adapter.requests.last.queryParameters, {'companyId': 6});
      final m = await api.load(80);
      expect(adapter.requests.last.queryParameters, {'companyId': 6, 'id': 80});
      expect(PettyCashDraft.fromEdit(m).number, 'PTC000000080');
      final s = await api.save({'id': 0});
      expect((s.id, s.number), (81, 'PTC000000081'));
      expect(adapter.requests.last.headers['Comid'], 6);

      adapter.replies['/api/petty-cash-masters/save'] = (400, jsonEncode({'IsSuccess': false, 'Message': 'Employee not found'}));
      expect(() => api.save({'id': 0}), throwsA(isA<ApiFailure>().having((e) => e.message, 'm', 'Employee not found')));
      adapter.replies['/api/petty-cash-masters/edit'] = (404, jsonEncode({'IsSuccess': false, 'Message': 'Petty cash not found: 9'}));
      expect(() => api.load(9), throwsA(isA<ApiFailure>()));
    });

    test('last balance, follow, extract', () async {
      adapter.replies['/api/petty-cash-book/last-balance'] = (
        200,
        jsonEncode({'IsSuccess': true, 'Data1': {'ready': true, 'found': true, 'sheetId': 74, 'number': 'PTC000000074', 'date': '2026-09-12', 'balanceAfter': 15.99}})
      );
      final l = await api.lastBalance(employeeId: 15, date: DateTime(2026, 10, 30));
      expect((l.ready, l.found, l.number, l.date, l.balanceAfter), (true, true, 'PTC000000074', DateTime(2026, 9, 12), 15.99));
      expect(adapter.requests.last.queryParameters, {'companyId': 6, 'employeeId': 15, 'date': '2026-10-30'});
      await api.lastBalance(employeeId: 15, date: DateTime(2026, 10, 30), excludeId: 80);
      expect(adapter.requests.last.queryParameters['excludeId'], 80);

      adapter.replies['/api/petty-cash-book/80/follow'] =
          (200, jsonEncode({'IsSuccess': true, 'Data1': {'updated': ['PTC000000080', 'PTC000000082'], 'stoppedAt': 'PTC000000083', 'reason': 'COMPLETED'}}));
      final f = await api.follow(80);
      expect(f.message, 'Updated 2 sheet(s) — stopped at PTC000000083: COMPLETED');
      expect(adapter.requests.last.method, 'POST');

      final photo = File('${Directory.systemTemp.createTempSync().path}/sheet.jpg')..writeAsBytesSync([1, 2, 3]);
      adapter.replies['/api/ai/petty-cash/extract'] = (200, jsonEncode({'IsSuccess': true, 'Data1': {'header': {'remark': 'X'}}}));
      expect((await api.extract(photo))['header'], {'remark': 'X'});
      expect(adapter.requests.last.queryParameters['companyId'], 6);
    });

    test('employees (bare list), employee types, accounts ({ok, data}) with classification', () async {
      adapter.replies['/api/employees/company/6/all'] =
          (200, jsonEncode([{'id': 15, 'employeeName': 'LIM AH KOW'}, {'id': 0, 'employeeName': 'X'}, {'id': 16, 'employeeName': 'LIM MEI'}]));
      adapter.replies['/api/employees/types'] =
          (200, jsonEncode({'IsSuccess': true, 'Data1': [{'id': 0, 'customerName': 'ALL'}, {'id': 1100, 'customerName': 'ACCOUNTS'}]}));
      adapter.replies['/api/payment-vouchers/select-coa-expense'] = (
        200,
        jsonEncode({'ok': true, 'data': [{'id': 502, 'accountCode': '6100-05', 'accountName': 'TOLL', 'parentName': 'EXPENSES', 'classification': 7, 'classificationName': 'Travel'}]})
      );
      expect((await api.employees()).map((e) => e.name), ['LIM AH KOW', 'LIM MEI']);
      expect(await api.employeeTypes(), ['ALL', 'ACCOUNTS']);
      expect(adapter.requests.last.queryParameters['all'], true);
      final a = (await api.accounts()).single;
      expect((a.id, a.name, a.code, a.classification, a.classificationName, a.sub), (502, 'TOLL', '6100-05', 7, 'Travel', '6100-05 · EXPENSES'));
    });
  });

  test('AI fill the web way (pettyCashAi.ts)', () {
    final base = PettyCashDraft(number: 'PTC000000081', paymentStatus: 'SEND FOR APPROVAL', employee: lim, remark: 'old');
    final r = applyPettyCashExtraction({
      'header': {'date': '2026-10-20', 'remark': '', 'employeeTypeText': 'accounts', 'balanceBefore': 15.99, 'cashReceived': 2000, 'total': 42.5},
      'employee': {'extractedName': 'Lim', 'employeeId': null, 'candidates': [{'id': 15, 'name': 'LIM AH KOW', 'score': 0.8}, {'id': 16, 'name': 'LIM MEI', 'score': 0.7}]},
      'lastBalance': 15.99,
      'lines': [
        {'items': 'PLUS', 'notes': 'toll', 'amount': 30, 'accountId': 502},
        {'items': 'CAR PARK', 'notes': '', 'amount': 12.5, 'accountId': null, 'accountCode': '6100-06'},
        {'items': 'FOOD', 'notes': '', 'amount': null, 'accountCode': '9999'},
      ],
      'warnings': ['1 line has no account'],
    }, base, accounts: const [toll, parking], types: const ['ACCOUNTS', 'ADMIN'], employees: const [lim, mei]);
    final d = r.draft;
    expect(d.number, 'PTC000000081');
    expect(d.date, DateTime(2026, 10, 20));
    expect(d.remark, 'old', reason: 'blank remark leaves the form as it is');
    expect(d.paymentStatus, 'SEND FOR APPROVAL');
    expect(d.employee, lim, reason: 'no match for sure: the person stays');
    expect(d.department, 'ACCOUNTS');
    expect(d.typedBefore, isNull, reason: 'same as the server: follows the last sheet');
    expect(d.cashReceived, '2000.00');
    expect(d.lines.map((l) => (l.items, l.amount, l.account?.id)), [('PLUS', '30.00', 502), ('CAR PARK', '12.50', 503), ('FOOD', '', null)]);
    expect(d.dirty, isTrue);
    expect(r.warnings, ['1 line has no account']);
    expect(r.unmatched, isTrue);
    expect(r.unmatchedName, 'Lim');
    expect(r.candidates, [lim, mei]);

    final typed = applyPettyCashExtraction({
      'header': {'balanceBefore': 20, 'employeeTypeText': 'DRIVER'},
      'employee': {'employeeId': 16, 'employeeName': 'LIM MEI'},
      'lastBalance': 15.99,
    }, PettyCashDraft(department: 'ADMIN'), accounts: const [], types: const ['ACCOUNTS'], employees: const [lim, mei]);
    expect(typed.draft.typedBefore, '20.00');
    expect(typed.draft.employee, mei);
    expect(typed.draft.department, '', reason: 'a type not in the list is left blank, as on the web');
    expect(typed.unmatched, isFalse);
  });

  group('form', () {
    late MockApi api;
    late MockFiles files;

    setUp(() {
      api = MockApi();
      files = MockFiles();
      PettyCashFormPage.debugEmployeeId = 15;
      PettyCashFormPage.debugPickPhoto = (_) async => File('/tmp/sheet.jpg');
      when(() => api.companyId).thenReturn(6);
      when(() => api.employees()).thenAnswer((_) async => const [lim, mei]);
      when(() => api.employeeTypes()).thenAnswer((_) async => const ['ACCOUNTS', 'ADMIN']);
      when(() => api.accounts()).thenAnswer((_) async => const [toll, parking]);
      when(() => api.nextNumber()).thenAnswer((_) async => 'PTC000000081');
      when(() => api.lastBalance(
              employeeId: any(named: 'employeeId'), date: any(named: 'date'), excludeId: any(named: 'excludeId')))
          .thenAnswer((_) async => last());
      when(() => api.save(any())).thenAnswer((_) async => (id: 81, number: 'PTC000000081', message: 'Saved'));
      when(() => files.add(any(), folder: any(named: 'folder'), recordId: any(named: 'recordId')))
          .thenAnswer((_) async => const []);
      when(() => files.list(folder: any(named: 'folder'), recordId: any(named: 'recordId'))).thenAnswer((_) async => const []);
    });

    tearDown(() {
      PettyCashFormPage.debugEmployeeId = null;
      PettyCashFormPage.debugPickPhoto = null;
    });

    Future<void> pump(WidgetTester tester, {int? editId, Size size = const Size(360, 2600)}) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute<bool>(builder: (_) => PettyCashFormPage(api: api, files: files, editId: editId))),
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    Future<void> choose(WidgetTester tester, String field, String option) async {
      await tester.ensureVisible(find.byKey(ValueKey(field)));
      await tester.tap(find.byKey(ValueKey(field)));
      await tester.pumpAndSettle();
      await tester.tap(find.text(option).last);
      await tester.pumpAndSettle();
    }

    Future<void> addLine(WidgetTester tester, String item, String amount, {String? account}) async {
      final list = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first;
      await tester.scrollUntilVisible(find.byKey(const ValueKey('pc-add-line')), 200, scrollable: list);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pc-add-line')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('pcl-items')), item);
      await tester.enterText(find.byKey(const ValueKey('pcl-amount')), amount);
      if (account != null) {
        await tester.tap(find.byKey(const ValueKey('pcl-account')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(account).last);
        await tester.pumpAndSettle();
        expect(find.text('e-Invoice classification: Travel'), findsOneWidget);
      }
      await tester.ensureVisible(find.byKey(const ValueKey('pcl-done')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pcl-done')));
      await tester.pumpAndSettle();
    }

    String text(WidgetTester tester, String key) => tester.widget<Text>(find.byKey(ValueKey(key))).data!;

    testWidgets('new sheet at 360 px: last balance from the server, live balance, saved with balances', (tester) async {
      await pump(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('New petty cash'), findsOneWidget);
      expect(find.text('LIM AH KOW'), findsOneWidget, reason: 'the signed-in employee by default');
      expect(find.text('from PTC000000074, 12/09/2026'), findsOneWidget);
      verify(() => api.lastBalance(employeeId: 15, date: any(named: 'date'), excludeId: null)).called(1);

      await choose(tester, 'pc-type', 'ACCOUNTS');
      await tester.enterText(find.byKey(const ValueKey('pc-cash')), '2000');
      await tester.pump();
      await addLine(tester, 'PLUS', '1739.91', account: 'TOLL');
      expect(text(tester, 'pc-this'), 'RM 276.08');
      expect(find.byKey(const ValueKey('pc-short')), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const ValueKey('pc-save')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pc-confirm')));
      await tester.pumpAndSettle();
      final body = verify(() => api.save(captureAny())).captured.single as Map<String, dynamic>;
      expect(body['employeeRefId'], 15);
      expect(body['department'], 'ACCOUNTS');
      expect((body['balanceBefore'], body['cashReceived'], body['balanceBeforeTyped']), (15.99, 2000.0, false));
      expect((body['pettyCashDetails'] as List).single, {'items': 'PLUS', 'amount': 1739.91, 'notes': '', 'accountGroupRefId': 502, 'classification': 7});
      verifyNever(() => files.add(any(), folder: any(named: 'folder'), recordId: any(named: 'recordId')));
      expect(find.text('New petty cash'), findsNothing, reason: 'closed after saving');
    });

    testWidgets('person changes → last balance asked again; pencil types it; below 0 is red and still saves', (tester) async {
      when(() => api.lastBalance(employeeId: 16, date: any(named: 'date'), excludeId: any(named: 'excludeId')))
          .thenAnswer((_) async => last(found: false));
      await pump(tester);
      await choose(tester, 'pc-employee', 'LIM MEI');
      expect(find.text('No earlier sheet: type the opening balance'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('pc-pencil')));
      await tester.pump();
      await tester.enterText(find.byKey(const ValueKey('pc-before')), '10');
      await tester.pump();
      expect(find.text('Typed by hand'), findsOneWidget);
      await choose(tester, 'pc-type', 'ADMIN');
      await addLine(tester, 'PARKING', '25');
      expect(text(tester, 'pc-this'), 'RM -15.00');
      expect(find.text('More spent than cash in hand'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const ValueKey('pc-save')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pc-confirm')));
      await tester.pumpAndSettle();
      final body = verify(() => api.save(captureAny())).captured.single as Map<String, dynamic>;
      expect((body['employeeRefId'], body['balanceBefore'], body['cashReceived'], body['balanceBeforeTyped']), (16, 10.0, null, true));
    });

    testWidgets('not ready: only Total shows; a missing employee type is refused', (tester) async {
      when(() => api.lastBalance(
              employeeId: any(named: 'employeeId'), date: any(named: 'date'), excludeId: any(named: 'excludeId')))
          .thenAnswer((_) async => last(ready: false));
      await pump(tester);
      expect(find.byKey(const ValueKey('pc-total')), findsOneWidget);
      expect(find.byKey(const ValueKey('pc-before')), findsNothing);
      expect(find.byKey(const ValueKey('pc-this')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('pc-save')));
      await tester.pumpAndSettle();
      expect(find.text('Choose the employee type'), findsOneWidget);
      verifyNever(() => api.save(any()));
    });

    testWidgets('Read with AI: replace asked, filled, names to tap, photo attached to PettyCash after the save', (tester) async {
      when(() => api.extract(any())).thenAnswer((_) async => {
            'header': {'date': '2026-10-20', 'remark': 'Week 43', 'employeeTypeText': 'ACCOUNTS', 'balanceBefore': 15.99, 'cashReceived': 100},
            'employee': {'extractedName': 'Lim', 'candidates': [{'id': 15, 'name': 'LIM AH KOW'}, {'id': 16, 'name': 'LIM MEI'}]},
            'lastBalance': 15.99,
            'lines': [{'items': 'PLUS', 'notes': 'toll', 'amount': 30, 'accountId': 502}],
            'warnings': ['Check the total'],
          });
      await pump(tester);
      await tester.enterText(find.byKey(const ValueKey('pc-remark')), 'typed');
      await tester.tap(find.byKey(const ValueKey('pc-ai')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ai-gallery')));
      await tester.pumpAndSettle();
      expect(find.text('Replace the form?'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('ai-replace')));
      await tester.pumpAndSettle();

      expect(find.text('Filled by AI — please check'), findsOneWidget);
      expect(find.text('• Check the total'), findsOneWidget);
      expect(find.textContaining("Requested by 'Lim' not found for sure"), findsOneWidget);
      expect(find.text('Week 43'), findsOneWidget);
      expect(text(tester, 'pc-this'), 'RM 85.99');
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const ValueKey('pc-candidate-16')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('pc-candidate-16')), findsNothing);
      verify(() => api.lastBalance(employeeId: 16, date: DateTime(2026, 10, 20), excludeId: null)).called(1);

      await tester.tap(find.byKey(const ValueKey('pc-save')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pc-confirm')));
      await tester.pumpAndSettle();
      final body = verify(() => api.save(captureAny())).captured.single as Map<String, dynamic>;
      expect((body['employeeRefId'], body['pettyCashDate'], body['remark'], body['cashReceived']), (16, '2026-10-20', 'Week 43', 100.0));
      final sent = verify(() => files.add(captureAny(), folder: 'PettyCash', recordId: 81)).captured.single as List<File>;
      expect(sent.single.path, '/tmp/sheet.jpg');
    });

    testWidgets('edit: saved balances shown, Last balance changed note, Update follows and reloads', (tester) async {
      var loads = 0;
      when(() => api.load(80)).thenAnswer((_) async => ++loads == 1 ? editJson(expected: 90) : (editJson()..['balanceBefore'] = 90));
      when(() => api.follow(80)).thenAnswer((_) async => const PettyCashFollowResult(updated: ['PTC000000080']));
      await pump(tester, editId: 80);
      expect(find.text('Edit PTC000000080'), findsOneWidget);
      expect(text(tester, 'pc-this'), 'RM 120.00');
      expect(find.text('Last balance changed: was RM 100.00, now RM 90.00'), findsOneWidget);
      verify(() => api.lastBalance(employeeId: 15, date: DateTime(2026, 10, 28), excludeId: 80)).called(1);
      verify(() => files.list(folder: 'PettyCash', recordId: 80)).called(1);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const ValueKey('pc-follow')));
      await tester.pumpAndSettle();
      verify(() => api.follow(80)).called(1);
      expect(loads, 2);
      expect(find.byKey(const ValueKey('pc-chain')), findsNothing);
      expect(find.text('Updated 1 sheet(s)'), findsOneWidget);
    });

    testWidgets('no overflow on a 360 × 640 phone while scrolling the whole page', (tester) async {
      await pump(tester, size: const Size(360, 640));
      await addLine(tester, 'A VERY LONG ITEM NAME THAT DOES NOT FIT ON A SMALL PHONE SCREEN', '123456.78', account: 'TOLL');
      final list = find.descendant(of: find.byType(ListView), matching: find.byType(Scrollable)).first;
      for (var i = 0; i < 8; i++) {
        await tester.drag(list, const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  });
}
