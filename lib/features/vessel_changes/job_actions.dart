import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';
import 'package:maleva/features/vessel_changes/vessel_changes_cubit.dart';

/// Under a job's times: the boarding pay month note (confirmed on the row, as before), why the last
/// update refused it, then "Use PTP's times" (this job only) and "Keep mine (dismiss)".
class VesselJobActions extends StatelessWidget {
  const VesselJobActions({super.key, required this.group, required this.job, required this.state});

  final VesselChangeGroup group;
  final VesselChangeJob job;
  final VesselChangesState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VesselChangesCubit>();
    final key = vesselJobKey(group.call.id, job);
    final error = Theme.of(context).colorScheme.error;
    final refused = state.refused[key];
    final waits = job.boardingMonthChanges && !state.confirmedBoarding.contains(key);
    const compact = VisualDensity(horizontal: -2, vertical: -2);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (job.boardingMonthChanges)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(children: [
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
        ),
      if (refused != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('Not updated: $refused', style: TextStyle(color: error)),
        ),
      const SizedBox(height: 4),
      Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
        FilledButton(
          key: ValueKey('use_ptp_$key'),
          style: FilledButton.styleFrom(visualDensity: compact, padding: const EdgeInsets.symmetric(horizontal: 14)),
          onPressed: state.busy ? null : () => cubit.updateJob(group, job),
          child: const Text("Use PTP's times"),
        ),
        TextButton(
          key: ValueKey('dismiss_$key'),
          style: TextButton.styleFrom(visualDensity: compact),
          onPressed: state.busy ? null : () => cubit.dismiss(group, job),
          child: const Text('Keep mine (dismiss)'),
        ),
      ]),
    ]);
  }
}
