import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/features/dashboard/payable_dashboard/levy/data/levy_api.dart';
import 'package:maleva/features/dashboard/payable_dashboard/levy/data/levy_draft.dart';
import 'package:maleva/features/dashboard/payable_dashboard/levy/view/levy_form_page.dart';
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

class MockLevyApi extends Mock implements LevyApi {}

class MockFiles extends Mock implements AttachmentsApi {}

const truck = Option(7, 'WXY 1234');
const driver = Option(15, 'ALI-0123456789');
const rti = Option(118, 'RTI000000118');

Map<String, dynamic> savedLevy() => {
      'id': 41,
      'companyRefId': 6,
      'cnumberDisplay': 'LE000000241',
      'saleDate': '2026-10-28',
      'truckRefId': 7,
      'truckName': 'WXY 1234',
      'driverRefId': 99,
      'driverName': 'OLD DRIVER',
      'rtiRefId': 118,
      'rtiNumber': 'RTI000000118',
      'enterLink': 'IN',
      'exitLink': '',
      'amount': 25.5,
      'remarks': 'north port',
    };

void main() {
  setUpAll(installLocalTestFonts);
  setUpAll(() {
    registerFallbackValue(<File>[]);
    registerFallbackValue(<String, dynamic>{});
  });

  group('draft (web PassEntryFormPage.tsx, PassEntrySaveRequest)', () {
    test('problems in the web order, then amount and remarks limits', () {
      final d = LevyDraft();
      expect(d.problems(), ['Choose the truck', 'Choose the driver', 'Choose the RTI number', 'Type the amount']);
      d
        ..truck = truck
        ..driver = driver
        ..rti = rti
        ..amount = -1;
      expect(d.problems(), ['The amount cannot be below zero']);
      d
        ..amount = 0
        ..remarks = 'x' * 2001;
      expect(d.problems(), ['Remarks can have at most 2000 letters']);
      d.remarks = 'ok';
      expect(d.problems(), isEmpty);
    });

    test('new levy body: no id, date yyyy-MM-dd, unset links and empty remarks left out', () {
      final d = LevyDraft(date: DateTime(2026, 10, 30), truck: truck, driver: driver, rti: rti, amount: 25);
      expect(d.toJson(companyId: 6, employeeId: 0), {
        'companyRefId': 6,
        'truckRefId': 7,
        'driverRefId': 15,
        'rtiRefId': 118,
        'saleDate': '2026-10-30',
        'amount': 25.0,
      });
      d
        ..id = 41
        ..enterLink = 'OUT'
        ..exitLink = '2ND LINK'
        ..remarks = '  gate  ';
      final j = d.toJson(companyId: 6, employeeId: 12);
      expect(j['id'], 41);
      expect(j['employeeRefId'], 12);
      expect(j['enterLink'], 'OUT');
      expect(j['exitLink'], '2ND LINK');
      expect(j['remarks'], 'gate');
    });

    test('fromEdit: listed choices used, a driver no longer listed kept by its saved name', () {
      final d = LevyDraft.fromEdit(savedLevy(), trucks: const [truck], drivers: const [driver], rtis: const [rti]);
      expect(d.id, 41);
      expect(d.number, 'LE000000241');
      expect(d.date, DateTime(2026, 10, 28));
      expect(d.truck, truck);
      expect(d.driver?.id, 99);
      expect(d.driver?.name, 'OLD DRIVER');
      expect(d.rti?.name, 'RTI000000118');
      expect(d.enterLink, 'IN');
      expect(d.exitLink, '');
      expect(d.amount, 25.5);
      expect(d.remarks, 'north port');
      expect(LevyDraft.fromEdit({'id': 1}).amount, isNull);
    });
  });

  group('api', () {
    late RouteAdapter adapter;
    late LevyApi api;
    setUp(() {
      adapter = RouteAdapter();
      api = LevyApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: 6);
    });

    String ok(Object? data) => jsonEncode({'IsSuccess': true, 'StatusCode': 200, 'Data1': data});

    test('next number, RTI choices, trucks, drivers (web names, active only, by name)', () async {
      adapter.replies['/api/levi-entries/next-no'] = (200, ok('LE000000242'));
      adapter.replies['/api/levi-entries/rti-options'] = (200, ok([{'id': 118, 'rtiNumber': 'RTI000000118'}, {'id': 0}]));
      adapter.replies['/api/truck-masters/alltruckdetatilcombo'] = (
        200,
        ok([{'id': 7, 'truckName': 'WXY 1234'}, {'id': 8, 'truckName': ''}])
      );
      adapter.replies['/api/driver-masters/selectalldriverDetails'] = (
        200,
        ok([
          {'id': 16, 'driverName': 'ZUL', 'mobileNo': '', 'active': 1, 'companyRefId': 6},
          {'id': 15, 'driverName': 'ALI', 'mobileNo': '0123456789', 'active': 1, 'companyRefId': 6},
          {'id': 17, 'driverName': 'OFF', 'active': 2, 'companyRefId': 6},
        ])
      );
      expect(await api.nextNumber(), 'LE000000242');
      expect(adapter.requests.last.queryParameters['companyRefId'], 6);
      expect((await api.rtiOptions()).map((o) => (o.id, o.name)), [(118, 'RTI000000118')]);
      expect((await api.trucks()).map((o) => o.name), ['WXY 1234']);
      expect(adapter.requests.last.queryParameters, {'companyId': 6, 'keyword': '', 'column': 'All'});
      expect((await api.drivers()).map((o) => o.name), ['ALI-0123456789', 'ZUL']);
    });

    test('load and save read Data1; a refusal is an ApiFailure with the server message', () async {
      adapter.replies['/api/levi-entries/41'] = (200, ok(savedLevy()));
      expect((await api.load(41))['truckName'], 'WXY 1234');

      adapter.replies['/api/levi-entries'] = (200, ok(savedLevy()));
      final r = await api.save({'companyRefId': 6});
      expect((r.id, r.number), (41, 'LE000000241'));
      expect(adapter.requests.last.method, 'POST');
      expect(adapter.requests.last.headers['Comid'], 6);

      adapter.replies['/api/levi-entries'] = (400, jsonEncode({'IsSuccess': false, 'Message': 'Truck 7 was not found'}));
      expect(() => api.save({}), throwsA(isA<ApiFailure>().having((e) => e.message, 'm', 'Truck 7 was not found')));
    });
  });

  group('form', () {
    late MockLevyApi api;
    late MockFiles files;

    setUp(() {
      api = MockLevyApi();
      files = MockFiles();
      when(() => api.companyId).thenReturn(6);
      when(() => api.trucks()).thenAnswer((_) async => const [truck]);
      when(() => api.drivers()).thenAnswer((_) async => const [driver]);
      when(() => api.rtiOptions()).thenAnswer((_) async => const [rti]);
      when(() => api.nextNumber()).thenAnswer((_) async => 'LE000000242');
      when(() => api.load(41)).thenAnswer((_) async => savedLevy());
      when(() => api.save(any())).thenAnswer((_) async => (id: 42, number: 'LE000000242'));
      when(() => files.list(folder: 'LeviEntry', recordId: 41)).thenAnswer((_) async => [
            {'fileName': 'receipt.pdf', 'path': '/Upload/6/LeviEntry/41/receipt.pdf', 'contentType': 'application/pdf'},
          ]);
    });

    Future<List<bool?>> pump(WidgetTester tester, {int? editId}) async {
      tester.view.physicalSize = const Size(360, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final results = <bool?>[];
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => results.add(await Navigator.of(context).push(MaterialPageRoute<bool>(
                  builder: (_) => LevyFormPage(api: api, files: files, editId: editId)))),
              child: const Text('open'),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return results;
    }

    Future<void> choose(WidgetTester tester, String key, String text) async {
      await tester.ensureVisible(find.byKey(ValueKey(key)));
      await tester.tap(find.byKey(ValueKey(key)));
      await tester.pumpAndSettle();
      await tester.tap(find.text(text).last);
      await tester.pumpAndSettle();
    }

    testWidgets('new levy at 360 px: missing fields refused, then saved and closed with true', (tester) async {
      final results = await pump(tester);
      expect(find.text('New levy'), findsOneWidget);
      expect(find.text('LE000000242'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('levy-save')));
      await tester.pumpAndSettle();
      expect(find.text('Choose the truck'), findsOneWidget);
      expect(find.text('Type the amount'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      verifyNever(() => api.save(any()));

      await choose(tester, 'levy-truck', 'WXY 1234');
      await choose(tester, 'levy-driver', 'ALI-0123456789');
      await choose(tester, 'levy-rti', 'RTI000000118');
      await choose(tester, 'levy-exit', '1ST LINK');
      await tester.ensureVisible(find.byKey(const ValueKey('levy-amount')));
      await tester.enterText(find.byKey(const ValueKey('levy-amount')), '25');
      await tester.pump();
      expect(find.text('RM 25.00'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('levy-save')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('levy-confirm')));
      await tester.pumpAndSettle();

      final body = verify(() => api.save(captureAny())).captured.single as Map<String, dynamic>;
      expect(body.containsKey('id'), isFalse);
      expect(body['truckRefId'], 7);
      expect(body['driverRefId'], 15);
      expect(body['rtiRefId'], 118);
      expect(body['exitLink'], '1ST LINK');
      expect(body.containsKey('enterLink'), isFalse);
      expect(body['amount'], 25);
      expect(body['saleDate'], Fmt.ymd(Fmt.today()));
      verifyNever(() => files.add(any(), folder: any(named: 'folder'), recordId: any(named: 'recordId')));
      expect(results, [true]);
      expect(find.text('New levy'), findsNothing);
    });

    testWidgets('edit levy at 360 px: saved values and files shown, saved with its id', (tester) async {
      final results = await pump(tester, editId: 41);
      expect(find.text('Edit LE000000241'), findsOneWidget);
      expect(find.text('OLD DRIVER'), findsOneWidget);
      expect(find.text('IN'), findsOneWidget);
      expect(find.text('receipt.pdf'), findsOneWidget);
      verifyNever(() => api.nextNumber());

      await tester.ensureVisible(find.byKey(const ValueKey('levy-amount')));
      await tester.enterText(find.byKey(const ValueKey('levy-amount')), '30.5');
      await tester.tap(find.byKey(const ValueKey('levy-save')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('levy-confirm')));
      await tester.pumpAndSettle();

      final body = verify(() => api.save(captureAny())).captured.single as Map<String, dynamic>;
      expect(body['id'], 41);
      expect(body['driverRefId'], 99);
      expect(body['amount'], 30.5);
      expect(body['enterLink'], 'IN');
      expect(body['remarks'], 'north port');
      expect(body['saleDate'], '2026-10-28');
      expect(results, [true]);
    });

    testWidgets('a server refusal keeps the form open', (tester) async {
      when(() => api.save(any())).thenThrow(const ApiFailure('Truck 7 was not found'));
      final results = await pump(tester, editId: 41);
      await tester.tap(find.byKey(const ValueKey('levy-save')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('levy-confirm')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Not saved'), findsOneWidget);
      expect(find.text('Edit LE000000241'), findsOneWidget);
      expect(results, isEmpty);
    });
  });
}
