import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/mailmonitor/mail_monitor_api.dart';
import 'package:maleva/core/mailmonitor/response_report_models.dart';
import 'package:maleva/features/mail_monitor/report/mail_response_tab.dart';
import 'package:maleva/features/mail_monitor/report/response_rules.dart';
import 'package:maleva/features/mail_monitor/report/summary_speaker.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/local_fonts.dart';
import 'response_fixtures.dart';

class _Api extends Mock implements MailMonitorApi {}

class _Quiet implements SummarySpeaker {
  @override
  Future<SpeakResult> speak(String text, {required String voice}) async => SpeakResult.spoken;

  @override
  Future<void> stop() async {}
}

// Sun 11 Oct 2026, 09:30 in Malaysia.
final _now = DateTime.utc(2026, 10, 11, 1, 30);
const _last7 = ReportRange('2026-10-05', '2026-10-11');
const _sorting = {'customerMails': 100, 'needReply': 10, 'ccOnly': 60, 'otherName': 20, 'team': 10, 'sorted': true};

void main() {
  setUpAll(() async {
    await installLocalTestFonts();
    registerFallbackValue(_last7);
  });

  group('who the mail was for', () {
    test('the sorting and the proof list are read as the Java API sends them', () {
      final row = responseRow({'sorting': _sorting});
      expect(row.numbers.sorting!.notTheirs, 90);
      expect(sortingText(row.numbers.sorting),
          '10 of 100 customer mails needed a reply · 90 did not (60 copied in, 20 to a colleague, 10 answered by a colleague)');
      expect(sortingText(responseRow().numbers.sorting), isNull);
      expect(sortingText(responseRow({'sorting': {..._sorting, 'sorted': false}}).numbers.sorting), isNull);

      final list = MailList.fromJava({
        'group': 'NOT_THEIRS',
        'limit': 200,
        'sorted': true,
        'items': [
          {'uid': 51, 'receivedAt': '2026-10-07T02:00:00Z', 'status': 'WAITING', 'senderDomain': 'gac.com', 'relevance': 'TEAM'},
        ],
      });
      expect(list.items.single.relevance, 'TEAM');
      expect(relevanceText('TEAM'), 'Answered by a colleague');
      expect(relevanceText('CC_ONLY'), 'Copied in');
      expect(LateItem.fromJava({'uid': 1, 'status': 'WAITING'}).relevance, 'MINE');
    });
  });

  group('tab', () {
    late _Api api;
    setUp(() {
      api = _Api();
      final company = rowJson({'received': 10, 'sorting': _sorting});
      when(() => api.responseReport(any())).thenAnswer((_) async => ResponseReport.fromJava({
            'from': '2026-10-05',
            'to': '2026-10-11',
            'company': company,
            'mailboxes': [
              rowJson({'mailboxId': 2, 'address': 'shalini@maleva.com.my', 'owners': ['Shalini'], 'sorting': _sorting}),
            ],
          }));
      when(() => api.responseLate(2, any()))
          .thenAnswer((_) async => LateList.fromJava({'slowest': <Map<String, dynamic>>[], 'waiting': <Map<String, dynamic>>[]}));
      when(() => api.responseMails(2, any(), 'NOT_THEIRS')).thenAnswer((_) async => MailList.fromJava({
            'group': 'NOT_THEIRS',
            'limit': 200,
            'sorted': true,
            'items': [
              {'uid': 51, 'receivedAt': '2026-10-07T02:00:00Z', 'status': 'WAITING', 'senderDomain': 'fujiglobal.co.kr', 'relevance': 'CC_ONLY'},
              {'uid': 52, 'receivedAt': '2026-10-07T03:00:00Z', 'status': 'WAITING', 'senderDomain': 'gac.com', 'relevance': 'TEAM'},
            ],
          }));
    });

    Future<void> pump(WidgetTester tester, Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: MailResponseTab(api: api, speaker: _Quiet(), clock: () => _now)),
      ));
      await tester.pump();
    }

    testWidgets('phone: the card says who the mail was for and the sheet lists the mails that were not theirs',
        (tester) async {
      await pump(tester, const Size(400, 2600));
      expect(find.text('Needed a reply'), findsOneWidget);
      expect(find.text('of 100 customer mails · 9 replied'), findsOneWidget);
      expect(find.textContaining('10 of 100 customer mails needed a reply'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('shalini@maleva.com.my · Customer service'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Not theirs (90)'));
      await tester.pumpAndSettle();
      verify(() => api.responseMails(2, any(), 'NOT_THEIRS')).called(1);
      expect(find.text('Copied in'), findsOneWidget);
      expect(find.text('Answered by a colleague'), findsOneWidget);
      expect(find.text('from fujiglobal.co.kr'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tablet: lays out without overflow', (tester) async {
      await pump(tester, const Size(1100, 2400));
      expect(find.textContaining('10 of 100 customer mails needed a reply'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('team credit and corrections', () {
    test('the credit fields and texts', () {
      final s = Sorting.fromJava({..._sorting, 'marked': 2, 'helped': 5, 'helpedMedianMinutes': 12, 'corrected': 3});
      expect(s.notTheirs, 92);
      expect(helpedText(s), 'Includes 5 mails handled for other mailboxes (median 12 m)');
      expect(helpedText(Sorting.fromJava(_sorting)), isNull);
      expect(sortingText(s), contains('2 marked not needed'));
      final item = LateItem.fromJava({'id': 11, 'uid': 41, 'status': 'REPLIED', 'repliedBy': 'santhia@maleva.com.my',
        'correction': 'MINE', 'relevance': 'MINE', 'handledFor': 'operation@maleva.com.my'});
      expect((item.id, item.repliedBy, item.correction, item.counted, item.handledFor),
          (11, 'santhia@maleva.com.my', 'MINE', true, 'operation@maleva.com.my'));
      expect(relevanceText('MARKED'), 'Marked not needed');
    });

    testWidgets('a mail answered by a colleague names who replied, and Wrong? saves a correction', (tester) async {
      final api = _Api();
      when(() => api.responseReport(any())).thenAnswer((_) async => ResponseReport.fromJava({
            'from': '2026-10-05',
            'to': '2026-10-11',
            'company': rowJson(),
            'mailboxes': [rowJson({'mailboxId': 2, 'address': 'operation@maleva.com.my', 'owners': ['Amirul']})],
          }));
      when(() => api.responseLate(2, any())).thenAnswer((_) async => LateList.fromJava({
            'slowest': [
              {'id': 11, 'uid': 41, 'receivedAt': '2026-10-07T02:00:00Z', 'firstReplyAt': '2026-10-07T02:12:00Z',
                'minutes': 12, 'status': 'REPLIED', 'senderDomain': 'fujiglobal.co.kr', 'relevance': 'MINE',
                'repliedBy': 'santhia@maleva.com.my'},
            ],
            'waiting': <Map<String, dynamic>>[],
          }));
      when(() => api.correctMail(11, 'NOT_MINE')).thenAnswer((_) async {});
      tester.view.physicalSize = const Size(400, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: MailResponseTab(api: api, speaker: _Quiet(), clock: () => _now))));
      await tester.pump();

      await tester.tap(find.text('operation@maleva.com.my · Customer service'));
      await tester.pumpAndSettle();
      expect(find.textContaining('replied by santhia@maleva.com.my'), findsOneWidget);
      await tester.tap(find.text('Wrong?'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('It did not need its reply'));
      await tester.pumpAndSettle();
      verify(() => api.correctMail(11, 'NOT_MINE')).called(1);
      verify(() => api.responseLate(2, any())).called(2);   // the list reloads
      expect(find.text('Correction saved'), findsOneWidget);
    });
  });

  group('leave and workload', () {
    test('the leave line, the load line and the busy reason', () {
      final row = responseRow({
        'reasons': ['HEAVY_LOAD'],
        'workload': {'officeDays': 5, 'leaveDays': ['2026-10-08'], 'perDay': 36, 'previousPerDay': 20, 'teamMedianPerDay': 12},
      });
      expect(leaveText(row.workload), 'On leave 1 day (8 Oct): not counted');
      expect(workloadText(row.workload), '36 mails a day needed a reply · team 12 · before 20');
      expect(reasonTexts(row), ["Busy: 3x the team's mail (36 a day)"]);
      expect(leaveText(responseRow().workload), isNull);
    });

    testWidgets('the card shows leave and load without overflow', (tester) async {
      final api = _Api();
      when(() => api.responseReport(any())).thenAnswer((_) async => ResponseReport.fromJava({
            'from': '2026-10-05',
            'to': '2026-10-11',
            'company': rowJson(),
            'mailboxes': [
              rowJson({
                'mailboxId': 1,
                'address': 'shalini@maleva.com.my',
                'workload': {'officeDays': 5, 'leaveDays': ['2026-10-08', '2026-10-09'], 'perDay': 36, 'teamMedianPerDay': 12},
              }),
            ],
          }));
      tester.view.physicalSize = const Size(360, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: MailResponseTab(api: api, speaker: _Quiet(), clock: () => _now))));
      await tester.pump();
      expect(find.text('On leave 2 days (8 Oct, 9 Oct): not counted'), findsOneWidget);
      expect(find.text('36 mails a day needed a reply · team 12'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
