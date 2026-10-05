import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/list/bloc/rti_list_bloc.dart';
import 'package:maleva/features/rti/list/models/rti_list_row.dart';
import 'package:maleva/features/rti/list/view/rti_filter_sheet.dart';
import 'package:maleva/features/rti/list/widgets/rti_actions.dart';
import 'package:maleva/features/rti/list/widgets/rti_card.dart';
import 'package:maleva/features/rti/list/widgets/rti_list_states.dart';
import 'package:maleva/features/rti/list/widgets/rti_preview.dart';
import 'package:maleva/features/rti/list/widgets/rti_toolbar.dart';

/// The RTI list on a phone: search bar + filter sheet, chips, stats, cards with Report / Share /
/// Edit, a preview bottom sheet and the New RTI button.
class RtiListPhoneView extends StatelessWidget {
  const RtiListPhoneView({super.key, this.onAssignments});

  final VoidCallback? onAssignments;

  Future<void> _preview(BuildContext context, RtiListRow row) async {
    final bloc = context.read<RtiListBloc>()..add(RtiListRowSelected(row.id, toggle: false));
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => BlocProvider.value(
        value: bloc,
        child: MalevaThemeScope(
          child: SizedBox(
            height: MediaQuery.sizeOf(ctx).height * 0.75,
            child: BlocBuilder<RtiListBloc, RtiListState>(
              builder: (ctx, s) => RtiPreview(row: s.selected ?? row, state: s, onClose: () => Navigator.of(ctx).pop()),
            ),
          ),
        ),
      ),
    );
    if (!bloc.isClosed) bloc.add(const RtiListPreviewClosed());
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<RtiListBloc, RtiListState>(
        builder: (context, s) => Scaffold(
          appBar: AppBar(
            title: const Text('RTI'),
            actions: [
              if (onAssignments != null && !s.isDriver)
                IconButton(tooltip: 'Employee assignments', onPressed: onAssignments, icon: const Icon(Icons.assignment_ind_outlined)),
            ],
          ),
          floatingActionButton: s.isDriver
              ? null
              : FloatingActionButton.extended(onPressed: () => openRtiNew(context), icon: const Icon(Icons.add), label: const Text('New RTI')),
          body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(children: [
                const Expanded(child: RtiFindBar()),
                const SizedBox(width: 8),
                RtiFilterButton(count: s.applied.activeCount(Fmt.today()), onPressed: () => showRtiFilterSheet(context)),
              ]),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 4), child: RtiChips(onOpenFilters: () => showRtiFilterSheet(context))),
            Padding(padding: const EdgeInsets.fromLTRB(16, 6, 16, 4), child: RtiStats(state: s)),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => context.read<RtiListBloc>().add(const RtiListRetried()),
                child: RtiListStateSwitch(
                  state: s,
                  content: (context) {
                    final rows = s.visible;
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
                      itemCount: rows.length,
                      itemBuilder: (context, i) => RtiCard(row: rows[i], state: s, onPreview: () => _preview(context, rows[i])),
                    );
                  },
                ),
              ),
            ),
          ]),
        ),
      );
}
