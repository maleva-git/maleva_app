import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/ui/formats.dart';
import 'package:maleva/features/dashboard/admin_dashboard/overview/view/overview_widgets.dart';

import '../data/ceo_analytics_models.dart';

/// The CEO dashboard's own small pieces; the panels, tiles and charts come from the Super Admin Overview
/// (`overview_widgets.dart`) so both dashboards look alike.

final _count = NumberFormat('#,##0', 'en_US');

/// `1,234`.
String ceoCount(int v) => _count.format(v);

/// `98.5k`, `1.2M`: for chart axes and the donut centre, where the full amount does not fit.
String ceoCompact(double v) {
  final a = v.abs();
  if (a >= 1e6) return '${(v / 1e6).toStringAsFixed(a >= 1e7 ? 0 : 1)}M';
  if (a >= 1e3) return '${(v / 1e3).toStringAsFixed(a >= 1e4 ? 0 : 1)}k';
  return v.toStringAsFixed(0);
}

/// How many documents a breakdown row stands for: the leading number of `N jobs` / `N invoices` / `N POs`.
int ceoJobsOf(CeoDetailRow row) => int.tryParse(RegExp(r'\d+').stringMatch(row.subtitle.replaceAll(',', '')) ?? '') ?? 0;

/// `12.4%` of [part] in [whole], or `0%`.
String ceoShare(double part, double whole) => whole <= 0 ? '0%' : '${(part * 100 / whole).toStringAsFixed(1)}%';

/// Accents for the panels the Overview has no colour for.
abstract final class CeoAccent {
  static const revenue = PanelAccent.emerald;
  static const expenses = PanelAccent(
      start: Color(0xFFFBBF24), end: Color(0xFFF59E0B), strong: Color(0xFFB45309), soft: Color(0xFFFEF3C7));
  static const cash = PanelAccent(
      start: Color(0xFF60A5FA), end: Color(0xFF3B82F6), strong: Color(0xFF1D4ED8), soft: Color(0xFFDBEAFE));
  static const operations = PanelAccent.indigo;
  static const people = PanelAccent(
      start: Color(0xFFA78BFA), end: Color(0xFF8B5CF6), strong: Color(0xFF6D28D9), soft: Color(0xFFEDE9FE));

  /// Expense categories, in rank order; the last one is "Others".
  static const series = [
    Palette.blueMid,
    Color(0xFF10B981),
    Palette.amberGold,
    Color(0xFFF43F5E),
    Color(0xFF6366F1),
    Color(0xFF14B8A6),
    Color(0xFF7C3AED),
    Palette.grey700,
  ];

  /// Ageing buckets: current to over 90 days, calm to alarming.
  static const ageing = [
    Color(0xFF10B981),
    Color(0xFF84CC16),
    Color(0xFFF59E0B),
    Color(0xFFF97316),
    Color(0xFFE11D48),
  ];
}

/// Rows of [columns] equal cells, each at least [minCellHeight] tall; a short last row keeps the cell
/// width. No intrinsic measuring, so charts can sit inside.
class CeoGrid extends StatelessWidget {
  const CeoGrid({super.key, required this.columns, required this.children, this.spacing = 8, this.minCellHeight = 0});

  final int columns;
  final double spacing;
  final double minCellHeight;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final cells = children.sublist(i, (i + columns).clamp(0, children.length));
      rows.add(Padding(
        padding: EdgeInsets.only(bottom: i + columns < children.length ? spacing : 0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var c = 0; c < columns; c++) ...[
            if (c > 0) SizedBox(width: spacing),
            Expanded(
              child: c >= cells.length
                  ? const SizedBox.shrink()
                  : ConstrainedBox(constraints: BoxConstraints(minHeight: minCellHeight), child: cells[c]),
            ),
          ],
        ]),
      ));
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }
}

/// A small label in capitals between blocks of a panel, with an optional hint on the right.
class CeoSubheading extends StatelessWidget {
  const CeoSubheading(this.text, {super.key, this.hint});

  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Row(children: [
          Expanded(
            child: Text(text.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w800)
                    .copyWith(letterSpacing: 1)),
          ),
          if (hint != null) Text(hint!, style: AppTypography.badgeText(color: Palette.textDim, fontWeight: FontWeight.w500)),
        ]),
      );
}

/// Up or down against the previous period, as an arrow and a percentage. [upIsGood] false for costs.
class ChangeChip extends StatelessWidget {
  const ChangeChip({super.key, required this.change, this.upIsGood = true, this.onDark = false, this.suffix = ''});

  /// Percent; null when there was nothing to compare with.
  final double? change;
  final bool upIsGood;
  final bool onDark;

  /// ` vs prev`.
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final c = change;
    if (c == null) {
      return Text('— $suffix'.trim(),
          style: AppTypography.badgeText(
              color: onDark ? AppTokens.textOnDark.withValues(alpha: 0.7) : AppTokens.textMuted,
              fontWeight: FontWeight.w600));
    }
    final up = c >= 0;
    final good = up == upIsGood || c == 0;
    final Color fg = onDark
        ? (good ? const Color(0xFF6EE7B7) : const Color(0xFFFDA4AF))
        : (good ? AppTokens.statusSuccess : Palette.rose);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 12, color: fg),
      const SizedBox(width: 2),
      Flexible(
        child: Text('${c.abs().toStringAsFixed(1)}%$suffix',
            maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.badgeText(color: fg, fontWeight: FontWeight.w800)),
      ),
    ]);
  }
}

/// A thin rounded bar filled to [fraction] (0..1).
class ShareBar extends StatelessWidget {
  const ShareBar({super.key, required this.fraction, required this.color, this.height = 6});

  final double fraction;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: height,
          child: Stack(children: [
            const Positioned.fill(child: ColoredBox(color: Palette.grey300)),
            FractionallySizedBox(
              widthFactor: fraction.isNaN ? 0 : fraction.clamp(0.0, 1.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [color.withValues(alpha: 0.7), color]),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ]),
        ),
      );
}

/// A tappable list row: name and a line on the left, value on the right, a share bar under them and a
/// chevron when it opens a list.
class RankRow extends StatelessWidget {
  const RankRow({
    super.key,
    required this.title,
    required this.value,
    required this.fraction,
    required this.color,
    this.lead,
    this.subtitle,
    this.trailingSub,
    this.onTap,
  });

  final Widget? lead;
  final String title;
  final String? subtitle;
  final String value;
  final Widget? trailingSub;
  final double fraction;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
          child: Row(children: [
            if (lead != null) ...[lead!, const SizedBox(width: 10)],
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
                      if (subtitle != null)
                        Text(subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(value,
                            maxLines: 1,
                            style: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
                      ),
                      if (trailingSub != null) trailingSub!,
                    ]),
                  ),
                ]),
                const SizedBox(height: 6),
                ShareBar(fraction: fraction, color: color),
              ]),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, size: 18, color: Palette.textDim),
            ],
          ]),
        ),
      );
}

/// A number tile on a white panel: label, big value, a line under it; a chevron when tapping opens a list.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.sub,
    this.onTap,
  });

  final String label;
  final String value;
  final String? sub;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.18)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(7)),
                  child: Icon(icon, size: 14, color: color),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.badgeText(color: color, fontWeight: FontWeight.w800)),
                ),
                if (onTap != null) Icon(Icons.chevron_right_rounded, size: 16, color: color),
              ]),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value,
                    maxLines: 1,
                    style: AppTypography.heading1(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
              ),
              if (sub != null) ...[
                const SizedBox(height: 2),
                Text(sub!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w600)),
              ],
            ]),
          ),
        ),
      );
}

/// Money split into parts as one rounded bar, with a legend row per part (amount and share).
class MoneySplitBar extends StatelessWidget {
  const MoneySplitBar({super.key, required this.labels, required this.amounts, required this.colors});

  final List<String> labels;
  final List<double> amounts;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final total = amounts.fold<double>(0, (a, v) => a + (v > 0 ? v : 0));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: 12,
          child: total <= 0
              ? const ColoredBox(color: Palette.grey300)
              : Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (var i = 0; i < amounts.length; i++)
                    if (amounts[i] > 0)
                      Expanded(
                        flex: (amounts[i] * 10000 / total).round().clamp(1, 10000),
                        child: ColoredBox(color: colors[i % colors.length]),
                      ),
                ]),
        ),
      ),
      const SizedBox(height: 8),
      for (var i = 0; i < labels.length; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall(color: AppTokens.textMuted, fontWeight: FontWeight.w600)),
            ),
            Text(ceoShare(amounts[i], total),
                style: AppTypography.badgeText(color: Palette.textDim, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 96),
              child: Text(Fmt.rm(amounts[i]),
                  textAlign: TextAlign.right,
                  style: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
    ]);
  }
}

/// A quiet line for an empty list.
class CeoQuiet extends StatelessWidget {
  const CeoQuiet(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          const Icon(Icons.check_circle_outline, size: 16, color: AppTokens.statusSuccess),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: AppTypography.bodySmall(color: AppTokens.textMuted))),
        ]),
      );
}

/// The customer's own currency amount (`SGD 300.00`) under an RM amount; nothing for RM.
class CeoForeignAmount extends StatelessWidget {
  const CeoForeignAmount(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => text.isEmpty
      ? const SizedBox.shrink()
      : FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(text,
              maxLines: 1,
              style: AppTypography.badgeText(color: const Color(0xFF0369A1), fontWeight: FontWeight.w700)),
        );
}

/// A small muted note: these parts of the panel could not be loaded on the server (they arrive as zeros).
class CeoUnavailableNote extends StatelessWidget {
  const CeoUnavailableNote({super.key, required this.parts});

  final List<String> parts;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 4, bottom: 6),
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        decoration: BoxDecoration(
          color: Palette.grey300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline_rounded, size: 15, color: AppTokens.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text('Some figures are unavailable: ${parts.join(', ')} (the server could not load them; zeros are not real)',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w600)),
          ),
        ]),
      );
}
