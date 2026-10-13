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

/// The server's fair judgement on the app (change mail-report-office-hours-fair-ranking).
Map<String, dynamic> judgedJson() => {
      ...reportJson([
        rowJson({
          'mailboxId': 1, 'address': 'transport@maleva.com.my', 'owners': ['Aina'], 'received': 300,
          'withinTargetPct': 96, 'category': 'ON_TRACK', 'reasons': <String>[], 'afterHoursReceived': 30,
          'afterHoursAnsweredBeforeOpen': 9, 'withinTargetLow': 93.1,
        }),
        rowJson({
          'mailboxId': 2, 'address': 'cs1@maleva.com.my', 'owners': ['Badrul'], 'received': 120,
          'withinTargetPct': 41.7, 'category': 'NEEDS_SUPPORT', 'reasons': ['LOW_WITHIN_TARGET', 'MANY_WAITING'],
          'waitingOverDay': 12,
        }),
        rowJson({
          'mailboxId': 3, 'address': 'eswaran@maleva.com.my', 'owners': ['Mages'], 'received': 544,
          'withinTargetPct': 0, 'category': 'NOT_ENOUGH_DATA', 'reasons': ['SCAN_FAILED'],
        }),
      ]),
      'company': rowJson({'afterHoursReceived': 38, 'afterHoursAnsweredBeforeOpen': 12, 'waitingOverDay': 2}),
      'clock': 'OFFICE',
      'office': {
        'open': '08:30', 'close': '20:00', 'days': ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'],
        'zone': 'Asia/Kuala_Lumpur', 'holidays': ['2026-10-06'],
      },
      'fastestMailboxId': 1,
      'attentionMailboxId': 2,
      'onTarget': 1,
      'counted': 2,
    };

void main() {
  setUpAll(() async {
    await installLocalTestFonts();
    registerFallbackValue(const ReportRange('a', 'b'));
  });

  test('reads the judgement and the office hours as the server sends them', () {
    final r = ResponseReport.fromJava(judgedJson());
    expect(r.officeClock, isTrue);
    expect(r.judged, isTrue);
    expect(r.office!.holidays, ['2026-10-06']);
    expect(r.mailboxes[1].category, Category.needsSupport);
    expect(r.company.afterHoursReceived, 38);
    expect(officeText(r.office!), 'Office hours Mon–Sat 8:30 am – 8:00 pm (Malaysia), public holidays closed');
    expect(reasonTexts(r.mailboxes[1]), ['Under 70% within target', '12 waiting over one office day']);
    expect(reasonTexts(r.mailboxes[2]), ['Last scan failed']);
    expect(worstFirst(r.mailboxes).map((m) => m.mailboxId), [2, 1, 3]);
    expect(spotlightOf(r).worst!.mailboxId, 2);
    expect(spotlightOf(r).best!.mailboxId, 1);
  });

  test('an older server: no category, the bands as before', () {
    final r = ResponseReport.fromJava(reportJson([rowJson({'withinTargetPct': 40})]));
    expect(r.judged, isFalse);
    expect(statusOf(r.mailboxes.single).$1, 'Behind');
  });

  test('the AI points are read with their category and check', () {
    final s = ResponseSummary.fromJava({
      'text': '- x',
      'points': [
        {'mailboxId': 2, 'mailbox': 'cs1@maleva.com.my', 'category': 'NEEDS_SUPPORT', 'text': '42% within 15 min.',
          'suggestion': 'Share the oldest mails.', 'checked': true},
        {'mailboxId': null, 'mailbox': null, 'category': 'COMPANY', 'text': 'Company: 70%', 'suggestion': null, 'checked': false},
      ],
    });
    expect(s.items.first.category, Category.needsSupport);
    expect(s.items.last.category, isNull);
    expect(s.points, ['42% within 15 min. Share the oldest mails.', 'Company: 70%']);
  });

  testWidgets('the tab shows office hours, categories with reasons, after-office mail and the server spotlight',
      (tester) async {
    final api = _Api();
    when(() => api.responseReport(any())).thenAnswer((_) async => ResponseReport.fromJava(judgedJson()));
    tester.view.physicalSize = const Size(400, 3400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: MailResponseTab(api: api, speaker: _Quiet(), clock: () => DateTime.utc(2026, 10, 11, 1, 30))),
    ));
    await tester.pump();

    expect(find.textContaining('Office hours Mon–Sat 8:30 am – 8:00 pm'), findsOneWidget);
    expect(find.textContaining('Holidays in these dates: 2026-10-06'), findsOneWidget);
    expect(find.text('Arrived after office hours'), findsOneWidget);
    expect(find.text('12 answered before 8:30 am'), findsOneWidget);
    expect(find.text('Under 70% within target · 12 waiting over one office day'), findsOneWidget);
    expect(find.text('Last scan failed'), findsOneWidget);
    expect(find.text('Not enough data'), findsOneWidget);
    expect(find.text('1 of 2 mailboxes with enough data on track'), findsOneWidget);
    expect(find.textContaining('decided by fixed rules'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an AI point opens its mailbox', (tester) async {
    final api = _Api();
    when(() => api.responseReport(any())).thenAnswer((_) async => ResponseReport.fromJava(judgedJson()));
    when(() => api.responseSummary(any(), language: any(named: 'language'))).thenAnswer((_) async =>
        ResponseSummary.fromJava({
          'text': '- x',
          'points': [
            {'mailboxId': 2, 'mailbox': 'cs1@maleva.com.my', 'category': 'NEEDS_SUPPORT', 'text': '42% within 15 min.',
              'suggestion': 'Share the oldest mails.', 'checked': true},
          ],
        }));
    when(() => api.responseLate(2, any()))
        .thenAnswer((_) async => LateList.fromJava({'slowest': <Map<String, dynamic>>[], 'waiting': <Map<String, dynamic>>[]}));
    tester.view.physicalSize = const Size(400, 3400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: MailResponseTab(api: api, speaker: _Quiet(), clock: () => DateTime.utc(2026, 10, 11, 1, 30))),
    ));
    await tester.pump();
    await tester.tap(find.text('Write summary'));
    await tester.pump();

    expect(find.text('→ Share the oldest mails.'), findsOneWidget);
    await tester.tap(find.text('cs1@maleva.com.my').first);
    await tester.pumpAndSettle();
    verify(() => api.responseLate(2, any())).called(1);
  });
}
