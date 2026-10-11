import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/response_report_models.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/features/mail_monitor/report/mail_response_tab.dart';
import 'package:maleva/features/mail_monitor/report/response_report_cubit.dart';
import 'package:maleva/features/mail_monitor/report/response_rules.dart';
import 'package:maleva/features/mail_monitor/report/summary_speaker.dart';
import 'package:mocktail/mocktail.dart';

import '../../../core/network/java_api_client_test.dart' show QueueAdapter;
import '../../../support/local_fonts.dart';
import 'response_fixtures.dart';

class _Api extends Mock implements MailMonitorApi {}

class _Speaker implements SummarySpeaker {
  final spoken = <String>[];
  Completer<void>? _done;
  bool available = true;

  @override
  Future<bool> speak(String text) async {
    spoken.add(text);
    _done = Completer<void>();
    await _done!.future;
    return available;
  }

  void finish() => _done?.complete();

  @override
  Future<void> stop() async {
    if (_done != null && !_done!.isCompleted) _done!.complete();
  }
}

Map<String, dynamic> ok(Object? data) => {'IsSuccess': true, 'StatusCode': 200, 'Message': 'ok', 'Data1': data};

// Sat 11 Oct 2026, 09:30 in Malaysia.
final _now = DateTime.utc(2026, 10, 11, 1, 30);
const _last7 = ReportRange('2026-10-05', '2026-10-11');

ResponseReport report(List<Map<String, dynamic>> rows) => ResponseReport.fromJava(reportJson(rows));

void main() {
  setUpAll(() async {
    await installLocalTestFonts();
    registerFallbackValue(_last7);
  });

  group('MailMonitorApi report calls', () {
    late QueueAdapter adapter;
    late MailMonitorApi api;
    setUp(() {
      adapter = QueueAdapter();
      api = MailMonitorApi(Dio(BaseOptions(baseUrl: 'https://java.test'))..httpClientAdapter = adapter, companyId: () => 6);
    });

    test('report, late list and summary go to the web endpoints with the company and range', () async {
      adapter.replies
        ..add((200, jsonEncode(ok(reportJson([rowJson()])))))
        ..add((200, jsonEncode(ok({
              'mailboxId': 1,
              'slowest': [
                {'uid': 7, 'receivedAt': '2026-10-10T01:00:00Z', 'firstReplyAt': '2026-10-10T03:00:00Z', 'minutes': 120, 'status': 'REPLIED'},
              ],
              'waiting': [
                {'uid': 9, 'receivedAt': '2026-10-09T01:00:00Z', 'status': 'WAITING', 'senderDomain': 'client.com'},
              ],
            }))))
        ..add((200, jsonEncode(ok({'text': '- Good week', 'provider': 'x', 'model': 'y', 'generatedAt': '2026-10-11T01:00:00Z'}))));

      final r = await api.responseReport(_last7);
      expect(adapter.requests.last.uri.toString(),
          'https://java.test/api/mail-monitor/response-report?companyId=6&from=2026-10-05&to=2026-10-11');
      expect(r.mailboxes.single.numbers.waiting, 1);

      final late = await api.responseLate(1, _last7);
      expect(adapter.requests.last.uri.path, '/api/mail-monitor/response-report/late');
      expect(adapter.requests.last.uri.queryParameters['mailboxId'], '1');
      expect(late.slowest.single.minutes, 120);
      expect(late.waiting.single.waiting, isTrue);

      final s = await api.responseSummary(_last7);
      expect(adapter.requests.last.method, 'POST');
      expect(adapter.requests.last.uri.queryParameters['from'], '2026-10-05');
      expect(s.points, ['Good week']);
    });

    test('a refused PDF keeps the server message', () async {
      adapter.replies.add((403, jsonEncode({'IsSuccess': false, 'StatusCode': 403, 'Message': 'Only the Super Admin'})));
      await expectLater(
        api.responsePdf(_last7),
        throwsA(isA<ApiFailure>().having((f) => f.message, 'message', 'Only the Super Admin')),
      );
    });
  });

  group('ResponseReportCubit', () {
    late _Api api;
    late _Speaker speaker;
    setUp(() {
      api = _Api();
      speaker = _Speaker();
      when(() => api.responseReport(any())).thenAnswer((_) async => report([rowJson()]));
    });

    test('opens on the last 7 Malaysia days; a new range reloads and clears the summary', () async {
      when(() => api.responseSummary(any()))
          .thenAnswer((_) async => const ResponseSummary(text: 'One', generatedAt: null));
      final cubit = ResponseReportCubit(api, speaker, clock: () => _now);
      await cubit.load();
      expect(cubit.state.range, _last7);
      await cubit.writeSummary();
      expect(cubit.state.summary, isNotNull);

      await cubit.choosePreset(RangePreset.today);
      expect(cubit.state.range, const ReportRange('2026-10-11', '2026-10-11'));
      expect(cubit.state.summary, isNull);
      verify(() => api.responseReport(const ReportRange('2026-10-11', '2026-10-11'))).called(1);
      await cubit.close();
    });

    test('a summary error stays on the card; the report stays', () async {
      when(() => api.responseSummary(any())).thenThrow(const ApiFailure('AI is not configured', statusCode: 503));
      final cubit = ResponseReportCubit(api, speaker, clock: () => _now);
      await cubit.load();
      await cubit.writeSummary();
      expect(cubit.state.summaryError, 'AI is not configured');
      expect(cubit.state.report, isNotNull);
      await cubit.close();
    });

    test('read aloud speaks the points; Stop stops', () async {
      when(() => api.responseSummary(any()))
          .thenAnswer((_) async => const ResponseSummary(text: '- One\n- Two', generatedAt: null));
      final cubit = ResponseReportCubit(api, speaker, clock: () => _now);
      await cubit.load();
      await cubit.writeSummary();

      final speaking = cubit.toggleSpeech();
      expect(cubit.state.speaking, isTrue);
      expect(speaker.spoken.single, 'One. Two');
      await cubit.toggleSpeech();
      await speaking;
      expect(cubit.state.speaking, isFalse);
      await cubit.close();
    });

    test('a 503 keeps its code for the message', () async {
      when(() => api.responseReport(any())).thenThrow(const ApiFailure('Mail monitor not set up', statusCode: 503));
      final cubit = ResponseReportCubit(api, speaker, clock: () => _now);
      await cubit.load();
      expect((cubit.state.error, cubit.state.errorCode), ('Mail monitor not set up', 503));
      await cubit.close();
    });
  });

  group('Mail Response tab', () {
    late _Api api;
    late _Speaker speaker;
    setUp(() {
      api = _Api();
      speaker = _Speaker();
      when(() => api.responseReport(any())).thenAnswer((_) async => report([
            rowJson({'mailboxId': 1, 'address': 'fast@maleva.com.my', 'owners': ['Aina'], 'withinTargetPct': 96, 'avgMinutes': 6}),
            rowJson({'mailboxId': 2, 'address': 'slow@maleva.com.my', 'owners': ['Badrul'], 'withinTargetPct': 42, 'waiting': 3}),
          ]));
    });

    Future<void> pump(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MailResponseTab(api: api, speaker: speaker, clock: () => _now)),
      ));
      await tester.pump();
    }

    testWidgets('phone: spotlight, numbers, slowest first, then fastest first', (tester) async {
      await pump(tester, const Size(400, 2600));

      expect(find.text('Showing 5 Oct 2026 – 11 Oct 2026 · 7 days'), findsOneWidget);
      expect(find.text('Aina'), findsWidgets);
      expect(find.text('Badrul'), findsWidgets);
      expect(find.text('Behind'), findsOneWidget);
      expect(find.text('On target'), findsOneWidget);
      expect(tester.takeException(), isNull);

      Offset at(String owner) => tester.getTopLeft(find.text(owner).last);
      expect(at('Badrul').dy, lessThan(at('Aina').dy));
      await tester.tap(find.text('Fastest first'));
      await tester.pump();
      expect(at('Aina').dy, lessThan(at('Badrul').dy));
    });

    testWidgets('tablet: lays out without overflow', (tester) async {
      await pump(tester, const Size(1280, 1800));
      expect(find.text('Fastest replier'.toUpperCase()), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AI summary: write, then read aloud and stop', (tester) async {
      when(() => api.responseSummary(any()))
          .thenAnswer((_) async => const ResponseSummary(text: '- Replies were fast', generatedAt: null));
      await pump(tester, const Size(400, 2600));

      await tester.tap(find.text('Write summary'));
      await tester.pump();
      expect(find.text('Replies were fast'), findsOneWidget);

      await tester.tap(find.text('Read aloud'));
      await tester.pump();
      expect(find.text('Stop'), findsOneWidget);
      expect(speaker.spoken.single, 'Replies were fast');

      speaker.finish();
      await tester.pump();
      expect(find.text('Read aloud'), findsOneWidget);
    });

    testWidgets('a mailbox opens its late mail', (tester) async {
      when(() => api.responseLate(2, any())).thenAnswer((_) async => LateList.fromJava({
            'slowest': <Map<String, dynamic>>[],
            'waiting': [
              {'uid': 9, 'receivedAt': '2026-10-09T01:00:00Z', 'status': 'WAITING', 'senderDomain': 'client.com'},
            ],
          }));
      await pump(tester, const Size(400, 2600));

      await tester.tap(find.text('slow@maleva.com.my · Customer service'));
      await tester.pumpAndSettle();
      expect(find.text('Still waiting for a reply (oldest first)'), findsOneWidget);
      expect(find.text('No reply'), findsOneWidget);
      expect(find.text('from client.com'), findsOneWidget);
    });

    testWidgets('403 says only the Super Admin can see it', (tester) async {
      when(() => api.responseReport(any())).thenThrow(const ApiFailure('Forbidden', statusCode: 403));
      await pump(tester, const Size(400, 1400));
      expect(find.text('Only the Super Admin can see the mail response report'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
