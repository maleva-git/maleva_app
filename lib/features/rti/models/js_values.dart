import 'package:maleva/core/utils/json_read.dart';

/// The web RTI code's value readers (`R/services/rtiService.ts:28-55`), so the app reads
/// and writes the same values React does. Field names are matched without case, because
/// Jackson writes some Lombok names either way (`cnumberDisplay` / `CNumberDisplay`).
abstract final class Js {
  /// JavaScript's `String(n)` for a number: `120` not `120.0`.
  static String str(dynamic v) {
    if (v == null) return '';
    if (v is num) {
      if (v is double && v.isFinite && v == v.truncateToDouble() && v.abs() < 1e15) return v.toInt().toString();
      return v.toString();
    }
    return v.toString();
  }

  /// `getText`: the first value whose text is not blank, trimmed; '' when none.
  static String text(Iterable<dynamic> values) {
    for (final v in values) {
      if (v == null) continue;
      final t = str(v).trim();
      if (t.isNotEmpty) return t;
    }
    return '';
  }

  /// `getNumber`: the first value that reads as a finite number; 0 when none.
  /// (`Number('')` is 0 in JavaScript, so a blank text reads as 0.)
  static num number(Iterable<dynamic> values) {
    for (final v in values) {
      final n = toNumber(v);
      if (n != null) return n;
    }
    return 0;
  }

  /// JavaScript's `Number(v)` for the values RTI uses; null for NaN (and for null, which
  /// the app treats as "absent").
  static num? toNumber(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.isFinite ? v : null;
    if (v is bool) return v ? 1 : 0;
    final t = v.toString().trim();
    if (t.isEmpty) return 0;
    final n = num.tryParse(t);
    return (n != null && n.isFinite) ? n : null;
  }

  /// JavaScript's `parseFloat`: the leading number of the text; null for NaN.
  static double? parseFloat(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    final m = RegExp(r'^\s*[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?').firstMatch(v.toString());
    return m == null ? null : double.tryParse(m.group(0)!.trim());
  }

  /// `getBoolean`.
  static bool boolean(dynamic v) {
    if (v is bool) return v;
    final n = toNumber(v);
    if (n != null && v is! String) return n > 0;
    if (v is String && num.tryParse(v.trim()) != null) return num.parse(v.trim()) > 0;
    final t = text([v]).toLowerCase();
    return t == 'true' || t == 'yes';
  }

  /// A field of a Java row, by any of [keys] (each matched without case); null when none.
  static dynamic field(Map<String, dynamic>? m, List<String> keys) {
    if (m == null) return null;
    for (final k in keys) {
      final v = JsonRead.field(m, k);
      if (v != null) return v;
    }
    return null;
  }

  /// `getText` over fields of a row.
  static String fieldText(Map<String, dynamic>? m, List<String> keys) =>
      m == null ? '' : text([for (final k in keys) JsonRead.field(m, k)]);

  /// `getNumber` over fields of a row.
  static num fieldNumber(Map<String, dynamic>? m, List<String> keys) =>
      m == null ? 0 : number([for (final k in keys) JsonRead.field(m, k)]);

  /// `toPositiveNumber` of the planning services: the first value that is a positive integer.
  static int positiveInt(Iterable<dynamic> values) {
    for (final v in values) {
      final n = toNumber(v);
      if (n != null && n == n.truncate() && n > 0) return n.toInt();
    }
    return 0;
  }
}
