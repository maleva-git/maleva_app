import 'package:intl/intl.dart';

/// Number and date formats shared by the Planning and RTI screens.
abstract final class Fmt {
  static final NumberFormat _money = NumberFormat('#,##0.00', 'en_US');

  /// "RM 1,245.00", as the web shows amounts.
  static String rm(num? v) => 'RM ${_money.format(v ?? 0)}';

  /// The web's `formatPlanningDateTime`: `yyyy-MM-dd HH:mm[:ss]` or the `T` form → `dd/MM/yyyy HH:mm`;
  /// a date alone → `dd/MM/yyyy`; empty → ''; anything else is shown as it is.
  static String planningDateTime(String? raw) {
    final s = (raw ?? '').trim();
    if (s.isEmpty) return '';
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})(?:[T ](\d{2}):(\d{2})(?::\d{2}(?:\.\d+)?)?)?$').firstMatch(s);
    if (m == null) return s;
    final d = '${m[3]}/${m[2]}/${m[1]}';
    return m[4] == null ? d : '$d ${m[4]}:${m[5]}';
  }

  static String ddMMyyyy(DateTime? d) => d == null ? '' : DateFormat('dd/MM/yyyy').format(d);
  static String ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  static String ymdSlash(DateTime d) => DateFormat('yyyy/MM/dd').format(d);
  static String dMonY(DateTime? d) => d == null ? '' : DateFormat('dd MMM yyyy').format(d);

  /// Today at midnight, local time (the web uses UTC by mistake; the app uses the device's day).
  static DateTime today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }
}
