import 'package:intl/intl.dart';
import 'package:maleva/core/mailmonitor/response_report_models.dart';
import 'package:maleva/core/theme/status_tone.dart';

/// The web's report rules (`maleva-front-end/src/features/mail-monitor/report/model/responseBands.ts`),
/// ported one-to-one so the app and the web agree (change `mail-response-report-tab`).

enum Band { onTarget, close, behind, none, noSent }

/// On target (90% or more within the target), close (70-89%), behind (under 70%).
Band bandOf(ResponseRow row) {
  if (!row.sentFolderFound) return Band.noSent;
  final pct = row.withinTargetPct;
  if (pct == null) return Band.none;
  if (pct >= 90) return Band.onTarget;
  if (pct >= 70) return Band.close;
  return Band.behind;
}

String bandLabel(Band b) => switch (b) {
      Band.onTarget => 'On target',
      Band.close => 'Close',
      Band.behind => 'Behind',
      Band.none => 'No mail',
      Band.noSent => 'No sent mail found',
    };

StatusTone bandTone(Band b) => switch (b) {
      Band.onTarget => StatusTone.success,
      Band.close => StatusTone.warning,
      Band.behind => StatusTone.danger,
      Band.none || Band.noSent => StatusTone.neutral,
    };

/// "9 m", "1 h 05 m", "2 d 3 h"; "—" when unknown. Fractions are rounded.
String minutesText(num? m) {
  if (m == null) return '—';
  final v = m.round();
  if (v < 60) return '$v m';
  if (v < 24 * 60) return '${v ~/ 60} h ${(v % 60).toString().padLeft(2, '0')} m';
  return '${v ~/ (24 * 60)} d ${(v ~/ 60) % 24} h';
}

String pctText(num? p) => p == null ? '—' : '${p.round()}%';

const _rank = {Band.behind: 0, Band.close: 1, Band.onTarget: 2, Band.noSent: 3, Band.none: 4};

// ── The server's fair judgement (backend change mail-report-office-hours-fair-ranking) ──

String categoryLabel(Category c) => switch (c) {
      Category.onTrack => 'On track',
      Category.watch => 'Watch',
      Category.needsSupport => 'Needs support',
      Category.notEnoughData => 'Not enough data',
    };

StatusTone categoryTone(Category c) => switch (c) {
      Category.onTrack => StatusTone.success,
      Category.watch => StatusTone.warning,
      Category.needsSupport => StatusTone.danger,
      Category.notEnoughData => StatusTone.neutral,
    };

const _categoryRank = {Category.needsSupport: 0, Category.watch: 1, Category.onTrack: 2, Category.notEnoughData: 3};

/// The pill of a row: the server's category when it judged the row, else the band.
(String, StatusTone) statusOf(ResponseRow r) => r.category != null
    ? (categoryLabel(r.category!), categoryTone(r.category!))
    : (bandLabel(bandOf(r)), bandTone(bandOf(r)));

/// The reason codes as short sentences, in the server's order; unknown codes are left out.
List<String> reasonTexts(ResponseRow r) {
  final overDay = r.numbers.waitingOverDay ?? 0;
  final before = (r.previousWithinTargetPct ?? 0).round();
  return [
    for (final code in r.reasons)
      if (switch (code) {
        'SCAN_FAILED' => 'Last scan failed',
        'SCAN_STALE' => 'Not scanned in the last hour',
        'NO_SENT_FOLDER' => 'No Sent folder found',
        'TOO_FEW_MAILS' => 'Only ${r.numbers.received} customer ${r.numbers.received == 1 ? 'mail' : 'mails'}',
        'LOW_WITHIN_TARGET' => 'Under 70% within target',
        'MANY_WAITING' || 'SOME_WAITING' => '$overDay waiting over one office day',
        'CLOSE_TO_TARGET' => '70–89% within target',
        'WORSE_THAN_BEFORE' => 'Worse than the period before ($before%)',
        'IMPROVED' => 'Better than the period before ($before%)',
        'READS_RARELY' => 'Mail read on only ${r.reading?.readDays ?? 0} of ${r.reading?.officeDays ?? 0} office days',
        'OLD_UNREAD' => 'Oldest unread mail is ${r.reading?.oldestUnreadOfficeDays ?? 0} office days old',
        'HEAVY_LOAD' => _busy(r.workload),
        _ => null,
      }
          case final String text)
        text,
  ];
}

/// "Read on 4 of 6 office days · 12 unread · oldest 2 office days", or null when the server sent no reading
/// (change mail-reading-and-booking-speed).
String? readingText(ResponseRow row) {
  final r = row.reading;
  if (r == null || r.officeDays == 0) return null;
  String days(int n) => n == 1 ? 'day' : 'days';
  final oldest = r.oldestUnreadOfficeDays;
  return [
    'Read on ${r.readDays} of ${r.officeDays} office ${days(r.officeDays)}',
    '${r.unreadNow} unread',
    if (oldest != null && oldest > 0) 'oldest $oldest office ${days(oldest)}',
  ].join(' · ');
}

/// Who a listed mail was for, in words (change mail-count-own-mail).
String relevanceText(String code) => switch (code) {
      'CC_ONLY' => 'Copied in',
      'OTHER_NAME' => 'Written to a colleague',
      'TEAM' => 'Answered by a colleague',
      'MARKED' => 'Marked not needed',
      _ => 'Needed a reply',
    };

/// "10 of 100 customer mails needed a reply · 90 did not (60 copied in, 20 to a colleague, 10 answered by a colleague)",
/// or null when the server has not sorted the mail yet.
String? sortingText(Sorting? s) {
  if (s == null || !s.sorted || s.customerMails == 0) return null;
  final head = '${s.needReply} of ${s.customerMails} customer ${s.customerMails == 1 ? 'mail' : 'mails'} needed a reply';
  if (s.notTheirs == 0) return head;
  final parts = [
    if (s.ccOnly > 0) '${s.ccOnly} copied in',
    if (s.otherName > 0) '${s.otherName} to a colleague',
    if (s.team > 0) '${s.team} answered by a colleague',
    if (s.marked > 0) '${s.marked} marked not needed',
  ];
  return '$head · ${s.notTheirs} did not (${parts.join(', ')})';
}

/// "Includes 5 mails handled for other mailboxes (median 12 m)", or null when it handled none.
String? helpedText(Sorting? s) {
  if (s == null || s.helped == 0) return null;
  final median = s.helpedMedianMinutes == null ? '' : ' (median ${minutesText(s.helpedMedianMinutes)})';
  return 'Includes ${s.helped} ${s.helped == 1 ? 'mail' : 'mails'} handled for other mailboxes$median';
}

String _busy(Workload? w) {
  final perDay = w?.perDay;
  final median = w?.teamMedianPerDay;
  if (perDay == null || median == null || median <= 0) return 'Busy: much more mail than the team';
  return "Busy: ${(perDay / median).round()}x the team's mail (${perDay.round()} a day)";
}

String _n(double v) {
  final r = (v * 10).round() / 10;
  return r == r.roundToDouble() ? r.toStringAsFixed(0) : r.toString();
}

/// "On leave 2 days (8 Oct, 9 Oct): not counted", or null without leave (change mail-leave-and-workload).
String? leaveText(Workload? w) {
  final days = w?.leaveDays ?? const <String>[];
  if (days.isEmpty) return null;
  final f = DateFormat('d MMM');
  final list = days.take(5).map((d) => f.format(DateTime.parse(d))).join(', ');
  return 'On leave ${days.length} ${days.length == 1 ? 'day' : 'days'} ($list${days.length > 5 ? ', ...' : ''}): not counted';
}

/// "36 mails a day needed a reply · team 12 · before 20", or null without a load.
String? workloadText(Workload? w) {
  final perDay = w?.perDay;
  if (w == null || perDay == null) return null;
  return [
    '${_n(perDay)} ${perDay == 1 ? 'mail' : 'mails'} a day needed a reply',
    if (w.teamMedianPerDay != null) 'team ${_n(w.teamMedianPerDay!)}',
    if (w.previousPerDay != null) 'before ${_n(w.previousPerDay!)}',
  ].join(' · ');
}

/// "8:30 am" from "08:30".
String clockText(String hhmm) {
  final parts = hhmm.split(':');
  final h = int.tryParse(parts.first) ?? 0;
  final m = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
  return '${h % 12 == 0 ? 12 : h % 12}:$m ${h < 12 ? 'am' : 'pm'}';
}

const _dayNames = {'MON': 'Mon', 'TUE': 'Tue', 'WED': 'Wed', 'THU': 'Thu', 'FRI': 'Fri', 'SAT': 'Sat', 'SUN': 'Sun'};

/// "Office hours Mon–Sat 8:30 am – 8:00 pm (Malaysia), public holidays closed".
String officeText(OfficeHours o) {
  final order = _dayNames.keys.toList();
  final idx = [for (final d in o.days) order.indexOf(d)]..removeWhere((i) => i < 0);
  idx.sort();
  final consecutive = idx.length > 2 && [for (var i = 1; i < idx.length; i++) idx[i] == idx[i - 1] + 1].every((x) => x);
  final days = idx.isEmpty
      ? ''
      : consecutive
          ? '${_dayNames[order[idx.first]]}–${_dayNames[order[idx.last]]}'
          : idx.map((i) => _dayNames[order[i]]).join(', ');
  return 'Office hours $days ${clockText(o.open)} – ${clockText(o.close)} (Malaysia), public holidays closed';
}

/// The server's spotlight when it judged the report, else the page's own (older server).
Spotlight spotlightOf(ResponseReport report) {
  if (!report.judged) return spotlight(report.mailboxes);
  ResponseRow? byId(int? id) => id == null ? null : report.mailboxes.where((r) => r.mailboxId == id).firstOrNull;
  return Spotlight(
    best: byId(report.fastestMailboxId),
    worst: byId(report.attentionMailboxId),
    onTarget: report.onTarget,
    counted: report.counted,
  );
}

int _rankOf(ResponseRow r) => r.category != null ? _categoryRank[r.category!]! : _rank[bandOf(r)]!;

int _byAddress(ResponseRow a, ResponseRow b) => a.address.compareTo(b.address);

/// Lowest share within target first; mailboxes without numbers last.
List<ResponseRow> worstFirst(List<ResponseRow> rows) => [...rows]..sort((a, b) {
    final r = _rankOf(a).compareTo(_rankOf(b));
    if (r != 0) return r;
    final p = (a.withinTargetPct ?? 101).compareTo(b.withinTargetPct ?? 101);
    if (p != 0) return p;
    final n = b.numbers.received.compareTo(a.numbers.received);
    return n != 0 ? n : _byAddress(a, b);
  });

bool _counted(ResponseRow r) =>
    r.category != null ? r.category != Category.notEnoughData : r.sentFolderFound && r.withinTargetPct != null;

/// Slowest first, or fastest first when [fastest]; rows without numbers stay last.
List<ResponseRow> ranked(List<ResponseRow> rows, {required bool fastest}) {
  if (!fastest) return worstFirst(rows);
  return [...rows]..sort((a, b) {
      final c = (_counted(b) ? 1 : 0).compareTo(_counted(a) ? 1 : 0);
      if (c != 0) return c;
      final low = (b.withinTargetLow ?? -1).compareTo(a.withinTargetLow ?? -1);
      if (low != 0) return low;
      final p = (b.withinTargetPct ?? -1).compareTo(a.withinTargetPct ?? -1);
      if (p != 0) return p;
      final avg = (a.numbers.avgMinutes ?? double.infinity).compareTo(b.numbers.avgMinutes ?? double.infinity);
      return avg != 0 ? avg : _byAddress(a, b);
    });
}

/// Who answers for the mailbox: its owners' names, or a hint to link one.
String ownerText(ResponseRow row) => row.owners.isEmpty ? 'No employee linked' : row.owners.join(', ');

class Spotlight {
  const Spotlight({required this.best, required this.worst, required this.onTarget, required this.counted});

  final ResponseRow? best;

  /// Null when nobody is below target, or the only counted mailbox is also the best.
  final ResponseRow? worst;
  final int onTarget;
  final int counted;
}

/// The fastest and the slowest mailbox among those with customer mail and a Sent folder.
Spotlight spotlight(List<ResponseRow> rows) {
  final counted = rows.where((r) => _counted(r) && r.numbers.received > 0).toList();
  final best = ranked(counted, fastest: true).firstOrNull;
  final worst = ([...counted]..sort((a, b) {
          final p = (a.withinTargetPct ?? 0).compareTo(b.withinTargetPct ?? 0);
          if (p != 0) return p;
          final w = b.numbers.waiting.compareTo(a.numbers.waiting);
          return w != 0 ? w : (b.numbers.avgMinutes ?? 0).compareTo(a.numbers.avgMinutes ?? 0);
        }))
      .firstOrNull;
  return Spotlight(
    best: best,
    worst: worst != null && worst != best && bandOf(worst) != Band.onTarget ? worst : null,
    onTarget: counted.where((r) => bandOf(r) == Band.onTarget).length,
    counted: counted.length,
  );
}

enum RangePreset { today, last7, month }

String presetLabel(RangePreset p) => switch (p) {
      RangePreset.today => 'Today',
      RangePreset.last7 => 'Last 7 days',
      RangePreset.month => 'This month',
    };

final _ymd = DateFormat('yyyy-MM-dd');

/// The Malaysia (UTC+8) calendar day of [now].
DateTime malaysiaDay(DateTime now) {
  final local = now.toUtc().add(const Duration(hours: 8));
  return DateTime(local.year, local.month, local.day);
}

ReportRange rangeOf(RangePreset preset, DateTime now) {
  final today = malaysiaDay(now);
  return switch (preset) {
    RangePreset.today => ReportRange(_ymd.format(today), _ymd.format(today)),
    RangePreset.last7 => ReportRange(_ymd.format(DateTime(today.year, today.month, today.day - 6)), _ymd.format(today)),
    RangePreset.month => ReportRange(_ymd.format(DateTime(today.year, today.month, 1)), _ymd.format(today)),
  };
}

ReportRange rangeFromDates(DateTime from, DateTime to) => ReportRange(_ymd.format(from), _ymd.format(to));

/// "1 Oct 2026 – 7 Oct 2026 · 7 days".
String rangeText(ReportRange range) {
  final a = DateTime.parse(range.from);
  final b = DateTime.parse(range.to);
  final f = DateFormat('d MMM yyyy');
  final days = DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays + 1;
  final dates = range.from == range.to ? f.format(a) : '${f.format(a)} – ${f.format(b)}';
  return '$dates · $days ${days == 1 ? 'day' : 'days'}';
}
