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

int _byAddress(ResponseRow a, ResponseRow b) => a.address.compareTo(b.address);

/// Lowest share within target first; mailboxes without numbers last.
List<ResponseRow> worstFirst(List<ResponseRow> rows) => [...rows]..sort((a, b) {
    final r = _rank[bandOf(a)]!.compareTo(_rank[bandOf(b)]!);
    if (r != 0) return r;
    final p = (a.withinTargetPct ?? 101).compareTo(b.withinTargetPct ?? 101);
    if (p != 0) return p;
    final n = b.numbers.received.compareTo(a.numbers.received);
    return n != 0 ? n : _byAddress(a, b);
  });

bool _counted(ResponseRow r) => r.sentFolderFound && r.withinTargetPct != null;

/// Slowest first, or fastest first when [fastest]; rows without numbers stay last.
List<ResponseRow> ranked(List<ResponseRow> rows, {required bool fastest}) {
  if (!fastest) return worstFirst(rows);
  return [...rows]..sort((a, b) {
      final c = (_counted(b) ? 1 : 0).compareTo(_counted(a) ? 1 : 0);
      if (c != 0) return c;
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
