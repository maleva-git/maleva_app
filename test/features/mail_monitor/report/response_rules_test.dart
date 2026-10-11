import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/mailmonitor/response_report_models.dart';
import 'package:maleva/features/mail_monitor/report/response_rules.dart';

import 'response_fixtures.dart';

/// The web's cases (`responseBands.test.ts`), so the app and the web agree (change `mail-response-report-tab`).
void main() {
  test('bands: on target 90+, close 70-89, behind under 70, and no sent folder', () {
    expect(bandOf(responseRow({'withinTargetPct': 95})), Band.onTarget);
    expect(bandOf(responseRow({'withinTargetPct': 78})), Band.close);
    expect(bandOf(responseRow({'withinTargetPct': 40})), Band.behind);
    expect(bandOf(responseRow({'withinTargetPct': null})), Band.none);
    expect(bandOf(responseRow({'sentFolderFound': false})), Band.noSent);
  });

  test('writes minutes and percents the way the page shows them', () {
    expect(minutesText(9), '9 m');
    expect(minutesText(65), '1 h 05 m');
    expect(minutesText(3060), '2 d 3 h');
    expect(minutesText(15.5), '16 m');
    expect(minutesText(null), '—');
    expect(pctText(77.8), '78%');
  });

  test('lists the worst mailbox first', () {
    final rows = [
      responseRow({'mailboxId': 1, 'address': 'a@maleva.com.my', 'withinTargetPct': 95}),
      responseRow({'mailboxId': 2, 'address': 'b@maleva.com.my', 'withinTargetPct': 40}),
      responseRow({'mailboxId': 3, 'address': 'c@maleva.com.my', 'sentFolderFound': false}),
      responseRow({'mailboxId': 4, 'address': 'd@maleva.com.my', 'withinTargetPct': 78}),
    ];
    expect(worstFirst(rows).map((r) => r.mailboxId), [2, 4, 1, 3]);
  });

  test('fastest first puts the best on top and mailboxes without numbers last', () {
    final rows = [
      responseRow({'mailboxId': 1, 'withinTargetPct': 80, 'avgMinutes': 20}),
      responseRow({'mailboxId': 2, 'sentFolderFound': false}),
      responseRow({'mailboxId': 3, 'withinTargetPct': 95, 'avgMinutes': 12}),
      responseRow({'mailboxId': 4, 'withinTargetPct': 95, 'avgMinutes': 7}),
    ];
    expect(ranked(rows, fastest: true).map((r) => r.mailboxId), [4, 3, 1, 2]);
  });

  test('the banner names the fastest and the one that needs attention', () {
    final rows = [
      responseRow({'mailboxId': 1, 'owners': ['Aina'], 'withinTargetPct': 96, 'avgMinutes': 6}),
      responseRow({'mailboxId': 2, 'owners': ['Badrul'], 'withinTargetPct': 42, 'waiting': 3}),
      responseRow({'mailboxId': 3, 'owners': <String>[], 'withinTargetPct': 42, 'waiting': 0}),
      responseRow({'mailboxId': 4, 'sentFolderFound': false}),
      responseRow({'mailboxId': 5, 'received': 0, 'withinTargetPct': null}),
    ];
    final s = spotlight(rows);
    expect(s.best?.mailboxId, 1);
    expect(s.worst?.mailboxId, 2);
    expect((s.onTarget, s.counted), (1, 3));
    expect(ownerText(rows[2]), 'No employee linked');
  });

  test('nobody needs attention when every mailbox is on target', () {
    final s = spotlight([
      responseRow({'mailboxId': 1, 'withinTargetPct': 100}),
      responseRow({'mailboxId': 2, 'withinTargetPct': 92}),
    ]);
    expect(s.best?.mailboxId, 1);
    expect(s.worst, isNull);
  });

  test('writes the date range with its length', () {
    expect(rangeText(const ReportRange('2026-10-01', '2026-10-07')), '1 Oct 2026 – 7 Oct 2026 · 7 days');
    expect(rangeText(const ReportRange('2026-10-07', '2026-10-07')), '7 Oct 2026 · 1 day');
  });

  test('ranges are Malaysia days', () {
    final now = DateTime.utc(2026, 10, 6, 17); // 01:00 on 7 Oct in Malaysia
    expect(rangeOf(RangePreset.today, now), const ReportRange('2026-10-07', '2026-10-07'));
    expect(rangeOf(RangePreset.last7, now), const ReportRange('2026-10-01', '2026-10-07'));
    expect(rangeOf(RangePreset.month, now), const ReportRange('2026-10-01', '2026-10-07'));
  });

  test('reads the Java row as sent: nulls stay null, owners kept', () {
    final r = responseRow({'withinTargetPct': null, 'avgMinutes': null, 'owners': ['Aina', null, '']});
    expect(r.withinTargetPct, isNull);
    expect(r.numbers.avgMinutes, isNull);
    expect(r.owners, ['Aina']);
    expect(r.numbers.daily.single.withinTarget, 8);
  });

  test('the AI text becomes points without bullets', () {
    const s = ResponseSummary(text: '- First point\n\n* Second point\n• Third', generatedAt: null);
    expect(s.points, ['First point', 'Second point', 'Third']);
  });
}
