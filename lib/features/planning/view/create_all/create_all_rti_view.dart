import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/create_all_rti_cubit.dart';
import 'package:maleva/features/planning/data/planning_repository.dart';
import 'package:maleva/features/planning/data/planning_rti_batch.dart';
import 'package:maleva/features/planning/models/fleet_options.dart';
import 'package:maleva/features/planning/models/rti_batch.dart';
import 'package:maleva/features/planning/view/create_all/create_all_group_card.dart';

/// What a finished batch hands back to the plan.
class CreateAllOutcome {
  const CreateAllOutcome(this.result, this.preview, this.message, this.info);

  final RtiBatchResult result;
  final RtiBatchPreview preview;
  final String message;
  final String? info;
}

/// "Create RTI for the whole plan" (`CreateAllRtiModal.tsx`): review → creating → result.
/// Full screen on the phone, a dialog on a tablet.
class CreateAllRtiView extends StatelessWidget {
  const CreateAllRtiView({super.key, required this.drivers, required this.companyId, required this.employeeId, required this.onCreated});

  final List<DriverOption> drivers;
  final int companyId;
  final int employeeId;
  final void Function(CreateAllOutcome) onCreated;

  static Future<CreateAllOutcome?> open(BuildContext context,
      {required PlanningRepository repo, required int planningId, required List<DriverOption> drivers}) async {
    CreateAllOutcome? outcome;
    Widget page(BuildContext _) => MalevaThemeScope(
          child: BlocProvider(
            create: (_) => CreateAllRtiCubit(repo: repo, planningId: planningId)..open(),
            child: CreateAllRtiView(drivers: drivers, companyId: repo.companyId, employeeId: repo.employeeId, onCreated: (o) => outcome = o),
          ),
        );
    if (FormFactor.of(context).isTablet) {
      await showDialog<void>(
        context: context,
        useRootNavigator: true,
        builder: (ctx) => Dialog(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: FormFactor.of(ctx) == FormFactor.tabletLandscape ? 880 : 720, maxHeight: MediaQuery.sizeOf(ctx).height * 0.9),
              child: page(ctx)),
        ),
      );
    } else {
      await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(fullscreenDialog: true, builder: page));
    }
    return outcome;
  }

  @override
  Widget build(BuildContext context) => BlocListener<CreateAllRtiCubit, CreateAllRtiState>(
        listenWhen: (a, b) => a.errorSeq != b.errorSeq && b.stage != CreateAllStage.failed,
        listener: (context, s) => showSnack(context, s.error, kind: SnackKind.error),
        child: BlocConsumer<CreateAllRtiCubit, CreateAllRtiState>(
          listenWhen: (a, b) => a.stage != b.stage,
          listener: (context, s) {
            if (s.stage == CreateAllStage.failed) {
              showSnack(context, s.error, kind: SnackKind.error);
              Navigator.of(context).pop();
            }
            if (s.stage == CreateAllStage.done && s.result != null && s.preview != null) {
              onCreated(CreateAllOutcome(s.result!, s.preview!, s.resultMessage, s.infoMessage));
            }
          },
          builder: (context, s) {
            final p = s.preview;
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Create RTI for the whole plan'),
                  Text(p != null ? '${p.planningNo} · ${RtiBatchRules.day(p.planningDate)} · ${p.plannedJobs} job(s) planned' : 'Reading the plan…',
                      style: TextStyle(fontSize: 14, color: context.mc.muted, fontWeight: FontWeight.w500)),
                ]),
                actions: [IconButton(tooltip: 'Close', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close))],
              ),
              body: switch (s.stage) {
                CreateAllStage.loading || CreateAllStage.failed => const _Working('Working out what this plan would create…'),
                CreateAllStage.creating => _Working('Creating ${s.tally.trucks} RTI…'),
                CreateAllStage.done => _Result(state: s),
                CreateAllStage.review => _Review(state: s, drivers: drivers),
              },
              bottomNavigationBar: s.stage == CreateAllStage.done
                  ? StickyActionBar(actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done'))])
                  : _Footer(state: s, companyId: companyId, employeeId: employeeId),
            );
          },
        ),
      );
}

class _Working extends StatelessWidget {
  const _Working(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ]),
      );
}

class _Review extends StatefulWidget {
  const _Review({required this.state, required this.drivers});

  final CreateAllRtiState state;
  final List<DriverOption> drivers;

  @override
  State<_Review> createState() => _ReviewState();
}

class _ReviewState extends State<_Review> {
  bool _showSkipped = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final p = s.preview!;
    final mc = context.mc;
    final alreadyHave = p.skipped.where((k) => k.reason == 'ALREADY_IN_RTI').length;
    final noTruck = p.skipped.where((k) => k.reason == 'NO_TRUCK').length;
    final wide = FormFactor.of(context) == FormFactor.tabletLandscape;
    final cards = [
      for (final g in p.groups)
        CreateAllGroupCard(
            group: g, choice: RtiBatchRules.choiceFor(g, s.choices), drivers: widget.drivers, enabled: s.stage == CreateAllStage.review),
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      SwitchRow(
        label: 'Skip jobs that already have an RTI',
        value: !s.includeExisting,
        onChanged: (v) => context.read<CreateAllRtiCubit>().setSkipExisting(v),
        subtitle: !s.includeExisting
            ? (alreadyHave > 0 ? '$alreadyHave job(s) left out because they already have one.' : null)
            : (s.duplicates > 0 ? '${s.duplicates} job(s) were on an earlier RTI — a new one is created, the old one stays.' : null),
      ),
      const SizedBox(height: 8),
      if (p.groups.isEmpty)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const Text('There is nothing to create from this plan.', textAlign: TextAlign.center),
              if (alreadyHave > 0 && !s.includeExisting)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                      '$alreadyHave job(s) already have an RTI. Untick Skip jobs that already have an RTI above to create one for them anyway.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: mc.muted)),
                ),
              if (noTruck > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('$noTruck job(s) have no truck on the plan — assign one and try again.',
                      textAlign: TextAlign.center, style: TextStyle(color: mc.muted)),
                ),
            ]),
          ),
        )
      else if (wide)
        LayoutBuilder(
          builder: (ctx, box) => Wrap(spacing: 12, runSpacing: 12, children: [
            for (final c in cards) SizedBox(width: (box.maxWidth - 12) / 2, child: c),
          ]),
        )
      else
        for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: 10), child: c),
      if (p.skipped.isNotEmpty) ...[
        const SizedBox(height: 12),
        Card(
          child: Column(children: [
            ListTile(
              title: Text('${p.skipped.length} job(s) will not get a new RTI', style: const TextStyle(fontWeight: FontWeight.w700)),
              trailing: Text(_showSkipped ? 'Hide' : 'Show', style: TextStyle(color: context.cs.primary, fontWeight: FontWeight.w700)),
              onTap: () => setState(() => _showSkipped = !_showSkipped),
            ),
            if (_showSkipped)
              for (final k in p.skipped)
                ListTile(
                  dense: true,
                  title: Text(k.jobNo.isNotEmpty ? k.jobNo : '(no job no)', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  subtitle: Text(k.customerName),
                  trailing: StatusPill('${RtiBatchRules.skipLabel(k.reason)}${k.existingRtiNo.isNotEmpty ? ' — ${k.existingRtiNo}' : ''}',
                      tone: StatusTone.neutral, showDot: false),
                ),
          ]),
        ),
      ],
    ]);
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.companyId, required this.employeeId});

  final CreateAllRtiState state;
  final int companyId;
  final int employeeId;

  @override
  Widget build(BuildContext context) {
    final t = state.tally;
    final mc = context.mc;
    final creating = state.stage == CreateAllStage.creating;
    final notes = <Widget>[
      Text('${t.trucks} RTI · ${t.jobs} job${t.jobs == 1 ? '' : 's'}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
      if (t.needingDriver > 0) Text('${t.needingDriver} truck(s) still need a driver', style: TextStyle(color: context.cs.error, fontSize: 14)),
      if (state.preview != null && t.leftOut > 0)
        Text('${t.leftOut} job${t.leftOut == 1 ? '' : 's'} on this plan will still have no RTI',
            style: TextStyle(color: mc.toneFg(StatusTone.warning), fontSize: 14)),
      if (t.leftOut == 0 && t.trucks > 0)
        Text('Every job on this plan is covered', style: TextStyle(color: mc.toneFg(StatusTone.success), fontSize: 14)),
      if (state.duplicates > 0)
        Text('${state.duplicates} job(s) had an earlier RTI', style: TextStyle(color: mc.toneFg(StatusTone.warning), fontSize: 14)),
    ];
    return StickyActionBar(
      leading: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: notes),
      actions: [
        if (FormFactor.of(context).isTablet)
          OutlinedButton(onPressed: creating ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: state.stage == CreateAllStage.review && t.trucks > 0
              ? () => context.read<CreateAllRtiCubit>().confirm(companyId: companyId, employeeId: employeeId)
              : null,
          child: Text(creating ? 'Creating…' : 'Create ${t.trucks} RTI'),
        ),
      ],
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.state});

  final CreateAllRtiState state;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final r = state.result!;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: mc.toneBg(StatusTone.success), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Icon(Icons.check_circle, color: mc.toneFg(StatusTone.success)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(state.resultMessage, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: mc.toneFg(StatusTone.success)))),
        ]),
      ),
      if (state.infoMessage != null)
        Padding(padding: const EdgeInsets.only(top: 8), child: Text(state.infoMessage!, style: TextStyle(color: mc.muted))),
      const SizedBox(height: 12),
      for (final c in r.created)
        ListTile(
          title: Text(c.rtiNo, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text('${c.truckName} · ${c.driverName} · ${c.jobCount} job${c.jobCount == 1 ? '' : 's'}'),
          trailing: const StatusPill('Created', tone: StatusTone.success),
        ),
      for (final k in r.skipped)
        ListTile(
          title: Text(k.jobNo.isNotEmpty ? k.jobNo : '(no job no)', style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(RtiBatchRules.skipLabel(k.reason) + (k.existingRtiNo.isNotEmpty ? ' — ${k.existingRtiNo}' : '')),
          trailing: const StatusPill('Left alone', tone: StatusTone.neutral),
        ),
    ]);
  }
}
