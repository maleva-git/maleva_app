import 'package:flutter/material.dart';
import 'package:maleva/core/forwarding_request/forwarding_request_models.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/forwarding_requests/view/forwarding_request_card.dart';

/// Customer Service's view of one of their requests: read-only, with who did each step and when.
class ForwardingRequestDetailPage extends StatelessWidget {
  const ForwardingRequestDetailPage({super.key, required this.request});

  final ForwardingRequest request;

  @override
  Widget build(BuildContext context) {
    final r = request;
    String who(String by, DateTime? at) => by.isEmpty ? '' : '$by · ${forwardingWhen(at)}';
    return MalevaThemeScope(
      child: Scaffold(
        appBar: AppBar(title: Text('${r.formType} · ${r.jobNo}')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Row(children: [
            FormTypeBadge(r.formType),
            const SizedBox(width: 8),
            Expanded(child: StatusSteps(r.status)),
            StatusPill(forwardingStatusLabel(r.status), tone: forwardingTone(r.status)),
          ]),
          const SizedBox(height: 12),
          DetailSection(
            title: 'Job',
            icon: Icons.work_outline,
            child: Column(children: [
              KeyValueRow('Customer', r.customerName),
              KeyValueRow('Vessel', r.vesselName),
              KeyValueRow('Job type', r.jobType),
              KeyValueRow('Estimated', forwardingWhen(r.estimatedDate)),
              KeyValueRow('Requested', who(r.requestedBy, r.requestedDate)),
              if (r.remarks.isNotEmpty) KeyValueRow('Remarks', r.remarks),
            ]),
          ),
          const SizedBox(height: 8),
          DetailSection(
            title: 'Progress',
            icon: Icons.timeline,
            child: Column(children: [
              KeyValueRow('Documents received', r.documentReceived ? who(r.documentReceivedBy, r.documentReceivedDate) : 'Not yet'),
              KeyValueRow('Draft created', r.draftCreated ? who(r.draftCreatedBy, r.draftCreatedDate) : 'Not yet'),
              if (r.draftCNumber.isNotEmpty) KeyValueRow('C Number', r.draftCNumber),
              KeyValueRow('Submitted', r.submitted ? who(r.submittedBy, r.submittedDate) : 'Not yet'),
              if (r.submittedRef.isNotEmpty) KeyValueRow('Registration no', r.submittedRef),
              KeyValueRow('Approved', r.approved ? '${Fmt.ddMMyyyy(r.approvedDate)} · ${r.approvedBy}' : 'Not yet'),
              KeyValueRow('Released', r.released ? who(r.releasedBy, r.releasedDate) : 'Not yet'),
              if (r.releaseNo.isNotEmpty) KeyValueRow('Release number', r.releaseNo),
              if (r.sealBy.isNotEmpty) KeyValueRow('Seal by', r.sealBy),
              if (r.breakSealBy.isNotEmpty) KeyValueRow('Break seal by', r.breakSealBy),
              if (r.cancelled) KeyValueRow('Cancelled', who(r.cancelledBy, r.cancelledDate)),
            ]),
          ),
        ]),
      ),
    );
  }
}
