import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_theme.dart';
import 'package:maleva/core/theme/status_tone.dart';

/// A coloured status pill (dot + text). The tone follows the web's status rules unless given.
class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, this.tone, this.icon, this.showDot = true});

  final String label;
  final StatusTone? tone;
  final IconData? icon;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final t = tone ?? statusToneOf(label);
    final mc = context.mc;
    final fg = mc.toneFg(t);
    return Semantics(
      label: label,
      child: Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: mc.toneBg(t), borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 6)]
          else if (showDot) ...[Container(width: 7, height: 7, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)), const SizedBox(width: 6)],
          Text(label.isEmpty ? '—' : label,
              style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }
}

/// The green RTI badge ("RTI created: X"); tapping opens that RTI when [onTap] is given.
class RtiBadge extends StatelessWidget {
  const RtiBadge(this.rtiNo, {super.key, this.onTap});

  final String rtiNo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pill = StatusPill(rtiNo, tone: StatusTone.success, icon: Icons.receipt_long_outlined);
    if (onTap == null) return Tooltip(message: 'RTI created: $rtiNo', child: pill);
    return Tooltip(
      message: 'RTI created: $rtiNo',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 44), child: Center(widthFactor: 1, child: pill)),
      ),
    );
  }
}
