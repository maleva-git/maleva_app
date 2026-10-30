import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/features/dashboard/payable_dashboard/po/data/po_api.dart';
import 'package:maleva/features/dashboard/payable_dashboard/po/data/po_draft.dart';
import 'package:maleva/features/dashboard/payable_dashboard/records/data/payable_record.dart';
import 'package:maleva/features/dashboard/payable_dashboard/records/data/payable_records_api.dart';
import 'package:maleva/features/dashboard/payable_dashboard/records/view/record_detail_page.dart';
import 'package:maleva/features/dashboard/payable_dashboard/voucher/data/voucher_api.dart';
import 'package:maleva/features/dashboard/payable_dashboard/voucher/data/voucher_draft.dart';
import 'package:maleva/features/dashboard/payable_dashboard/voucher/view/voucher_form_page.dart';
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

class MockPoApi extends Mock implements PoApi {}

class MockVoucherApi extends Mock implements VoucherApi {}

class MockFiles extends Mock implements AttachmentsApi {}

class MockRecordsApi extends Mock implements PayableRecordsApi {}

const tyre = Option(502, 'TYRE', sub: '6100-02 · EXPENSES', extra: 7);
const maybank = Option(3, 'MAYBANK CURRENT');

Map<String, dynamic> poJson() => {
      'id': 77,
      'cNumberDisplay': 'PO000000077',
      'payTo': 'KWANG HENG',
      'description': 'SPARE PARTS',
      'billsOrderDetails': [
        {'id': 5, 'accountMasterRefId': 502, 'productName': 'TYRE', 'productCode': '6100-02', 'remarksD': '2 tyres', 'amount': 636},
      ],
    };

void main() {
  setUpAll(installLocalTestFonts);
  setUpAll(() {
    registerFallbackValue(<File>[]);
    registerFallbackValue(<String>[]);
    registerFallbackValue(<String, dynamic>{});
    registerFallbackValue(const PayableRecord(kind: RecordKind.po, id: 0, number: '', date: null, party: '', amount: 0, status: ''));
  });

  group('draft', () {
    test('checks in the web order', () {
      final d = VoucherDraft();
      expect(d.problems(), ['Choose the expense head', 'Choose the bank (payment by)', 'Add at least one line']);
      d
        ..head = 'FUEL'
        ..bank = maybank
        ..lines = [VoucherLine(description: 'diesel', amount: 100)];
      expect(d.problems(), ['Line 1: choose the account']);
      d.lines.first.account = tyre;
      expect(d.problems(), isEmpty);
    });

    test('save body: date, bank, status default, total, classification, links kept', () {
      final d = VoucherDraft(
        date: DateTime(2026, 10, 30),
        payTo: ' TNB ',
        bank: maybank,
        head: 'UTILITY',
        poId: 77,
        lines: [
          VoucherLine(id: 9, account: tyre, description: 'x', amount: 80.5, leviEntryRefId: 12, pendingPaymentRefId: 4, subExpenseRefid: 2),
          VoucherLine(),
        ],
      );
      final j = d.toJson(companyId: 6, employeeId: 15);
      expect(j['paymentVoucherDate'], '2026-10-30');
      expect(j['payTo'], 'TNB');
      expect(j['paymentById'], 3);
      expect(j['paymentStatus'], '');
      expect(j['amount'], 80.5);
      expect(j['billsOrderMasterRefId'], 77);
      final l = (j['paymentVoucherDetails'] as List).single as Map;
      expect(l['accountGroupRefId'], 502);
      expect(l['accountCode'], '6100-02');
      expect(l['classification'], 7);
      expect(l['leviEntryRefId'], 12);
      expect(l['pendingPaymentRefId'], 4);
      expect(l['subExpenseRefid'], 2);
      expect(l['id'], 9);
    });

    test('from a PO: link, pay to, head, one line per PO line with its amount', () {
      final d = VoucherDraft.fromPo(poJson(), number: 'PV000000100');
      expect(d.poId, 77);
      expect(d.poNumber, 'PO000000077');
      expect(d.payTo, 'KWANG HENG');
      expect(d.head, 'SPARE PARTS');
      expect(d.bank, isNull, reason: 'the person chooses the bank');
      expect(d.lines.single.account?.id, 502);
      expect(d.lines.single.description, '2 tyres');
      expect(d.total, 636);
    });

    test('edit: SEND FOR APPROVAL reads as the default; bank found; line links kept', () {
      final d = VoucherDraft.fromEdit({
        'id': 41,
        'paymentById': 3,
        'paymentStatus': 'SEND FOR APPROVAL',
        'paymentVoucherDetails': [
          {'id': 1, 'accountGroupRefId': 502, 'accountName': 'TYRE', 'amount': 50, 'leviEntryRefId': 12},
        ],
      }, banks: [maybank]);
      expect(d.status, '');
      expect(d.bank, maybank);
      expect(d.lines.single.leviEntryRefId, 12);
      expect(d.lines.single.linkLabel, 'Levy');
    });
  });

  group('api', () {
    late RouteAdapter adapter;
    late VoucherApi api;
    setUp(() {
      adapter = RouteAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter;
      api = VoucherApi(dio, PoApi(dio, companyId: () => 6));
    });

    test('lookups in their envelopes; heads merged with the fixed list', () async {
      adapter.replies['/api/banks/company/6'] = (200, jsonEncode({'IsSuccess': true, 'Data1': [{'Id': 3, 'AccountName': 'MAYBANK CURRENT'}, {'Id': 0, 'BankName': 'X'}]}));
      adapter.replies['/api/payment-voucher-masters/select-payment-to'] = (200, jsonEncode({'data': [{'accountName': 'TNB'}, {'accountName': ''}]}));
      adapter.replies['/api/payment-voucher-masters/descriptions'] = (200, jsonEncode({'IsSuccess': true, 'Data1': ['PORT CHARGES', 'FUEL']}));
      expect(await api.banks(), [maybank]);
      expect(await api.payTos(), ['TNB']);
      final heads = await api.heads();
      expect(heads, contains('PORT CHARGES'));
      expect(heads, contains('HIRE PURCHASE'));
      expect(heads.where((h) => h == 'FUEL'), hasLength(1));
    });

    test('save answers id, number, duplicate', () async {
      adapter.replies['/api/payment-voucher-masters/save'] = (
        200,
        jsonEncode({'IsSuccess': true, 'Data1': {'success': true, 'id': 100, 'voucherNoDisplay': 'PV000000100', 'duplicate': false}})
      );
      final r = await api.save({'id': 0});
      expect((r.id, r.number, r.duplicate), (100, 'PV000000100', false));
      expect(adapter.requests.single.headers['Comid'], 6);
    });
  });

  group('form', () {
    late MockPoApi po;
    late MockVoucherApi api;
    late MockFiles files;

    setUp(() {
      po = MockPoApi();
      api = MockVoucherApi();
      files = MockFiles();
      when(() => api.po).thenReturn(po);
      when(() => api.companyId).thenReturn(6);
      when(() => api.banks()).thenAnswer((_) async => [maybank]);
      when(() => po.accounts()).thenAnswer((_) async => [tyre]);
      when(() => api.heads()).thenAnswer((_) async => voucherDefaultHeads);
      when(() => api.payTos()).thenAnswer((_) async => const []);
      when(() => api.payFroms()).thenAnswer((_) async => const []);
      when(() => api.nextNumber()).thenAnswer((_) async => 'PV000000100');
      when(() => po.load(77)).thenAnswer((_) async => poJson());
      when(() => api.save(any())).thenAnswer((_) async => (id: 100, number: 'PV000000100', duplicate: false));
      when(() => files.list(folder: 'BillOrderMaster', recordId: 77)).thenAnswer((_) async => [
            {'fileName': 'invoice.pdf', 'path': '/uploads/6/BillOrderMaster/77/invoice.pdf', 'contentType': 'application/pdf'},
          ]);
      when(() => files.copyFrom(any(), folder: any(named: 'folder'), recordId: any(named: 'recordId')))
          .thenAnswer((_) async => const []);
      when(() => files.add(any(), folder: any(named: 'folder'), recordId: any(named: 'recordId'))).thenAnswer((_) async => const []);
    });

    Future<void> pump(WidgetTester tester, {int? fromPoId}) async {
      tester.view.physicalSize = const Size(390, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<bool>(
                  builder: (_) => VoucherFormPage(api: api, files: files, fromPoId: fromPoId, employeeId: 15))),
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('Push to PV: bank needed, then saved with the PO link and the PO file copied', (tester) async {
      await pump(tester, fromPoId: 77);
      expect(find.text('Pay PO000000077'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('step-2')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Choose the bank'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('step-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pv-bank')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('MAYBANK CURRENT'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('pv-status')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pv-status')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Completed').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('step-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pv-save')));
      await tester.pumpAndSettle();
      expect(find.textContaining('the PO will be marked PAYMENT COMPLETED'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('pv-confirm')));
      await tester.pumpAndSettle();

      final body = verify(() => api.save(captureAny())).captured.single as Map<String, dynamic>;
      expect(body['billsOrderMasterRefId'], 77);
      expect(body['paymentById'], 3);
      expect(body['paymentStatus'], 'COMPLETED');
      expect(body['description'], 'SPARE PARTS');
      expect(body['amount'], 636);
      verify(() => files.copyFrom(['/uploads/6/BillOrderMaster/77/invoice.pdf'], folder: 'PaymentVoucher', recordId: 100)).called(1);
    });

    testWidgets('new voucher: add a line and save', (tester) async {
      await pump(tester);
      expect(find.text('New payment voucher'), findsOneWidget);
      await tester.enterText(find.byKey(const ValueKey('pv-payto')), 'tnb');
      await tester.tap(find.byKey(const ValueKey('pv-bank')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('MAYBANK CURRENT'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('pv-head')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pv-head')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('UTILITY').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pv-next')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pv-add-line')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pv-line-account')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TYRE'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('pv-line-amount')), '120.50');
      await tester.tap(find.byKey(const ValueKey('pv-line-done')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pv-next')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pv-save')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pv-confirm')));
      await tester.pumpAndSettle();
      final body = verify(() => api.save(captureAny())).captured.single as Map<String, dynamic>;
      expect(body['payTo'], 'tnb');
      expect(body['description'], 'UTILITY');
      expect(body['amount'], 120.5);
      expect(body['paymentStatus'], '');
    });
  });

  testWidgets('a PO page shows Edit, Push to Bill and Push to PV on a phone without overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final records = MockRecordsApi();
    when(() => records.detail(any())).thenAnswer((_) async => const RecordDetail(facts: [], lines: [], total: 0));
    when(() => records.files(any())).thenAnswer((_) async => const []);
    await tester.pumpWidget(MaterialApp(
      home: RecordDetailPage(
        record: const PayableRecord(kind: RecordKind.po, id: 77, number: 'PO000000077', date: null, party: 'KH', amount: 600, status: 'PENDING'),
        api: records,
        actions: [
          RecordAction('Edit', Icons.edit_outlined, (_) async => false),
          RecordAction('Push to Bill', Icons.receipt_long_outlined, (_) async => false),
          RecordAction('Push to PV', Icons.request_quote_outlined, (_) async => false),
        ],
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Push to PV'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
