import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti_assignments/bloc/assignments_bloc.dart';
import 'package:maleva/features/rti_assignments/models/employee_assignment.dart';

/// "Active", hard-coded as React shows it (`EmployeeAssignmentsPage.tsx:418-423`).
class AssignmentStatusPill extends StatelessWidget {
  const AssignmentStatusPill({super.key});

  @override
  Widget build(BuildContext context) => const StatusPill('Active', tone: StatusTone.success);
}

/// The RTI report button of a job (only when it has an RTI number, as React).
class AssignmentReportButton extends StatelessWidget {
  const AssignmentReportButton({super.key, required this.job, required this.busy});

  final EmployeeAssignment job;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    if (job.rtiNumber.isEmpty) return const SizedBox(width: 48);
    return IconButton(
      tooltip: 'View RTI Report',
      color: context.cs.primary,
      onPressed: busy ? null : () => context.read<AssignmentsBloc>().add(AssignmentReportRequested(job)),
      icon: busy
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.picture_as_pdf_outlined),
    );
  }
}

/// One job as a card (phone, tablet portrait): RTI / SO / customer, route and dates, cargo,
/// counts, employee and driver, truck, status and remarks.
class AssignmentCard extends StatelessWidget {
  const AssignmentCard({super.key, required this.job, required this.reportBusy});

  final EmployeeAssignment job;
  final bool reportBusy;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final muted = TextStyle(fontSize: 14, color: mc.muted);
    final small = TextStyle(fontSize: 13, color: mc.muted);
    String d(String v) => EmployeeAssignment.orDash(v);
    Widget fact(String label, String value) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 13, color: mc.muted, fontWeight: FontWeight.w700)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ]);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(d(job.rtiNumber), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
            AssignmentReportButton(job: job, busy: reportBusy),
          ]),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('SO ${d(job.saleOrderNumber)} · ${d(job.customerName)}', style: muted),
          ),
          const SizedBox(height: 8),
          Text('${d(job.originD)} → ${d(job.destinationD)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          Text(
            'Pickup ${EmployeeAssignment.formatDateTime(job.pickupDateD)} · Delivery ${EmployeeAssignment.formatDateTime(job.deliveryDateD)}',
            style: small,
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: mc.surface2, borderRadius: BorderRadius.circular(12)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: fact('Vessel', d(job.vesselNameRaw))),
              Expanded(child: fact('Cargo', '${d(job.commodity)} · ${d(job.quantity)} · ${d(job.truckSize)}')),
              Expanded(child: fact('Pickups · Drops', '${job.pickupCount} · ${job.dropCount}')),
            ]),
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 14, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.person_outline, size: 16, color: mc.muted),
              const SizedBox(width: 6),
              Flexible(child: Text('${d(job.employeeName)} · ${d(job.driverName)}', style: muted, overflow: TextOverflow.ellipsis)),
            ]),
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.local_shipping_outlined, size: 16, color: mc.muted),
              const SizedBox(width: 6),
              Flexible(child: Text('${d(job.truckNumber)} · ${d(job.truckType)}', style: muted, overflow: TextOverflow.ellipsis)),
            ]),
            const AssignmentStatusPill(),
          ]),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text.rich(TextSpan(children: [
              TextSpan(text: 'Remarks: ', style: small.copyWith(fontWeight: FontWeight.w700)),
              TextSpan(
                text: job.remarks.isEmpty ? 'No remarks provided.' : job.remarks,
                style: small.copyWith(fontStyle: job.remarks.isEmpty ? FontStyle.italic : FontStyle.normal),
              ),
            ])),
          ),
        ]),
      ),
    );
  }
}
