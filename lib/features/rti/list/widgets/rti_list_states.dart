import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/list/bloc/rti_list_bloc.dart';
import 'package:maleva/features/rti/list/models/rti_list_row.dart';
import 'package:maleva/features/rti/list/widgets/rti_actions.dart';

/// The list area's states (`RTIViewPage.tsx:537-568`): loading, still loading after 30 s,
/// unable to load, no records, waiting for login; else [content].
class RtiListStateSwitch extends StatelessWidget {
  const RtiListStateSwitch({super.key, required this.state, required this.content});

  final RtiListState state;
  final WidgetBuilder content;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RtiListBloc>();
    final mc = context.mc;
    switch (state.status) {
      case RtiListStatus.initial:
        return const EmptyState(
          icon: Icons.description_outlined,
          title: 'Waiting for login...',
          message: 'Please wait while your session is being loaded.',
        );
      case RtiListStatus.loading:
        return Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Semantics(
              liveRegion: true,
              child: Column(children: [
                const Text('Loading RTI records', style: TextStyle(fontWeight: FontWeight.w700)),
                Text('Please wait while the latest records are loaded.', style: TextStyle(color: mc.muted, fontSize: 13)),
              ]),
            ),
          ),
          const Expanded(child: SkeletonList(count: 4)),
        ]);
      case RtiListStatus.slow:
        return EmptyState(
          icon: Icons.schedule,
          title: 'Still loading records',
          message: 'The RTI request is taking longer than usual. You can wait or try again with a smaller date range.',
          actionLabel: 'Retry',
          onAction: () => bloc.add(const RtiListRetried()),
        );
      case RtiListStatus.failure:
        return ErrorState(title: 'Unable to load records', message: state.error, onRetry: () => bloc.add(const RtiListRetried()));
      case RtiListStatus.success:
        if (state.visible.isEmpty) {
          return ListView(children: [
            const EmptyState(
              icon: Icons.description_outlined,
              title: 'No RTI records found',
              message: 'Try adjusting your date range, changing filters, or uncheck "My RTIs Only" to see all records.',
            ),
            Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 8, children: [
              if (!state.isDriver)
                FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
                  onPressed: () => openRtiNew(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Create New RTI'),
                ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: () => bloc.add(const RtiListCleared()),
                child: const Text('Clear Filters'),
              ),
            ]),
          ]);
        }
        return content(context);
    }
  }
}

/// Records · Total Amount (`RTIViewPage.tsx:506-516`), shown when there are rows.
class RtiStats extends StatelessWidget {
  const RtiStats({super.key, required this.state});

  final RtiListState state;

  @override
  Widget build(BuildContext context) {
    final rows = state.visible;
    if (rows.isEmpty || state.status != RtiListStatus.success) return const SizedBox.shrink();
    Widget tile(String label, String value) => Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.mc.muted)),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              ]),
            ),
          ),
        );
    return Row(children: [
      tile('Records', '${rows.length}'),
      const SizedBox(width: 10),
      tile('Total Amount', RtiListRow.rmFixed(state.totalAmount)),
    ]);
  }
}
