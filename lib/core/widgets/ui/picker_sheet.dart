import 'package:flutter/material.dart';
import 'package:maleva/core/layout/responsive_layout.dart';
import 'package:maleva/core/theme/app_theme.dart';
import 'package:maleva/core/theme/status_tone.dart';

/// How a picker row is coloured (the web's truck / driver expiry and leave colours).
enum PickSeverity { normal, warning, critical, leaveApproved, leavePending }

class PickOption<T> {
  const PickOption({required this.value, required this.label, this.subtitle, this.severity = PickSeverity.normal});

  final T value;
  final String label;
  final String? subtitle;
  final PickSeverity severity;
}

Color severityColor(BuildContext context, PickSeverity s) {
  final mc = context.mc;
  return switch (s) {
    PickSeverity.normal => context.cs.onSurface,
    PickSeverity.warning => mc.toneFg(StatusTone.warning),
    PickSeverity.critical => mc.toneFg(StatusTone.danger),
    PickSeverity.leaveApproved => mc.toneFg(StatusTone.accent),
    PickSeverity.leavePending => mc.leavePending,
  };
}

/// The result of a picker: a chosen option, a typed name, or "cleared".
class PickResult<T> {
  const PickResult.option(T this.value) : typed = null, cleared = false;
  const PickResult.typed(String this.typed) : value = null, cleared = false;
  const PickResult.cleared() : value = null, typed = null, cleared = true;

  final T? value;
  final String? typed;
  final bool cleared;
}

/// A searchable picker: a bottom sheet on the phone, a dialog on a tablet. Recent values come
/// first; the current value is marked "Current". [allowTyped] adds "Use '<text>'" for a typed name
/// (outside driver); [allowClear] adds Clear.
Future<PickResult<T>?> showPickerSheet<T>(
  BuildContext context, {
  required String title,
  required List<PickOption<T>> options,
  T? current,
  Set<T> recent = const {},
  bool allowTyped = false,
  bool allowClear = false,
  String searchHint = 'Search…',
}) {
  final body = _PickerBody<T>(title: title, options: options, current: current, recent: recent, allowTyped: allowTyped, allowClear: allowClear, searchHint: searchHint);
  if (FormFactor.of(context).isTablet) {
    return showDialog<PickResult<T>>(
      context: context,
      useRootNavigator: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440, maxHeight: 560), child: body),
      ),
    );
  }
  return showModalBottomSheet<PickResult<T>>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (ctx) => SizedBox(height: MediaQuery.sizeOf(ctx).height * 0.82, child: body),
  );
}

class _PickerBody<T> extends StatefulWidget {
  const _PickerBody({required this.title, required this.options, this.current, required this.recent, required this.allowTyped, required this.allowClear, required this.searchHint});

  final String title;
  final List<PickOption<T>> options;
  final T? current;
  final Set<T> recent;
  final bool allowTyped;
  final bool allowClear;
  final String searchHint;

  @override
  State<_PickerBody<T>> createState() => _PickerBodyState<T>();
}

class _PickerBodyState<T> extends State<_PickerBody<T>> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    final list = widget.options.where((o) => q.isEmpty || o.label.toLowerCase().contains(q) || (o.subtitle ?? '').toLowerCase().contains(q)).toList()
      ..sort((a, b) => (widget.recent.contains(b.value) ? 1 : 0) - (widget.recent.contains(a.value) ? 1 : 0));
    final mc = context.mc;
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
            child: Row(children: [
              Expanded(child: Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
              if (widget.allowClear) TextButton(onPressed: () => Navigator.pop(context, PickResult<T>.cleared()), child: const Text('Clear')),
              IconButton(tooltip: 'Close', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              autofocus: FormFactor.of(context).isTablet,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: widget.searchHint),
              onChanged: (v) => setState(() => _q = v),
              onSubmitted: (_) {
                if (list.length == 1) Navigator.pop(context, PickResult<T>.option(list.first.value));
              },
            ),
          ),
          if (widget.allowTyped && _q.trim().isNotEmpty)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text('Use "${_q.trim()}"'),
              subtitle: const Text('Typed name'),
              onTap: () => Navigator.pop(context, PickResult<T>.typed(_q.trim())),
            ),
          Expanded(
            child: list.isEmpty
                ? Center(child: Text('No match', style: TextStyle(color: mc.muted)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final o = list[i];
                      final isCurrent = widget.current != null && o.value == widget.current;
                      final isRecent = widget.recent.contains(o.value);
                      return ListTile(
                        minVerticalPadding: 10,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        selected: isCurrent,
                        selectedTileColor: mc.primarySoft,
                        title: Text(o.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        subtitle: o.subtitle == null ? null : Text(o.subtitle!, style: TextStyle(color: o.severity == PickSeverity.normal ? mc.muted : severityColor(context, o.severity), fontWeight: FontWeight.w600)),
                        trailing: Wrap(spacing: 6, children: [
                          if (isCurrent) const Chip(label: Text('Current'), visualDensity: VisualDensity.compact),
                          if (isRecent) const Chip(label: Text('Recent'), visualDensity: VisualDensity.compact),
                        ]),
                        onTap: () => Navigator.pop(context, PickResult<T>.option(o.value)),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}
