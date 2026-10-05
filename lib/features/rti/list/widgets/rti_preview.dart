import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/dashboard/common_tabs/rtistatus/view/rtistatus_tab.dart';
import 'package:maleva/features/rti/list/bloc/rti_list_bloc.dart';
import 'package:maleva/features/rti/list/models/rti_list_row.dart';
import 'package:maleva/features/rti/list/widgets/rti_actions.dart';

/// The RTI preview (`RTIDetailPanel`, `RTIViewPage.tsx:749-848`): Driver, Vehicle, Date,
/// Amount, Destination, Remarks (from the full RTI), up to 10 jobs `JobNo · CustomerName`
/// ("+n more"), Edit, Report, Share, Close.
class RtiPreview extends StatelessWidget {
  const RtiPreview({super.key, required this.row, required this.state, this.onClose});

  final RtiListRow row;
  final RtiListState state;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final preview = state.preview;
    final loading = preview?.loading ?? true;
    final data = preview?.data;
    final jobs = data?.jobs ?? row.jobs.where((j) => j.jobNo.isNotEmpty).toList();
    final label = TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: mc.muted);
    Widget item(String l, String v) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l, style: label),
          const SizedBox(height: 2),
          Text(v.trim().isEmpty ? '-' : v, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ]);
    final bloc = context.read<RtiListBloc>();
    final hasNo = rtiHasNumber(row);
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(row.rtiNo.isEmpty ? 'RTI Details' : row.rtiNo, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            Text(row.longDateText, style: TextStyle(color: mc.muted)),
          ]),
        ),
        Text(row.amountText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        if (onClose != null) IconButton(tooltip: 'Close preview', onPressed: onClose, icon: const Icon(Icons.close)),
      ]),
      const SizedBox(height: 12),
      if (loading)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            Text('Loading details...', style: TextStyle(color: mc.muted)),
          ]),
        )
      else ...[
        LayoutBuilder(builder: (context, c) {
          final w = (c.maxWidth - 12) / 2;
          return Wrap(spacing: 12, runSpacing: 12, children: [
            SizedBox(width: w, child: item('DRIVER', row.driverName)),
            SizedBox(width: w, child: item('VEHICLE', row.truckName)),
            SizedBox(width: w, child: item('DATE', row.longDateText)),
            SizedBox(width: w, child: item('AMOUNT', row.amountText)),
            SizedBox(width: w, child: item('DESTINATION', data?.destination ?? '')),
            SizedBox(width: c.maxWidth, child: item('REMARKS', data?.remarks ?? '')),
          ]);
        }),
        if (jobs.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('JOB LINES (${jobs.length})', style: label),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final j in jobs.take(10))
              _JobChip(
                // A driver sends a job's pickup / delivery status from here (the old Update RTI long-press).
                onTap: state.isDriver
                    ? () => Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => RTIStatusPage(rtiDetails: [
                              {'RtiId': row.id, 'RTINo': row.rtiNo, 'JobId': j.saleOrderId, 'JobNo': j.jobNo},
                            ])))
                    : null,
                child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: mc.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: mc.outline),
                ),
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: j.jobNo, style: TextStyle(fontWeight: FontWeight.w800, color: context.cs.primary)),
                  if (j.customerName.isNotEmpty) TextSpan(text: ' · ${j.customerName}', style: TextStyle(color: mc.muted)),
                ])),
              )),
            if (jobs.length > 10)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('+${jobs.length - 10} more', style: TextStyle(color: mc.muted, fontWeight: FontWeight.w700)),
              ),
          ]),
        ],
      ],
      const SizedBox(height: 18),
      Wrap(spacing: 8, runSpacing: 8, children: [
        if (!state.isDriver)
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size(120, 48)),
            onPressed: () => openRtiEdit(context, row.id),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit'),
          ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
          onPressed: !hasNo || state.reportBusyId == row.id ? null : () => bloc.add(RtiReportRequested(row)),
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Report'),
        ),
        if (!state.isDriver)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
            onPressed: !hasNo || state.shareBusyId == row.id ? null : () => confirmAndShareRti(context, row),
            icon: const Icon(Icons.send_outlined),
            label: const Text('Share'),
          ),
      ]),
    ]);
  }
}

class _JobChip extends StatelessWidget {
  const _JobChip({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => onTap == null
      ? child
      : Semantics(
          button: true,
          hint: 'Send job status',
          child: InkWell(borderRadius: BorderRadius.circular(10), onTap: onTap, child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 44), child: child)),
        );
}
