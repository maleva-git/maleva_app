import 'package:flutter/material.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/list/bloc/rti_list_bloc.dart';
import 'package:maleva/features/rti/list/models/rti_list_row.dart';
import 'package:maleva/features/rti/list/widgets/rti_actions.dart';

/// The RTI's facts: number and amount, date, driver, truck, remarks, "No salary", job count.
class RtiSummary extends StatelessWidget {
  const RtiSummary(this.row, {super.key});

  final RtiListRow row;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final muted = TextStyle(color: mc.muted, fontSize: 14);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Text(row.rtiNo.isEmpty ? '-' : row.rtiNo,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
        ),
        Text(row.amountText,
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: row.salaryMissing ? mc.toneFg(StatusTone.warning) : context.cs.onSurface)),
      ]),
      const SizedBox(height: 6),
      Wrap(spacing: 14, runSpacing: 4, children: [
        _Fact(Icons.calendar_today_outlined, row.dateText, muted),
        _Fact(Icons.person_outline, row.driverName.isEmpty ? '-' : row.driverName, muted),
        _Fact(Icons.local_shipping_outlined, row.truckName.isEmpty ? '-' : row.truckName, muted),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
          child: Text(row.remarks.trim().isEmpty ? '—' : row.remarks,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
        ),
        if (row.salaryMissing) ...[
          const StatusPill('No salary', tone: StatusTone.warning, showDot: false),
          const SizedBox(width: 6),
        ],
        StatusPill('${row.jobs.length} jobs', tone: StatusTone.neutral, showDot: false),
      ]),
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

/// An RTI on the phone: tap previews it; Report · Share · Edit below.
class RtiCard extends StatelessWidget {
  const RtiCard({super.key, required this.row, required this.state, required this.onPreview});

  final RtiListRow row;
  final RtiListState state;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          InkWell(onTap: onPreview, child: Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 12), child: RtiSummary(row))),
          Divider(height: 1, color: context.mc.outline),
          RtiCardActions(row: row, state: state),
        ]),
      );
}

/// An RTI in the tablet's list: tap previews it, double tap edits (React's double-click).
class RtiListTile extends StatelessWidget {
  const RtiListTile({super.key, required this.row, required this.selected, required this.onTap, this.onDoubleTap});

  final RtiListRow row;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;

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
          onDoubleTap: onDoubleTap,
          child: Semantics(selected: selected, child: Padding(padding: const EdgeInsets.all(14), child: RtiSummary(row))),
        ),
      ),
    );
  }
}
