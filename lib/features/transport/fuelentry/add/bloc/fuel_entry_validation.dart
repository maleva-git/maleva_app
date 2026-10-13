/// The driver fuel form's Liter and Amount checks, shared by the form and the bloc.
abstract final class FuelEntryValidation {
  /// The value as a number; a comma decimal (`12,5`) reads as a point.
  static double? parse(String value) => double.tryParse(value.trim().replaceAll(',', '.'));

  /// Null when [value] is a number over 0, else the message to show for [label].
  static String? check(String label, String value) {
    if (value.trim().isEmpty) return 'Enter $label';
    final n = parse(value);
    if (n == null || !n.isFinite) return '$label must be a number';
    if (n <= 0) return '$label must be more than 0';
    return null;
  }

  /// The first problem with the form's Liter and Amount, or null when both are valid.
  static String? form({required String liter, required String amount}) =>
      check('Liter', liter) ?? check('Amount', amount);
}
