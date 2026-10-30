import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/dashboard/payable_dashboard/bill/data/bill_ai.dart';
import 'package:maleva/features/dashboard/payable_dashboard/bill/data/bill_api.dart';
import 'package:maleva/features/dashboard/payable_dashboard/bill/data/bill_draft.dart';
import 'package:maleva/features/dashboard/payable_dashboard/bill/view/bill_form_page.dart';
import 'package:maleva/features/dashboard/payable_dashboard/po/data/po_api.dart';
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

class MockPoApi extends Mock implements PoApi {}

class MockBillApi extends Mock implements BillApi {}

class MockFiles extends Mock implements AttachmentsApi {}

const tyre = Option(502, 'TYRE', sub: '6100-02 · EXPENSES');
const kh = Option(9, 'KWANG HENG SDN BHD', extra: 3);

Map<String, dynamic> poJson() => {
      'id': 77,
      'cNumberDisplay': 'PO000000077',
      'supplierRefId': 9,
      'saleDate': '2026-10-02',
      'invoiceNo': 'QT-5',
      'invoiceDate': '2026-10-01',
      'paymentTermsRefid': 3,
      'description': 'SPARE PARTS',
      'billStatus': 'ASSIGNED',
      'saleType': 'CREDIT',
      'billsOrderDetails': [
        {'id': 5, 'accountMasterRefId': 502, 'productName': 'TYRE', 'productCode': '6100-02', 'remarksD': '2 tyres', 'itemQty': 2, 'salesRate': 300, 'taxPercent': 0},
      ],
    };

void main() {
  setUpAll(installLocalTestFonts);
  setUpAll(() {
    registerFallbackValue(File('x'));
    registerFallbackValue(<File>[]);
    registerFallbackValue(<String>[]);
    registerFallbackValue(<String, dynamic>{});
  });

  group('draft rules (web useBillSave.ts, billCalculations.ts)', () {
    test('problems in the web order; invoice used only for a new bill; not below paid on edit', () {
      final d = BillDraft();
      expect(d.problems(), [
        'Choose the supplier',
        'Choose the payment term',
        'Type the invoice number',
        'Choose the expense type',
        'Add at least one item',
      ]);
      d
        ..supplier = kh
        ..paymentTermId = 3
        ..invoiceNo = 'inv-1'
        ..description = 'SPARE PARTS'
        ..lines = [PoLine(remarks: 'oil', qty: 1, rate: 10)];
      expect(d.problems(), ['Item 1: choose the account', 'Add at least one item']);
      d.lines.first.account = tyre;
      expect(d.problems(invoiceUsed: true), ['Invoice number inv-1 already exists']);
      d.id = 4;
      expect(d.problems(invoiceUsed: true), isEmpty);
      expect(d.problems(paid: 50), ['The total RM 10.00 is below what is already paid (RM 50.00)']);
    });

    test('save body as the web sends it (dates with time, currency, lines with an account only)', () {
      final d = BillDraft(
        supplier: kh,
        billDate: DateTime(2026, 10, 30),
        invoiceNo: 'inv-1',
        invoiceDate: DateTime(2026, 10, 29),
        dueDate: DateTime(2026, 11, 28),
        paymentTermId: 3,
        description: 'SPARE PARTS',
        currencyValue: 3.4,
        poId: 77,
        lines: [PoLine(account: tyre, remarks: 'tyres', qty: 2, rate: 300, taxPercent: 6), PoLine(remarks: 'empty')],
      );
      final j = d.toJson(companyId: 6, employeeId: 15);
      expect(j['saleDate'], '2026-10-30T00:00:00');
      expect(j['invoiceDate'], '2026-10-29T00:00:00');
      expect(j['dueDate'], '2026-11-28');
      expect(j['invoiceNo'], 'INV-1');
      expect(j['saleType'], 'CREDIT');
      expect(j['billStatus'], 'Completed');
      expect(j['amount'], 636);
      expect(j['taxAmount'], 36);
      expect(j['actualAmount'], 2162.4);
      expect(j['billsOrderMasterRefId'], 77);
      final lines = j['billDetails'] as List;
      expect(lines, hasLength(1));
      final l = lines.single as Map;
      expect(l['accountMasterRefId'], 502);
      expect(l['salesRate'], 300);
      expect(l['taxAmount'], 36);
      expect(l['amount'], 636);
      expect(l['actualAmount'], 1020);
      expect(l['actualAmount1'], 300);
    });

    test('from a PO: supplier, invoice, term, lines (new ids), PO link; PO status not copied', () {
      final d = BillDraft.fromPo(poJson(), number: 'BIL2610/004', suppliers: [kh]);
      expect(d.number, 'BIL2610/004');
      expect(d.supplier, kh);
      expect(d.invoiceNo, 'QT-5');
      expect(d.paymentTermId, 3);
      expect(d.description, 'SPARE PARTS');
      expect(d.status, 'Completed');
      expect(d.poId, 77);
      expect(d.poNumber, 'PO000000077');
      expect(d.lines.single.id, 0);
      expect(d.lines.single.account?.id, 502);
      expect(d.total, 600);
    });

    test('edit: saved currency and lines kept', () {
      final d = BillDraft.fromEdit({
        'id': 4,
        'cNumberDisplay': 'BIL2610/001',
        'supplierRefId': 9,
        'currencyValue': 3.4,
        'currencyValue1': 0,
        'billDetails': [{'id': 11, 'accountMasterRefId': 502, 'itemQty': 1, 'salesRate': 50}],
      }, suppliers: [kh]);
      expect(d.currencyValue, 3.4);
      expect(d.currencyValue1, 1);
      expect(d.lines.single.id, 11);
    });
  });

  test('AI read: supplier by id, upper-case invoice and lines, "PO x" remarks, account by code', () {
    final r = applyBillExtraction({
      'supplier': {'supplierId': 9},
      'header': {'invoiceNo': 'inv-9', 'invoiceDate': '2026-10-28', 'purchaseOrderNo': 'PO000000077', 'totalAmount': 100, 'description': 'spare parts'},
      'lines': [
        {'description': 'tyre', 'quantity': 0, 'amount': 106, 'taxAmount': 6, 'accountCode': '6100-02'},
      ],
    }, BillDraft(number: 'BIL1'), suppliers: [kh], accounts: [tyre], descriptions: const ['SPARE PARTS']);
    final d = r.draft;
    expect(d.number, 'BIL1');
    expect(d.supplier, kh);
    expect(d.invoiceNo, 'INV-9');
    expect(d.remarks, 'PO PO000000077');
    expect(d.description, 'SPARE PARTS');
    expect(d.lines.single.remarks, 'TYRE');
    expect(d.lines.single.qty, 1);
    expect(d.lines.single.rate, 100);
    expect(d.lines.single.taxPercent, 6);
    expect(d.lines.single.account, tyre);
    expect(r.warnings.any((w) => w.contains('RM 100.00')), isTrue);
  });

  group('api', () {
    late RouteAdapter adapter;
    late BillApi api;
    setUp(() {
      adapter = RouteAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter;
      api = BillApi(dio, PoApi(dio, companyId: () => 6));
    });

    test('save answers id, number and duplicate; a 400 is an ApiFailure', () async {
      adapter.replies['/api/bills/save'] = (
        200,
        jsonEncode({'IsSuccess': true, 'Data1': {'success': true, 'id': 40, 'billNoDisplay': 'BIL2610/004', 'duplicate': false}})
      );
      final r = await api.save({'id': 0});
      expect((r.id, r.number, r.duplicate), (40, 'BIL2610/004', false));
      expect(adapter.requests.single.queryParameters['companyId'], 6);
      expect(adapter.requests.single.headers['Comid'], 6);

      adapter.replies['/api/bills/save'] = (400, jsonEncode({'IsSuccess': false, 'Message': 'Supplier not found'}));
      expect(() => api.save({'id': 0}), throwsA(isA<ApiFailure>().having((e) => e.message, 'm', 'Supplier not found')));
    });

    test('invoice check, paid amount, currency', () async {
      adapter.replies['/api/bills/invoice-no-exists'] = (200, jsonEncode({'IsSuccess': true, 'Data1': true}));
      adapter.replies['/api/bills/4/paid-amount'] = (200, jsonEncode({'IsSuccess': true, 'Data1': 50.5}));
      adapter.replies['/api/bills/supplier-currency'] = (200, jsonEncode({'IsSuccess': true, 'Data1': 3.4}));
      expect(await api.invoiceExists(' inv-1 '), isTrue);
      expect(adapter.requests.last.queryParameters['invoiceNo'], 'inv-1');
      expect(await api.paidAmount(4), 50.5);
      expect(await api.supplierCurrency(9), 3.4);
    });
  });

  group('form', () {
    late MockPoApi po;
    late MockBillApi api;
    late MockFiles files;

    setUp(() {
      po = MockPoApi();
      api = MockBillApi();
      files = MockFiles();
      when(() => api.po).thenReturn(po);
      when(() => api.companyId).thenReturn(6);
      when(() => po.suppliers()).thenAnswer((_) async => [kh]);
      when(() => po.paymentTerms()).thenAnswer((_) async => const [Option(3, '30 DAYS')]);
      when(() => po.accounts()).thenAnswer((_) async => [tyre]);
      when(() => po.trucks()).thenAnswer((_) async => const []);
      when(() => po.drivers()).thenAnswer((_) async => const []);
      when(() => po.descriptions()).thenAnswer((_) async => const ['SPARE PARTS']);
      when(() => po.load(77)).thenAnswer((_) async => poJson());
      when(() => po.dueDays(3)).thenAnswer((_) async => 30);
      when(() => api.nextNumber()).thenAnswer((_) async => 'BIL2610/004');
      when(() => api.supplierCurrency(9)).thenAnswer((_) async => 0);
      when(() => api.invoiceExists(any())).thenAnswer((_) async => false);
      when(() => api.save(any())).thenAnswer((_) async => (id: 40, number: 'BIL2610/004', duplicate: false));
      when(() => files.list(folder: 'BillOrderMaster', recordId: 77)).thenAnswer((_) async => [
            {'fileName': 'quote.pdf', 'path': '/uploads/6/BillOrderMaster/77/quote.pdf', 'contentType': 'application/pdf'},
            {'fileName': 'photo.jpg', 'path': '/uploads/6/BillOrderMaster/77/photo.jpg', 'contentType': 'image/jpeg'},
          ]);
      when(() => files.copyFrom(any(), folder: any(named: 'folder'), recordId: any(named: 'recordId')))
          .thenAnswer((_) async => const []);
      when(() => files.add(any(), folder: any(named: 'folder'), recordId: any(named: 'recordId')))
          .thenAnswer((_) async => const []);
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
                  builder: (_) => BillFormPage(api: api, files: files, fromPoId: fromPoId, employeeId: 15))),
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('Push to Bill: filled from the PO, one PO file left out, saved with the PO link and the kept file', (tester) async {
      await pump(tester, fromPoId: 77);
      expect(find.text('Bill from PO000000077'), findsOneWidget);
      expect(find.text('KWANG HENG SDN BHD'), findsOneWidget);
      expect(find.byKey(const ValueKey('bill-ai')), findsNothing, reason: 'no AI read on a pushed bill');

      await tester.tap(find.byKey(const ValueKey('step-2')));
      await tester.pumpAndSettle();
      expect(find.text('Files from the PO'), findsOneWidget);
      await tester.tap(find.text('photo.jpg'));
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('bill-save')));
      await tester.pumpAndSettle();
      expect(find.textContaining('the PO will be marked INVOICE MADE'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('bill-confirm')));
      await tester.pumpAndSettle();

      final body = verify(() => api.save(captureAny())).captured.single as Map<String, dynamic>;
      expect(body['billsOrderMasterRefId'], 77);
      expect(body['supplierRefId'], 9);
      expect(body['amount'], 600);
      expect(body['employeeRefId'], 15);
      verify(() => files.copyFrom(['/uploads/6/BillOrderMaster/77/quote.pdf'], folder: 'BillMaster', recordId: 40)).called(1);
      verifyNever(() => files.add(any(), folder: any(named: 'folder'), recordId: any(named: 'recordId')));
      expect(find.textContaining('Bill from'), findsNothing, reason: 'closed after saving');
    });

    testWidgets('the same bill already saved: told, nothing uploaded', (tester) async {
      when(() => api.save(any())).thenAnswer((_) async => (id: 12, number: 'BIL2610/001', duplicate: true));
      await pump(tester, fromPoId: 77);
      await tester.tap(find.byKey(const ValueKey('step-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('bill-save')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('bill-confirm')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('already in the system as BIL2610/001'), findsOneWidget);
      verifyNever(() => files.copyFrom(any(), folder: any(named: 'folder'), recordId: any(named: 'recordId')));
    });

    testWidgets('new bill: invoice already used is refused', (tester) async {
      when(() => api.invoiceExists(any())).thenAnswer((_) async => true);
      when(() => po.supplierTerm(9)).thenAnswer((_) async => 3);
      await pump(tester);
      expect(find.text('New bill'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('bill-supplier')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('KWANG HENG SDN BHD'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('bill-invoice')), 'inv-1');
      await tester.ensureVisible(find.byKey(const ValueKey('bill-desc')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('bill-desc')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SPARE PARTS').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('bill-next')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('bill-add-line')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('line-account')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TYRE'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('line-rate')), '100');
      await tester.tap(find.byKey(const ValueKey('line-done')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('bill-next')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('bill-save')));
      await tester.pumpAndSettle();
      expect(find.text('Invoice number inv-1 already exists'), findsWidgets);
      verifyNever(() => api.save(any()));
    });
  });
}
