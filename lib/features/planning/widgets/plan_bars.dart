import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/models/planning_access.dart';

/// "Read-only" / "Editing Plan #n" / "Editing" / "New plan" (`PlanningFilters.tsx:46-72`).
class ModeBadge extends StatelessWidget {
  const ModeBadge({super.key, required this.access, required this.planningNo});

  final PlanningAccess access;
  final String planningNo;

  @override
  Widget build(BuildContext context) {
    final label = access.badge(planningNo);
    final (tone, icon) = !access.canWrite
        ? (StatusTone.neutral, Icons.lock_outline)
        : access.mode == PlanningMode.edit
            ? (StatusTone.warning, Icons.edit_outlined)
            : (StatusTone.primary, Icons.note_add_outlined);
    final pill = StatusPill(label, tone: tone, icon: icon);
    return access.canWrite ? pill : Tooltip(message: access.deniedReason, child: pill);
  }
}

/// The view-only notice (`PlanningList.tsx:225-237`).
class AccessBanner extends StatelessWidget {
  const AccessBanner({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration:
              BoxDecoration(color: context.mc.surface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: context.mc.outline)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.lock_outline, size: 18, color: context.mc.muted),
            const SizedBox(width: 10),
            Expanded(child: Text(viewOnlyBannerText(), style: TextStyle(color: context.mc.muted, fontSize: 14))),
          ]),
        ),
      );
}

/// Total · Unassigned · Assigned · In RTI; a tap filters the list.
class SummaryTiles extends StatelessWidget {
  const SummaryTiles({super.key, required this.state});

  final PlanState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlanCubit>();
    final mc = context.mc;
    Widget tile(TileFilter f, String label, int n, Color? c) => Expanded(
          child: CountTile(
              count: n, label: label, color: c, selected: state.tile == f, onTap: () => cubit.setTile(state.tile == f ? TileFilter.all : f)),
        );
    return Row(children: [
      tile(TileFilter.all, 'Total', state.rows.length, null),
      const SizedBox(width: 8),
      tile(TileFilter.unassigned, 'Unassigned', state.unassignedCount, mc.toneFg(StatusTone.warning)),
      const SizedBox(width: 8),
      tile(TileFilter.assigned, 'Assigned', state.assignedCount, null),
      const SizedBox(width: 8),
      tile(TileFilter.inRti, 'In RTI', state.inRtiCount, mc.toneFg(StatusTone.success)),
    ]);
  }
}

/// Find in the loaded rows: truck, driver, customer, vessel, job no., status.
class FindBar extends StatefulWidget {
  const FindBar({super.key, this.hint = 'Find truck, driver, customer, vessel, job no.'});

  final String hint;

  @override
  State<FindBar> createState() => _FindBarState();
}

class _FindBarState extends State<FindBar> {
  late final TextEditingController _c = TextEditingController(text: context.read<PlanCubit>().state.find);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _c,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: widget.hint,
          suffixIcon: _c.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _c.clear();
                    context.read<PlanCubit>().setFind('');
                    setState(() {});
                  },
                ),
        ),
        onChanged: (v) {
          context.read<PlanCubit>().setFind(v);
          setState(() {});
        },
      );
}

/// "N changes · Save" with the busy state (a second tap is ignored while saving).
class SaveBar extends StatelessWidget {
  const SaveBar({super.key, required this.state, this.alwaysShow = false, this.extra = const []});

  final PlanState state;
  final bool alwaysShow;
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    if (!state.access.canWrite || (!alwaysShow && !state.hasChanges && extra.isEmpty)) return const SizedBox.shrink();
    final n = state.changeCount;
    return StickyActionBar(
      leading: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(state.hasChanges ? '$n ${n == 1 ? 'change' : 'changes'} · not saved' : 'All changes saved',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        if (state.hasChanges) Text('You will be asked before leaving', style: TextStyle(fontSize: 13, color: context.mc.muted)),
      ]),
      actions: [
        ...extra,
        FilledButton(
          onPressed: state.saving || !state.hasChanges ? null : () => context.read<PlanCubit>().save(),
          child: state.saving
              ? const Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text('Saving...'),
                ])
              : const Text('Save'),
        ),
      ],
    );
  }
}

/// The plan's title and its mode badge.
class PlanTitle extends StatelessWidget {
  const PlanTitle({super.key, required this.state});

  final PlanState state;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Text(state.header.planningNo.isEmpty ? 'Planning' : state.header.planningNo,
            maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
          Text(Fmt.planningDateTime(state.header.planningDate), style: TextStyle(fontSize: 13, color: context.mc.muted, fontWeight: FontWeight.w500)),
          ModeBadge(access: state.access, planningNo: state.header.planningNo),
        ]),
      ]);
}
