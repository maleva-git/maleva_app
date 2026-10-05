import 'package:flutter/material.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/plans/models/plan_row.dart';

/// "{n} orders", as React's Total Orders column shows it.
class PlanOrdersBadge extends StatelessWidget {
  const PlanOrdersBadge(this.count, {super.key});

  final int count;

  @override
  Widget build(BuildContext context) => StatusPill('$count orders', tone: StatusTone.neutral, showDot: false);
}

/// The plan's facts: number, orders, date, employee, id and remarks.
class PlanSummary extends StatelessWidget {
  const PlanSummary(this.plan, {super.key});

  final PlanRow plan;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final muted = TextStyle(color: mc.muted, fontSize: 14);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Text(plan.planningNo.isEmpty ? '-' : plan.planningNo,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
        ),
        PlanOrdersBadge(plan.totalOrders),
      ]),
      const SizedBox(height: 6),
      Wrap(spacing: 14, runSpacing: 4, children: [
        _Fact(Icons.calendar_today_outlined, plan.planningDate.isEmpty ? '-' : plan.planningDate, muted),
        _Fact(Icons.person_outline, plan.employeeName.isEmpty ? '-' : plan.employeeName, muted),
        Text('#${plan.id}', style: muted),
      ]),
      if (plan.remarks.trim().isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(plan.remarks, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15)),
      ],
    ]);
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.icon, this.text, this.style);

  final IconData icon;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: style.color),
        const SizedBox(width: 6),
        Flexible(child: Text(text, style: style, overflow: TextOverflow.ellipsis)),
      ]);
}

/// A plan on the phone: tap opens it; Report and Edit below.
class PlanCard extends StatelessWidget {
  const PlanCard({super.key, required this.plan, required this.onOpen, required this.onReport, this.reportBusy = false});

  final PlanRow plan;
  final VoidCallback onOpen;
  final VoidCallback? onReport;
  final bool reportBusy;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final primary = context.cs.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        InkWell(onTap: onOpen, child: Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 12), child: PlanSummary(plan))),
        Divider(height: 1, color: mc.outline),
        Row(children: [
          Expanded(
            child: TextButton.icon(
              style: TextButton.styleFrom(minimumSize: const Size(0, 48), foregroundColor: primary),
              onPressed: reportBusy ? null : onReport,
              icon: reportBusy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('Report'),
            ),
          ),
          SizedBox(height: 48, child: VerticalDivider(width: 1, color: mc.outline)),
          Expanded(
            child: TextButton.icon(
              style: TextButton.styleFrom(minimumSize: const Size(0, 48), foregroundColor: primary),
              onPressed: onOpen,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit'),
            ),
          ),
        ]),
      ]),
    );
  }
}

/// A plan in the tablet's list: tap previews it.
class PlanListTile extends StatelessWidget {
  const PlanListTile({super.key, required this.plan, required this.selected, required this.onTap});

  final PlanRow plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? mc.primarySoft : context.cs.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: selected ? context.cs.primary : mc.outline, width: selected ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Semantics(selected: selected, child: Padding(padding: const EdgeInsets.all(14), child: PlanSummary(plan))),
        ),
      ),
    );
  }
}
