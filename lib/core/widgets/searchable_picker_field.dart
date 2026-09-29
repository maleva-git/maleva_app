import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/app_form_fields.dart';

/// A dropdown that opens a searchable bottom sheet - usable for any list
/// (trucks, drivers, statuses ...). [value] null shows [hint]; the clear button
/// sends null to [onChanged].
class SearchablePickerField<T> extends StatelessWidget {
  const SearchablePickerField({
    super.key,
    required this.items,
    required this.value,
    required this.itemLabel,
    required this.onChanged,
    this.hint = 'Select',
    this.sheetTitle,
    this.enabled = true,
    this.hasError = false,
    this.clearable = true,
    this.searchThreshold = 8,
  });

  final List<T> items;
  final T? value;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final String hint;
  final String? sheetTitle;
  final bool enabled;
  final bool hasError;
  final bool clearable;

  /// Lists shorter than this open without a search box.
  final int searchThreshold;

  Future<void> _open(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet<T>(
        title: sheetTitle ?? hint,
        items: items,
        selected: value,
        itemLabel: itemLabel,
        showSearch: items.length >= searchThreshold,
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final current = value;
    final Widget? suffix;
    if (!enabled) {
      suffix = null;
    } else if (current != null && clearable) {
      suffix = IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.close_rounded, size: 18),
        color: AppTokens.textDim,
        onPressed: () => onChanged(null),
      );
    } else {
      suffix = const Icon(Icons.expand_more_rounded, color: AppTokens.brandPrimary);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: enabled ? () => _open(context) : null,
      child: InputDecorator(
        isEmpty: current == null,
        decoration: appInputDecoration(
          hint: hint,
          enabled: enabled,
          hasError: hasError,
          suffixIcon: suffix,
        ),
        child: Text(
          current == null ? '' : itemLabel(current),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyLarge(color: AppTokens.textPrimary),
        ),
      ),
    );
  }
}

class _PickerSheet<T> extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.items,
    required this.selected,
    required this.itemLabel,
    required this.showSearch,
  });

  final String title;
  final List<T> items;
  final T? selected;
  final String Function(T item) itemLabel;
  final bool showSearch;

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final visible = query.isEmpty
        ? widget.items
        : widget.items
            .where((item) => widget.itemLabel(item).toLowerCase().contains(query))
            .toList();
    final media = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.75),
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppTokens.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTokens.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Expanded(child: Text(widget.title, style: AppTypography.heading3())),
                  Text('${visible.length}', style: AppTypography.bodySmall()),
                ],
              ),
            ),
            if (widget.showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  autofocus: true,
                  onChanged: (text) => setState(() => _query = text),
                  style: AppTypography.bodyLarge(color: AppTokens.textPrimary),
                  decoration: appInputDecoration(
                    hint: 'Search',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  ),
                ),
              ),
            Flexible(
              child: visible.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('No matches', style: AppTypography.bodyMedium()),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                      itemCount: visible.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppTokens.surfaceBorder),
                      itemBuilder: (context, index) {
                        final item = visible[index];
                        final isSelected = item == widget.selected;
                        return ListTile(
                          dense: true,
                          title: Text(
                            widget.itemLabel(item),
                            style: AppTypography.bodyLarge(
                              color: isSelected
                                  ? AppTokens.brandPrimary
                                  : AppTokens.textPrimary,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_rounded, color: AppTokens.brandPrimary)
                              : null,
                          onTap: () => Navigator.of(context).pop(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
