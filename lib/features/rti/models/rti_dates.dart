import 'package:intl/intl.dart';
import 'package:maleva/features/rti/models/js_values.dart';

/// The RTI page's date handling (`R/services/rtiService.ts:57-121`, `R/utils/rtiFormatting.ts`).
abstract final class RtiDates {
  static const _months = {'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6, 'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12};

  /// `parseDateTime`: an ISO date / date-time (local), `yyyy/MM/dd`, `dd/MM/yyyy` or
  /// `dd MMM yy[yy]`; null otherwise.
  ///
  /// The web first tries the browser's `new Date(text)`, which reads `02/10/2026` the US
  /// way (month first). The app reads it day first, as the fallback rule intends; the Java
  /// API answers ISO dates, so the two only differ for a typed `dd/MM/yyyy`.
  static DateTime? parse(dynamic value) {
    final text = Js.text([value]);
    if (text.isEmpty) return null;
    final iso = DateTime.tryParse(text);
    if (iso != null) return iso.isUtc ? iso.toLocal() : iso;
    var m = RegExp(r'^(\d{4})[/-](\d{2})[/-](\d{2})$').firstMatch(text);
    if (m != null) return DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
    m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(text);
    if (m != null) return DateTime(int.parse(m[3]!), int.parse(m[2]!), int.parse(m[1]!));
    m = RegExp(r'^(\d{2})\s([A-Za-z]{3})\s(\d{2}|\d{4})$').firstMatch(text);
    if (m != null) {
      final month = _months[m[2]!.toLowerCase()];
      if (month == null) return null;
      final y = m[3]!.length == 2 ? 2000 + int.parse(m[3]!) : int.parse(m[3]!);
      return DateTime(y, month, int.parse(m[1]!));
    }
    return null;
  }

  /// `toApiDateTime`: the day at `T00:00:00` (so the server's BETWEEN queries match), or null.
  static String? apiDateTime(dynamic value) {
    final d = parse(value);
    return d == null ? null : '${DateFormat('yyyy-MM-dd').format(d)}T00:00:00';
  }

  /// `toDateInputValue`: `yyyy-MM-dd`, or ''.
  static String dateInput(dynamic value) {
    if (value is DateTime) return DateFormat('yyyy-MM-dd').format(value);
    final text = Js.text([value]);
    final m = RegExp(r'^(\d{4}-\d{2}-\d{2})').firstMatch(text);
    if (m != null) return m[1]!;
    final d = parse(text);
    return d == null ? '' : DateFormat('yyyy-MM-dd').format(d);
  }

  /// Today as the RTI form's date (`yyyy-MM-dd`).
  static String today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// `formatShortDate`: `dd/MM/yyyy`, or '-'.
  static String short(dynamic value) {
    final d = parse(value);
    return d == null ? '-' : DateFormat('dd/MM/yyyy').format(d);
  }
}
