import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/view/phone/rti_phone_steps.dart';
import 'package:maleva/features/rti/widgets/rti_entry_actions.dart';
import 'package:maleva/features/rti/widgets/rti_trip_fields.dart';

/// The page heading (`R/components/RTIPageHeader.tsx:88`): `RTI (employee)` or `RTI`, with the
/// "Edit Mode" / "New RTI" badge.
class RtiTitle extends StatelessWidget {
  const RtiTitle({super.key, required this.employeeName, required this.isEdit});

  final String employeeName;
  final bool isEdit;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Flexible(child: Text(employeeName.isEmpty ? 'RTI' : 'RTI ($employeeName)', overflow: TextOverflow.ellipsis)),
        const SizedBox(width: 8),
        StatusPill(isEdit ? 'Edit Mode' : 'New RTI', tone: isEdit ? StatusTone.warning : StatusTone.success, showDot: false),
      ]);
}

enum _Menu { revise, levi, share, report, clear, delete }

/// The phone RTI form: five steps with the live RM total and Back / Next / Save at the bottom.
class RtiEntryPhone extends StatelessWidget {
  const RtiEntryPhone({super.key, required this.employeeName, required this.onRetry});

  final String employeeName;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => BlocBuilder<RtiEntryBloc, RtiEntryState>(
        buildWhen: (a, b) =>
            a.step != b.step || a.form.isEdit != b.form.isEdit || a.status != b.status || a.busy != b.busy || a.refsError != b.refsError || a.total != b.total,
        builder: (context, s) {
          final bloc = context.read<RtiEntryBloc>();
          return Scaffold(
            appBar: AppBar(
              title: RtiTitle(employeeName: employeeName, isEdit: s.form.isEdit),
              actions: [_menu(context, s)],
            ),
            body: switch (s.status) {
              RtiLoadStatus.loading => const SkeletonList(),
              RtiLoadStatus.failed => ErrorState(
                  title: 'Could not open the RTI',
                  message: s.loadError,
                  onRetry: onRetry,
                ),
              RtiLoadStatus.ready => Column(children: [
                  _StepBar(step: s.step),
                  if (s.busy == RtiBusy.saving || s.busy == RtiBusy.deleting || s.busy == RtiBusy.revising) const LinearProgressIndicator(),
                  Expanded(
                    child: ListView(
                      key: PageStorageKey('rti-step-${s.step}'),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      children: [
                        if (s.refsError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(onTap: () => bloc.add(const RtiReferencesRetried()), child: RtiBanner(text: '${s.refsError} (tap to retry)', tone: StatusTone.danger)),
                          ),
                        ...RtiPhoneSteps.build(context, s.step),
                      ],
                    ),
                  ),
                ]),
            },
            bottomNavigationBar: s.status != RtiLoadStatus.ready
                ? null
                : StickyActionBar(
                    leading: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('RM total', style: TextStyle(fontSize: 12, color: context.mc.muted, fontWeight: FontWeight.w700)),
                      Text(Fmt.rm(s.total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                    ]),
                    actions: [
                      if (s.step > 0) OutlinedButton(onPressed: () => bloc.add(RtiStepChanged(s.step - 1)), child: const Text('Back')),
                      if (s.step < 4)
                        FilledButton(onPressed: () => bloc.add(RtiStepChanged(s.step + 1)), child: const Text('Next'))
                      else
                        FilledButton.icon(
                          onPressed: s.busy == RtiBusy.saving ? null : () => RtiEntryActions.save(context),
                          icon: s.busy == RtiBusy.saving
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.save_outlined),
                          label: Text(s.busy == RtiBusy.saving ? 'Saving...' : 'Save'),
                        ),
                    ],
                  ),
          );
        },
      );

  Widget _menu(BuildContext context, RtiEntryState s) => PopupMenuButton<_Menu>(
        tooltip: 'More',
        enabled: !s.isBusy || s.busy == RtiBusy.lookingUp,
        onSelected: (m) => switch (m) {
          _Menu.revise => RtiEntryActions.revise(context),
          _Menu.levi => RtiEntryActions.levi(context),
          _Menu.share => RtiEntryActions.share(context),
          _Menu.report => RtiEntryActions.report(context),
          _Menu.clear => Future.sync(() => RtiEntryActions.clear(context)),
          _Menu.delete => RtiEntryActions.delete(context),
        },
        itemBuilder: (_) => [
          if (s.form.isEdit) ...const [
            PopupMenuItem(value: _Menu.revise, child: ListTile(leading: Icon(Icons.sync), title: Text('Revise from sales order'))),
            PopupMenuItem(value: _Menu.levi, child: ListTile(leading: Icon(Icons.receipt_long_outlined), title: Text('Levi Entry'))),
            PopupMenuItem(value: _Menu.share, child: ListTile(leading: Icon(Icons.send_outlined), title: Text('Share to WhatsApp'))),
            PopupMenuItem(value: _Menu.report, child: ListTile(leading: Icon(Icons.picture_as_pdf_outlined), title: Text('RTI report'))),
          ],
          const PopupMenuItem(value: _Menu.clear, child: ListTile(leading: Icon(Icons.restart_alt), title: Text('New RTI (Clear)'))),
          if (s.form.isEdit)
            PopupMenuItem(
              value: _Menu.delete,
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: context.cs.error),
                title: Text('Delete RTI', style: TextStyle(color: context.cs.error)),
              ),
            ),
        ],
      );
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    final mc = context.mc;
    return Material(
      color: cs.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
        child: Row(children: [
          for (var i = 0; i < RtiPhoneSteps.titles.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == step,
                label: 'Step ${i + 1} ${RtiPhoneSteps.titles[i]}',
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.read<RtiEntryBloc>().add(RtiStepChanged(i)),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: i == step ? cs.primary : (i < step ? mc.primarySoft : mc.surface2),
                        child: Text('${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: i == step ? cs.onPrimary : mc.muted)),
                      ),
                      const SizedBox(height: 2),
                      Text(RtiPhoneSteps.titles[i], maxLines: 1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: i == step ? cs.primary : mc.muted)),
                    ]),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
