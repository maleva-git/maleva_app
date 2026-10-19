import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';

import '../bloc/admin_overview_cubit.dart';

/// The Overview tab's building blocks, in the colours the other dashboard tabs use.

const overviewRadius = 16.0;

/// Shows an area's data, or its loading state, or its error with Retry.
class AreaBody<T> extends StatelessWidget {
  const AreaBody({super.key, required this.area, required this.onRetry, required this.builder, this.onDark = false});

  final AreaState<T> area;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  /// On the blue header: white text.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final data = area.data;
    if (data != null && area.error == null) return builder(data);
    if (area.loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: onDark ? AppTokens.textOnDark : AppTokens.brandGradientStart),
        ),
      );
    }
    final fg = onDark ? AppTokens.textOnDark : Palette.rose;
    return Row(children: [
      Icon(Icons.error_outline, size: 16, color: fg),
      const SizedBox(width: 6),
      Expanded(
        child: Text(area.error ?? 'Could not load',
            maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTypography.bodySmall(color: fg)),
      ),
      TextButton(
        onPressed: onRetry,
        style: TextButton.styleFrom(
            foregroundColor: onDark ? AppTokens.textOnDark : AppTokens.brandGradientStart,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 32)),
        child: const Text('Retry'),
      ),
    ]);
  }
}

/// A number tile on the blue header: a glass card with an icon, the label, the big number and a line.
/// Tapping it opens the area's tab.
class KpiTile extends StatelessWidget {
  const KpiTile({super.key, required this.label, required this.icon, required this.body, this.onTap});

  final String label;
  final IconData icon;
  final Widget body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.textOnDark.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTokens.textOnDark.withValues(alpha: 0.18)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                    color: AppTokens.textOnDark.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 15, color: AppTokens.textOnDark),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall(
                        color: AppTokens.textOnDark.withValues(alpha: 0.9), fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 8),
            body,
          ]),
        ),
      ),
    );
  }
}

/// The big number and the line under it, on the blue header.
class KpiValue extends StatelessWidget {
  const KpiValue({super.key, required this.value, this.sub, this.alert});

  final String value;
  final String? sub;

  /// A rose pill under the number (overdue mailboxes).
  final String? alert;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: AppTypography.display(color: AppTokens.textOnDark, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      if (alert != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: Palette.rose, borderRadius: BorderRadius.circular(999)),
          child: Text(alert!, style: AppTypography.badgeText(color: AppTokens.textOnDark)),
        )
      else if (sub != null)
        Text(sub!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall(color: AppTokens.textOnDark.withValues(alpha: 0.8))),
    ]);
  }
}

/// A Quick Access tile: a white card with the area's coloured icon square and its name under it.
class QuickButton extends StatelessWidget {
  const QuickButton({super.key, required this.label, required this.icon, required this.color, required this.onTap});

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.surfaceCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTokens.surfaceBorder),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.85), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Icon(icon, size: 21, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

/// The colours of a panel: the top stripe, the icon box and the soft fills.
class PanelAccent {
  const PanelAccent({required this.start, required this.end, required this.strong, required this.soft});

  final Color start;
  final Color end;

  /// Title, icon and emphasis text.
  final Color strong;

  /// Icon box and soft fills.
  final Color soft;

  /// Sale orders (web emerald).
  static const emerald = PanelAccent(
      start: Color(0xFF34D399), end: Color(0xFF10B981), strong: Color(0xFF047857), soft: Color(0xFFD1FAE5));

  /// Invoices (web indigo).
  static const indigo = PanelAccent(
      start: Color(0xFF818CF8), end: Color(0xFF6366F1), strong: Color(0xFF3730A3), soft: Color(0xFFE0E7FF));

  /// Mailbox monitor.
  static const teal = PanelAccent(
      start: Color(0xFF2DD4BF), end: Color(0xFF14B8A6), strong: Color(0xFF0F766E), soft: Color(0xFFCCFBF1));

  /// Incident reports.
  static const rose = PanelAccent(
      start: Color(0xFFFB7185), end: Color(0xFFF43F5E), strong: Color(0xFFBE123C), soft: Color(0xFFFFE4E6));

  /// Truck location.
  static const green = PanelAccent(
      start: Color(0xFF4ADE80), end: Color(0xFF22C55E), strong: Color(0xFF15803D), soft: Color(0xFFDCFCE7));
}

/// A dashboard panel: coloured stripe on top, icon box, upper-case title and a line under it, an optional
/// switch, "Open" when it leads to a screen.
class AccentPanel extends StatelessWidget {
  const AccentPanel({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.child,
    this.subtitle,
    this.action,
    this.onOpen,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final PanelAccent accent;
  final Widget child;

  /// A switch shown under the title (Sale Order / Invoice).
  final Widget? action;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTokens.surfaceCard,
        borderRadius: BorderRadius.circular(overviewRadius),
        border: Border.all(color: accent.soft),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Container(height: 4, decoration: BoxDecoration(gradient: LinearGradient(colors: [accent.start, accent.end]))),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accent.soft.withValues(alpha: 0.5), AppTokens.surfaceCard],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accent.start, accent.end]),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 19, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall(color: accent.strong, fontWeight: FontWeight.w800)
                          .copyWith(letterSpacing: 1.1)),
                  if (subtitle != null)
                    Text(subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w600)),
                ]),
              ),
              if (onOpen != null) OpenLink(onTap: onOpen!, color: accent.strong),
            ]),
            if (action != null) ...[const SizedBox(height: 10), action!],
          ]),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(12, 4, 12, 12), child: child),
      ]),
    );
  }
}

/// "Open →" in a soft pill.
class OpenLink extends StatelessWidget {
  const OpenLink({super.key, required this.onTap, this.color = AppTokens.brandGradientStart});

  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Open', style: AppTypography.bodySmall(color: color, fontWeight: FontWeight.w700)),
              const SizedBox(width: 3),
              Icon(Icons.arrow_forward_rounded, size: 14, color: color),
            ]),
          ),
        ),
      );
}

/// A toggle group: the options in a grey track, the chosen one white.
class SegmentSwitch extends StatelessWidget {
  const SegmentSwitch({super.key, required this.options, required this.selected, required this.onChanged, this.color});

  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  /// The chosen option's text colour.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: Palette.grey300, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        for (var i = 0; i < options.length; i++)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: i == selected ? AppTokens.surfaceCard : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: i == selected
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 1))]
                      : null,
                ),
                child: Text(options[i],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall(
                      color: i == selected ? (color ?? AppTokens.brandDark) : AppTokens.textMuted,
                      fontWeight: i == selected ? FontWeight.w700 : FontWeight.w500,
                    )),
              ),
            ),
          ),
      ]),
    );
  }
}

/// A period tile of the report card: coloured icon, period, count and amount.
class PeriodTile extends StatelessWidget {
  const PeriodTile({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.count,
    required this.amount,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String count;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.10), color.withValues(alpha: 0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
        ]),
        const SizedBox(height: 8),
        Text(count, style: AppTypography.heading1(color: AppTokens.textPrimary, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall(color: Palette.greenEco, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

/// The report card's months as a bar chart, oldest on the left, the newest month in the strong colour.
/// A tap on a bar shows the month's count and amount.
class MonthChart extends StatelessWidget {
  const MonthChart({super.key, required this.names, required this.amounts, required this.counts, required this.accent});

  /// Oldest first.
  final List<String> names;
  final List<double> amounts;
  final List<int> counts;
  final PanelAccent accent;

  static String short(String name) {
    final w = name.trim().split(RegExp(r'\s+')).first;
    return w.length <= 3 ? w : w.substring(0, 3);
  }

  @override
  Widget build(BuildContext context) {
    final best = amounts.fold<double>(0, (a, v) => v > a ? v : a);
    final top = best <= 0 ? 1.0 : best * 1.15;
    return SizedBox(
      height: 170,
      child: BarChart(
        BarChartData(
          maxY: top,
          alignment: BarChartAlignment.spaceAround,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: top / 4,
            getDrawingHorizontalLine: (_) => const FlLine(color: Palette.grey300, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= names.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(short(names[i]),
                        style: AppTypography.badgeText(
                            color: i == names.length - 1 ? accent.strong : AppTokens.textMuted,
                            fontWeight: i == names.length - 1 ? FontWeight.w800 : FontWeight.w500)),
                  );
                },
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppTokens.textPrimary,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '${names[group.x]}\n',
                AppTypography.badgeText(color: Colors.white, fontWeight: FontWeight.w700),
                children: [
                  TextSpan(
                    text: '${counts[group.x]} jobs · RM ${NumberFormatCache.money(rod.toY)}',
                    style: AppTypography.badgeText(color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < amounts.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: amounts[i],
                  width: names.length > 8 ? 12 : 18,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                  gradient: LinearGradient(
                    colors: i == amounts.length - 1
                        ? [accent.end, accent.strong]
                        : [accent.start.withValues(alpha: 0.45), accent.end.withValues(alpha: 0.6)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  backDrawRodData: BackgroundBarChartRodData(show: true, toY: top, color: Palette.grey300.withValues(alpha: 0.5)),
                ),
              ]),
          ],
        ),
      ),
    );
  }
}

/// Money without the currency, for the chart tooltip.
abstract final class NumberFormatCache {
  static String money(double v) {
    final s = v.toStringAsFixed(2).split('.');
    final whole = s[0].replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    return '$whole.${s[1]}';
  }
}

/// A small stat under the chart: label, value and an optional line.
class MiniStat extends StatelessWidget {
  const MiniStat({super.key, required this.label, required this.value, this.sub, required this.color});

  final String label;
  final String value;
  final String? sub;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(color: Palette.grey50, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 3),
          // Shrinks a long amount (RM 1,082,654.00) to fit a narrow phone column instead of cutting it.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, maxLines: 1, style: AppTypography.bodyMedium(color: color, fontWeight: FontWeight.w800)),
          ),
          if (sub != null)
            Text(sub!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.badgeText(color: AppTokens.textMuted)),
        ]),
      );
}

/// A list row with a leading block (avatar or date), a title, a line under it and a pill on the right.
class LeadRow extends StatelessWidget {
  const LeadRow({super.key, required this.lead, required this.title, this.subtitle, this.trailing, this.last = false});

  final Widget lead;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  /// No divider under the last row.
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          border: last ? null : const Border(bottom: BorderSide(color: AppTokens.surfaceBorder))),
      child: Row(children: [
        lead,
        const SizedBox(width: 10),
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
                  style: AppTypography.badgeText(color: AppTokens.textMuted)),
          ]),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 140), child: trailing!),
        ],
      ]),
    );
  }
}

/// A round avatar with a name's first letter.
class LetterAvatar extends StatelessWidget {
  const LetterAvatar({super.key, required this.text, required this.accent});

  final String text;
  final PanelAccent accent;

  @override
  Widget build(BuildContext context) => Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: accent.soft, shape: BoxShape.circle),
        child: Text(text.trim().isEmpty ? '?' : text.trim()[0].toUpperCase(),
            style: AppTypography.bodyMedium(color: accent.strong, fontWeight: FontWeight.w800)),
      );
}

/// A small calendar block: the day big, the month under it.
class DateBlock extends StatelessWidget {
  const DateBlock({super.key, required this.day, required this.month, required this.accent});

  final String day;
  final String month;
  final PanelAccent accent;

  @override
  Widget build(BuildContext context) => Container(
        width: 38,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(color: accent.soft, borderRadius: BorderRadius.circular(10)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(day, style: AppTypography.bodyMedium(color: accent.strong, fontWeight: FontWeight.w800)),
          Text(month.toUpperCase(), style: AppTypography.badgeText(color: accent.strong, fontWeight: FontWeight.w700)),
        ]),
      );
}

/// One part of a [StackedBar] and its legend.
class BarPart {
  const BarPart({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;
}

/// A rounded bar split by the parts' counts, with a legend of big numbers under it.
class StackedBar extends StatelessWidget {
  const StackedBar({super.key, required this.parts});

  final List<BarPart> parts;

  @override
  Widget build(BuildContext context) {
    final total = parts.fold<int>(0, (a, p) => a + p.count);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: 10,
          child: total == 0
              ? const ColoredBox(color: Palette.grey300)
              : Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (final p in parts)
                    if (p.count > 0) Expanded(flex: p.count, child: ColoredBox(color: p.color)),
                ]),
        ),
      ),
      const SizedBox(height: 12),
      Row(children: [
        for (var i = 0; i < parts.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: parts[i].color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${parts[i].count}',
                    style: AppTypography.heading1(color: parts[i].color, fontWeight: FontWeight.w800)),
                Row(children: [
                  Container(
                      width: 7, height: 7, decoration: BoxDecoration(color: parts[i].color, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(parts[i].label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ]),
            ),
          ),
        ],
      ]),
    ]);
  }
}
