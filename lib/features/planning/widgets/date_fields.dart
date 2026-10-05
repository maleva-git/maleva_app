import 'package:flutter/material.dart';
import 'package:maleva/core/widgets/ui/ui.dart';

String _two(int n) => n.toString().padLeft(2, '0');

/// `yyyy-MM-dd` ↔ [DateTime].
DateTime? parseYmd(String v) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(v.trim());
  return m == null ? null : DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
}

String toYmd(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

/// `yyyy-MM-ddTHH:mm` ↔ [DateTime].
DateTime? parseYmdHm(String v) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})').firstMatch(v.trim());
  return m == null ? null : DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!), int.parse(m[4]!), int.parse(m[5]!));
}

String toYmdHm(DateTime d) => '${toYmd(d)}T${_two(d.hour)}:${_two(d.minute)}';

/// A date box (the web's `<input type="date">`): the value is `yyyy-MM-dd` or '' (when [clearable]).
class DateField extends StatelessWidget {
  const DateField(
      {super.key,
      required this.label,
      required this.value,
      required this.onChanged,
      this.required = false,
      this.clearable = false,
      this.errorText,
      this.enabled = true});

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool required;
  final bool clearable;
  final String? errorText;
  final bool enabled;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: parseYmd(value) ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (d != null) onChanged(toYmd(d));
  }

  @override
  Widget build(BuildContext context) {
    final d = parseYmd(value);
    return Row(children: [
      Expanded(
        child: PickerField(
          label: label,
          value: d == null ? '' : Fmt.ddMMyyyy(d),
          hint: 'Any',
          required: required,
          errorText: errorText,
          enabled: enabled,
          icon: Icons.calendar_today_outlined,
          onTap: () => _pick(context),
        ),
      ),
      if (clearable && value.isNotEmpty && enabled)
        IconButton(tooltip: 'Clear $label', onPressed: () => onChanged(''), icon: const Icon(Icons.close)),
    ]);
  }
}

/// A date and time box (the web's `datetime-local` / `DateToggle`): `yyyy-MM-ddTHH:mm` or ''.
class DateTimeField extends StatelessWidget {
  const DateTimeField({super.key, required this.label, required this.value, required this.onChanged, this.enabled = true});

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool enabled;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final current = parseYmdHm(value) ?? DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final d = await showDatePicker(context: context, initialDate: current, firstDate: DateTime(now.year - 10), lastDate: DateTime(now.year + 10));
    if (d == null || !context.mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(current));
    if (t == null) return;
    onChanged(toYmdHm(DateTime(d.year, d.month, d.day, t.hour, t.minute)));
  }

  @override
  Widget build(BuildContext context) {
    final d = parseYmdHm(value);
    return Row(children: [
      Expanded(
        child: PickerField(
          label: label,
          value: d == null ? '' : '${Fmt.ddMMyyyy(d)} ${_two(d.hour)}:${_two(d.minute)}',
          hint: 'Not set',
          enabled: enabled,
          icon: Icons.schedule,
          onTap: () => _pick(context),
        ),
      ),
      if (value.isNotEmpty && enabled) IconButton(tooltip: 'Clear $label', onPressed: () => onChanged(''), icon: const Icon(Icons.close)),
    ]);
  }
}
