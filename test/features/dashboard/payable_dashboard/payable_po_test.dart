import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/dashboard/payable_dashboard/po/data/po_ai.dart';
import 'package:maleva/features/dashboard/payable_dashboard/po/data/po_api.dart';
import 'package:maleva/features/dashboard/payable_dashboard/po/data/po_draft.dart';
import 'package:maleva/features/dashboard/payable_dashboard/po/view/po_form_page.dart';
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

class MockFiles extends Mock implements AttachmentsApi {}

const fuelAcc = Option(501, 'SPARE PARTS EXPENSE', sub: '6100-01 · EXPENSES');
const tyreAcc = Option(502, 'TYRE', sub: '6100-02 · EXPENSES');
const kh = Option(9, 'KWANG HENG SDN BHD', extra: 3);

void main() {
  setUpAll(installLocalTestFonts);
  setUpAll(() {
    registerFallbackValue(File('x'));
    registerFallbackValue(<File>[]);
    registerFallbackValue(<String, dynamic>{});
  });

  group('draft rules (web purchaseOrderForm.ts / usePurchaseOrderSave.ts)', () {
    test('line amount = qty × rate + tax; totals over filled lines only', () {
      final l = PoLine(account: fuelAcc, qty: 2, rate: 60, taxPercent: 8);
      expect(l.taxAmount, 9.6);
      expect(l.amount, 129.6);
      final d = PoDraft(lines: [l, PoLine(qty: 1, rate: 0)]);
      expect(d.filledLines, hasLength(1));
      expect(d.total, 129.6);
      expect(d.taxTotal, 9.6);
    });

    test('problems in the web order; used invoice only for a new PO', () {
      final d = PoDraft();
      expect(d.problems(), [
        'Choose the supplier',
        'Choose the payment term',
        'Choose the expense type',
        'Type the invoice number',
        'Add at least one item',
      ]);
      d
        ..supplier = kh
        ..paymentTermId = 3
        ..description = 'SPARE PARTS'
        ..invoiceNo = ' inv-7 '
        ..lines = [PoLine(remarks: 'oil', qty: 1, rate: 10)];
      expect(d.problems(), ['1 item without an account']);
      d.lines.first.account = fuelAcc;
      expect(d.problems(usedInvoiceNos: {'INV-7'}), ['Invoice number inv-7 is already on another PO']);
      d.id = 12;
      expect(d.problems(usedInvoiceNos: {'INV-7'}), isEmpty);
    });

    test('save body as the web sends it', () {
      final d = PoDraft(
        supplier: kh,
        poDate: DateTime(2026, 10, 30),
        invoiceNo: 'inv-7',
        invoiceDate: DateTime(2026, 10, 29),
        dueDate: DateTime(2026, 11, 28),
        paymentTermId: 3,
        description: 'SPARE PARTS',
        payTo: '',
        status: 'PAYMENT COMPLETED',
        lines: [PoLine(account: tyreAcc, remarks: ' 2 tyres ', qty: 2, rate: 300, inventoryProductId: 0)],
      );
      final j = d.toJson(companyId: 6, employeeId: 15);
      expect(j['id'], 0);
      expect(j['supplierRefId'], 9);
      expect(j['saleDate'], '2026-10-30');
      expect(j['invoiceDate'], '2026-10-29');
      expect(j['dueDate'], '2026-11-28');
      expect(j['invoiceNo'], 'INV-7');
      expect(j['saleType'], 'CREDIT');
      expect(j['payTo'], 'DIRECT PAYMENT');
      expect(j['pStatus'], 1);
      expect(j['billStatus'], 'PAYMENT COMPLETED');
      expect(j['amount'], 600);
      expect(j['grossAmount'], 600);
      expect(j['employeeRefId'], 15);
      expect(j['jobOrderDetailIds'], isEmpty);
      final line = (j['billsOrderDetails'] as List).single as Map;
      expect(line['accountMasterRefId'], 502);
      expect(line['productRefId'], 502);
      expect(line['inventoryProductRefId'], isNull);
      expect(line['remarksD'], '2 tyres');
      expect(line['amount'], 600);
    });

    test('edit: a saved PO, lines keep their ids; a job-order PO is flagged', () {
      final d = PoDraft.fromEdit({
        'id': 77,
        'cNumberDisplay': 'PO000000077',
        'supplierRefId': 9,
        'saleDate': '2026-10-02T00:00:00',
        'invoiceNo': 'X1',
        'paymentTermsRefid': 3,
        'billStatus': 'ASSIGNED',
        'billsOrderDetails': [
          {'id': 5, 'accountMasterRefId': 502, 'productName': 'TYRE', 'productCode': '6100-02', 'itemQty': 2, 'salesRate': 300},
        ],
      }, suppliers: [kh]);
      expect(d.id, 77);
      expect(d.supplier, kh);
      expect(d.poDate, DateTime(2026, 10, 2));
      expect(d.lines.single.id, 5);
      expect(d.lines.single.account?.id, 502);
      expect(d.fromJobOrder, isFalse);
      expect(PoDraft.fromEdit({'id': 1, 'jobOrderMasterRefId': 4}).fromJobOrder, isTrue);
    });
  });

  group('AI read mapping (web usePurchaseOrderAiReading.ts)', () {
    Map<String, dynamic> ai({int supplierId = 9}) => {
          'supplier': {
            'extractedName': 'Kwang Heng',
            'supplierId': supplierId,
            'paymentTermsId': 3,
            'candidates': [
              {'id': 9, 'name': 'KWANG HENG SDN BHD', 'score': 0.8},
            ],
          },
          'header': {
            'invoiceNo': 'qt-55',
            'invoiceDate': '2026-10-28',
            'description': 'spare parts',
            'totalAmount': 700,
            'purchaseOrderNo': 'REF9',
          },
          'lines': [
            {'description': 'Tyre 11R22.5', 'quantity': 2, 'unitPrice': 300, 'accountId': 502},
            {'description': 'Labour', 'quantity': 0, 'amount': 54, 'taxAmount': 4, 'accountCode': '6100-01'},
          ],
          'warnings': ['Low quality photo'],
        };

    test('fills supplier, term, invoice, type and lines; warns on totals', () {
      final r = applyPoExtraction(ai(), PoDraft(number: 'PO1'),
          suppliers: [kh], accounts: [fuelAcc, tyreAcc], trucks: const [], drivers: const [], descriptions: const ['SPARE PARTS', 'SERVICE']);
      final d = r.draft;
      expect(d.number, 'PO1');
      expect(d.supplier, kh);
      expect(d.paymentTermId, 3);
      expect(d.invoiceNo, 'QT-55');
      expect(d.invoiceDate, DateTime(2026, 10, 28));
      expect(d.poDate, DateTime(2026, 10, 28), reason: 'PO date falls back to the invoice date');
      expect(d.description, 'SPARE PARTS');
      expect(d.remarks, 'SUPPLIER REF REF9');
      expect(d.lines[0].account, tyreAcc);
      expect(d.lines[0].amount, 600);
      expect(d.lines[1].qty, 1);
      expect(d.lines[1].rate, 50);
      expect(d.lines[1].taxPercent, 8);
      expect(d.lines[1].account, fuelAcc, reason: 'found by account code');
      expect(r.warnings, contains('Low quality photo'));
      expect(r.warnings.any((w) => w.contains('RM 700.00')), isTrue);
    });

    test('no supplier match: candidates and a warning, nothing guessed', () {
      final r = applyPoExtraction(ai(supplierId: 0), PoDraft(),
          suppliers: [kh], accounts: const [], trucks: const [], drivers: const [], descriptions: const []);
      expect(r.draft.supplier, isNull);
      expect(r.candidates, [kh]);
      expect(r.warnings.any((w) => w.contains('Kwang Heng')), isTrue);
      expect(r.draft.description, '', reason: 'not in the list');
    });
  });

  group('api', () {
    late RouteAdapter adapter;
    late PoApi api;
    setUp(() {
      adapter = RouteAdapter();
      api = PoApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
    });

    test('save: Comid header; id and number back; refusal is an ApiFailure', () async {
      adapter.replies['/api/bills-order/insert'] = (200, jsonEncode({'ok': true, 'id': 88, 'billNo': 'PO000000088'}));
      final r = await api.save({'id': 0});
      expect(r.id, 88);
      expect(r.number, 'PO000000088');
      expect(adapter.requests.single.headers['Comid'], 6);

      adapter.replies['/api/bills-order/insert'] = (200, jsonEncode({'ok': false, 'message': 'Invoice number already used'}));
      expect(() => api.save({'id': 0}), throwsA(isA<ApiFailure>().having((e) => e.message, 'm', 'Invoice number already used')));
    });

    test('lookups read every envelope', () async {
      adapter.replies['/api/suppliers/combo'] = (200, jsonEncode({'isSuccess': true, 'data1': [{'Id': 9, 'AccountName': 'KH', 'PaymentTermsRefid': 3}]}));
      adapter.replies['/api/bills-order/select-description/6'] = (200, jsonEncode({'IsSuccess': true, 'Data1': ['SERVICE', {'Description': 'REPAIR'}, '']}));
      adapter.replies['/api/bills-order/check-invoice-no/6'] = (200, jsonEncode({'isSuccess': true, 'data1': [{'InvoiceNo': ' inv-1 '}]}));
      adapter.replies['/api/payment-terms/supplier-due'] = (200, jsonEncode({'isSuccess': true, 'data1': 30}));
      expect((await api.suppliers()).single.extra, 3);
      expect(await api.descriptions(), ['SERVICE', 'REPAIR']);
      expect(await api.usedInvoiceNumbers(), {'INV-1'});
      expect(await api.dueDays(3), 30);
    });

    test('accounts carry their classification (a voucher line saves it, as the web does)', () async {
      adapter.replies['/api/payment-vouchers/select-coa-expense'] = (
        200,
        jsonEncode({'ok': true, 'data': [{'id': 502, 'accountCode': '6100-05', 'accountName': 'TOLL', 'classification': 7}]})
      );
      final a = (await api.accounts()).single;
      expect((a.id, a.name, a.extra), (502, 'TOLL', 7));
    });

    test('load: data is a list', () async {
      adapter.replies['/api/bills-order/edit-bills-order'] = (200, jsonEncode({'ok': true, 'data': [{'id': 77}]}));
      expect((await api.load(77))['id'], 77);
    });
  });

  group('form', () {
    late MockPoApi api;
    late MockFiles files;
    late File photo;

    setUp(() {
      api = MockPoApi();
      files = MockFiles();
      photo = File('${Directory.systemTemp.path}/po_test_photo.jpg')..writeAsBytesSync([1, 2, 3]);
      when(() => api.companyId).thenReturn(6);
      when(() => api.suppliers()).thenAnswer((_) async => [kh]);
      when(() => api.paymentTerms()).thenAnswer((_) async => const [Option(3, '30 DAYS')]);
      when(() => api.accounts()).thenAnswer((_) async => [fuelAcc, tyreAcc]);
      when(() => api.trucks()).thenAnswer((_) async => const []);
      when(() => api.drivers()).thenAnswer((_) async => const []);
      when(() => api.descriptions()).thenAnswer((_) async => const []);
      when(() => api.payTos()).thenAnswer((_) async => const []);
      when(() => api.nextNumber()).thenAnswer((_) async => 'PO000000088');
      when(() => api.dueDays(3)).thenAnswer((_) async => 30);
      when(() => api.usedInvoiceNumbers()).thenAnswer((_) async => <String>{});
      when(() => api.save(any())).thenAnswer((_) async => (id: 88, number: 'PO000000088'));
      when(() => files.add(any(), folder: any(named: 'folder'), recordId: any(named: 'recordId')))
          .thenAnswer((_) async => const []);
    });

    Future<void> pump(WidgetTester tester, {int? editId}) async {
      tester.view.physicalSize = const Size(390, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute<bool>(
                    builder: (_) => PoFormPage(
                        api: api, files: files, editId: editId, employeeId: 15, pickPhoto: (_) async => photo))),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('new PO: supplier sets term and due date, add an item, save with the photo', (tester) async {
      await tester.runAsync(() async {});
      await pump(tester);
      expect(find.text('New purchase order'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('po-supplier')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('KWANG HENG SDN BHD'));
      await tester.pumpAndSettle();
      expect(find.text('30 DAYS'), findsOneWidget, reason: "the supplier's own term");

      await tester.enterText(find.byKey(const ValueKey('po-invoice')), 'inv-9');
      await tester.ensureVisible(find.byKey(const ValueKey('po-desc')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('po-desc')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SPARE PARTS').last);
      await tester.pumpAndSettle();
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('po-next')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('po-add-line')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('line-account')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TYRE'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('line-qty')), '2');
      await tester.enterText(find.byKey(const ValueKey('line-rate')), '300');
      await tester.pump();
      expect(find.text('RM 600.00'), findsWidgets);
      await tester.tap(find.byKey(const ValueKey('line-done')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('po-total')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('po-next')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('po-photo-camera')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('po-save')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('po-confirm')));
      await tester.pumpAndSettle();

      final body = verify(() => api.save(captureAny())).captured.single as Map<String, dynamic>;
      expect(body['supplierRefId'], 9);
      expect(body['paymentTermsRefid'], 3);
      expect(body['invoiceNo'], 'INV-9');
      expect(body['description'], 'SPARE PARTS');
      expect(body['amount'], 600);
      expect(body['employeeRefId'], 15);
      expect(body['dueDate'], isNotNull);
      verify(() => files.add([photo], folder: 'BillOrderMaster', recordId: 88)).called(1);
      expect(find.text('New purchase order'), findsNothing, reason: 'the form closes after saving');
    });

    testWidgets('save with problems shows them and does not save', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('step-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('po-save')));
      await tester.pumpAndSettle();
      expect(find.text('Please check'), findsOneWidget);
      verifyNever(() => api.save(any()));
    });

    testWidgets('Read with AI fills the form and keeps the photo', (tester) async {
      when(() => api.extract(any())).thenAnswer((_) async => {
            'supplier': {'supplierId': 9, 'paymentTermsId': 3},
            'header': {'invoiceNo': 'qt-1', 'invoiceDate': '2026-10-28'},
            'lines': [
              {'description': 'Tyre', 'quantity': 1, 'unitPrice': 250, 'accountId': 502},
            ],
            'warnings': [],
          });
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('po-ai')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ai-gallery')));
      await tester.pumpAndSettle();

      expect(find.text('KWANG HENG SDN BHD'), findsOneWidget);
      expect(find.text('Filled by AI: please check every field'), findsOneWidget);
      verify(() => api.extract(photo)).called(1);
      verifyNever(() => api.save(any()));
    });

    testWidgets('a job-order PO is sent to the web', (tester) async {
      when(() => api.load(5)).thenAnswer((_) async => {'id': 5, 'jobOrderMasterRefId': 2});
      await pump(tester, editId: 5);
      expect(find.textContaining('edit it on the web'), findsOneWidget);
      expect(find.byKey(const ValueKey('po-save')), findsNothing);
    });
  });

  test('ImageSource is passed through', () => expect(ImageSource.camera, isNotNull));
}
