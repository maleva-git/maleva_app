import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/features/dashboard/payable_dashboard/paybill/data/paybill_api.dart';
import 'package:maleva/features/dashboard/payable_dashboard/paybill/data/paybill_draft.dart';
import 'package:maleva/features/dashboard/payable_dashboard/paybill/view/paybill_form_page.dart';
import 'package:maleva/features/dashboard/payable_dashboard/po/data/po_api.dart';
import 'package:maleva/features/dashboard/payable_dashboard/po/data/po_draft.dart';
import 'package:maleva/features/dashboard/payable_dashboard/voucher/data/voucher_api.dart';
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

class MockPayBillApi extends Mock implements PayBillApi {}

class MockFiles extends Mock implements AttachmentsApi {}

const kh = Option(9, 'KWANG HENG SDN BHD');
const maybank = Option(3, 'MAYBANK CURRENT');

List<PayRow> openRows() => [
      PayRow(billMasterRefId: 40, billNo: 'BIL2610/004', invoiceNo: 'INV-1', billAmount: 600, balance: 600),
      PayRow(billMasterRefId: 41, billNo: 'BIL2610/005', billAmount: 300, paid: 100, balance: 200),
      PayRow(supplieropenRefId: 2, billAmount: 50, balance: 50),
    ];

void main() {
  setUpAll(installLocalTestFonts);
  setUpAll(() {
    registerFallbackValue(<File>[]);
    registerFallbackValue(<String>[]);
    registerFallbackValue(<String, dynamic>{});
  });

  group('draft (web PaymentPage.tsx)', () {
    test('checks in the web order; overpaying a bill refused', () {
      final d = PayBillDraft();
      expect(d.problems(), [
        'Choose the supplier',
        'Choose the bank (payment by)',
        'Type the reference number',
        'Choose the description',
        'Put an amount on at least one bill',
      ]);
      d
        ..supplier = kh
        ..bank = maybank
        ..refNo = 'TT123'
        ..description = 'VENDOR'
        ..rows = openRows();
      d.rows[1].amount = 250;
      expect(d.problems(), ['BIL2610/005: the amount is more than its balance (RM 200.00)']);
      d.rows[1].amount = 200;
      expect(d.problems(), isEmpty);
    });

    test('Pay all fills every balance; labels', () {
      final d = PayBillDraft(rows: openRows())..payAll();
      expect(d.total, 850);
      expect(d.outstanding, 850);
      expect(d.rows[2].label, 'Opening balance');
    });

    test('save body: only rows with an amount, their refs; pv status', () {
      final d = PayBillDraft(
        supplier: kh,
        bank: maybank,
        date: DateTime(2026, 10, 30),
        refNo: ' TT123 ',
        payTo: '',
        description: 'VENDOR',
        sendToVoucher: true,
        bankName: 'CIMB',
        accountNo: '800-1',
        rows: openRows(),
      );
      d.rows[0].amount = 600;
      final j = d.toJson(employeeId: 15);
      expect(j['supplierRefId'], 9);
      expect(j['bankRefId'], 3);
      expect(j['paymentDate'], '2026-10-30');
      expect(j['refNumber'], 'TT123');
      expect(j['payTo'], 'DIRECT PAYMENT');
      expect(j['paymentStatus'], 'SEND FOR APPROVAL');
      expect(j['pvStatus'], 1);
      expect(j['amount'], 600);
      expect(j['bankName'], 'CIMB');
      final line = (j['paymentDetails'] as List).single as Map;
      expect(line['billMasterRefId'], 40);
      expect(line['supplieropenRefId'], isNull);
      expect(line['amount'], 600);
    });

    test('edit: whole open list with this payment amounts', () {
      final d = PayBillDraft.fromEdit({
        'id': 9,
        'cNumberDisplay': 'PAY000009',
        'supplierRefId': 9,
        'bankRefId': 3,
        'paymentDate': '2026-10-04T00:00:00',
        'refNumber': 'TT1',
        'paymentStatus': 'ACCEPETED',
        'pvStatus': 1,
        'paymentDetails': [
          {'billMasterRefId': 40, 'billNo': 'BIL1', 'balance': 600, 'amount': 300},
          {'billMasterRefId': 41, 'billNo': 'BIL2', 'balance': 200, 'amount': 0},
        ],
      }, suppliers: [kh], banks: [maybank]);
      expect(d.supplier, kh);
      expect(d.bank, maybank);
      expect(d.date, DateTime(2026, 10, 4));
      expect(d.sendToVoucher, isTrue);
      expect(d.rows, hasLength(2));
      expect(d.selected.single.billNo, 'BIL1');
      expect(d.total, 300);
    });
  });

  test('api: supplier bills and save', () async {
    final adapter = RouteAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter;
    final po = PoApi(dio, companyId: () => 6);
    final api = PayBillApi(dio, po, VoucherApi(dio, po));
    adapter.replies['/api/payments/supplier-bills'] = (
      200,
      jsonEncode({'IsSuccess': true, 'Data1': [{'billMasterRefId': 40, 'billNo': 'BIL1', 'sBillDate': '2026-10-02 00:00:00', 'billAmount': 600, 'payment': 0, 'balance': 600, 'amount': 0}]})
    );
    adapter.replies['/api/payments/save'] = (
      200,
      jsonEncode({'IsSuccess': true, 'Data1': {'success': true, 'id': 77, 'paymentNoDisplay': 'PAY000077', 'duplicate': false}})
    );
    final rows = await api.supplierBills(9);
    expect(rows.single.balance, 600);
    expect(adapter.requests.single.queryParameters, {'companyId': 6, 'supplierId': 9, 'excludePaymentId': 0});
    final r = await api.save({'id': 0});
    expect((r.id, r.number), (77, 'PAY000077'));
  });

  group('form', () {
    late MockPoApi po;
    late MockPayBillApi api;
    late MockFiles files;

    setUp(() {
      po = MockPoApi();
      api = MockPayBillApi();
      files = MockFiles();
      when(() => api.po).thenReturn(po);
      when(() => api.companyId).thenReturn(6);
      when(() => po.suppliers()).thenAnswer((_) async => [kh]);
      when(() => api.banks()).thenAnswer((_) async => [maybank]);
      when(() => api.nextNumber()).thenAnswer((_) async => 'PAY000078');
      when(() => api.supplierBills(9, excludePaymentId: any(named: 'excludePaymentId'))).thenAnswer((_) async => openRows());
      when(() => api.supplierBank(9)).thenAnswer(
          (_) async => (bankName: 'CIMB', accountNo: '800-1', tinNo: '', sstNo: '', msicCode: '', serviceTaxType: ''));
      when(() => api.supplierOfBill(41)).thenAnswer((_) async => 9);
      when(() => api.save(any())).thenAnswer((_) async => (id: 78, number: 'PAY000078', duplicate: false));
      when(() => files.list(folder: 'BillMaster', recordId: any(named: 'recordId'))).thenAnswer((_) async => [
            {'fileName': 'bill.pdf', 'path': '/uploads/6/BillMaster/41/bill.pdf', 'contentType': 'application/pdf'},
          ]);
      when(() => files.copyFrom(any(), folder: any(named: 'folder'), recordId: any(named: 'recordId'))).thenAnswer((_) async => const []);
    });

    Future<void> pump(WidgetTester tester, {int? fromBillId}) async {
      tester.view.physicalSize = const Size(390, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<bool>(
                  builder: (_) => PayBillFormPage(api: api, files: files, fromBillId: fromBillId, employeeId: 15))),
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('Pay this bill: supplier chosen, that bill gets its balance, saved with the bill file copied', (tester) async {
      await pump(tester, fromBillId: 41);
      expect(find.text('Open bills of KWANG HENG SDN BHD'), findsOneWidget, reason: 'opens on the Bills step');
      expect(find.text('RM 200.00'), findsWidgets);

      await tester.tap(find.byKey(const ValueKey('step-0')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Their bank: CIMB'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('pb-bank')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('MAYBANK CURRENT'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('pb-ref')), 'TT555');
      await tester.ensureVisible(find.byKey(const ValueKey('pb-desc')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pb-desc')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('VENDOR').last);
      await tester.pumpAndSettle();
      await tester.pump();

      await tester.tap(find.byKey(const ValueKey('step-2')));
      await tester.pumpAndSettle();
      expect(find.text('bill.pdf'), findsOneWidget, reason: "the paid bill's file is offered");
      await tester.tap(find.byKey(const ValueKey('pb-save')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pb-confirm')));
      await tester.pumpAndSettle();

      final body = verify(() => api.save(captureAny())).captured.single as Map<String, dynamic>;
      expect(body['refNumber'], 'TT555');
      expect(body['bankRefId'], 3);
      expect(body['amount'], 200);
      expect((body['paymentDetails'] as List).single['billMasterRefId'], 41);
      expect(body['bankName'], 'CIMB');
      verify(() => files.copyFrom(['/uploads/6/BillMaster/41/bill.pdf'], folder: 'PayBills', recordId: 78)).called(1);
    });

    testWidgets('put an amount on a bill with Full balance; more than balance is refused', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('pb-supplier')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('KWANG HENG SDN BHD'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pb-next')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('pb-row-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('pb-row-full')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('po-total')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('pb-row-1')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('pb-row-amount')), '999');
      await tester.tap(find.byKey(const ValueKey('pb-row-done')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('pb-next')));
      await tester.pumpAndSettle();
      expect(find.textContaining('more than its balance'), findsOneWidget);
      verifyNever(() => api.save(any()));
    });
  });
}
