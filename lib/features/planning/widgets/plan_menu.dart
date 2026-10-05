import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/widgets/assign_picker.dart';
import 'package:maleva/features/planning/widgets/plan_flows.dart';

class _Item {
  const _Item(this.label, this.icon, this.run, {this.locked = false, this.danger = false});

  final String label;
  final IconData icon;
  final Future<void> Function() run;

  /// The role may not: the item shows a lock and a tap says why (`WriteActionButton`).
  final bool locked;
  final bool danger;
}

PopupMenuItem<_Item> _entry(BuildContext context, _Item i) {
  final color = i.danger && !i.locked ? context.cs.error : null;
  return PopupMenuItem<_Item>(
    value: i,
    child: Row(children: [
      Icon(i.locked ? Icons.lock_outline : i.icon, color: i.locked ? context.mc.faint : color),
      const SizedBox(width: 12),
      Text(i.label, style: TextStyle(color: i.locked ? context.mc.faint : color)),
    ]),
  );
}

Future<void> _run(BuildContext context, _Item i, String deniedReason) async {
  if (i.locked) {
    context.read<PlanCubit>().notify(deniedReason, NoticeKind.error);
    return;
  }
  await i.run();
}

/// The plan's ⋮ menu: what the web's header buttons do that has no place of its own.
class PlanMenuButton extends StatelessWidget {
  const PlanMenuButton({super.key, required this.state, this.includeCreateAll = true});

  final PlanState state;
  final bool includeCreateAll;

  @override
  Widget build(BuildContext context) {
    final a = state.access;
    final items = [
      _Item('New plan', Icons.note_add_outlined, () => PlanFlows.newPlan(context)),
      _Item('Plans', Icons.list_alt, () => PlanFlows.openPlans(context)),
      _Item('Refresh', Icons.refresh, () => context.read<PlanCubit>().refresh()),
      _Item('Sort', Icons.swap_vert, () async => context.read<PlanCubit>().sort(), locked: !a.canWrite),
      if (includeCreateAll) _Item('Create All RTI', Icons.layers_outlined, () => PlanFlows.createAllRti(context), locked: !a.canWrite),
      _Item('Export CSV', Icons.download_outlined, () => PlanFlows.exportCsv(context)),
      _Item('Truck Location', Icons.place_outlined, () => PlanFlows.truckLocation(context)),
      _Item('Delete plan', Icons.delete_outline, () => PlanFlows.deletePlan(context), locked: !a.canDelete, danger: true),
    ];
    return PopupMenuButton<_Item>(
      tooltip: 'More actions',
      icon: const Icon(Icons.more_vert),
      itemBuilder: (ctx) => [for (final i in items) _entry(ctx, i)],
      onSelected: (i) => _run(context, i, i.label == 'Delete plan' ? a.deleteDeniedReason : a.deniedReason),
    );
  }
}

/// A row's ⋮ menu: Clone, Update sale order, Open / Revise RTI, Copy, Remove.
class RowMenuButton extends StatelessWidget {
  const RowMenuButton({super.key, required this.row, required this.state});

  final PlanLine row;
  final PlanState state;

  @override
  Widget build(BuildContext context) {
    final a = state.access;
    final items = [
      _Item('Duplicate row', Icons.copy_all_outlined, () => PlanFlows.clone(context, row.uid), locked: !a.canWrite),
      _Item('Update sale order', Icons.edit_calendar_outlined, () => PlanFlows.updateSaleOrder(context, row.uid), locked: !a.canWrite),
      if (row.rtiNo.isNotEmpty) ...[
        _Item('Open RTI', Icons.receipt_long_outlined, () => PlanFlows.openRti(context, row)),
        _Item('Revise RTI', Icons.published_with_changes, () => PlanFlows.reviseRti(context, row), locked: !a.canWrite),
      ],
      if (a.canWrite) ...[
        _Item('Move to top', Icons.vertical_align_top, () async {
          final i = state.rows.indexWhere((r) => r.uid == row.uid);
          if (i > 0) context.read<PlanCubit>().reorder(i, 0);
        }),
        _Item('Move up', Icons.arrow_upward, () async {
          final i = state.rows.indexWhere((r) => r.uid == row.uid);
          if (i > 0) context.read<PlanCubit>().reorder(i, i - 1);
        }),
        _Item('Move down', Icons.arrow_downward, () async {
          final i = state.rows.indexWhere((r) => r.uid == row.uid);
          if (i >= 0 && i < state.rows.length - 1) context.read<PlanCubit>().reorder(i, i + 1);
        }),
        _Item('Move to bottom', Icons.vertical_align_bottom, () async {
          final i = state.rows.indexWhere((r) => r.uid == row.uid);
          if (i >= 0 && i < state.rows.length - 1) context.read<PlanCubit>().reorder(i, state.rows.length - 1);
        }),
      ],
      _Item('Copy job no.', Icons.content_copy, () => PlanFlows.copy(context, row.jobNo)),
      _Item('Remove from plan', Icons.delete_outline, () => PlanFlows.remove(context, row.uid), locked: !a.canWrite, danger: true),
    ];
    return PopupMenuButton<_Item>(
      tooltip: 'Actions for ${row.jobNo}',
      icon: const Icon(Icons.more_vert),
      itemBuilder: (ctx) => [for (final i in items) _entry(ctx, i)],
      onSelected: (i) {
        context.read<PlanCubit>().selectRow(row.uid);
        _run(context, i, a.deniedReason);
      },
    );
  }
}

/// Truck or driver for the ticked jobs (the phone's Assign, the board's Assign).
Future<void> chooseAssign(BuildContext context, Set<int> uids) async {
  final cubit = context.read<PlanCubit>();
  if (uids.isEmpty || !cubit.guardWrite()) return;
  final which = await showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    builder: (ctx) => MalevaThemeScope(
      child: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child:
                Text('Assign · ${uids.length} job${uids.length == 1 ? '' : 's'}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          ListTile(leading: const Icon(Icons.local_shipping_outlined), title: const Text('Truck'), onTap: () => Navigator.pop(ctx, 'truck')),
          ListTile(leading: const Icon(Icons.person_outline), title: const Text('Driver'), onTap: () => Navigator.pop(ctx, 'driver')),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Text('Only the jobs you chose change.', style: TextStyle(color: ctx.mc.muted)),
          ),
        ]),
      ),
    ),
  );
  if (!context.mounted) return;
  if (which == 'truck') {
    await AssignPicker.truck(context, uids);
  } else if (which == 'driver') {
    await AssignPicker.driver(context, uids);
  }
}

/// The ticked jobs' actions: Assign, Create RTI, Push RTI, and for one job Clone / Update / Remove.
class SelectionActions extends StatelessWidget {
  const SelectionActions({super.key, required this.state, this.compact = false});

  final PlanState state;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ticked = state.ticked;
    final uids = {for (final r in ticked) r.uid};
    final none = ticked.isEmpty;
    final single = ticked.length == 1 ? ticked.first : null;
    final locked = !state.access.canWrite;
    void deny() => context.read<PlanCubit>().notify(state.access.deniedReason, NoticeKind.error);
    Widget grow(Widget w) => compact ? Expanded(child: w) : w;
    return Row(mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min, children: [
      grow(FilledButton.icon(
        onPressed: none ? null : (locked ? deny : () => chooseAssign(context, uids)),
        icon: Icon(locked ? Icons.lock_outline : Icons.local_shipping_outlined),
        label: const Text('Assign'),
      )),
      const SizedBox(width: 8),
      grow(OutlinedButton(onPressed: none ? null : () => PlanFlows.createRti(context), child: const Text('Create RTI'))),
      if (!compact) ...[
        const SizedBox(width: 8),
        OutlinedButton(onPressed: none ? null : () => PlanFlows.pushRti(context), child: const Text('Push RTI')),
      ],
      PopupMenuButton<String>(
        tooltip: 'More for selected jobs',
        icon: const Icon(Icons.more_vert),
        itemBuilder: (_) => [
          if (compact) const PopupMenuItem(value: 'push', child: Text('Push RTI')),
          const PopupMenuItem(value: 'clone', child: Text('Clone')),
          const PopupMenuItem(value: 'update', child: Text('Update sale order')),
          const PopupMenuItem(value: 'remove', child: Text('Remove')),
          const PopupMenuItem(value: 'clear', child: Text('Clear ticks')),
        ],
        onSelected: (v) {
          final cubit = context.read<PlanCubit>();
          switch (v) {
            case 'push':
              PlanFlows.pushRti(context);
            case 'clone':
              if (single == null) {
                cubit.notify('Please select a row to duplicate', NoticeKind.error);
              } else {
                PlanFlows.clone(context, single.uid);
              }
            case 'update':
              if (single == null) {
                cubit.notify('Please select a row first', NoticeKind.error);
              } else {
                PlanFlows.updateSaleOrder(context, single.uid);
              }
            case 'remove':
              if (single != null) PlanFlows.remove(context, single.uid);
              if (single == null) cubit.notify('Please select a row first', NoticeKind.error);
            case 'clear':
              cubit.clearTicks();
          }
        },
      ),
    ]);
  }
}
