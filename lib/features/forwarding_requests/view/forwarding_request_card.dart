import 'package:flutter/material.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_models.dart';
import 'package:maleva/core/widgets/ui/ui.dart';

StatusTone forwardingTone(String status) => switch (status) {
      'REQUESTED' => StatusTone.neutral,
      'DOCUMENTS_RECEIVED' => StatusTone.info,
      'DRAFT_CREATED' => StatusTone.primary,
      'SUBMITTED' => StatusTone.accent,
      'APPROVED' => StatusTone.success,
      'RELEASED' => StatusTone.success,
      'CANCELLED' => StatusTone.danger,
      _ => StatusTone.neutral,
    };

Color formTypeColor(String formType) => switch (formType) {
      'K1' => const Color(0xFF2563EB),
      'K2' => const Color(0xFF059669),
      'K3' => const Color(0xFFF59E0B),
      'K8' => const Color(0xFFDC2626),
      _ => const Color(0xFF64748B),
    };

/// K1 / K2 / K3 / K8 as a small badge, the same colours the web uses.
class FormTypeBadge extends StatelessWidget {
  const FormTypeBadge(this.formType, {super.key});

  final String formType;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: formTypeColor(formType), borderRadius: BorderRadius.circular(8)),
        child: Text(formType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
      );
}

/// Six dots, filled up to the current step; "cancelled" when outside the ladder.
class StatusSteps extends StatelessWidget {
  const StatusSteps(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final reached = forwardingStepIndex(status);
    if (reached < 0) return Text('cancelled', style: TextStyle(fontSize: 11, color: context.mc.toneFg(StatusTone.danger)));
    return Semantics(
      label: forwardingStatusLabel(status),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < forwardingStatusSteps.length; i++)
          Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < reached
                  ? context.mc.toneFg(StatusTone.success)
                  : i == reached
                      ? context.cs.primary
                      : context.mc.outline,
            ),
          ),
      ]),
    );
  }
}

/// One request in the list: job, form, estimate, requester, status; coral when overdue.
class ForwardingRequestCard extends StatelessWidget {
  const ForwardingRequestCard(this.r, {super.key, required this.onTap, this.busy = false});

  final ForwardingRequest r;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final overdue = r.isOverdue();
    final estimate = r.estimatedDate == null ? '—' : '${Fmt.ddMMyyyy(r.estimatedDate)} ${_hm(r.estimatedDate!)}';
    return Card(
      color: overdue ? mc.toneBg(StatusTone.danger) : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: busy ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              FormTypeBadge(r.formType),
              const SizedBox(width: 8),
              Expanded(child: Text(r.jobNo, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15), overflow: TextOverflow.ellipsis)),
              if (busy) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) else StatusPill(forwardingStatusLabel(r.status), tone: forwardingTone(r.status)),
            ]),
            const SizedBox(height: 6),
            if (r.customerName.isNotEmpty || r.vesselName.isNotEmpty)
              Text([r.customerName, r.vesselName].where((s) => s.isNotEmpty).join(' · '),
                  style: TextStyle(color: mc.muted, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.schedule, size: 14, color: overdue ? mc.toneFg(StatusTone.danger) : mc.muted),
              const SizedBox(width: 4),
              Text(estimate, style: TextStyle(fontSize: 13, fontWeight: overdue ? FontWeight.w700 : FontWeight.w500, color: overdue ? mc.toneFg(StatusTone.danger) : null)),
              const Spacer(),
              StatusSteps(r.status),
            ]),
            if (r.draftCNumber.isNotEmpty || r.releaseNo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text([if (r.draftCNumber.isNotEmpty) 'C No ${r.draftCNumber}', if (r.releaseNo.isNotEmpty) 'Release ${r.releaseNo}'].join(' · '),
                  style: TextStyle(fontSize: 12, color: mc.muted, fontFamily: 'monospace')),
            ],
            const SizedBox(height: 2),
            Text('Requested by ${r.requestedBy.isEmpty ? '—' : r.requestedBy}', style: TextStyle(fontSize: 12, color: mc.muted)),
          ]),
        ),
      ),
    );
  }
}

String _hm(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// `dd/MM/yyyy HH:mm` or blank.
String forwardingWhen(DateTime? d) => d == null ? '' : '${Fmt.ddMMyyyy(d)} ${_hm(d)}';
