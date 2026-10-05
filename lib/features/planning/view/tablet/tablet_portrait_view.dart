import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/widgets/assign_picker.dart';
import 'package:maleva/features/planning/widgets/filter_form.dart';
import 'package:maleva/features/planning/widgets/job_card.dart';
import 'package:maleva/features/planning/widgets/job_detail.dart';
import 'package:maleva/features/planning/widgets/plan_bars.dart';
import 'package:maleva/features/planning/widgets/plan_flows.dart';
import 'package:maleva/features/planning/widgets/plan_menu.dart';

/// Tablet portrait (600–900 dp): the jobs (40%, drag to reorder) beside the chosen job's
/// detail with inline assign; the search form slides in from the right.
class TabletPortraitView extends StatelessWidget {
  const TabletPortraitView({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<PlanCubit, PlanState>(builder: (context, s) {
        final cubit = context.read<PlanCubit>();
        final filters = activeFilters(cubit, s);
        final visible = s.visibleRows;
        final selected = s.selected;
        final canWrite = s.access.canWrite;
        final reorderable = canWrite && s.tile == TileFilter.all && s.find.trim().isEmpty;
        return Scaffold(
          endDrawer: Drawer(
            width: 420,
            child: SafeArea(
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
                  child: Row(children: [
                    const Expanded(child: Text('Search & filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                    Builder(builder: (ctx) => IconButton(tooltip: 'Close', onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close))),
                  ]),
                ),
                const Expanded(child: SingleChildScrollView(padding: EdgeInsets.fromLTRB(20, 8, 20, 16), child: FilterForm())),
                Builder(
                  builder: (ctx) => StickyActionBar(actions: [
                    OutlinedButton(onPressed: () => clearFilters(cubit), child: const Text('Clear all')),
                    FilledButton.icon(
                      onPressed: s.searching
                          ? null
                          : () async {
                              await cubit.search();
                              if (ctx.mounted && cubit.state.searchError == null) Navigator.pop(ctx);
                            },
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
          appBar: AppBar(
            title: PlanTitle(state: s),
            actions: [
              Builder(
                builder: (ctx) => TextButton.icon(
                  onPressed: () => Scaffold.of(ctx).openEndDrawer(),
                  icon: const Icon(Icons.tune),
                  label: Text('Filters · ${filters.length}'),
                ),
              ),
              TextButton.icon(
                onPressed: () => PlanFlows.createAllRti(context),
                icon: Icon(canWrite ? Icons.layers_outlined : Icons.lock_outline),
                label: const Text('Create All RTI'),
              ),
              PlanMenuButton(state: s, includeCreateAll: false),
            ],
          ),
          body: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Column(children: [
                if (!canWrite) ...[const AccessBanner(), const SizedBox(height: 8)],
                Row(children: [
                  Expanded(flex: 5, child: SummaryTiles(state: s)),
                  const SizedBox(width: 12),
                  const Expanded(flex: 4, child: FindBar())
                ]),
                if (filters.isNotEmpty) ...[const SizedBox(height: 8), FilterChipsBar(filters: filters, onClearAll: () => clearFilters(cubit))],
              ]),
            ),
            Expanded(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.4,
                  child: RefreshIndicator(
                    onRefresh: cubit.refresh,
                    child: s.searching || s.fetchingPlan
                        ? const SkeletonList(count: 5)
                        : s.rows.isEmpty
                            ? ListView(children: const [
                                SizedBox(height: 80),
                                EmptyState(title: 'No jobs on this plan yet', message: 'Open Filters to search for jobs.')
                              ])
                            : _JobList(state: s, rows: visible, reorderable: reorderable),
                  ),
                ),
                VerticalDivider(width: 1, color: context.mc.outline),
                Expanded(
                  child: selected == null
                      ? const EmptyState(
                          title: 'Pick a job', message: 'Its route, timing, cargo and assignment show here.', icon: Icons.touch_app_outlined)
                      : Column(children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                            child: Row(children: [
                              Expanded(
                                  child: Text('Job ${s.rows.indexOf(selected) + 1} of ${s.rows.length}', style: TextStyle(color: context.mc.muted))),
                              if (canWrite)
                                TextButton(onPressed: () => PlanFlows.updateSaleOrder(context, selected.uid), child: const Text('Update sale order')),
                              RowMenuButton(row: selected, state: s),
                            ]),
                          ),
                          Expanded(child: JobDetailSections(row: selected, state: s)),
                        ]),
                ),
              ]),
            ),
          ]),
          bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
            if (s.tickedCount > 0 && canWrite)
              Material(
                color: context.mc.surface2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                  child: Row(children: [
                    Expanded(child: Text('${s.tickedCount} selected', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
                    SelectionActions(state: s),
                  ]),
                ),
              ),
            SaveBar(state: s, alwaysShow: true),
          ]),
        );
      });
}

class _JobList extends StatelessWidget {
  const _JobList({required this.state, required this.rows, required this.reorderable});

  final PlanState state;
  final List<PlanLine> rows;
  final bool reorderable;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlanCubit>();
    final canWrite = state.access.canWrite;
    Widget item(int i) {
      final r = rows[i];
      return Padding(
        key: ValueKey('tp-${r.uid}'),
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (canWrite) Checkbox(value: r.print, onChanged: (_) => cubit.toggleTick(r.uid), semanticLabel: 'Tick ${r.jobNo}'),
          Expanded(
            child: JobCard(
              row: r,
              state: state,
              compact: true,
              current: state.selectedUid == r.uid,
              onTap: () => cubit.selectRow(r.uid),
              onTruck: canWrite ? () => AssignPicker.truck(context, {r.uid}) : null,
              onDriver: canWrite ? () => AssignPicker.driver(context, {r.uid}) : null,
              onRti: () => PlanFlows.openRti(context, r),
            ),
          ),
          if (reorderable) ReorderableDragStartListener(index: i, child: const SizedBox(width: 40, height: 56, child: Icon(Icons.drag_indicator))),
        ]),
      );
    }

    if (!reorderable) {
      return ListView.builder(padding: const EdgeInsets.only(top: 4, bottom: 24), itemCount: rows.length, itemBuilder: (_, i) => item(i));
    }
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      itemCount: rows.length,
      onReorderItem: cubit.reorder,
      itemBuilder: (_, i) => item(i),
    );
  }
}
