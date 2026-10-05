import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/plans/bloc/plans_bloc.dart';
import 'package:maleva/features/planning/plans/view/plans_filter_sheet.dart';
import 'package:maleva/features/planning/plans/widgets/plan_card.dart';
import 'package:maleva/features/planning/plans/widgets/plans_states.dart';
import 'package:maleva/features/planning/plans/widgets/plans_toolbar.dart';

/// Plans on a phone: search bar + filter sheet, chips, "Rows: n", plan cards.
class PlansPhoneView extends StatelessWidget {
  const PlansPhoneView({super.key, required this.onNewPlan});

  final VoidCallback onNewPlan;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Plans'),
          actions: [IconButton(tooltip: 'New plan', onPressed: onNewPlan, icon: const Icon(Icons.add))],
        ),
        body: BlocBuilder<PlansBloc, PlansState>(
          builder: (context, s) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(children: [
                const Expanded(child: PlansSearchBar()),
                const SizedBox(width: 8),
                PlansFilterButton(count: s.applied.activeCount(Fmt.today()), onPressed: () => showPlansFilterSheet(context)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: PlansChips(onOpenFilters: () => showPlansFilterSheet(context)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
              child: Text('Rows: ${s.rows.length}', style: TextStyle(color: context.mc.muted, fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => context.read<PlansBloc>().add(const PlansRefreshed()),
                child: PlansStateSwitch(
                  state: s,
                  content: (context) => ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
                    itemCount: s.rows.length,
                    itemBuilder: (context, i) {
                      final p = s.rows[i];
                      return PlanCard(
                        plan: p,
                        reportBusy: s.reportBusyId == p.id,
                        onOpen: () => openPlanAndRefresh(context, p),
                        onReport: p.planningNo.trim().isEmpty ? null : () => context.read<PlansBloc>().add(PlanReportRequested(p)),
                      );
                    },
                  ),
                ),
              ),
            ),
          ]),
        ),
      );
}
