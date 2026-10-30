import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/dashboard/payable_dashboard/records/bloc/records_cubit.dart';
import 'package:maleva/features/dashboard/payable_dashboard/records/data/payable_record.dart';
import 'package:maleva/features/dashboard/payable_dashboard/records/data/payable_records_api.dart';
import 'package:maleva/features/dashboard/payable_dashboard/records/view/records_tab.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/local_fonts.dart';

/// Answers by path, so parallel calls get the right body.
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

class MockApi extends Mock implements PayableRecordsApi {}

String ok(Object data) => jsonEncode({'IsSuccess': true, 'StatusCode': 200, 'Data1': data});

PayableRecord rec(int id, String status, {double amount = 100, String party = 'KWANG HENG', String number = 'PV-1'}) =>
    PayableRecord(
        kind: RecordKind.voucher,
        id: id,
        number: number,
        date: DateTime(2026, 10, id),
        party: party,
        amount: amount,
        status: status,
        description: 'FUEL');

void main() {
  setUpAll(installLocalTestFonts);
  setUpAll(() => registerFallbackValue(RecordKind.po));
  setUpAll(() => registerFallbackValue(DateTime(2026)));
  setUpAll(() => registerFallbackValue(rec(1, '')));

  group('rules', () {
    test('status words and colours', () {
      expect(statusLabel('ACCEPETED'), 'Accepted');
      expect(statusLabel(''), 'Pending');
      expect(statusLabel('SEND FOR APPROVAL'), 'Send for approval');
      expect(statusTone('ACCEPETED'), StatusTone.done);
      expect(statusTone('COMPLETED'), StatusTone.done);
      expect(statusTone('REJECTED'), StatusTone.rejected);
      expect(statusTone('SEND FOR APPROVAL'), StatusTone.waiting);
      expect(statusTone(''), StatusTone.waiting);
    });

    test('dates: dd/MM/yyyy, ISO, SQL; 1900 means none', () {
      expect(readDate('05/10/2026'), DateTime(2026, 10, 5));
      expect(readDate('2026-10-05'), DateTime(2026, 10, 5));
      expect(readDate('2026-10-05 13:20:00'), DateTime(2026, 10, 5, 13, 20));
      expect(readDate('01/01/1900')?.year, 1900); // dd/MM/yyyy kept as typed
      expect(readDate('1900-01-01T00:00:00'), isNull);
      expect(readDate(''), isNull);
    });
  });

  group('api', () {
    late RouteAdapter adapter;
    late PayableRecordsApi api;
    final from = DateTime(2026, 10, 1), to = DateTime(2026, 10, 30);

    setUp(() {
      adapter = RouteAdapter();
      api = PayableRecordsApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
    });

    test('PO list: legacy {ok,data}, PStatus 0 = Pending, lines counted, newest first', () async {
      adapter.replies['/api/bills-order/select-bills-order'] = (
        200,
        jsonEncode({
          'ok': true,
          'data': {
            'billsOrderMaster': [
              {'id': 1, 'billNoDisplay': 'PO-1', 'billDate': '02/10/2026', 'supplierName': 'A', 'netAmt': 10, 'pstatus': 0, 'billStatus': 'SPARE PARTS'},
              {'id': 2, 'billNoDisplay': 'PO-2', 'billDate': '20/10/2026', 'supplierName': 'B', 'netAmt': 20, 'pStatus': 1},
            ],
            'billsOrderDetails': [
              {'saleRefId': 1}, {'saleRefId': 1}, {'saleRefId': 2},
            ],
          },
        })
      );
      final rows = await api.list(RecordKind.po, from, to);
      expect(adapter.requests.single.queryParameters, {'comid': 6, 'fromdate': '2026-10-01', 'todate': '2026-10-30'});
      expect(rows.map((r) => r.number), ['PO-2', 'PO-1']);
      expect(rows.last.status, 'PENDING');
      expect(rows.last.tag, 'SPARE PARTS');
      expect(rows.last.lineCount, 2);
      expect(rows.first.status, 'DONE');
    });

    test('voucher list: ApiResponse, lower-case Lombok names read too, company sent', () async {
      adapter.replies['/api/payment-voucher-masters/search'] = (
        200,
        ok({
          'paymentVoucherMaster': [
            {'id': 41, 'cnumberDisplay': 'PV-41', 'spaymentVoucherDate': '03/10/2026', 'payTo': 'TNB', 'amount': 80, 'paymentStatus': 'ACCEPETED', 'description': 'UTILITY'},
          ],
          'paymentVoucherDetails': [],
        })
      );
      final r = (await api.list(RecordKind.voucher, from, to)).single;
      expect(r.number, 'PV-41');
      expect(r.date, DateTime(2026, 10, 3));
      expect(r.party, 'TNB');
      expect(statusLabel(r.status), 'Accepted');
      final req = adapter.requests.single;
      expect(req.queryParameters['companyId'], 6);
      expect((req.data as Map)['fromDate'], '2026-10-01');
    });

    test('a refusal is an ApiFailure', () async {
      adapter.replies['/api/bills/search'] = (200, jsonEncode({'IsSuccess': false, 'Message': 'No access'}));
      expect(() => api.list(RecordKind.bill, from, to), throwsA(isA<ApiFailure>()));
    });

    test('pay bill detail: only the bills this payment paid', () async {
      adapter.replies['/api/payments/edit'] = (
        200,
        ok({
          'id': 9, 'cNumberDisplay': 'PB-9', 'paymentDate': '2026-10-04', 'bankName': 'MAYBANK', 'amount': 300,
          'paymentDetails': [
            {'billNo': 'B-1', 'invoiceNo': 'INV1', 'billAmount': 500, 'amount': 300},
            {'billNo': 'B-2', 'billAmount': 200, 'amount': 0},
          ],
        })
      );
      final d = await api.detail(const PayableRecord(
          kind: RecordKind.payBill, id: 9, number: 'PB-9', date: null, party: 'KH', amount: 300, status: ''));
      expect(d.lines.single.title, 'Bill B-1 · Inv INV1');
      expect(d.total, 300);
      expect(d.facts, contains(('Bank', 'MAYBANK')));
      expect(d.facts, contains(('Payment date', '04/10/2026')));
    });

    test('petty cash detail: amount sent as text is read as a number', () async {
      adapter.replies['/api/petty-cash-masters/edit'] = (
        200,
        ok({'id': 3, 'amount': '45.50', 'pettyCashDetails': [{'items': 'PARKING', 'amount': 45.5}]})
      );
      final d = await api.detail(const PayableRecord(
          kind: RecordKind.pettyCash, id: 3, number: 'PC-3', date: null, party: 'ALI', amount: 0, status: ''));
      expect(d.total, 45.5);
      expect(d.lines.single.title, 'PARKING');
    });

    test('PO detail: data is a list; the first record is read', () async {
      adapter.replies['/api/bills-order/edit-bills-order'] = (
        200,
        jsonEncode({
          'ok': true,
          'data': [
            {'id': 1, 'amount': 120, 'invoiceNo': 'X1', 'billsOrderDetails': [{'productName': 'TYRE', 'itemQty': 2, 'salesRate': 60, 'amount': 120}]},
          ],
        })
      );
      final d = await api.detail(const PayableRecord(
          kind: RecordKind.po, id: 1, number: 'PO-1', date: null, party: 'A', amount: 0, status: 'PENDING'));
      expect(d.total, 120);
      expect(d.lines.single.quantity, 2);
      expect(d.facts, contains(('Invoice no.', 'X1')));
    });

    test('file counts: string keys to ids; files listed', () async {
      adapter.replies['/api/attachments/summary'] = (200, ok({'41': 2, '7': 1}));
      adapter.replies['/api/attachments'] = (
        200,
        ok([
          {'fileName': 'a.jpg', 'path': '/uploads/6/PaymentVoucher/41/a.jpg', 'contentType': 'image/jpeg', 'sizeBytes': 2048},
          {'fileName': 'b.pdf', 'path': '/uploads/6/PaymentVoucher/41/b.pdf', 'contentType': 'application/pdf', 'sizeBytes': 1},
        ])
      );
      expect(await api.fileCounts(RecordKind.voucher), {41: 2, 7: 1});
      final files = await api.files(rec(41, ''));
      expect(files.first.isImage, isTrue);
      expect(files.last.isPdf, isTrue);
      expect(adapter.requests.last.queryParameters, {'companyRefId': 6, 'recordId': 41, 'folderName': 'PaymentVoucher'});
    });
  });

  group('cubit', () {
    late MockApi api;
    setUp(() {
      api = MockApi();
      when(() => api.list(any(), any(), any())).thenAnswer((_) async => [
            rec(1, 'ACCEPETED', party: 'TNB'),
            rec(2, 'REJECTED', party: 'KWANG HENG'),
            rec(3, 'ACCEPETED', party: 'PETRON'),
          ]);
      when(() => api.fileCounts(any())).thenAnswer((_) async => {1: 2});
    });

    test('search and status filter the loaded list; last month dates', () async {
      final c = RecordsCubit(api, clock: () => DateTime(2026, 10, 30));
      await c.load();
      expect(c.state.statuses, ['Accepted', 'Rejected']);
      c.chooseStatus('Accepted');
      expect(c.state.shown.map((r) => r.id), [1, 3]);
      c.search('petr');
      expect(c.state.shown.single.id, 3);
      expect(c.state.fileCounts, {1: 2});

      c.choosePeriod(RecordPeriod.lastMonth);
      expect(c.state.from, DateTime(2026, 9, 1));
      expect(c.state.to, DateTime(2026, 9, 30));
    });

    test('a failing file count leaves the list', () async {
      when(() => api.fileCounts(any())).thenThrow(const ApiFailure('down'));
      final c = RecordsCubit(api, clock: () => DateTime(2026, 10, 30));
      await c.load();
      expect(c.state.records, hasLength(3));
      expect(c.state.error, isNull);
    });
  });

  group('screens', () {
    late MockApi api;
    setUp(() {
      api = MockApi();
      when(() => api.list(any(), any(), any())).thenAnswer((_) async => [
            rec(1, 'ACCEPETED', party: 'TNB', amount: 80),
            rec(2, 'REJECTED', party: 'KWANG HENG', amount: 20),
          ]);
      when(() => api.fileCounts(any())).thenAnswer((_) async => {1: 2});
      when(() => api.detail(any())).thenAnswer((_) async => const RecordDetail(
            facts: [('Pay to', 'TNB'), ('Reference', '')],
            lines: [RecordLine(title: 'ELECTRIC', subtitle: 'Oct', amount: 80)],
            total: 80,
            lineTitle: 'Accounts',
          ));
      when(() => api.files(any())).thenAnswer((_) async => const [
            RecordFile(name: 'bill.pdf', path: '/uploads/6/PaymentVoucher/1/bill.pdf', contentType: 'application/pdf', size: 30000),
          ]);
    });

    Future<RecordsCubit> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = RecordsCubit(api, clock: () => DateTime(2026, 10, 30));
      await c.load();
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: RecordsTab(api: api, cubit: c))));
      await tester.pump();
      return c;
    }

    testWidgets('cards, total, status chip, open the detail with lines and files', (tester) async {
      await pump(tester);
      expect(find.text('TNB'), findsOneWidget);
      expect(find.text('KWANG HENG'), findsOneWidget);
      expect(find.byKey(const ValueKey('records-total')), findsOneWidget);
      expect(find.text('RM 100.00'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('status-Rejected')));
      await tester.pump();
      expect(find.text('TNB'), findsNothing);
      await tester.tap(find.byKey(const ValueKey('status-All')));
      await tester.pump();

      await tester.tap(find.text('TNB'));
      await tester.pumpAndSettle();
      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('ELECTRIC'), findsOneWidget);
      expect(find.text('Reference'), findsNothing, reason: 'empty facts are left out');
      expect(find.text('bill.pdf'), findsOneWidget);
    });

    testWidgets('switching record type asks that type', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const ValueKey('kind-payBill')));
      await tester.pump();
      verify(() => api.list(RecordKind.payBill, DateTime(2026, 10, 1), DateTime(2026, 10, 30))).called(1);
    });

    testWidgets('detail: files failing shows Retry, details still shown', (tester) async {
      when(() => api.files(any())).thenThrow(const ApiFailure('Files down'));
      await pump(tester);
      await tester.tap(find.text('TNB'));
      await tester.pumpAndSettle();
      expect(find.text('ELECTRIC'), findsOneWidget);
      expect(find.text('Files down'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
