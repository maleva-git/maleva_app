import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_theme.dart';

/// A titled card section of a detail page (sections 1–6 of a job, the parts of an RTI).
class DetailSection extends StatelessWidget {
  const DetailSection({super.key, required this.title, required this.child, this.icon, this.trailing});

  final String title;
  final Widget child;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            if (icon != null) ...[Icon(icon, size: 18, color: mc.muted), const SizedBox(width: 8)],
            Expanded(
              child: Text(title.toUpperCase(),
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.9, color: mc.muted)),
            ),
            if (trailing != null) trailing!,
          ]),
          const SizedBox(height: 8),
          child,
        ]),
      ),
    );
  }
}

/// A label / value row; [value] wraps rather than overflow on small phones.
class KeyValueRow extends StatelessWidget {
  const KeyValueRow(this.label, this.value, {super.key, this.valueStyle});

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(color: context.mc.muted, fontSize: 15))),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(value.isEmpty ? '—' : value, textAlign: TextAlign.right,
                style: valueStyle ?? const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ]),
      );
}

/// A small label over a value, for two- or three-column grids of facts.
class LabeledValue extends StatelessWidget {
  const LabeledValue(this.label, this.value, {super.key, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.mc.muted)),
        const SizedBox(height: 2),
        Text(value.isEmpty ? '—' : value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
      ]);
}

/// The sticky bottom bar: a summary on the left, actions on the right. Keeps above the system inset.
class StickyActionBar extends StatelessWidget {
  const StickyActionBar({super.key, this.leading, required this.actions});

  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Material(
        color: context.cs.surface,
        child: DecoratedBox(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: context.mc.outline))),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(children: [
                if (leading != null) Expanded(child: leading!) else const Spacer(),
                for (final a in actions) ...[const SizedBox(width: 10), a],
              ]),
            ),
          ),
        ),
      );
}

/// A large page title for list screens (phone), with actions on the right.
class LargeTitle extends StatelessWidget {
  const LargeTitle(this.title, {super.key, this.actions = const []});

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
        child: Row(children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.5))),
          ...actions,
        ]),
      );
}

/// A summary tile (count + label) that filters a list when tapped.
class CountTile extends StatelessWidget {
  const CountTile({super.key, required this.count, required this.label, required this.selected, required this.onTap, this.color});

  final int count;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return Semantics(
      button: true,
      selected: selected,
      label: '$label $count',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? mc.primarySoft : context.cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? context.cs.primary : mc.outline, width: selected ? 2 : 1),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: mc.muted)),
          ]),
        ),
      ),
    );
  }
}
