import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/models/plan_line.dart';

/// "By truck": each truck's jobs in pickup order (a read-only grouping of the same rows).
class ByTruckView extends StatelessWidget {
  const ByTruckView({super.key, required this.state, required this.rows});

  final PlanState state;
  final List<PlanLine> rows;

  @override
  Widget build(BuildContext context) {
    final lanes = <String, List<PlanLine>>{};
    for (final r in rows) {
      lanes.putIfAbsent(r.truckName.trim().isEmpty ? '' : r.truckName.trim(), () => []).add(r);
    }
    final keys = lanes.keys.toList()..sort((a, b) => a.isEmpty != b.isEmpty ? (a.isEmpty ? 1 : -1) : a.compareTo(b));
    final mc = context.mc;
    return ListView(padding: const EdgeInsets.all(16), children: [
      for (final k in keys)
        () {
          final jobs = [...lanes[k]!]..sort((a, b) => a.sPickupDate.compareTo(b.sPickupDate));
          final first = Fmt.planningDateTime(jobs.first.sPickupDate);
          final last = Fmt.planningDateTime(jobs.last.sDeliveryDate);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DetailSection(
              title: k.isEmpty ? 'Unassigned' : k,
              icon: Icons.local_shipping_outlined,
              trailing: Text('${jobs.length} jobs${first.isNotEmpty ? ' · $first – $last' : ''}', style: TextStyle(color: mc.muted, fontSize: 13)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (k.isEmpty) Text('Needs a truck', style: TextStyle(color: mc.toneFg(StatusTone.warning), fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [for (final r in jobs) _MiniCard(row: r, selected: state.selectedUid == r.uid, showTruck: false)]),
              ]),
            ),
          );
        }(),
    ]);
  }
}

/// "By status": Waiting · Planned · On the road · Done or cancelled, by the status colours.
class ByStatusView extends StatelessWidget {
  const ByStatusView({super.key, required this.state, required this.rows});

  final PlanState state;
  final List<PlanLine> rows;

  @override
  Widget build(BuildContext context) {
    const buckets = [
      ('Waiting', [StatusTone.warning]),
      ('Planned', [StatusTone.primary]),
      ('On the road', [StatusTone.info]),
      ('Done or cancelled', [StatusTone.success, StatusTone.danger, StatusTone.neutral, StatusTone.accent]),
    ];
    final mc = context.mc;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (final b in buckets)
          Expanded(
            child: () {
              final jobs = rows.where((r) => b.$2.contains(statusToneOf(r.status))).toList();
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(color: mc.surface2, borderRadius: BorderRadius.circular(16), border: Border.all(color: mc.outline)),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      StatusPill(b.$1, tone: b.$2.first),
                      const Spacer(),
                      Text('${jobs.length}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ]),
                  ),
                  Expanded(
                    child: ListView(padding: const EdgeInsets.fromLTRB(8, 0, 8, 8), children: [
                      for (final r in jobs)
                        Padding(padding: const EdgeInsets.only(bottom: 8), child: _MiniCard(row: r, selected: state.selectedUid == r.uid)),
                    ]),
                  ),
                ]),
              );
            }(),
          ),
      ]),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.row, required this.selected, this.showTruck = true});

  final PlanLine row;
  final bool selected;
  final bool showTruck;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final noDriver = row.driverName.trim().isEmpty;
    return Material(
      color: selected ? mc.primarySoft : context.cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: selected ? context.cs.primary : mc.outline)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.read<PlanCubit>().selectRow(row.uid),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 200, maxWidth: 260, minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Expanded(child: Text(row.jobNo, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
                if (!showTruck) Text(Fmt.planningDateTime(row.sPickupDate).split(' ').last, style: TextStyle(color: mc.muted, fontSize: 13)),
              ]),
              Text('${row.origin} → ${row.destination}',
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: mc.muted, fontSize: 14)),
              Text(
                showTruck
                    ? '${row.truckName.isEmpty ? 'Unassigned' : row.truckName} · ${noDriver ? 'Unassigned' : row.driverName}'
                    : (noDriver ? 'Unassigned' : row.driverName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: noDriver ? mc.toneFg(StatusTone.warning) : null),
              ),
              if (!showTruck) Padding(padding: const EdgeInsets.only(top: 4), child: StatusPill(row.status)),
            ]),
          ),
        ),
      ),
    );
  }
}
