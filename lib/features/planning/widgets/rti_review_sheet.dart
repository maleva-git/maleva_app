import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/rti/models/planning_transfer_item.dart';

/// Create RTI (review → working → result) and Push RTI (review → RTI form): a bottom sheet on
/// the phone, a dialog on a tablet.
abstract final class RtiReviewSheet {
  static Future<T?> _present<T>(BuildContext context, Widget Function(BuildContext) body) {
    if (FormFactor.of(context).isTablet) {
      return showDialog<T>(
        context: context,
        useRootNavigator: true,
        builder: (ctx) => MalevaThemeScope(
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640), child: body(ctx)),
          ),
        ),
      );
    }
    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (ctx) => MalevaThemeScope(child: SizedBox(height: MediaQuery.sizeOf(ctx).height * 0.85, child: body(ctx))),
    );
  }

  static Future<void> showCreate(BuildContext context, PlanCubit cubit) {
    final items = cubit.tickedItems();
    return _present<void>(context, (ctx) => BlocProvider.value(value: cubit, child: _CreateBody(items: items)));
  }

  static Future<bool?> showPush(BuildContext context, List<PlanningTransferItem> items) => _present<bool>(
        context,
        (ctx) => _Frame(
          title: 'Push to RTI',
          subtitle: 'Opens a new RTI with ${items.length} ticked job${items.length == 1 ? '' : 's'}',
          body: [
            _Facts(items: items),
            const SizedBox(height: 12),
            _JobList(items: items),
            const SizedBox(height: 12),
            Text('Nothing is saved yet. The RTI form opens with these jobs; you check it and save.', style: TextStyle(color: ctx.mc.muted)),
          ],
          actions: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel'))),
            const SizedBox(width: 12),
            Expanded(child: FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Push RTI'))),
          ],
        ),
      );
}

class _CreateBody extends StatelessWidget {
  const _CreateBody({required this.items});

  final List<PlanningTransferItem> items;

  @override
  Widget build(BuildContext context) => BlocBuilder<PlanCubit, PlanState>(
        buildWhen: (a, b) => a.rtiStage != b.rtiStage || a.rtiMessage != b.rtiMessage,
        builder: (context, s) {
          final cubit = context.read<PlanCubit>();
          final mc = context.mc;
          switch (s.rtiStage) {
            case RtiCreateStage.working:
              return _Frame(title: 'Create RTI', subtitle: 'One RTI from ${items.length} ticked jobs', body: const [
                SizedBox(height: 48),
                Center(child: CircularProgressIndicator()),
                SizedBox(height: 16),
                Center(child: Text('Creating...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
              ], actions: const []);
            case RtiCreateStage.done:
              return _Frame(title: 'Create RTI', subtitle: s.rtiMessage, body: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: mc.toneBg(StatusTone.success), borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    Icon(Icons.check_circle, color: mc.toneFg(StatusTone.success)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(s.rtiMessage, style: TextStyle(fontWeight: FontWeight.w800, color: mc.toneFg(StatusTone.success)))),
                  ]),
                ),
                const SizedBox(height: 12),
                _JobList(items: items),
              ], actions: [
                Expanded(child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))),
              ]);
            case RtiCreateStage.idle:
            case RtiCreateStage.refused:
              return _Frame(title: 'Create RTI', subtitle: 'One RTI from ${items.length} ticked job${items.length == 1 ? '' : 's'}', body: [
                _Facts(items: items, showDate: true),
                if (s.rtiStage == RtiCreateStage.refused) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: mc.dangerSoft, borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Icon(Icons.error_outline, color: context.cs.error),
                        const SizedBox(width: 10),
                        Expanded(child: Text(s.rtiMessage, style: TextStyle(color: context.cs.error, fontWeight: FontWeight.w700))),
                      ]),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _JobList(items: items),
              ], actions: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: cubit.createRti, child: const Text('Create RTI'))),
              ]);
          }
        },
      );
}

class _Frame extends StatelessWidget {
  const _Frame({required this.title, required this.subtitle, required this.body, required this.actions});

  final String title;
  final String subtitle;
  final List<Widget> body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                if (subtitle.isNotEmpty) Text(subtitle, style: TextStyle(color: context.mc.muted)),
              ]),
            ),
            IconButton(tooltip: 'Close', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
        ),
        Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 16), children: body)),
        if (actions.isNotEmpty)
          SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), child: Row(children: actions))),
      ]);
}

/// Truck and driver come from the first job (the web's RTI form takes them so).
class _Facts extends StatelessWidget {
  const _Facts({required this.items, this.showDate = false});

  final List<PlanningTransferItem> items;
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final first = items.isEmpty ? null : items.first;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(spacing: 24, runSpacing: 12, children: [
          LabeledValue('Truck', first?.truckName ?? ''),
          LabeledValue('Driver', first?.driverName ?? ''),
          if (showDate) LabeledValue('RTI date', Fmt.ddMMyyyy(Fmt.today())),
        ]),
      ),
    );
  }
}

class _JobList extends StatelessWidget {
  const _JobList({required this.items});

  final List<PlanningTransferItem> items;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('${items.length} job${items.length == 1 ? '' : 's'}'.toUpperCase(),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: context.mc.muted)),
        const SizedBox(height: 6),
        for (final i in items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(i.jobNo, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text([i.customerName, '${i.origin} → ${i.destination}'].where((t) => t.trim().isNotEmpty).join(' · ')),
            trailing: Text(Fmt.planningDateTime(i.pickupDate), style: TextStyle(color: context.mc.muted)),
          ),
      ]);
}
