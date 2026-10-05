import 'package:flutter/material.dart';
import 'package:maleva/core/widgets/ui/ui.dart';

/// A date as a tappable field ("05/10/2026") that opens the platform date picker.
class RtiDateField extends StatelessWidget {
  const RtiDateField({super.key, required this.label, required this.value, required this.onChanged, this.required = false});

  final String label;

  /// Null shows an empty field.
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final bool required;

  @override
  Widget build(BuildContext context) => PickerField(
        label: label,
        required: required,
        value: Fmt.ddMMyyyy(value),
        icon: Icons.calendar_today_outlined,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? Fmt.today(),
            firstDate: DateTime(2015),
            lastDate: DateTime(2100),
          );
          if (picked != null) onChanged(picked);
        },
      );
}
