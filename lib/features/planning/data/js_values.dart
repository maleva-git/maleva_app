/// The web's value rules, so ports of its mappers read a JSON value the same way:
/// JavaScript truthiness (`a || b`), nullish fall-back (`a ?? b`), `Number(v)` and `String(v)`.
abstract final class Js {
  /// JavaScript truthiness of a JSON value: null, false, 0, NaN and '' are false.
  static bool truthy(dynamic v) {
    if (v == null || v == false) return false;
    if (v is num) return v != 0 && !v.isNaN;
    if (v is String) return v.isNotEmpty;
    return true;
  }

  /// `m[k1] || m[k2] || ...`; null when none is truthy.
  static dynamic or(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      if (truthy(m[k])) return m[k];
    }
    return null;
  }

  /// `m[k1] ?? m[k2] ?? ...`; null when every one is null.
  static dynamic nn(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      if (m[k] != null) return m[k];
    }
    return null;
  }

  /// `String(v ?? '')`, with whole doubles written as JavaScript writes them (1.0 → "1").
  static String text(dynamic v) {
    if (v == null) return '';
    if (v is double && v == v.truncateToDouble() && v.isFinite) return v.toInt().toString();
    return v.toString();
  }

  /// `Number(v)`: NaN for anything that is not a number.
  static double number(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    if (v is bool) return v ? 1 : 0;
    final s = v.toString().trim();
    if (s.isEmpty) return 0;
    return double.tryParse(s) ?? double.nan;
  }

  /// `Number(v) || 0` as an int.
  static int intOr0(dynamic v) {
    final n = number(v);
    return n.isNaN ? 0 : n.toInt();
  }

  /// The web's `toPositiveInt`: a whole number above 0, else 0.
  static int positiveInt(dynamic v) {
    final n = number(v);
    if (n.isNaN || n <= 0 || n != n.truncateToDouble()) return 0;
    return n.toInt();
  }

  /// The first value (in order) that is a whole number above 0, else 0.
  static int firstPositive(List<dynamic> values) {
    for (final v in values) {
      final p = positiveInt(v);
      if (p > 0) return p;
    }
    return 0;
  }

  /// The first value whose trimmed text is not empty, trimmed; '' when none.
  static String firstText(List<dynamic> values) {
    for (final v in values) {
      if (v == null) continue;
      final t = text(v).trim();
      if (t.isNotEmpty) return t;
    }
    return '';
  }
}

/// The web's `error.message || fallback`: the failure's own words, or [fallback] when it has none.
String errorText(Object e, String fallback) {
  if (e is StateError) return e.message;
  var text = e.toString().trim();
  if (text.startsWith('Exception: ')) text = text.substring('Exception: '.length).trim();
  if (text.isEmpty || text == 'Exception' || text.startsWith('Instance of')) return fallback;
  return text;
}
