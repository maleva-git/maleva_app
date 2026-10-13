import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/vessel_changes/vessel_change_look.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_api.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';
import 'package:maleva/features/vessel_changes/job_actions.dart';
import 'package:maleva/features/vessel_changes/vessel_changes_cubit.dart';
import 'package:maleva/features/vessel_changes/vessel_time_compare.dart';

/// "Vessel changes" (change vessel-master-and-ptp-schedule): the jobs whose ETA or ETD differ from PTP's
/// schedule, one card per vessel call: what PTP says now, then per job Maleva's time against PTP's
/// ("In Maleva" | "PTP now") with "Use PTP's times" or "Keep mine (dismiss)", and "Update all N jobs to
/// PTP" for the whole call. Opened from a
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
        body: BlocConsumer<VesselChangesCubit, VesselChangesState>(
          // "MY002605808 updated to PTP's times" / "3 jobs updated to PTP's times"
          listenWhen: (a, b) => a.doneSeq != b.doneSeq && b.done != null,
          listener: (context, state) =>
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.done!))),
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
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Text(vesselCallTitle(call),
                  key: ValueKey('vessel_title_${call.id}'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
            if (call.scn != null) ...[const SizedBox(width: 8), _ScnChip(call.scn!)],
          ]),
          const SizedBox(height: 2),
          Text(vesselCallSubline(group),
              key: ValueKey('vessel_subline_${call.id}'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted)),
          for (final j in group.jobs) ...[
            const Divider(height: 20),
            _JobRow(group: group, job: j, state: state),
          ],
          const SizedBox(height: 12),
          FilledButton(
            key: ValueKey('update_${call.id}'),
            onPressed: state.busy ? null : () => cubit.update(group),
            child: Text(updateAllLabel(group.jobs.length), maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ]),
      ),
    );
  }
}

/// One job: "MY002605808 · Loading", the customer and employee, Maleva's and PTP's times, its actions.
class _JobRow extends StatelessWidget {
  const _JobRow({required this.group, required this.job, required this.state});

  final VesselChangeGroup group;
  final VesselChangeJob job;
  final VesselChangesState state;

  @override
  Widget build(BuildContext context) {
    final key = vesselJobKey(group.call.id, job);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final who = [job.customerName, job.employeeName].whereType<String>().where((s) => s.trim().isNotEmpty);
    return Column(
      key: ValueKey('job_$key'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('${vesselJobName(job)} · ${job.isLoading ? 'Loading' : 'Off'}',
            maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
        if (who.isNotEmpty)
          Text(who.join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: muted)),
        const SizedBox(height: 6),
        VesselTimeCompare(call: group.call, job: job),
        VesselJobActions(group: group, job: job, state: state),
      ],
    );
  }
}

/// PTP's SCN, copied on tap (it is not sent with the update).
class _ScnChip extends StatelessWidget {
  const _ScnChip(this.scn);

  final String scn;

  @override
  Widget build(BuildContext context) {
    Future<void> copy() async {
      await Clipboard.setData(ClipboardData(text: scn));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('SCN $scn copied')));
      }
    }

    // read aloud as "Copy SCN 269EK6", as on the web
    return Semantics(
      container: true,
      label: 'Copy SCN $scn',
      button: true,
      onTap: copy,
      excludeSemantics: true,
      child: ActionChip(
        key: const Key('copy_scn'),
        avatar: const Icon(Icons.copy, size: 16),
        label: Text('SCN $scn'),
        onPressed: copy,
      ),
    );
  }
}
