import 'package:flutter/material.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/plans/models/plan_row.dart';
import 'package:maleva/features/planning/plans/widgets/plan_card.dart';

/// The tablet's preview pane: the plan, Open plan, Report (with the Report Date), and the
/// plan's jobs (from the same select-planning answer).
class PlanPreview extends StatelessWidget {
  const PlanPreview({
    super.key,
    required this.plan,
    required this.reportDate,
    required this.onOpen,
    required this.onReport,
    this.reportBusy = false,
  });

  final PlanRow plan;
  final DateTime reportDate;
  final VoidCallback onOpen;
  final VoidCallback? onReport;
  final bool reportBusy;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            PlanSummary(plan),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              FilledButton.icon(
                style: FilledButton.styleFrom(minimumSize: const Size(160, 48)),
                onPressed: onOpen,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Open plan'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: reportBusy ? null : onReport,
                icon: reportBusy
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.picture_as_pdf_outlined),
                label: Text('Report · ${Fmt.ddMMyyyy(reportDate).substring(0, 5)}'),
              ),
            ]),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
        child: Text('JOBS ON THIS PLAN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.9, color: mc.muted)),
      ),
      if (plan.jobs.isEmpty)
        Padding(padding: const EdgeInsets.all(4), child: Text('No jobs', style: TextStyle(color: mc.muted)))
      else
        for (final j in plan.jobs)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: mc.outline))),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(j.jobNo.isEmpty ? '-' : j.jobNo, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(
                    [j.customerName, j.truckName, j.driverName].where((s) => s.trim().isNotEmpty).join(' · '),
                    style: TextStyle(fontSize: 13, color: mc.muted),
                  ),
                ]),
              ),
              if (j.rtiNo.trim().isNotEmpty) ...[RtiBadge(j.rtiNo), const SizedBox(width: 6)],
              if (j.jobStatus.trim().isNotEmpty) StatusPill(j.jobStatus, tone: statusToneOf(j.jobStatus)),
            ]),
          ),
    ]);
  }
}
