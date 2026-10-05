import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/view/tablet/board_grid.dart';
import 'package:maleva/features/planning/view/tablet/board_groupings.dart';
import 'package:maleva/features/planning/widgets/filter_form.dart';
import 'package:maleva/features/planning/widgets/plan_bars.dart';
import 'package:maleva/features/planning/widgets/plan_flows.dart';
import 'package:maleva/features/planning/widgets/plan_menu.dart';

enum BoardView { list, byTruck, byStatus }

/// Tablet landscape (over 900 dp): a collapsible filter panel beside the planning board.
/// The board has frozen ✓ / Job No / Truck columns, presets, a List / By truck / By status
/// switch (the groupings are read-only), multi-select and the sticky Save bar.
class TabletBoardView extends StatefulWidget {
  const TabletBoardView({super.key});

  @override
  State<TabletBoardView> createState() => _TabletBoardViewState();
}

class _TabletBoardViewState extends State<TabletBoardView> {
  bool? _panelChoice;

  /// The panel starts open on a wide screen and folded on a narrow one; the user's choice then holds.
  bool get _panel => _panelChoice ?? MediaQuery.sizeOf(context).width >= 1100;
  set _panel(bool v) => _panelChoice = v;
  bool _frozen = true;
  String _preset = 'All';
  BoardView _view = BoardView.list;

  Widget _panelView(BuildContext context, PlanState s) {
    final cubit = context.read<PlanCubit>();
    if (!_panel) {
      return Container(
        width: 64,
        decoration: BoxDecoration(color: context.cs.surface, border: Border(right: BorderSide(color: context.mc.outline))),
        child: Column(children: [
          const SizedBox(height: 8),
          IconButton(tooltip: 'Show filters', onPressed: () => setState(() => _panel = true), icon: const Icon(Icons.tune)),
          IconButton(tooltip: 'Search', onPressed: s.searching ? null : cubit.search, icon: const Icon(Icons.search)),
        ]),
      );
    }
    return Container(
      width: 320,
      decoration: BoxDecoration(color: context.cs.surface, border: Border(right: BorderSide(color: context.mc.outline))),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 0),
          child: Row(children: [
            const Expanded(child: Text('Search & filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800))),
            IconButton(tooltip: 'Collapse filters', onPressed: () => setState(() => _panel = false), icon: const Icon(Icons.chevron_left)),
          ]),
        ),
        const Expanded(child: SingleChildScrollView(padding: EdgeInsets.fromLTRB(16, 8, 16, 16), child: FilterForm())),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => clearFilters(cubit), child: const Text('Clear all'))),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: s.searching ? null : cubit.search,
                icon:
                    s.searching ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search),
                label: const Text('Search'),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<PlanCubit, PlanState>(builder: (context, s) {
        final cubit = context.read<PlanCubit>();
        final visible = s.visibleRows;
        final filters = activeFilters(cubit, s);
        final canWrite = s.access.canWrite;
        final board = s.searching || s.fetchingPlan
            ? const SkeletonList(count: 6)
            : s.rows.isEmpty
                ? const EmptyState(
                    title: 'No jobs on this plan yet',
                    message: 'Search for jobs in the panel, or open a plan by its number.',
                    icon: Icons.local_shipping_outlined)
                : switch (_view) {
                    BoardView.list => BoardGrid(state: s, rows: visible, columns: boardPresets[_preset]!, frozen: _frozen),
                    BoardView.byTruck => ByTruckView(state: s, rows: visible),
                    BoardView.byStatus => ByStatusView(state: s, rows: visible),
                  };
        return Scaffold(
          body: SafeArea(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _panelView(context, s),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 4, 0),
                    child: Row(children: [
                      if (Navigator.of(context).canPop()) const BackButton(),
                      Expanded(child: PlanTitle(state: s)),
                      SegmentedButton<BoardView>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: BoardView.list, label: Text('List')),
                          ButtonSegment(value: BoardView.byTruck, label: Text('By truck')),
                          ButtonSegment(value: BoardView.byStatus, label: Text('By status')),
                        ],
                        selected: {_view},
                        onSelectionChanged: (v) => setState(() => _view = v.first),
                      ),
                      const SizedBox(width: 8),
                      if (MediaQuery.sizeOf(context).width >= 1100)
                        TextButton.icon(
                          onPressed: () => PlanFlows.createAllRti(context),
                          icon: Icon(canWrite ? Icons.layers_outlined : Icons.lock_outline),
                          label: const Text('Create All RTI'),
                        )
                      else
                        IconButton(
                          tooltip: 'Create All RTI',
                          onPressed: () => PlanFlows.createAllRti(context),
                          icon: Icon(canWrite ? Icons.layers_outlined : Icons.lock_outline),
                        ),
                      IconButton(tooltip: 'Refresh', onPressed: cubit.refresh, icon: const Icon(Icons.refresh)),
                      PlanMenuButton(state: s, includeCreateAll: false),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    child: Column(children: [
                      if (!canWrite) ...[const AccessBanner(), const SizedBox(height: 8)],
                      Row(children: [
                        Expanded(flex: 5, child: SummaryTiles(state: s)),
                        const SizedBox(width: 12),
                        const Expanded(flex: 4, child: FindBar(hint: 'Find in results')),
                      ]),
                      if (filters.isNotEmpty) ...[const SizedBox(height: 6), FilterChipsBar(filters: filters, onClearAll: () => clearFilters(cubit))],
                    ]),
                  ),
                  if (_view == BoardView.list && s.rows.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                      child: Row(children: [
                        Text('Columns', style: TextStyle(color: context.mc.muted, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(children: [
                              for (final p in boardPresets.keys)
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(label: Text(p), selected: _preset == p, onSelected: (_) => setState(() => _preset = p)),
                                ),
                              const SizedBox(width: 8),
                              FilterChip(label: const Text('Freeze columns'), selected: _frozen, onSelected: (v) => setState(() => _frozen = v)),
                            ]),
                          ),
                        ),
                        Text('${visible.length} of ${s.rows.length} jobs', style: TextStyle(color: context.mc.muted, fontSize: 13)),
                      ]),
                    ),
                  Expanded(child: board),
                  if (canWrite && s.tickedCount > 0)
                    Material(
                      color: context.mc.surface2,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                        child: Row(children: [
                          Text('${s.tickedCount} selected', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              reverse: true,
                              child: SelectionActions(state: s),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  if (canWrite) SaveBar(state: s, alwaysShow: true),
                ]),
              ),
            ]),
          ),
        );
      });
}
