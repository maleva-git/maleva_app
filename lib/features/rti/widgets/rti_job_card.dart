import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/models/rti_dates.dart';
import 'package:maleva/features/rti/models/rti_job_row.dart';
import 'package:maleva/features/rti/models/rti_rules.dart';
import 'package:maleva/features/rti/widgets/rti_text_field.dart';

/// Asks before a job line goes (`R/components/RTIGrid.tsx:305-321`).
Future<void> confirmDeleteJobRow(BuildContext context, int index) async {
  final bloc = context.read<RtiEntryBloc>();
  final ok = await showConfirm(context,
      title: 'Delete RTI row?', message: 'This line item will be removed from the RTI grid.', confirmLabel: 'Delete', cancelLabel: 'Cancel', destructive: true);
  if (ok) bloc.add(RtiJobRowDeleted(index));
}

/// One job line on the phone: the job, its route and dates, the editable Salary / PPIC /
/// DPIC / PWD, the revise changes, and the not-found error with "Look up again".
class RtiJobCard extends StatelessWidget {
  const RtiJobCard({super.key, required this.index, required this.row, this.changes = const [], this.lookingUp = false});

  final int index;
  final RtiJobRow row;
  final List<RtiReviseChange> changes;
  final bool lookingUp;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RtiEntryBloc>();
    final mc = context.mc;
    final notFound = row.jobNo.trim().isNotEmpty && row.saleOrderMasterRefId <= 0;
    void edit(String column, String v) => bloc.add(RtiJobCellEdited(index, column, v));
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 4, 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Text('${index + 1}.', style: TextStyle(color: mc.muted, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Expanded(child: Text(row.jobNo.isEmpty ? 'Empty row' : row.jobNo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
            if (lookingUp) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            IconButton(tooltip: 'Remove row', icon: const Icon(Icons.delete_outline), onPressed: () => confirmDeleteJobRow(context, index)),
          ]),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (row.customerName.isNotEmpty) Text(row.customerName, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (row.originD.isNotEmpty || row.destinationD.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${row.originD.isEmpty ? '-' : row.originD} → ${row.destinationD.isEmpty ? '-' : row.destinationD}', style: TextStyle(color: mc.muted)),
                ),
              if (row.customerName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Job ${RtiDates.short(row.jobDate)} · P ${RtiDates.short(row.pickupDateD)} · D ${RtiDates.short(row.deliveryDateD)}',
                      style: TextStyle(color: mc.muted, fontSize: 13)),
                ),
              for (final c in changes) RtiChangeLine(change: c),
              if (notFound) ...[
                const SizedBox(height: 8),
                Text(RtiRules.rowNotFound(index, row.jobNo), style: TextStyle(color: context.cs.error, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => bloc.add(RtiJobLookupRequested(index, row.jobNo)), child: const Text('Look up again'))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: context.cs.error, foregroundColor: context.cs.onError),
                      onPressed: () => confirmDeleteJobRow(context, index),
                      child: const Text('Remove row'),
                    ),
                  ),
                ]),
              ],
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: RtiTextField(label: 'Salary', value: row.salary, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: RtiTextField.decimal, onChanged: (v) => edit(RtiJobColumns.salary, v))),
                const SizedBox(width: 10),
                Expanded(child: RtiTextField(label: 'PWD', value: row.pwdType, keyboardType: TextInputType.number, onChanged: (v) => edit(RtiJobColumns.pwdType, v))),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: RtiTextField(label: 'PPIC', value: row.ppic, onChanged: (v) => edit(RtiJobColumns.ppic, v))),
                const SizedBox(width: 10),
                Expanded(child: RtiTextField(label: 'DPIC', value: row.dpic, onChanged: (v) => edit(RtiJobColumns.dpic, v))),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// One revised value: label, was (struck through) → now.
class RtiChangeLine extends StatelessWidget {
  const RtiChangeLine({super.key, required this.change});

  final RtiReviseChange change;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 6, children: [
        Text(change.label.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: mc.muted)),
        Text(change.was.isEmpty ? '—' : change.was, style: TextStyle(color: mc.muted, decoration: TextDecoration.lineThrough)),
        const Text('→'),
        Text(change.now.isEmpty ? '—' : change.now, style: TextStyle(color: mc.toneFg(StatusTone.accent), fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

/// A Job No box with "Look up" (the phone's stand-in for Enter in the grid cell). [row] -1
/// fills the first blank row, or a new one.
class RtiJobNoLookup extends StatefulWidget {
  const RtiJobNoLookup({super.key, required this.row, this.busy = false});

  final int row;
  final bool busy;

  @override
  State<RtiJobNoLookup> createState() => _RtiJobNoLookupState();
}

class _RtiJobNoLookupState extends State<RtiJobNoLookup> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _go() {
    final text = _c.text.trim();
    if (text.isEmpty) return;
    context.read<RtiEntryBloc>().add(RtiJobLookupRequested(widget.row, text));
    _c.clear();
  }

  @override
  Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: TextField(
            controller: _c,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _go(),
            decoration: const InputDecoration(labelText: 'Job No', prefixIcon: Icon(Icons.search)),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 56,
          child: FilledButton(
            onPressed: widget.busy ? null : _go,
            child: widget.busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Look up'),
          ),
        ),
      ]);
}
