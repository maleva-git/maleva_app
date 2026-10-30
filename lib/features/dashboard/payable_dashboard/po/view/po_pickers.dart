import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';

import '../data/po_draft.dart';

/// A searchable list in a bottom sheet; answers the chosen option (null = closed). [allowClear] adds "None".
Future<Option?> pickOption(BuildContext context,
    {required String title, required List<Option> options, Option? selected, bool allowClear = false}) {
  return showModalBottomSheet<Option?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppTokens.surfaceCard,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    builder: (_) => _OptionSheet(title: title, options: options, selected: selected, allowClear: allowClear),
  );
}

/// The "None" answer of [pickOption] when [allowClear] is on.
const noneOption = Option(-1, 'None');

class _OptionSheet extends StatefulWidget {
  const _OptionSheet({required this.title, required this.options, this.selected, required this.allowClear});

  final String title;
  final List<Option> options;
  final Option? selected;
  final bool allowClear;

  @override
  State<_OptionSheet> createState() => _OptionSheetState();
}

class _OptionSheetState extends State<_OptionSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    final shown = widget.options
        .where((o) => q.isEmpty || o.name.toLowerCase().contains(q) || o.sub.toLowerCase().contains(q))
        .take(200)
        .toList();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.8,
        child: Column(children: [
          const SizedBox(height: 8),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppTokens.surfaceBorder, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(children: [
              Expanded(child: Text(widget.title, style: AppTypography.heading3(color: AppTokens.textPrimary))),
              Text('${widget.options.length}', style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              key: const ValueKey('option-search'),
              autofocus: widget.options.length > 12,
              onChanged: (v) => setState(() => _q = v),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView(children: [
              if (widget.allowClear)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.clear, size: 18),
                  title: const Text('None'),
                  onTap: () => Navigator.pop(context, noneOption),
                ),
              for (final o in shown)
                ListTile(
                  dense: true,
                  selected: o == widget.selected,
                  title: Text(o.name.isEmpty ? '#${o.id}' : o.name,
                      style: AppTypography.bodyMedium(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
                  subtitle:
                      o.sub.isEmpty ? null : Text(o.sub, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                  trailing: o == widget.selected ? const Icon(Icons.check, color: AppTokens.brandPrimary) : null,
                  onTap: () => Navigator.pop(context, o),
                ),
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Nothing found',
                      textAlign: TextAlign.center, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// A tappable field that shows a value or a hint (opens a picker).
class PickField extends StatelessWidget {
  const PickField(
      {super.key, required this.label, required this.value, required this.onTap, this.icon, this.required = false});

  final String label;
  final String? value;
  final VoidCallback onTap;
  final IconData? icon;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final empty = value == null || value!.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: required ? '$label *' : label,
            prefixIcon: icon == null ? null : Icon(icon, size: 20),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
          ),
          child: Text(empty ? 'Choose' : value!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium(color: empty ? AppTokens.textMuted : AppTokens.textPrimary)),
        ),
      ),
    );
  }
}

/// A drop-down for a list of words (expense type, expense head): shows the choice in one box and opens the searchable
/// [pickOption] sheet, so a long list never fills the page. The current value stays in the list even when it is not
/// one of [options] (an older record).
class TextPickField extends StatelessWidget {
  const TextPickField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon = Icons.category_outlined,
    this.required = false,
    this.labelOf,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final IconData? icon;
  final bool required;

  /// The text shown for a value (e.g. '' → 'Send for approval'); null shows the value itself.
  final String Function(String value)? labelOf;

  String _show(String v) => labelOf == null ? v : labelOf!(v);

  @override
  Widget build(BuildContext context) {
    final words = <String>[...options, if (!options.contains(value) && value.trim().isNotEmpty) value];
    final shown = _show(value);
    return PickField(
      label: label,
      value: shown.trim().isEmpty ? null : shown,
      icon: icon,
      required: required,
      onTap: () async {
        final list = [for (var i = 0; i < words.length; i++) Option(i, _show(words[i]))];
        final at = words.indexOf(value);
        final picked =
            await pickOption(context, title: label, options: list, selected: at < 0 ? null : list[at]);
        if (picked != null && picked.id >= 0 && picked.id < words.length) onChanged(words[picked.id]);
      },
    );
  }
}
