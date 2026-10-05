import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/view/phone/phone_job_page.dart';
import 'package:maleva/features/planning/widgets/assign_picker.dart';
import 'package:maleva/features/planning/widgets/filter_form.dart';
import 'package:maleva/features/planning/widgets/job_card.dart';
import 'package:maleva/features/planning/widgets/plan_bars.dart';
import 'package:maleva/features/planning/widgets/plan_flows.dart';
import 'package:maleva/features/planning/widgets/plan_menu.dart';

/// The plan on a phone: summary tiles, find bar, filter chips and job cards; long press or the
/// select button starts multi-select; changes wait in the sticky Save bar.
class PhonePlanView extends StatefulWidget {
  const PhonePlanView({super.key});

  @override
  State<PhonePlanView> createState() => _PhonePlanViewState();
}

class _PhonePlanViewState extends State<PhonePlanView> {
  bool _selecting = false;

  Future<void> _openFilters(BuildContext context) async {
    final cubit = context.read<PlanCubit>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (ctx) => MalevaThemeScope(
        child: BlocProvider.value(
          value: cubit,
          child: SizedBox(
            height: MediaQuery.sizeOf(ctx).height * 0.9,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
                child: Row(children: [
                  const Expanded(child: Text('Search & filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
                  IconButton(tooltip: 'Close', onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                ]),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 16 + MediaQuery.viewInsetsOf(ctx).bottom),
                  child: const FilterForm(),
                ),
              ),
              BlocBuilder<PlanCubit, PlanState>(
                builder: (ctx, s) => StickyActionBar(actions: [
                  OutlinedButton(onPressed: () => clearFilters(cubit), child: const Text('Clear all')),
                  FilledButton.icon(
                    onPressed: s.searching
                        ? null
                        : () async {
                            await cubit.search();
                            if (ctx.mounted && cubit.state.searchError == null) Navigator.pop(ctx);
                          },
                    icon: s.searching
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.search),
                    label: const Text('Search'),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _openJob(BuildContext context, PlanLine row) {
    final cubit = context.read<PlanCubit>();
    cubit.selectRow(row.uid);
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => MalevaThemeScope(child: BlocProvider.value(value: cubit, child: PhoneJobPage(uid: row.uid))),
    ));
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<PlanCubit, PlanState>(builder: (context, s) {
        final cubit = context.read<PlanCubit>();
        final visible = s.visibleRows;
        final filters = activeFilters(cubit, s);
        final canWrite = s.access.canWrite;
        final selecting = _selecting && canWrite;
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: PlanTitle(state: s),
            actions: [
              IconButton(
                tooltip: 'Search and filters, ${filters.length} active',
                onPressed: () => _openFilters(context),
                icon: Badge(isLabelVisible: filters.isNotEmpty, label: Text('${filters.length}'), child: const Icon(Icons.tune)),
              ),
              if (canWrite)
                IconButton(
                  tooltip: selecting ? 'Done selecting' : 'Select jobs',
                  onPressed: () => setState(() => _selecting = !_selecting),
                  icon: Icon(selecting ? Icons.check_box : Icons.check_box_outlined),
                ),
              PlanMenuButton(state: s),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: cubit.refresh,
            child: CustomScrollView(slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                sliver: SliverList.list(children: [
                  if (!canWrite) ...[const AccessBanner(), const SizedBox(height: 10)],
                  if (filters.isNotEmpty) ...[FilterChipsBar(filters: filters, onClearAll: () => clearFilters(cubit)), const SizedBox(height: 8)],
                  SummaryTiles(state: s),
                  const SizedBox(height: 10),
                  const FindBar(),
                  const SizedBox(height: 8),
                  Text('Showing ${visible.length} of ${s.rows.length} jobs${s.tickedCount > 0 ? ' · ${s.tickedCount} selected' : ''}',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.mc.muted)),
                ]),
              ),
              if (s.searching || s.fetchingPlan)
                const SliverFillRemaining(child: SkeletonList(count: 4))
              else if (s.rows.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    title: 'No jobs on this plan yet',
                    message: 'Search for jobs to plan, or open a plan by its number.',
                    icon: Icons.local_shipping_outlined,
                    actionLabel: 'Search & filters',
                    onAction: () => _openFilters(context),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final r = visible[i];
                      final card = JobCard(
                        row: r,
                        state: s,
                        selecting: selecting,
                        onTap: selecting ? () => cubit.toggleTick(r.uid) : () => _openJob(context, r),
                        onLongPress: canWrite
                            ? () {
                                setState(() => _selecting = true);
                                cubit.toggleTick(r.uid);
                              }
                            : null,
                        onTruck: canWrite ? () => AssignPicker.truck(context, {r.uid}) : null,
                        onDriver: canWrite ? () => AssignPicker.driver(context, {r.uid}) : null,
                        onRti: () => PlanFlows.openRti(context, r),
                      );
                      if (!canWrite || selecting) return card;
                      return Dismissible(
                        key: ValueKey('swipe-${r.uid}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(color: context.mc.dangerSoft, borderRadius: BorderRadius.circular(16)),
                          child: Icon(Icons.delete_outline, color: context.cs.error),
                        ),
                        confirmDismiss: (_) async {
                          await PlanFlows.remove(context, r.uid);
                          return false;
                        },
                        child: card,
                      );
                    },
                  ),
                ),
            ]),
          ),
          bottomNavigationBar: selecting
              ? Material(
                  color: context.cs.surface,
                  child: DecoratedBox(
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: context.mc.outline))),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 8, 12),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Row(children: [
                            Expanded(child: Text('${s.tickedCount} selected', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
                            TextButton(onPressed: () => setState(() => _selecting = false), child: const Text('Done')),
                          ]),
                          SelectionActions(state: s, compact: true),
                        ]),
                      ),
                    ),
                  ),
                )
              : SaveBar(state: s),
        );
      });
}
