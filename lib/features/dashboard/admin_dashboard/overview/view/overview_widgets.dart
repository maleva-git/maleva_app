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

/// A number tile on the blue header card.
class KpiTile extends StatelessWidget {
  const KpiTile({super.key, required this.label, required this.body});

  final String label;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: AppTokens.textOnDark.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall(color: AppTokens.textOnDark.withValues(alpha: 0.85))),
        const SizedBox(height: 4),
        body,
      ]),
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
      Text(value, style: AppTypography.display(color: AppTokens.textOnDark, fontWeight: FontWeight.w700)),
      if (alert != null)
        Container(
          margin: const EdgeInsets.only(top: 2),
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

/// A quick-open button: light-blue circle with the icon, the name under it.
class QuickButton extends StatelessWidget {
  const QuickButton({super.key, required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTokens.surfaceCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTokens.surfaceBorder),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(color: AppTokens.brandLight, shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: AppTokens.brandGradientStart),
            ),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall(color: AppTokens.brandDark, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

/// A section: white card (or light blue when [tinted]) with a title and "Open".
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.onOpen,
    this.tinted = false,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback? onOpen;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: tinted ? AppTokens.brandLight : AppTokens.surfaceCard,
        borderRadius: BorderRadius.circular(overviewRadius),
        border: Border.all(color: tinted ? AppTokens.brandMid.withValues(alpha: 0.3) : AppTokens.surfaceBorder),
        boxShadow: tinted
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: AppTokens.brandGradientStart),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.heading3(color: AppTokens.brandDark)),
          ),
          if (onOpen != null)
            InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Open',
                      style: AppTypography.bodySmall(color: AppTokens.brandGradientStart, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_forward, size: 14, color: AppTokens.brandGradientStart),
                ]),
              ),
            ),
        ]),
        const SizedBox(height: 8),
        child,
      ]),
    );
  }
}

/// A row inside a section: text on the left, a pill on the right, a hairline above.
class SectionRow extends StatelessWidget {
  const SectionRow({super.key, required this.text, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTokens.surfaceBorder))),
      child: Row(children: [
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall(color: AppTokens.textPrimary)),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 160), child: trailing!),
        ],
      ]),
    );
  }
}

/// A big count with its words, for the planning and truck-location sections.
class CountLine extends StatelessWidget {
  const CountLine({super.key, required this.count, required this.label, this.color});

  final int count;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text('$count',
              style: AppTypography.heading1(color: color ?? AppTokens.brandDark, fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Flexible(child: Text(label, style: AppTypography.bodySmall(color: AppTokens.textMuted))),
        ]);
  }
}
