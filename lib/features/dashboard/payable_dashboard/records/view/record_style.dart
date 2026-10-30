import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/palette.dart';
import 'package:maleva/core/theme/tokens.dart';

import '../data/payable_record.dart';

/// Shared look of the Records tab and the detail page (change `payable-records`).
Color toneColor(StatusTone t) => switch (t) {
      StatusTone.done => Palette.greenEco,
      StatusTone.waiting => Palette.amberGold,
      StatusTone.rejected => Palette.redDanger,
      StatusTone.other => AppTokens.brandPrimary,
    };

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final c = toneColor(statusTone(status));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(statusLabel(status), style: AppTypography.badgeText(color: c, fontWeight: FontWeight.w700)),
    );
  }
}

class SoftChip extends StatelessWidget {
  const SoftChip({super.key, required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: AppTokens.surfacePage, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 12, color: AppTokens.textMuted), const SizedBox(width: 3)],
        Text(text, style: AppTypography.badgeText(color: AppTokens.textMuted, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.title, this.icon, this.trailing});

  final Widget child;
  final String? title;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppTokens.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTokens.surfaceBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              if (icon != null) ...[Icon(icon, size: 18, color: AppTokens.brandPrimary), const SizedBox(width: 8)],
              Expanded(
                  child: Text(title!,
                      style: AppTypography.bodyLarge(color: AppTokens.textPrimary, fontWeight: FontWeight.w700))),
              if (trailing != null) trailing!,
            ]),
          ),
        child,
      ]),
    );
  }
}
