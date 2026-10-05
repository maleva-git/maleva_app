import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/widgets/job_detail.dart';
import 'package:maleva/features/planning/widgets/plan_flows.dart';
import 'package:maleva/features/planning/widgets/plan_menu.dart';

/// One job, full screen on the phone: the six sections, Assign / Update sale order, and Save
/// while there are changes.
class PhoneJobPage extends StatelessWidget {
  const PhoneJobPage({super.key, required this.uid});

  final int uid;

  @override
  Widget build(BuildContext context) => BlocBuilder<PlanCubit, PlanState>(builder: (context, s) {
        final row = s.rows.where((r) => r.uid == s.selectedUid).firstOrNull ?? s.rows.where((r) => r.uid == uid).firstOrNull;
        if (row == null) {
          // the row was removed (or the plan changed): back to the plan
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }
        final index = s.rows.indexOf(row);
        final canWrite = s.access.canWrite;
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Job ${index + 1} of ${s.rows.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text('${s.header.planningNo} · ${Fmt.planningDateTime(s.header.planningDate)}',
                  style: TextStyle(fontSize: 13, color: context.mc.muted, fontWeight: FontWeight.w500)),
            ]),
            actions: [RowMenuButton(row: row, state: s)],
          ),
          body: JobDetailSections(row: row, state: s),
          bottomNavigationBar: !canWrite
              ? null
              : _BottomActions(
                  children: s.hasChanges
                      ? [
                          Expanded(
                            child: FilledButton(
                              onPressed: s.saving ? null : () => context.read<PlanCubit>().save(),
                              child: Text(s.saving ? 'Saving...' : 'Save · ${s.changeCount} ${s.changeCount == 1 ? 'change' : 'changes'}'),
                            ),
                          ),
                        ]
                      : [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => chooseAssign(context, {row.uid}),
                              icon: const Icon(Icons.local_shipping_outlined),
                              label: const Text('Assign'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                              child: OutlinedButton(
                                  onPressed: () => PlanFlows.updateSaleOrder(context, row.uid), child: const Text('Update sale order'))),
                        ],
                ),
        );
      });
}

/// Full-width buttons above the system inset.
class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Material(
        color: context.cs.surface,
        child: DecoratedBox(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: context.mc.outline))),
          child: SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 12), child: Row(children: children))),
        ),
      );
}
