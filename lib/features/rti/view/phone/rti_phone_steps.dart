import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/widgets/rti_charges.dart';
import 'package:maleva/features/rti/widgets/rti_job_card.dart';
import 'package:maleva/features/rti/widgets/rti_pickers.dart';
import 'package:maleva/features/rti/widgets/rti_stop_fields.dart';
import 'package:maleva/features/rti/widgets/rti_trip_fields.dart';

/// The five steps of the phone RTI form: Trip, Charges, Jobs, Route activities, Review & Save.
abstract final class RtiPhoneSteps {
  static const titles = ['Trip', 'Charges', 'Jobs', 'Route', 'Review'];

  static List<Widget> build(BuildContext context, int step) => switch (step) {
        0 => const [RtiTripFields()],
        1 => const [RtiChargeFields()],
        2 => const [RtiJobsStep()],
        3 => const [RtiRouteStep()],
        _ => const [RtiReviewStep()],
      };
}

/// "Revised from the sales orders: …" while a revise is not yet saved.
class RtiReviseBanner extends StatelessWidget {
  const RtiReviseBanner({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<RtiEntryBloc, RtiEntryState>(
        buildWhen: (a, b) => a.inRevise != b.inRevise || a.reviseChanges != b.reviseChanges,
        builder: (context, s) {
          if (!s.inRevise) return const SizedBox.shrink();
          final n = s.reviseChangeCount;
          final jobs = s.reviseChanges.length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RtiBanner(
              icon: Icons.sync,
              text: 'Revised from the sales orders: $n ${n == 1 ? 'change' : 'changes'} in $jobs ${jobs == 1 ? 'job' : 'jobs'}. '
                  'Check them, edit if needed, then save. Route activities are kept.',
            ),
          );
        },
      );
}

/// The grid badges: Rows · Jobs · Salary (`R/components/RTIGrid.tsx:208-210`).
class RtiGridBadges extends StatelessWidget {
  const RtiGridBadges({super.key, required this.state});

  final RtiEntryState state;

  @override
  Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 8, children: [
        StatusPill('Rows: ${state.grid.length}', tone: StatusTone.neutral, showDot: false),
        StatusPill('Jobs: ${state.filledJobs}', tone: StatusTone.neutral, showDot: false),
        StatusPill('Salary: ${Fmt.rm(state.salaryTotal)}', tone: StatusTone.primary, showDot: false),
      ]);
}

class RtiJobsStep extends StatelessWidget {
  const RtiJobsStep({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<RtiEntryBloc, RtiEntryState>(
        buildWhen: (a, b) => a.grid != b.grid || a.busy != b.busy || a.lookupRow != b.lookupRow || a.reviseChanges != b.reviseChanges,
        builder: (context, s) {
          final placeholderOnly = s.grid.length == 1 && s.grid.first.isPlaceholder;
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const RtiReviseBanner(),
            RtiGridBadges(state: s),
            const SizedBox(height: 12),
            RtiJobNoLookup(row: -1, busy: s.busy == RtiBusy.lookingUp),
            const SizedBox(height: 8),
            if (placeholderOnly)
              Padding(padding: const EdgeInsets.all(8), child: Text('Type a Job No and tap Look up.', style: TextStyle(color: context.mc.muted)))
            else
              for (var i = 0; i < s.grid.length; i++)
                RtiJobCard(
                  key: ValueKey('job-$i-${s.grid[i].saleOrderMasterRefId}'),
                  index: i,
                  row: s.grid[i],
                  changes: s.reviseChanges[s.grid[i].saleOrderMasterRefId] ?? const [],
                  lookingUp: s.lookupRow == i,
                ),
          ]);
        },
      );
}

class RtiRouteStep extends StatelessWidget {
  const RtiRouteStep({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<RtiEntryBloc, RtiEntryState>(
        buildWhen: (a, b) => a.stops != b.stops || a.refs != b.refs,
        builder: (context, s) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (s.stops.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('No route activities defined. Tap "Add Activity" to create milestones.', textAlign: TextAlign.center, style: TextStyle(color: context.mc.muted)),
            ),
          for (var i = 0; i < s.stops.length; i++) RtiStopCard(key: ValueKey('stop-$i'), index: i, stop: s.stops[i]),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.read<RtiEntryBloc>().add(const RtiStopAdded()),
            icon: const Icon(Icons.add),
            label: const Text('Add Activity'),
          ),
        ]),
      );
}

class RtiReviewStep extends StatelessWidget {
  const RtiReviewStep({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<RtiEntryBloc, RtiEntryState>(
        buildWhen: (a, b) => a.errors != b.errors || a.form != b.form || a.grid != b.grid || a.stops != b.stops || a.refs != b.refs,
        builder: (context, s) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const RtiReviseBanner(),
          if (s.errors.isNotEmpty) ...[RtiErrorList(errors: s.errors), const SizedBox(height: 12)],
          DetailSection(
            title: 'Trip',
            child: Column(children: [
              KeyValueRow('RTI No', s.form.rtiNo),
              KeyValueRow('RTI Date', Fmt.ddMMyyyy(DateTime.tryParse(s.form.rtiDate))),
              KeyValueRow('Driver', RtiPickers.label(RtiPickers.drivers(s.refs.drivers), s.form.driverRefId)),
              KeyValueRow('Vehicle', RtiPickers.label(RtiPickers.trucks(s.refs.trucks), s.form.truckRefId)),
              KeyValueRow('Jobs', '${s.filledJobs}'),
              KeyValueRow('Route activities', '${s.stops.length}'),
            ]),
          ),
          const SizedBox(height: 12),
          const DetailSection(title: 'Charges Summary', child: RtiChargesSummary()),
          const SizedBox(height: 12),
          const RtiNotesFields(),
        ]),
      );
}

/// Every save problem together ("Fix before saving").
class RtiErrorList extends StatelessWidget {
  const RtiErrorList({super.key, required this.errors});

  final List<String> errors;

  @override
  Widget build(BuildContext context) => RtiBanner(
        tone: StatusTone.danger,
        title: 'Fix before saving',
        text: errors.map((e) => '• $e').join('\n'),
      );
}
