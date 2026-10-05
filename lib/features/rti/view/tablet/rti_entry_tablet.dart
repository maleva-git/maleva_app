import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/view/phone/rti_entry_phone.dart';
import 'package:maleva/features/rti/view/phone/rti_phone_steps.dart';
import 'package:maleva/features/rti/view/tablet/rti_job_grid.dart';
import 'package:maleva/features/rti/view/tablet/rti_stop_grid.dart';
import 'package:maleva/features/rti/widgets/rti_charges.dart';
import 'package:maleva/features/rti/widgets/rti_entry_actions.dart';
import 'package:maleva/features/rti/widgets/rti_trip_fields.dart';

/// The tablet RTI form (`R/pages/RTIPage.tsx`): the toolbar (View F5, Clear F10, Delete,
/// Revise, Levi Entry, Save F1), the trip form beside the charges panel, then the full-width
/// job grid and route-activity grid. [columns] is 2 in portrait, 3 in landscape.
class RtiEntryTablet extends StatelessWidget {
  const RtiEntryTablet({super.key, required this.employeeName, required this.columns, required this.onRetry});

  final String employeeName;
  final int columns;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.f1): () => RtiEntryActions.save(context),
          const SingleActivator(LogicalKeyboardKey.f5): () => RtiEntryActions.view(context),
          const SingleActivator(LogicalKeyboardKey.f10): () => RtiEntryActions.clear(context),
        },
        child: Focus(
          autofocus: true,
          child: BlocBuilder<RtiEntryBloc, RtiEntryState>(
            buildWhen: (a, b) => a.form.isEdit != b.form.isEdit || a.status != b.status || a.busy != b.busy || a.refsError != b.refsError || a.errors != b.errors,
            builder: (context, s) => Scaffold(
              appBar: AppBar(
                title: RtiTitle(employeeName: employeeName, isEdit: s.form.isEdit),
                bottom: s.busy == RtiBusy.none || s.busy == RtiBusy.lookingUp
                    ? null
                    : const PreferredSize(preferredSize: Size.fromHeight(4), child: LinearProgressIndicator()),
              ),
              body: switch (s.status) {
                RtiLoadStatus.loading => const SkeletonList(),
                RtiLoadStatus.failed => ErrorState(title: 'Could not open the RTI', message: s.loadError, onRetry: onRetry),
                RtiLoadStatus.ready => Column(children: [
                    _Toolbar(state: s),
                    Expanded(
                      child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: [
                        if (s.refsError != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () => context.read<RtiEntryBloc>().add(const RtiReferencesRetried()),
                              child: RtiBanner(text: '${s.refsError} (tap to retry)', tone: StatusTone.danger),
                            ),
                          ),
                        const RtiReviseBanner(),
                        if (s.errors.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 12), child: RtiErrorList(errors: s.errors)),
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(
                              flex: columns == 3 ? 5 : 3,
                              child: DetailSection(
                                title: 'Trip Details',
                                child: Column(children: [RtiTripFields(columns: columns), RtiNotesFields(columns: columns == 3 ? 2 : 1)]),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              flex: 2,
                              child: DetailSection(
                                title: 'Charges',
                                child: Column(children: [RtiChargesSummary(), Divider(height: 24), RtiChargeFields()]),
                              ),
                            ),
                        ]),
                        const SizedBox(height: 12),
                        const RtiJobGrid(),
                        const SizedBox(height: 12),
                        const RtiStopGrid(),
                      ]),
                    ),
                  ]),
              },
            ),
          ),
        ),
      );
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.state});

  final RtiEntryState state;

  @override
  Widget build(BuildContext context) {
    final edit = state.form.isEdit;
    final busy = state.isBusy && state.busy != RtiBusy.lookingUp;
    final saving = state.busy == RtiBusy.saving;
    return Material(
      color: context.cs.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.end, children: [
          OutlinedButton.icon(onPressed: () => RtiEntryActions.view(context), icon: const Icon(Icons.list_alt), label: const Text('View  F5')),
          OutlinedButton.icon(onPressed: busy ? null : () => RtiEntryActions.clear(context), icon: const Icon(Icons.restart_alt), label: const Text('Clear  F10')),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: context.cs.error),
            onPressed: !edit || busy ? null : () => RtiEntryActions.delete(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
          OutlinedButton.icon(onPressed: !edit || busy ? null : () => RtiEntryActions.revise(context), icon: const Icon(Icons.sync), label: const Text('Revise')),
          OutlinedButton.icon(onPressed: !edit || busy ? null : () => RtiEntryActions.levi(context), icon: const Icon(Icons.receipt_long_outlined), label: const Text('Levi Entry')),
          if (edit) ...[
            IconButton.outlined(tooltip: 'Share to WhatsApp', onPressed: busy ? null : () => RtiEntryActions.share(context), icon: const Icon(Icons.send_outlined)),
            IconButton.outlined(tooltip: 'RTI report', onPressed: () => RtiEntryActions.report(context), icon: const Icon(Icons.picture_as_pdf_outlined)),
          ],
          FilledButton.icon(
            onPressed: busy ? null : () => RtiEntryActions.save(context),
            icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_outlined),
            label: Text(saving ? 'Saving...' : 'Save  F1'),
          ),
        ]),
      ),
    );
  }
}
