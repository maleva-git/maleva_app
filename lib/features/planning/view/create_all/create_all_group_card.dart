import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/create_all_rti_cubit.dart';
import 'package:maleva/features/planning/data/planning_rti_batch.dart';
import 'package:maleva/features/planning/models/fleet_options.dart';
import 'package:maleva/features/planning/models/rti_batch.dart';

/// One truck and driver = one RTI (`CreateAllRtiModal.tsx:184-337`).
class CreateAllGroupCard extends StatelessWidget {
  const CreateAllGroupCard({super.key, required this.group, required this.choice, required this.drivers, required this.enabled});

  final RtiBatchGroup group;
  final GroupChoice choice;
  final List<DriverOption> drivers;
  final bool enabled;

  StatusTone _sourceTone(String source) => switch (source) {
        'LAST_TRIP' => StatusTone.warning,
        'OUTSIDE' => StatusTone.accent,
        'NONE' => StatusTone.danger,
        _ => StatusTone.neutral,
      };

  Future<void> _pickDriver(BuildContext context) async {
    final cubit = context.read<CreateAllRtiCubit>();
    final sorted = [...drivers]..sort((a, b) => a.name.compareTo(b.name));
    final listed = sorted.any((d) => d.id == choice.driverRefId);
    final options = [
      if (choice.driverRefId > 0 && !listed)
        PickOption<int>(
            value: choice.driverRefId,
            label: choice.outsideDriver.isNotEmpty ? choice.outsideDriver : (choice.driverName.isNotEmpty ? choice.driverName : 'Current driver')),
      for (final d in sorted) PickOption<int>(value: d.id, label: d.name),
    ];
    final result = await showPickerSheet<int>(context,
        title: 'Driver for ${group.truckName.isNotEmpty ? group.truckName : 'Truck #${group.truckRefId}'}',
        options: options,
        current: choice.driverRefId > 0 ? choice.driverRefId : null,
        allowClear: true,
        searchHint: 'Search driver...');
    if (result == null || cubit.isClosed) return;
    if (result.cleared) {
      cubit.pickDriver(group.groupKey, 0, '');
    } else if (result.value != null) {
      final picked = sorted.where((d) => d.id == result.value).firstOrNull;
      cubit.pickDriver(group.groupKey, result.value!, picked?.name ?? choice.driverName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final cs = context.cs;
    final choices = {group.groupKey: choice};
    final ready = RtiBatchRules.isGroupReady(group, choices);
    final days = RtiBatchRules.jobDays(group.jobs);
    final spansDays = days.length > 1;
    final truck = group.truckName.isNotEmpty ? group.truckName : 'Truck #${group.truckRefId}';
    final driverLabel = choice.driverRefId > 0
        ? (drivers.where((d) => d.id == choice.driverRefId).map((d) => d.name).firstOrNull ??
            (choice.outsideDriver.isNotEmpty ? choice.outsideDriver : (choice.driverName.isNotEmpty ? choice.driverName : 'Current driver')))
        : '';
    return Opacity(
      opacity: ready && !choice.selected ? 0.6 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: ready ? cs.surface : mc.dangerSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ready ? mc.outline : cs.error, width: ready ? 1 : 1.5),
        ),
        padding: const EdgeInsets.fromLTRB(4, 8, 14, 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Checkbox(
            value: choice.selected,
            onChanged: ready && enabled ? (v) => context.read<CreateAllRtiCubit>().tick(group.groupKey, v ?? false) : null,
            semanticLabel: 'Create RTI for $truck',
          ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.local_shipping_outlined, size: 20, color: mc.muted),
                  const SizedBox(width: 6),
                  Text(truck, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ]),
                Text('${RtiBatchRules.day(group.pickupDate)}${spansDays ? ' +${days.length - 1} more day(s)' : ''}',
                    style: TextStyle(color: mc.muted)),
                if (group.tripLabel.isNotEmpty)
                  Tooltip(
                    message: 'The planner wrote this trip in the REMARKS column; each trip is its own RTI',
                    child: StatusPill(group.tripLabel, tone: StatusTone.info, showDot: false),
                  ),
                StatusPill('${group.jobs.length} job${group.jobs.length == 1 ? '' : 's'}', tone: StatusTone.neutral, showDot: false),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: PickerField(
                    label: 'Driver',
                    value: driverLabel,
                    hint: '— pick a driver —',
                    icon: Icons.person_outline,
                    enabled: enabled,
                    onTap: () => _pickDriver(context),
                  ),
                ),
                const SizedBox(width: 8),
                StatusPill(RtiBatchRules.driverSourceLabel(group.driverSource), tone: _sourceTone(group.driverSource), showDot: false),
              ]),
              const SizedBox(height: 8),
              for (final job in group.jobs) _JobLine(job: job, spansDays: spansDays),
              for (final w in group.warnings)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: mc.toneFg(StatusTone.warning)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(w, style: TextStyle(color: mc.toneFg(StatusTone.warning), fontSize: 14))),
                  ]),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _JobLine extends StatelessWidget {
  const _JobLine({required this.job, required this.spansDays});

  final RtiBatchJob job;
  final bool spansDays;

  @override
  Widget build(BuildContext context) {
    final time = RtiBatchRules.time(job.pickupDate);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text(job.jobNo, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        Text('· ${job.customerName} · ${job.origin} → ${job.destination}', style: TextStyle(color: context.mc.muted, fontSize: 14)),
        if (time.isNotEmpty)
          Text('${spansDays ? '${RtiBatchRules.day(job.pickupDate)} ' : ''}$time', style: TextStyle(color: context.mc.faint, fontSize: 14)),
        if (job.remarks.isNotEmpty) StatusPill(job.remarks, tone: StatusTone.neutral, showDot: false),
        if (job.existingRtiNo.isNotEmpty)
          Tooltip(
            message: 'This job was on an earlier RTI; that one stays and a new one is created',
            child: StatusPill('was on ${job.existingRtiNo}${job.existingRtiDate.isNotEmpty ? ' · ${RtiBatchRules.day(job.existingRtiDate)}' : ''}',
                tone: StatusTone.warning, showDot: false),
          ),
      ]),
    );
  }
}
