import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_api.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';
import 'package:maleva/features/vessel_changes/vessel_changes_cubit.dart';

/// "Vessel changes" (change vessel-master-and-ptp-schedule): the jobs whose ETA, ETD or SCN differ from
/// PTP's schedule, one group per vessel call, Maleva's and PTP's times side by side. Opened from a
/// tapped VESSEL_ETA_CHANGED notice, the notifications page or the dashboard banner; [initialScope]
/// `team` opens "My team" (a leader's "Not handled" notice).
class VesselChangesPage extends StatelessWidget {
  const VesselChangesPage({super.key, this.api, this.initialScope = 'me'});

  final VesselChangesApi? api;

  /// `me` or `team`.
  final String initialScope;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VesselChangesCubit(api ?? sl<VesselChangesApi>(), scope: initialScope)..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Vessel changes'), actions: [
          // "Read PTP now", for every employee (the server reuses a read from the last few minutes)
          BlocBuilder<VesselChangesCubit, VesselChangesState>(
            builder: (context, state) => IconButton(
              key: const Key('read_ptp_now'),
              tooltip: 'Read PTP now',
              icon: const Icon(Icons.sync),
              onPressed: state.busy ? null : () => context.read<VesselChangesCubit>().readPtpNow(),
            ),
          ),
        ]),
        body: BlocBuilder<VesselChangesCubit, VesselChangesState>(
          builder: (context, state) {
            final cubit = context.read<VesselChangesCubit>();
            return Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'me', label: Text('My jobs')),
                    ButtonSegment(value: 'team', label: Text('My team')),
                  ],
                  selected: {state.scope},
                  onSelectionChanged: state.busy ? null : (s) => cubit.load(scope: s.first),
                ),
              ),
              SwitchListTile(
                key: const Key('move_pickup_delivery'),
                dense: true,
                title: const Text('Also move pickup and delivery'),
                value: state.movePickupDelivery,
                onChanged: state.busy ? null : cubit.setMovePickupDelivery,
              ),
              if (state.busy) const LinearProgressIndicator(),
              Expanded(child: _body(context, state, cubit)),
            ]);
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, VesselChangesState state, VesselChangesCubit cubit) {
    final data = state.data;
    final notes = state.notes.isEmpty ? null : _Notes(state.notes);
    if (data == null) {
      if (state.error != null) {
        return ListView(padding: const EdgeInsets.all(16), children: [
          if (notes != null) notes,
          Text(state.error!, key: const Key('vessel_changes_error')),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(onPressed: cubit.load, icon: const Icon(Icons.refresh), label: const Text('Retry')),
          ),
        ]);
      }
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: cubit.load,
      child: ListView(padding: const EdgeInsets.fromLTRB(12, 4, 12, 24), children: [
        if (notes != null) notes,
        if (data.isEmpty) ...[
          const SizedBox(height: 32),
          const Center(child: Text('No vessel changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
          const SizedBox(height: 6),
          Center(
            child: Text(data.lastGoodReadAt == null
                ? 'PTP has not been read yet'
                : 'PTP last read ${vesselTimeText(data.lastGoodReadAt)}'),
          ),
        ] else
          for (final g in data.groups)
            if (g.jobs.isNotEmpty) _GroupCard(group: g, state: state),
      ]),
    );
  }
}

class _Notes extends StatelessWidget {
  const _Notes(this.notes);

  final List<String> notes;

  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final n in notes) Text(n)]),
        ),
      );
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, required this.state});

  final VesselChangeGroup group;
  final VesselChangesState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VesselChangesCubit>();
    final call = group.call;
    final keys = [for (final j in group.jobs) vesselJobKey(call.id, j)];
    final chosen = keys.where(state.selected.contains).length;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Checkbox(
              value: chosen == 0 ? false : (chosen == keys.length ? true : null),
              tristate: true,
              onChanged: state.busy ? null : (_) => cubit.selectAll(group, chosen != keys.length),
            ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${call.vesselName}${call.voyage == null ? '' : ' ${call.voyage}'}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                Text('PTP changed ${vesselTimeText(group.lastChangedAt)}'
                    '${call.listed ? '' : ' · no longer listed by PTP'}',
                    style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
            if (call.scn != null) _ScnChip(call.scn!),
          ]),
          for (final j in group.jobs) _JobRow(group: group, job: j, state: state),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              key: ValueKey('update_${call.id}'),
              onPressed: state.busy || chosen == 0 ? null : () => cubit.update(group),
              child: Text(chosen == 0 ? 'Update these jobs' : 'Update these jobs ($chosen)'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _JobRow extends StatelessWidget {
  const _JobRow({required this.group, required this.job, required this.state});

  final VesselChangeGroup group;
  final VesselChangeJob job;
  final VesselChangesState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VesselChangesCubit>();
    final call = group.call;
    final key = vesselJobKey(call.id, job);
    final small = Theme.of(context).textTheme.bodySmall;
    final error = Theme.of(context).colorScheme.error;
    final reason = pickupReasonText(job);
    final refused = state.refused[key];
    final waits = job.boardingMonthChanges && !state.confirmedBoarding.contains(key);
    return Padding(
      key: ValueKey('job_$key'),
      padding: const EdgeInsets.only(top: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Checkbox(
          value: state.selected.contains(key),
          onChanged: state.busy ? null : (on) => cubit.toggle(group, job, on ?? false),
        ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${job.jobNo} · ${job.isLoading ? 'Loading' : 'Off'}', style: const TextStyle(fontWeight: FontWeight.w700)),
            if (job.customerName != null || job.employeeName != null)
              Text([job.customerName, job.employeeName].whereType<String>().join(' · '), style: small),
            _TimeLine('ETA', job.currentEta, job.ptpEta, call.arriveEstimated, job.etaDiffers),
            _TimeLine('ETD', job.currentEtd, job.ptpEtd, call.departEstimated, job.etdDiffers),
            if (job.scnDiffers || job.ptpScn != null)
              Text('SCN ${job.currentScn ?? '-'}  →  PTP ${job.ptpScn ?? '-'}',
                  style: TextStyle(fontWeight: job.scnDiffers ? FontWeight.w700 : FontWeight.normal)),
            if (job.suggestedPickupDate != null)
              Text('Pickup ${vesselTimeText(job.pickupDate)} → ${vesselTimeText(job.suggestedPickupDate)}'
                  ' · Delivery ${vesselTimeText(job.deliveryDate)} → ${vesselTimeText(job.suggestedDeliveryDate)}'),
            if (reason != null) Text(reason, style: small?.copyWith(fontStyle: FontStyle.italic)),
            if (job.boardingMonthChanges)
              Row(children: [
                Expanded(
                  child: Text(
                      'Boarding pay moves from ${boardingMonthText(job.boardingMonthFrom)} '
                      'to ${boardingMonthText(job.boardingMonthTo)}',
                      style: TextStyle(color: waits ? error : null)),
                ),
                if (waits)
                  TextButton(
                    key: ValueKey('confirm_$key'),
                    onPressed: state.busy ? null : () => cubit.confirmBoarding(group, job),
                    child: const Text('Confirm'),
                  )
                else
                  const Icon(Icons.check, size: 18),
              ]),
            if (refused != null) Text('Not updated: $refused', style: TextStyle(color: error)),
          ]),
        ),
        TextButton(
          key: ValueKey('dismiss_$key'),
          onPressed: state.busy ? null : () => cubit.dismiss(group, job),
          child: const Text('Dismiss'),
        ),
      ]),
    );
  }
}

class _TimeLine extends StatelessWidget {
  const _TimeLine(this.label, this.current, this.ptp, this.estimated, this.differs);

  final String label;
  final String? current;
  final String? ptp;
  final bool estimated;
  final bool differs;

  @override
  Widget build(BuildContext context) => Text(
        '$label ${vesselTimeText(current)}  →  PTP ${vesselTimeText(ptp)}${estimated && ptp != null ? ' est.' : ''}',
        style: TextStyle(fontWeight: differs ? FontWeight.w700 : FontWeight.normal),
      );
}

/// PTP's SCN, copied on tap (it is not sent with the update).
class _ScnChip extends StatelessWidget {
  const _ScnChip(this.scn);

  final String scn;

  @override
  Widget build(BuildContext context) => ActionChip(
        key: const Key('copy_scn'),
        avatar: const Icon(Icons.copy, size: 16),
        label: Text('SCN $scn'),
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: scn));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SCN $scn copied')));
          }
        },
      );
}
