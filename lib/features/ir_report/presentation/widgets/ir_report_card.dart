import 'package:flutter/material.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';

import '../../domain/entities/ir_report.dart';
import 'ir_format.dart';
import 'ir_status_badge.dart';

/// One incident in the list.
class IrReportCard extends StatelessWidget {
  const IrReportCard({
    super.key,
    required this.report,
    required this.onTap,
    this.onDelete,
    this.deleting = false,
  });

  final IrReport report;
  final VoidCallback onTap;

  /// Null hides the delete button (no delete permission).
  final VoidCallback? onDelete;
  final bool deleting;

  @override
  Widget build(BuildContext context) {
    final reason = report.reason;
    final reporter = report.reporter;

    return Material(
      color: AppTokens.surfaceCard,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: deleting ? null : onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTokens.surfaceCardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IrStatusBadge(
                    name: report.statusName ?? 'Unknown',
                    colorCode: report.statusColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      IrFormat.dateTime(report.irDate),
                      style: AppTypography.bodySmall(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onDelete != null) _deleteButton(),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  report.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.heading3(),
                ),
              ),
              if (reason != null) ...[
                const SizedBox(height: 3),
                Text(
                  reason,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium(),
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _InfoChip(icon: Icons.apartment_rounded, text: report.departmentName),
                  if (report.truckNo != null)
                    _InfoChip(icon: Icons.local_shipping_outlined, text: report.truckNo!),
                  if (report.driverName != null)
                    _InfoChip(icon: Icons.person_outline_rounded, text: report.driverName!),
                  if (report.employeeName != null)
                    _InfoChip(icon: Icons.badge_outlined, text: report.employeeName!),
                  if (report.vesselName != null)
                    _InfoChip(icon: Icons.directions_boat_outlined, text: report.vesselName!),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        reporter.isEmpty ? '' : 'Reported by $reporter',
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall(),
                      ),
                    ),
                    Text(
                      report.actualAmount == null ? '-' : IrFormat.amount(report.actualAmount!),
                      style: AppTypography.heading3(color: AppTokens.brandDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deleteButton() {
    if (deleting) {
      return const Padding(
        padding: EdgeInsets.all(10),
        child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return IconButton(
      tooltip: 'Delete',
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppTokens.statusDanger),
      onPressed: onDelete,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTokens.surfaceChip,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTokens.brandPrimary),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall(color: AppTokens.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
