import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/plans/bloc/plans_bloc.dart';
import 'package:maleva/features/planning/plans/models/plan_row.dart';
import 'package:maleva/features/planning/plans/view/plans_filter_sheet.dart';
import 'package:maleva/features/planning/plans/widgets/plan_card.dart';
import 'package:maleva/features/planning/plans/widgets/plan_preview.dart';
import 'package:maleva/features/planning/plans/widgets/plans_states.dart';
import 'package:maleva/features/planning/plans/widgets/plans_table.dart';
import 'package:maleva/features/planning/plans/widgets/plans_toolbar.dart';

Widget _preview(BuildContext context, PlansState s) {
  final p = s.selected;
  if (p == null) return const SizedBox.shrink();
  return PlanPreview(
    plan: p,
    reportDate: s.draft.reportDate,
    reportBusy: s.reportBusyId == p.id,
    onOpen: () => openPlanAndRefresh(context, p),
    onReport: p.planningNo.trim().isEmpty ? null : () => context.read<PlansBloc>().add(PlanReportRequested(p)),
  );
}

/// Plans on a tablet held upright: search, chips, the plan list and a preview pane with the
/// plan's jobs, Open plan and Report. The filters open in a side sheet.
class PlansTabletPortraitView extends StatelessWidget {
  const PlansTabletPortraitView({super.key, required this.onNewPlan});

  final VoidCallback onNewPlan;

  @override
  Widget build(BuildContext context) => BlocBuilder<PlansBloc, PlansState>(
        builder: (context, s) => Scaffold(
          appBar: AppBar(
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Plans'),
              Text('Saved plans · ${plansRangeLabel(s.applied.fromDate, s.applied.toDate)}', style: TextStyle(fontSize: 13, color: context.mc.muted)),
            ]),
            actions: [
              PlansFilterButton(label: true, count: s.applied.activeCount(Fmt.today()), onPressed: () => showPlansFilterSheet(context)),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: onNewPlan,
                icon: const Icon(Icons.add),
                label: const Text('New plan'),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 8), child: PlansSearchBar()),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: PlansChips(onOpenFilters: () => showPlansFilterSheet(context)),
            ),
            Divider(height: 1, color: context.mc.outline),
            Expanded(
              child: PlansStateSwitch(
                state: s,
                content: (context) => Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.42,
                    child: _PlanList(state: s),
                  ),
                  VerticalDivider(width: 1, color: context.mc.outline),
                  Expanded(child: _preview(context, s)),
                ]),
              ),
            ),
          ]),
        ),
      );
}

class _PlanList extends StatelessWidget {
  const _PlanList({required this.state});

  final PlansState state;

  @override
  Widget build(BuildContext context) {
    final selected = state.selected;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        child: Text('Rows: ${state.rows.length}', style: TextStyle(color: context.mc.muted, fontWeight: FontWeight.w600)),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: state.rows.length,
          itemBuilder: (context, i) {
            final PlanRow p = state.rows[i];
            return PlanListTile(
              plan: p,
              selected: p.id == selected?.id,
              onTap: () => context.read<PlansBloc>().add(PlanSelected(p.id)),
            );
          },
        ),
      ),
    ]);
  }
}

/// Plans on a tablet held sideways: the filters in a side panel, React's table, and the preview.
class PlansTabletLandscapeView extends StatelessWidget {
  const PlansTabletLandscapeView({super.key, required this.onNewPlan});

  final VoidCallback onNewPlan;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Material(
              color: context.cs.surface,
              child: Container(
                width: 300,
                decoration: BoxDecoration(border: Border(right: BorderSide(color: context.mc.outline))),
                child: const PlansFilterPanel(),
              ),
            ),
            Expanded(
              child: BlocBuilder<PlansBloc, PlansState>(
                builder: (context, s) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                    child: Row(children: [
                      if (Navigator.of(context).canPop()) const BackButton(),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Plans', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                          Text('Total Logs: ${s.rows.length}', style: TextStyle(fontSize: 13, color: context.mc.muted)),
                        ]),
                      ),
                      FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                        onPressed: onNewPlan,
                        icon: const Icon(Icons.add),
                        label: const Text('New plan'),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: PlansStateSwitch(
                      state: s,
                      content: (context) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          Expanded(
                            child: PlansTable(
                              rows: s.rows,
                              selectedId: s.selected?.id,
                              reportBusyId: s.reportBusyId,
                              onSelect: (p) => context.read<PlansBloc>().add(PlanSelected(p.id)),
                              onOpen: (p) => openPlanAndRefresh(context, p),
                              onReport: (p) => context.read<PlansBloc>().add(PlanReportRequested(p)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(width: 340, child: Card(margin: EdgeInsets.zero, child: _preview(context, s))),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      );
}
