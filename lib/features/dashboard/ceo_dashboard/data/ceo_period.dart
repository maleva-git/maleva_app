import 'package:maleva/core/widgets/ui/formats.dart';

/// The header's period switch. The server compares each with the same number of days just before it.
enum CeoPeriod {
  thisMonth('This month'),
  lastMonth('Last month'),
  thisQuarter('This quarter'),
  thisYear('This year');

  const CeoPeriod(this.label);

  final String label;

  /// `(fromDate, toDate)` as `yyyy-MM-dd`, for [today] (the device's day).
  (String, String) range(DateTime today) {
    final d = DateTime(today.year, today.month, today.day);
    final (from, to) = switch (this) {
      CeoPeriod.thisMonth => (DateTime(d.year, d.month, 1), d),
      // day 0 of this month is the last day of the previous one
      CeoPeriod.lastMonth => (DateTime(d.year, d.month - 1, 1), DateTime(d.year, d.month, 0)),
      CeoPeriod.thisQuarter => (DateTime(d.year, ((d.month - 1) ~/ 3) * 3 + 1, 1), d),
      CeoPeriod.thisYear => (DateTime(d.year, 1, 1), d),
    };
    return (Fmt.ymd(from), Fmt.ymd(to));
  }
}

/// One of the Sale orders cards (web `model/salePeriods.ts`, the Super Admin Sale Order tiles' days).
class CeoSalePeriod {
  const CeoSalePeriod(this.key, this.label, this.range);

  /// `TODAY`, `YESTERDAY`, `WEEK` or `MONTH`.
  final String key;
  final String label;

  /// `(fromDate, toDate)` as `yyyy-MM-dd`.
  final (String, String) range;

  /// Today, yesterday, the week Sunday to Saturday and the calendar month to its last day, for [today]
  /// (the device's day), exactly as the web.
  static List<CeoSalePeriod> of(DateTime today) {
    final d = DateTime(today.year, today.month, today.day);
    // Dart: Monday 1 .. Sunday 7, so weekday % 7 is the days since Sunday (JS getDay())
    final sunday = DateTime(d.year, d.month, d.day - d.weekday % 7);
    final yesterday = DateTime(d.year, d.month, d.day - 1);
    String ymd(DateTime x) => Fmt.ymd(x);
    return [
      CeoSalePeriod('TODAY', 'Today', (ymd(d), ymd(d))),
      CeoSalePeriod('YESTERDAY', 'Yesterday', (ymd(yesterday), ymd(yesterday))),
      CeoSalePeriod('WEEK', 'This week', (ymd(sunday), ymd(DateTime(sunday.year, sunday.month, sunday.day + 6)))),
      // day 0 of next month is the last day of this one
      CeoSalePeriod('MONTH', 'This month', (ymd(DateTime(d.year, d.month, 1)), ymd(DateTime(d.year, d.month + 1, 0)))),
    ];
  }
}

/// `2026-10` -> the whole month `(2026-10-01, 2026-10-31)` (web `monthRange`); null when not `yyyy-MM`.
(String, String)? ceoMonthRange(String month) {
  final m = RegExp(r'^(\d{4})-(\d{1,2})$').firstMatch(month.trim());
  if (m == null) return null;
  final year = int.parse(m.group(1)!);
  final mon = int.parse(m.group(2)!);
  if (mon < 1 || mon > 12) return null;
  return (Fmt.ymd(DateTime(year, mon, 1)), Fmt.ymd(DateTime(year, mon + 1, 0)));
}
