import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_theme.dart';

/// One removable active filter.
class ActiveFilter {
  const ActiveFilter(this.label, this.onRemove, {this.icon});

  final String label;
  final VoidCallback onRemove;
  final IconData? icon;
}

/// The active filters as removable chips, with "Clear all" when there are any.
class FilterChipsBar extends StatelessWidget {
  const FilterChipsBar({super.key, required this.filters, this.onClearAll, this.padding = EdgeInsets.zero});

  final List<ActiveFilter> filters;
  final VoidCallback? onClearAll;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(children: [
        for (final f in filters) ...[
          InputChip(
            avatar: f.icon == null ? null : Icon(f.icon, size: 18),
            label: Text(f.label),
            onDeleted: f.onRemove,
            deleteButtonTooltipMessage: 'Remove filter',
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
          const SizedBox(width: 8),
        ],
        if (onClearAll != null) TextButton(onPressed: onClearAll, child: const Text('Clear all')),
      ]),
    );
  }
}

/// A choice from a few fixed values (YES / NO, NO / EMPTY 80 / EMPTY 50, links ...).
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({super.key, required this.values, required this.selected, required this.onChanged, this.labelOf});

  final List<T> values;
  final T selected;
  final ValueChanged<T> onChanged;
  final String Function(T)? labelOf;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final cs = context.cs;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: mc.surface2, borderRadius: BorderRadius.circular(14), border: Border.all(color: mc.outline)),
      child: Row(children: [
        for (final v in values)
          Expanded(
            child: Semantics(
              button: true,
              selected: v == selected,
              child: InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: () => onChanged(v),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: v == selected ? cs.primary : null, borderRadius: BorderRadius.circular(11)),
                  child: Text(
                    labelOf?.call(v) ?? '$v',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: v == selected ? cs.onPrimary : cs.onSurface),
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

/// A count with − and + (Add Pickup / Add Drop counts).
class CountStepper extends StatelessWidget {
  const CountStepper({super.key, required this.value, required this.onChanged, this.min = 0, this.label = 'Count'});

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final String label;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(label, style: TextStyle(color: context.mc.muted))),
        IconButton.outlined(tooltip: 'Fewer', onPressed: value > min ? () => onChanged(value - 1) : null, icon: const Icon(Icons.remove)),
        SizedBox(width: 44, child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
        IconButton.outlined(tooltip: 'More', onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add)),
      ]);
}

/// A tappable field that opens a picker (date, driver, truck ...), styled like a text field.
class PickerField extends StatelessWidget {
  const PickerField({super.key, required this.label, required this.value, required this.onTap, this.icon = Icons.expand_more, this.required = false, this.errorText, this.enabled = true, this.hint});

  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData icon;
  final bool required;
  final String? errorText;
  final bool enabled;
  final String? hint;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: '$label, ${value.isEmpty ? (hint ?? 'not set') : value}',
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            isEmpty: value.isEmpty,
            decoration: InputDecoration(labelText: required ? '$label *' : label, hintText: hint, errorText: errorText, enabled: enabled, suffixIcon: Icon(icon)),
            child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16)),
          ),
        ),
      );
}

/// A switch row with a 52 dp target.
class SwitchRow extends StatelessWidget {
  const SwitchRow({super.key, required this.label, required this.value, required this.onChanged, this.subtitle});

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle == null ? null : Text(subtitle!),
        value: value,
        onChanged: onChanged,
      );
}
