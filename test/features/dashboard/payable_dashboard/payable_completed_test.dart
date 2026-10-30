import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/dashboard/payable_dashboard/completed/completed_api.dart';
import 'package:maleva/features/dashboard/payable_dashboard/completed/completed_tab.dart';
import 'package:maleva/features/dashboard/payable_dashboard/records/data/payable_record.dart';
import 'package:maleva/features/dashboard/payable_dashboard/records/data/payable_records_api.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/local_fonts.dart';

class BytesAdapter implements HttpClientAdapter {
  final Map<String, (int, Object)> replies = {};
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? stream, Future<void>? cancelFuture) async {
    requests.add(options);
    final (status, body) = replies[options.path] ?? (404, '{}');
    if (body is List<int>) {
      return ResponseBody.fromBytes(body, status, headers: {
        Headers.contentTypeHeader: ['application/pdf'],
      });
    }
    return ResponseBody.fromString(body as String, status, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

class MockCompletedApi extends Mock implements CompletedApi {}

class MockRecordsApi extends Mock implements PayableRecordsApi {}

Map<String, dynamic> row(int id, String paidTo, double amount, String head, {int detailed = 0, String status = 'ACCEPETED', String date = '05/10/2026'}) => {
      'id': id,
      'sSaleDate': date,
      'cNumberDisplay': detailed == 1 ? 'PAY$id' : 'PV$id',
      'expenseName': paidTo,
      'refNumber': 'R$id',
      'amount': amount,
      'detailedId': detailed,
      'filePath': head,
      'paymentStatus': status,
    };

CompletedMonth month() => CompletedMonth(
      rows: [
        CompletedRow.fromJava(row(1, 'PETRON', 10000, 'FUEL')),
        CompletedRow.fromJava(row(2, 'KWANG HENG', 3000, 'VENDOR', detailed: 1, status: 'SEND FOR APPROVAL', date: '20/10/2026')),
        CompletedRow.fromJava(row(3, 'SIN HOCK', 2052.91, 'VENDOR', status: 'COMPLETED')),
      ],
      total: 15052.91,
      count: 3,
    );

void main() {
  setUpAll(installLocalTestFonts);
  setUpAll(() {
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(const PayableRecord(kind: RecordKind.voucher, id: 0, number: '', date: null, party: '', amount: 0, status: ''));
  });

  test('rows, totals per head (biggest first), approved part; a row opens its register', () {
    final m = month();
    expect(m.byHead.map((h) => (h.head, h.count, h.amount)), [('FUEL', 1, 10000.0), ('VENDOR', 2, 5052.91)]);
    expect(m.approved, closeTo(12052.91, 0.001));
    final pay = m.rows[1].record;
    expect(pay.kind, RecordKind.payBill);
    expect(pay.number, 'PAY2');
    expect(m.rows[0].record.kind, RecordKind.voucher);
    expect(m.rows[0].date, DateTime(2026, 10, 5));
  });

  group('api', () {
    late BytesAdapter adapter;
    late CompletedApi api;
    setUp(() {
      adapter = BytesAdapter();
      api = CompletedApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
    });

    test('month: the web body, the server total and count', () async {
      adapter.replies['/api/transaction-reports/payment-done'] = (
        200,
        jsonEncode({
          'IsSuccess': true,
          'Data1': {'rows': [row(1, 'PETRON', 10000, 'FUEL')], 'totalAmount': 10000, 'count': 1},
        })
      );
      final m = await api.load(DateTime(2026, 10, 1), DateTime(2026, 10, 30));
      expect(m.total, 10000);
      expect(m.rows.single.head, 'FUEL');
      final req = adapter.requests.single;
      expect(req.queryParameters['companyId'], 6);
      expect(req.data, {
        'comid': 6,
        'fromDate': '2026-10-01',
        'toDate': '2026-10-30',
        'supplierId': 0,
        'payTo': '',
        'descriptions': <String>[],
      });
    });

    test('report: PDF bytes; a JSON refusal becomes its message', () async {
      final pdf = utf8.encode('%PDF-1.4 test');
      adapter.replies['/api/transaction-reports/payment-done/report'] = (200, pdf);
      expect(await api.reportPdf(DateTime(2026, 10, 1), DateTime(2026, 10, 30)), pdf);

      adapter.replies['/api/transaction-reports/payment-done/report'] = (500, utf8.encode(jsonEncode({'IsSuccess': false, 'Message': 'Report failed'})));
      expect(() => api.reportPdf(DateTime(2026, 10, 1), DateTime(2026, 10, 30)),
          throwsA(isA<ApiFailure>().having((e) => e.message, 'm', 'Report failed')));
    });
  });

  group('tab', () {
    late MockCompletedApi api;
    late MockRecordsApi records;
    setUp(() {
      api = MockCompletedApi();
      records = MockRecordsApi();
      when(() => api.load(any(), any())).thenAnswer((_) async => month());
      when(() => api.reportPdf(any(), any())).thenAnswer((_) async => utf8.encode('%PDF'));
      when(() => records.detail(any())).thenAnswer((_) async => const RecordDetail(facts: [], lines: [], total: 0));
      when(() => records.files(any())).thenAnswer((_) async => const []);
    });

    Future<List<String>> pump(WidgetTester tester) async {
      final opened = <String>[];
      tester.view.physicalSize = const Size(390, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CompletedTab(
            api: api,
            records: records,
            clock: () => DateTime(2026, 10, 30),
            openPdf: (bytes, name) async => opened.add(name),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      return opened;
    }

    testWidgets('this month: total, per head with a Total row, report opened, no next month', (tester) async {
      final opened = await pump(tester);
      expect(find.text('October 2026'), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const ValueKey('completed-total'))).data, 'RM 15,052.91');
      expect(find.text('Approved RM 12,052.91 · Waiting RM 3,000.00'), findsOneWidget);
      expect(tester.widget<IconButton>(find.byKey(const ValueKey('month-next'))).onPressed, isNull);
      verify(() => api.load(DateTime(2026, 10, 1), DateTime(2026, 10, 30))).called(1);

      await tester.tap(find.byKey(const ValueKey('completed-report')));
      await tester.pumpAndSettle();
      expect(opened, ['payments_2026_10.pdf']);
    });

    testWidgets('tap a head to filter; last month asks its whole month', (tester) async {
      await pump(tester);
      expect(find.text('PETRON'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('completed-head-VENDOR')));
      await tester.pump();
      expect(find.text('PETRON'), findsNothing);
      expect(find.text('KWANG HENG'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('month-prev')));
      await tester.pumpAndSettle();
      expect(find.text('September 2026'), findsOneWidget);
      verify(() => api.load(DateTime(2026, 9, 1), DateTime(2026, 9, 30))).called(1);
    });

    testWidgets('a payment opens its record page', (tester) async {
      await pump(tester);
      await tester.tap(find.text('KWANG HENG'));
      await tester.pumpAndSettle();
      expect(find.text('Pay bill PAY2'), findsOneWidget);
    });
  });
}
