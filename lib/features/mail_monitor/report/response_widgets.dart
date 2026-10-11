import 'package:flutter/material.dart';
import 'package:maleva/core/mailmonitor/response_report_models.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/ui/status_pill.dart';

import 'response_rules.dart';

/// The Mail Response tab's parts, in the app's colours (change `mail-response-report-tab`).

const reportRadius = 16.0;

BoxDecoration cardBox({Color? color, Color? border}) => BoxDecoration(
      color: color ?? AppTokens.surfaceCard,
      borderRadius: BorderRadius.circular(reportRadius),
      border: Border.all(color: border ?? AppTokens.surfaceBorder),
      boxShadow: color == null
          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))]
          : null,
    );

/// Mail received per day (grey) with the part replied within target (green).
class DailyBarsView extends StatelessWidget {
  const DailyBarsView({super.key, required this.daily, this.height = 40});

  final List<DayStats> daily;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return SizedBox(height: height);
    final max = daily.fold<int>(1, (m, d) => d.received > m ? d.received : m);
    return Semantics(
      label: daily.map((d) => '${d.day}: ${d.withinTarget} of ${d.received} within target').join('; '),
      child: SizedBox(
        height: height,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (final d in daily)
            Expanded(
              child: Tooltip(
                message: '${d.day}: ${d.withinTarget} of ${d.received} within target',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Stack(alignment: Alignment.bottomCenter, children: [
                    FractionallySizedBox(
                      heightFactor: d.received / max,
                      child: Container(
                        decoration:
                            BoxDecoration(color: AppTokens.surfaceBorder, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    FractionallySizedBox(
                      heightFactor: d.withinTarget / max,
                      child: Container(
                        decoration:
                            BoxDecoration(color: AppTokens.statusSuccess, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

/// One number with its label and a small note.
class NumberTile extends StatelessWidget {
  const NumberTile({super.key, required this.label, required this.value, this.note, this.valueColor, this.icon});

  final String label;
  final String value;
  final String? note;
  final Color? valueColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: cardBox(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          if (icon != null) ...[
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(color: AppTokens.brandLight, shape: BoxShape.circle),
              child: Icon(icon, size: 15, color: AppTokens.brandGradientStart),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall(color: AppTokens.textMuted, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(value,
            style: AppTypography.display(color: valueColor ?? AppTokens.brandDark, fontWeight: FontWeight.w700)),
        if (note != null)
          Text(note!,
              maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
      ]),
    );
  }
}

/// Fastest replier (green), needs attention (rose) or the whole company (white).
class SpotlightCard extends StatelessWidget {
  const SpotlightCard({
    super.key,
    required this.label,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.line,
    this.color,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final String title;
  final String? subtitle;
  final String line;

  /// Green or rose; null for the white company card.
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? AppTokens.brandDark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(reportRadius),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: color == null
              ? cardBox()
              : cardBox(color: color!.withValues(alpha: 0.08), border: color!.withValues(alpha: 0.3)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(icon, size: 15, color: fg),
              const SizedBox(width: 6),
              Text(label.toUpperCase(),
                  style: AppTypography.badgeText(color: fg).copyWith(letterSpacing: 0.8, fontWeight: FontWeight.w700)),
            ]),
            const SizedBox(height: 6),
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.heading2(color: color == null ? AppTokens.brandDark : fg)),
            if (subtitle != null)
              Text(subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall(color: AppTokens.textMuted)),
            const SizedBox(height: 4),
            Text(line, style: AppTypography.bodySmall(color: AppTokens.textPrimary, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

/// One mailbox: rank, employee, band, the share within target and the rest of its numbers.
class MailboxResponseCard extends StatelessWidget {
  const MailboxResponseCard({super.key, required this.rank, required this.row, required this.onTap});

  final int rank;
  final ResponseRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final band = bandOf(row);
    final n = row.numbers;
    final behind = band == Band.behind;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(reportRadius),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: behind
              ? cardBox(color: Palette.rose.withValues(alpha: 0.04), border: Palette.rose.withValues(alpha: 0.25))
              : cardBox(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppTokens.brandLight, shape: BoxShape.circle),
                child: Text('$rank',
                    style: AppTypography.bodySmall(color: AppTokens.brandGradientStart, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ownerText(row),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.heading3(
                          color: row.owners.isEmpty ? AppTokens.textMuted : AppTokens.brandDark)),
                  Text('${row.address} · ${row.department ?? (row.kind == 'PERSONAL' ? 'Personal' : 'Shared')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall(color: AppTokens.textMuted)),
                ]),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: StatusPill(bandLabel(band), tone: bandTone(band)),
              ),
            ]),
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                flex: 3,
                child: _Metric(
                  label: 'Within ${row.targetMinutes} min',
                  value: row.sentFolderFound ? pctText(n.withinTargetPct) : '—',
                  note: row.sentFolderFound ? '${n.withinTarget}/${n.received}' : null,
                  big: true,
                ),
              ),
              Expanded(flex: 2, child: _Metric(label: 'Average', value: minutesText(n.avgMinutes))),
              Expanded(flex: 2, child: _Metric(label: 'Slowest', value: minutesText(n.maxMinutes))),
              Expanded(
                flex: 2,
                child: _Metric(
                  label: 'Waiting',
                  value: '${n.waiting}',
                  color: n.waiting > 0 ? Palette.rose : AppTokens.textMuted,
                ),
              ),
            ]),
            const SizedBox(height: 8),
            DailyBarsView(daily: n.daily, height: 18),
            if (row.scanError != null) ...[
              const SizedBox(height: 6),
              Text('Last scan failed: ${row.scanError}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall(color: AppTokens.statusWarning)),
            ],
          ]),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.note, this.color, this.big = false});

  final String label;
  final String value;
  final String? note;
  final Color? color;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
      Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
        Flexible(
          child: Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (big ? AppTypography.heading1 : AppTypography.heading3)(
                  color: color ?? AppTokens.brandDark, fontWeight: FontWeight.w700)),
        ),
        if (note != null) ...[
          const SizedBox(width: 4),
          Text(note!, style: AppTypography.bodySmall(color: AppTokens.textMuted)),
        ],
      ]),
    ]);
  }
}

/// A light pill button on the blue header.
class HeaderPill extends StatelessWidget {
  const HeaderPill({super.key, required this.label, this.icon, this.selected = false, required this.onTap});

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppTokens.brandGradientStart : AppTokens.textOnDark;
    return Material(
      color: selected ? AppTokens.textOnDark : AppTokens.textOnDark.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 15, color: fg), const SizedBox(width: 6)],
            Text(label, style: AppTypography.bodySmall(color: fg, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}
