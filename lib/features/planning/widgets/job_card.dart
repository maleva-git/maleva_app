import 'package:flutter/material.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/models/fleet_options.dart';
import 'package:maleva/features/planning/models/plan_line.dart';

/// The truck's and driver's expiry / leave state for a row (`TruckSelectCell` / `DriverSelectCell`).
ExpirySeverity truckSeverityOf(PlanState s, PlanLine r) {
  final t =
      s.trucks.where((t) => t.id == r.truckRefid).firstOrNull ?? s.trucks.where((t) => r.truckName.isNotEmpty && t.name == r.truckName).firstOrNull;
  return t == null ? ExpirySeverity.normal : t.expiry().severity;
}

ExpirySeverity driverSeverityOf(PlanState s, PlanLine r) {
  final d = s.drivers.where((d) => d.id == r.driverRefid).firstOrNull ??
      s.drivers.where((d) => r.driverName.isNotEmpty && d.name == r.driverName).firstOrNull;
  return d == null ? ExpirySeverity.normal : d.expiry().severity;
}

/// The colour of a truck / driver name: red when critical, purple / indigo for leave (PR4, PR5).
Color? severityText(BuildContext context, ExpirySeverity s) => switch (s) {
      ExpirySeverity.critical => context.mc.toneFg(StatusTone.danger),
      ExpirySeverity.leaveApproved => context.mc.toneFg(StatusTone.accent),
      ExpirySeverity.leavePending => context.mc.leavePending,
      _ => null,
    };

/// A truck or driver chip: amber "Unassigned" when empty.
class AssignChip extends StatelessWidget {
  const AssignChip({super.key, required this.icon, required this.value, this.color, this.onTap, this.compact = false, this.semantic = ''});

  final IconData icon;
  final String value;
  final Color? color;
  final VoidCallback? onTap;
  final bool compact;
  final String semantic;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final empty = value.trim().isEmpty;
    final fg = empty ? mc.toneFg(StatusTone.warning) : (color ?? context.cs.onSurface);
    final chip = Container(
      constraints: BoxConstraints(minHeight: compact ? 32 : 44),
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
      decoration: BoxDecoration(
        color: empty ? mc.toneBg(StatusTone.warning) : mc.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: empty ? mc.toneFg(StatusTone.warning).withValues(alpha: 0.5) : mc.outline),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: compact ? 15 : 18, color: fg),
        const SizedBox(width: 6),
        Flexible(
          child: Text(empty ? 'Unassigned' : value,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 13 : 14, fontWeight: FontWeight.w700, color: fg)),
        ),
      ]),
    );
    if (onTap == null) return Semantics(label: '$semantic ${empty ? 'Unassigned' : value}', child: chip);
    return Semantics(
        button: true,
        label: '$semantic ${empty ? 'Unassigned' : value}',
        child: InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap, child: chip));
  }
}

/// A job on the phone list: Job No + status, customer, origin → destination, P/D dates,
/// truck and driver chips, RTI badge. With [selecting], a checkbox leads.
class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.row,
    required this.state,
    required this.onTap,
    this.onLongPress,
    this.selecting = false,
    this.current = false,
    this.compact = false,
    this.onTruck,
    this.onDriver,
    this.onRti,
  });

  final PlanLine row;
  final PlanState state;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool selecting;
  final bool current;
  final bool compact;
  final VoidCallback? onTruck;
  final VoidCallback? onDriver;
  final VoidCallback? onRti;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final cs = context.cs;
    final changed = state.changedUids.contains(row.uid);
    final sameTruck = state.selected != null && state.selected!.uid != row.uid && state.sameTruckAs(state.selected!).any((r) => r.uid == row.uid);
    final body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Flexible(child: Text(row.jobNo.isEmpty ? '—' : row.jobNo, style: TextStyle(fontSize: compact ? 15 : 16, fontWeight: FontWeight.w800))),
        if (changed) ...[
          const SizedBox(width: 6),
          Tooltip(
              message: 'Not saved',
              child: Container(width: 8, height: 8, decoration: BoxDecoration(color: mc.toneFg(StatusTone.warning), shape: BoxShape.circle))),
        ],
        const Spacer(),
        StatusPill(row.status),
      ]),
      const SizedBox(height: 3),
      Text([row.customerName, if (!compact && row.vesselName.isNotEmpty) row.vesselName].where((t) => t.isNotEmpty).join(' · '),
          maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: mc.muted)),
      const SizedBox(height: 6),
      Row(children: [
        Flexible(
            child: Text(row.origin, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.arrow_forward, size: 16, color: mc.muted)),
        Flexible(
            child: Text(row.destination,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
      ]),
      if (!compact)
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text('P ${Fmt.planningDateTime(row.sPickupDate)} → D ${Fmt.planningDateTime(row.sDeliveryDate)}',
              style: TextStyle(fontSize: 13, color: mc.muted)),
        ),
      SizedBox(height: compact ? 6 : 10),
      Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        AssignChip(
          icon: Icons.local_shipping_outlined,
          value: row.truckName + (row.truckSize.isNotEmpty && row.truckName.isNotEmpty ? ' · ${row.truckSize}' : ''),
          color: severityText(context, truckSeverityOf(state, row)),
          onTap: selecting ? null : onTruck,
          compact: compact,
          semantic: 'Truck',
        ),
        AssignChip(
          icon: Icons.person_outline,
          value: row.driverName,
          color: severityText(context, driverSeverityOf(state, row)),
          onTap: selecting ? null : onDriver,
          compact: compact,
          semantic: 'Driver',
        ),
        if (row.rtiNo.isNotEmpty) RtiBadge(row.rtiNo, onTap: selecting ? null : onRti),
      ]),
    ]);
    return Semantics(
      selected: row.print,
      child: Material(
        color: current ? mc.primarySoft : (sameTruck ? mc.primarySoft.withValues(alpha: 0.45) : cs.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: current || row.print ? cs.primary : mc.outline, width: current || row.print ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: EdgeInsets.fromLTRB(selecting ? 4 : 14, 12, 14, 12),
            child: selecting
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Checkbox(value: row.print, onChanged: (_) => onTap(), semanticLabel: 'Select ${row.jobNo}'),
                    Expanded(child: body),
                  ])
                : body,
          ),
        ),
      ),
    );
  }
}
