import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_typography.dart';

import 'ir_format.dart';

class IrStatusBadge extends StatelessWidget {
  const IrStatusBadge({super.key, required this.name, this.colorCode});

  final String name;
  final String? colorCode;

  @override
  Widget build(BuildContext context) {
    final color = IrFormat.statusColor(colorCode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(name.toUpperCase(), style: AppTypography.badgeText(color: color)),
        ],
      ),
    );
  }
}
