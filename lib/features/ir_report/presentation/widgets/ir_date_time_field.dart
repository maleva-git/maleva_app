import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/app_form_fields.dart';

import 'ir_format.dart';

/// Picks a date, then a time. Dismissing the time picker keeps the previous
/// time rather than resetting it to midnight.
class IrDateTimeField extends StatelessWidget {
  const IrDateTimeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.hasError = false,
  });

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final bool enabled;
  final bool hasError;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final initial = value ?? now;
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final lastDate = initial.isAfter(tomorrow) ? initial : tomorrow;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: lastDate,
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    final picked = time ?? TimeOfDay.fromDateTime(initial);
    onChanged(DateTime(date.year, date.month, date.day, picked.hour, picked.minute));
  }

  @override
  Widget build(BuildContext context) {
    final current = value;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: enabled ? () => _pick(context) : null,
      child: InputDecorator(
        isEmpty: current == null,
        decoration: appInputDecoration(
          hint: 'Select date and time',
          enabled: enabled,
          hasError: hasError,
          suffixIcon: const Icon(Icons.calendar_month_rounded, color: AppTokens.brandPrimary),
        ),
        child: Text(
          current == null ? '' : IrFormat.dateTime(current),
          style: AppTypography.bodyLarge(color: AppTokens.textPrimary),
        ),
      ),
    );
  }
}
