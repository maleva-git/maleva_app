import 'package:flutter/material.dart';
import 'package:maleva/core/widgets/ui/ui.dart';

/// Picks a day with the platform date picker; null when cancelled.
Future<DateTime?> pickPlansDate(BuildContext context, DateTime initial) => showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );

/// A date as a tappable field ("05/10/2026").
class PlansDateField extends StatelessWidget {
  const PlansDateField({super.key, required this.label, required this.value, required this.onChanged, this.errorText});

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) => PickerField(
        label: label,
        value: Fmt.ddMMyyyy(value),
        icon: Icons.calendar_today_outlined,
        errorText: errorText,
        onTap: () async {
          final picked = await pickPlansDate(context, value);
          if (picked != null) onChanged(picked);
        },
      );
}
