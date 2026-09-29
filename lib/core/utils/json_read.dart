/// Tolerant readers for JSON from the legacy .NET API, where a number can
/// arrive as an int, a double or a string, and any field can be null.
class JsonRead {
  JsonRead._();

  static int integer(dynamic value, {int fallback = 0}) =>
      intOrNull(value) ?? fallback;

  static int? intOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString().trim());
  }

  static String string(dynamic value) => value?.toString() ?? '';

  /// Null for a missing or blank value, so "no value" has one representation.
  static String? stringOrNull(dynamic value) {
    final text = value?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }

  static bool boolean(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase();
    return text == 'true' || text == '1';
  }

  /// .NET writes a DateTime without an offset ("2026-09-14T10:30:00"), which
  /// Dart reads as local time - the same wall clock the user entered.
  static DateTime? date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());

  static Map<String, dynamic> map(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static List<Map<String, dynamic>> listOfMaps(dynamic value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }
}
