import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/data/planning_rules.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/widgets/assign_picker.dart';
import 'package:maleva/features/planning/widgets/job_card.dart';
import 'package:maleva/features/planning/widgets/plan_flows.dart';

/// A job's six sections (Header, Assignment, Route, Timing, Cargo & vessel, Notes): the phone's
/// full-screen job and the tablet's detail pane. A long press on a value copies it.
class JobDetailSections extends StatelessWidget {
  const JobDetailSections({super.key, required this.row, required this.state, this.padding = const EdgeInsets.all(16)});

  final PlanLine row;
  final PlanState state;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final canWrite = state.access.canWrite;
    final index = state.rows.indexWhere((r) => r.uid == row.uid);
    final others = state.sameTruckAs(row);
    const gap = SizedBox(height: 12);
    return ListView(padding: padding, children: [
      _HeaderSection(row: row),
      gap,
      DetailSection(
        title: 'Assignment',
        icon: Icons.local_shipping_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _AssignRow(
            label: 'TRUCK',
            icon: Icons.local_shipping_outlined,
            value: row.truckName + (row.truckSize.isNotEmpty && row.truckName.isNotEmpty ? ' · ${row.truckSize}' : ''),
            color: severityText(context, truckSeverityOf(state, row)),
            enabled: canWrite,
            onTap: () => AssignPicker.truck(context, {row.uid}),
          ),
          const SizedBox(height: 8),
          _AssignRow(
            label: 'DRIVER',
            icon: Icons.person_outline,
            value: row.driverName,
            color: severityText(context, driverSeverityOf(state, row)),
            enabled: canWrite,
            onTap: () => AssignPicker.driver(context, {row.uid}),
          ),
          if (state.changedUids.contains(row.uid))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Changed · not saved yet', style: TextStyle(color: context.mc.toneFg(StatusTone.warning), fontWeight: FontWeight.w700)),
            ),
          _Copyable('D-leg truck / driver', '${row.truckNameD.isEmpty ? '—' : row.truckNameD} · ${row.driverNameD.isEmpty ? '—' : row.driverNameD}'),
          if (others.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('OTHER JOBS ON THIS TRUCK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: context.mc.muted)),
            for (final o in others)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(o.jobNo, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                subtitle: Text('${o.origin} → ${o.destination} · ${Fmt.planningDateTime(o.sPickupDate)}'),
                onTap: () => context.read<PlanCubit>().selectRow(o.uid),
              ),
          ],
        ]),
      ),
      gap,
      DetailSection(
        title: 'Route',
        icon: Icons.route_outlined,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('${row.origin}  →  ${row.destination}', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          _Copyable('S.Port / O.Port', '${row.sPort} / ${row.oPort}'),
          _Stops(label: 'Pickup address', joined: row.pickupAddress),
          _Stops(label: 'Delivery address', joined: row.deliveryAddress),
          _Copyable('D-leg route', '${row.originD} → ${row.destinationD}'),
        ]),
      ),
      gap,
      DetailSection(
        title: 'Timing',
        icon: Icons.schedule,
        child: Column(children: [
          _Copyable('P.Date', Fmt.planningDateTime(row.sPickupDate)),
          _Copyable('D.Date', Fmt.planningDateTime(row.sDeliveryDate)),
          _Copyable('L ETA', Fmt.planningDateTime(row.loadingETA)),
          _Copyable('O ETA', Fmt.planningDateTime(row.offloadingETA)),
          _Copyable('D-leg pickup', Fmt.planningDateTime(row.pickupDateD)),
          _Copyable('D-leg delivery', Fmt.planningDateTime(row.deliveryDateD)),
        ]),
      ),
      gap,
      DetailSection(
        title: 'Cargo & vessel',
        icon: Icons.inventory_2_outlined,
        child: Column(children: [
          _Copyable('PKG / WT', row.packageType),
          _Copyable('Vessel', row.vesselName),
          _Copyable('AWB No.', row.awbNo),
          _Copyable('BL copy', row.blCopy),
          _Copyable('Warehouse in / out', '${Fmt.planningDateTime(row.wareHouseEnterDate)} / ${Fmt.planningDateTime(row.wareHouseExitDate)}'),
          _Copyable('Warehouse address', row.wareHouseAddress),
        ]),
      ),
      gap,
      DetailSection(
        title: 'Notes',
        icon: Icons.edit_note,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (canWrite) ...[
            TextFormField(
              key: ValueKey('remarks-${row.uid}'),
              initialValue: row.remarks,
              decoration: const InputDecoration(labelText: 'Remarks'),
              onChanged: (v) => context.read<PlanCubit>().editRemarks(row.uid, v),
            ),
            const SizedBox(height: 10),
            TextFormField(
              key: ValueKey('sort-${row.uid}'),
              initialValue: row.sortByD,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Sort', hintText: row.originalSortByD),
              onChanged: (v) => context.read<PlanCubit>().editSort(row.uid, v),
            ),
          ] else ...[
            _Copyable('Remarks', row.remarks),
            _Copyable('Sort', row.sortByD),
          ],
          _Copyable('PIC', row.picName),
          _Copyable('S.No', index < 0 ? '' : '${index + 1}'),
          if (canWrite) _MoveButtons(index: index, last: state.rows.length - 1),
        ]),
      ),
    ]);
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.row});

  final PlanLine row;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 10, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
              GestureDetector(
                onLongPress: () => PlanFlows.copy(context, row.jobNo),
                child: Text(row.jobNo.isEmpty ? '—' : row.jobNo, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ),
              StatusPill(row.status),
              if (row.rtiNo.isNotEmpty)
                RtiBadge(row.rtiNo, onTap: () => PlanFlows.openRti(context, row))
              else
                const StatusPill('No RTI yet', tone: StatusTone.neutral, showDot: false),
            ]),
            const SizedBox(height: 6),
            GestureDetector(
              onLongPress: () => PlanFlows.copy(context, row.customerName),
              child: Text(row.customerName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            if (row.jobName.isNotEmpty || row.jobDate.isNotEmpty)
              Text([row.jobName, if (row.jobDate.isNotEmpty) 'job date ${Fmt.planningDateTime(row.jobDate)}'].where((t) => t.isNotEmpty).join(' · '),
                  style: TextStyle(color: context.mc.muted)),
          ]),
        ),
      );
}

class _AssignRow extends StatelessWidget {
  const _AssignRow({required this.label, required this.icon, required this.value, required this.onTap, required this.enabled, this.color});

  final String label;
  final IconData icon;
  final String value;
  final VoidCallback onTap;
  final bool enabled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final empty = value.trim().isEmpty;
    final fg = empty ? mc.toneFg(StatusTone.warning) : (color ?? context.cs.onSurface);
    return Semantics(
      button: enabled,
      label: '$label ${empty ? 'Unassigned' : value}',
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onTap : null,
        onLongPress: empty ? null : () => PlanFlows.copy(context, value),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: empty ? mc.toneBg(StatusTone.warning) : mc.surface2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: empty ? mc.toneFg(StatusTone.warning) : mc.outline),
          ),
          child: Row(children: [
            Icon(icon, color: fg),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: mc.muted)),
                Text(empty ? 'Unassigned' : value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: fg)),
              ]),
            ),
            if (enabled) Text(empty ? 'Assign' : 'Change', style: TextStyle(color: context.cs.primary, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

class _Copyable extends StatelessWidget {
  const _Copyable(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: value.trim().isEmpty ? null : () => PlanFlows.copy(context, value),
        child: KeyValueRow(label, value),
      );
}

/// The job's stops, split on `{@}` ("No address on this job").
class _Stops extends StatelessWidget {
  const _Stops({required this.label, required this.joined});

  final String label;
  final String joined;

  @override
  Widget build(BuildContext context) {
    final stops = PlanningRules.stops(joined);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: context.mc.muted, fontSize: 15)),
        const SizedBox(height: 4),
        if (stops.isEmpty) Text('No address on this job', style: TextStyle(fontStyle: FontStyle.italic, color: context.mc.faint)),
        for (var i = 0; i < stops.length; i++)
          GestureDetector(
            onLongPress: () => PlanFlows.copy(context, stops[i]),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(stops.length > 1 ? '${i + 1}. ${stops[i]}' : stops[i], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
      ]),
    );
  }
}

/// Move the job in the plan's order: to the top, up one, down one, to the bottom (the same
/// order change as dragging its S.NO grip).
class _MoveButtons extends StatelessWidget {
  const _MoveButtons({required this.index, required this.last});

  final int index;
  final int last;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlanCubit>();
    final up = index > 0, down = index >= 0 && index < last;
    Widget b(String tip, IconData icon, bool on, int to) => Expanded(
          child: Tooltip(
            message: tip,
            child: OutlinedButton(
              onPressed: on ? () => cubit.reorder(index, to) : null,
              style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
              child: Semantics(label: tip, child: Icon(icon)),
            ),
          ),
        );
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(children: [
        b('Move to top', Icons.vertical_align_top, up, 0),
        const SizedBox(width: 8),
        b('Move up', Icons.arrow_upward, up, index - 1),
        const SizedBox(width: 8),
        b('Move down', Icons.arrow_downward, down, index + 1),
        const SizedBox(width: 8),
        b('Move to bottom', Icons.vertical_align_bottom, down, last),
      ]),
    );
  }
}
