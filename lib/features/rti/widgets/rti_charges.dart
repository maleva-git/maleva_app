import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/models/rti_rules.dart';
import 'package:maleva/features/rti/widgets/rti_text_field.dart';

/// The charges of the RTI (`R/components/RTIFormFields.tsx:480-569`): the three toggles,
/// Sleeping, Empty Pickup, Empty Delivery, Add Pickup + count, Add Drop + count and
/// Manpower, each with its live amount.
class RtiChargeFields extends StatelessWidget {
  const RtiChargeFields({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<RtiEntryBloc, RtiEntryState>(
        buildWhen: (a, b) => a.form != b.form,
        builder: (context, s) {
          final f = s.form;
          final c = RtiCharges.of(f);
          void set(RtiForm Function(RtiForm) change) => context.read<RtiEntryBloc>().add(RtiFormChanged(change));
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SwitchRow(label: 'Punctuality', value: f.punctuality, onChanged: (v) => set((x) => x.copyWith(punctuality: v))),
            SwitchRow(label: 'Document Submission', value: f.documentSub, onChanged: (v) => set((x) => x.copyWith(documentSub: v))),
            SwitchRow(label: 'Multiple Pickup Handling', value: f.pckHandling, onChanged: (v) => set((x) => x.copyWith(pckHandling: v))),
            const SizedBox(height: 8),
            _Line(label: 'Sleeping', amount: c.sleeping, child: SegmentedChoice<String>(values: RtiChoices.yesNo, selected: f.sleeping, onChanged: (v) => set((x) => x.copyWith(sleeping: v)))),
            _Line(label: 'Empty Pickup', amount: c.emptyPickup, child: SegmentedChoice<String>(values: RtiChoices.exit, selected: f.exitYN, onChanged: (v) => set((x) => x.copyWith(exitYN: v)))),
            _Line(label: 'Empty Delivery', amount: c.emptyDelivery, child: SegmentedChoice<String>(values: RtiChoices.exit, selected: f.emptyDeliveryYN, onChanged: (v) => set((x) => x.copyWith(emptyDeliveryYN: v)))),
            _Line(
              label: 'Add Pickup',
              amount: c.pickup,
              child: _CountChoice(yes: f.pickup, count: f.pickupCount, onYes: (v) => set((x) => x.copyWith(pickup: v)), onCount: (v) => set((x) => x.copyWith(pickupCount: v))),
            ),
            _Line(
              label: 'Add Drop',
              amount: c.drop,
              child: _CountChoice(yes: f.addDrop, count: f.dropCount, onYes: (v) => set((x) => x.copyWith(addDrop: v)), onCount: (v) => set((x) => x.copyWith(dropCount: v))),
            ),
            _Line(label: 'Manpower', amount: c.manpower, child: SegmentedChoice<String>(values: RtiChoices.manpower, selected: f.manpw, onChanged: (v) => set((x) => x.copyWith(manpw: v)))),
          ]);
        },
      );
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.amount, required this.child});

  final String label;
  final num amount;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
            Text(Fmt.rm(amount), style: TextStyle(fontWeight: FontWeight.w700, color: amount == 0 ? context.mc.muted : null)),
          ]),
          const SizedBox(height: 6),
          child,
        ]),
      );
}

/// YES / NO with the count box shown only for YES (NO clears the count).
class _CountChoice extends StatelessWidget {
  const _CountChoice({required this.yes, required this.count, required this.onYes, required this.onCount});

  final String yes;
  final String count;
  final ValueChanged<String> onYes;
  final ValueChanged<String> onCount;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: SegmentedChoice<String>(values: RtiChoices.yesNo, selected: yes, onChanged: onYes)),
        if (yes == 'YES') ...[
          const SizedBox(width: 10),
          SizedBox(
            width: 96,
            child: RtiTextField(label: 'Count', value: count, hint: '#', keyboardType: TextInputType.number, inputFormatters: RtiTextField.digits, onChanged: onCount),
          ),
        ],
      ]);
}

/// The Charges Summary (`RTIFormFields.tsx:610-662`): each allowance and the total amount.
class RtiChargesSummary extends StatelessWidget {
  const RtiChargesSummary({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<RtiEntryBloc, RtiEntryState>(
        buildWhen: (a, b) => a.form != b.form || a.grid != b.grid,
        builder: (context, s) {
          final c = RtiCharges.of(s.form);
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(child: Text('Total Amount', style: TextStyle(color: context.mc.muted, fontWeight: FontWeight.w700))),
              Text(Fmt.rm(s.total), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ]),
            const Divider(height: 20),
            KeyValueRow('Salary (jobs)', Fmt.rm(s.salaryTotal)),
            KeyValueRow('Sleeping Allowance', Fmt.rm(c.sleeping)),
            KeyValueRow('Empty Pickup', Fmt.rm(c.emptyPickup)),
            KeyValueRow('Empty Delivery', Fmt.rm(c.emptyDelivery)),
            KeyValueRow('Add Pickup', Fmt.rm(c.pickup)),
            KeyValueRow('Add Drop', Fmt.rm(c.drop)),
            KeyValueRow('Manpower', Fmt.rm(c.manpower)),
          ]);
        },
      );
}

/// Remarks and Comments (`RTIFormFields.tsx:592-606`).
class RtiNotesFields extends StatelessWidget {
  const RtiNotesFields({super.key, this.columns = 1});

  final int columns;

  @override
  Widget build(BuildContext context) => BlocBuilder<RtiEntryBloc, RtiEntryState>(
        buildWhen: (a, b) => a.form.remarks != b.form.remarks || a.form.comments != b.form.comments,
        builder: (context, s) {
          void set(RtiForm Function(RtiForm) change) => context.read<RtiEntryBloc>().add(RtiFormChanged(change));
          final remarks = RtiTextField(label: 'Remarks', value: s.form.remarks, hint: 'Internal transport remarks', minLines: 2, maxLines: 4, onChanged: (v) => set((x) => x.copyWith(remarks: v)));
          final comments = RtiTextField(label: 'Comments', value: s.form.comments, hint: 'Driver or operations comments', minLines: 2, maxLines: 4, onChanged: (v) => set((x) => x.copyWith(comments: v)));
          if (columns == 1) return Column(children: [remarks, const SizedBox(height: 12), comments]);
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: remarks), const SizedBox(width: 12), Expanded(child: comments)]);
        },
      );
}
