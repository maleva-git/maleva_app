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
import 'package:maleva/features/rti/list/widgets/rti_table.dart';
import 'package:maleva/features/rti/list/widgets/rti_toolbar.dart';

Widget _previewPane(BuildContext context, RtiListState s) {
  final row = s.selected;
  if (row == null) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('Tap an RTI to preview it', style: TextStyle(color: context.mc.muted)),
      ),
    );
  }
  return RtiPreview(row: row, state: s, onClose: () => context.read<RtiListBloc>().add(const RtiListPreviewClosed()));
}

List<Widget> _newRti(BuildContext context, RtiListState s) => [
      if (!s.isDriver)
        FilledButton.tonalIcon(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          onPressed: () => openRtiNew(context),
          icon: const Icon(Icons.add),
          label: const Text('New RTI'),
        ),
    ];

/// The RTI list on a tablet held upright: search, chips, stats, the list and a preview pane.
class RtiListTabletPortraitView extends StatelessWidget {
  const RtiListTabletPortraitView({super.key, this.onAssignments});

  final VoidCallback? onAssignments;

  @override
  Widget build(BuildContext context) => BlocBuilder<RtiListBloc, RtiListState>(
        builder: (context, s) => Scaffold(
          appBar: AppBar(
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('RTI'),
              Text('Request for transport · ${rtiRangeLabel(s.applied.fromDate, s.applied.toDate)}',
                  style: TextStyle(fontSize: 13, color: context.mc.muted)),
            ]),
            actions: [
              if (onAssignments != null && !s.isDriver)
                IconButton(tooltip: 'Employee assignments', onPressed: onAssignments, icon: const Icon(Icons.assignment_ind_outlined)),
              RtiFilterButton(label: true, count: s.applied.activeCount(Fmt.today()), onPressed: () => showRtiFilterSheet(context)),
              const SizedBox(width: 8),
              ..._newRti(context, s),
              const SizedBox(width: 12),
            ],
          ),
          body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const RtiFindBar(),
                const SizedBox(height: 10),
                RtiChips(onOpenFilters: () => showRtiFilterSheet(context)),
                const SizedBox(height: 10),
                RtiStats(state: s),
                const SizedBox(height: 10),
              ]),
            ),
            Divider(height: 1, color: context.mc.outline),
            Expanded(
              child: RtiListStateSwitch(
                state: s,
                content: (context) {
                  final List<RtiListRow> rows = s.visible;
                  return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width * 0.46,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: rows.length,
                        itemBuilder: (context, i) => RtiListTile(
                          row: rows[i],
                          selected: s.preview?.id == rows[i].id,
                          onTap: () => context.read<RtiListBloc>().add(RtiListRowSelected(rows[i].id)),
                          onDoubleTap: s.isDriver ? null : () => openRtiEdit(context, rows[i].id),
                        ),
                      ),
                    ),
                    VerticalDivider(width: 1, color: context.mc.outline),
                    Expanded(child: _previewPane(context, s)),
                  ]);
                },
              ),
            ),
          ]),
        ),
      );
}

/// The RTI list on a tablet held sideways: filters in a side panel, React's table and the preview.
class RtiListTabletLandscapeView extends StatelessWidget {
  const RtiListTabletLandscapeView({super.key, this.onAssignments});

  final VoidCallback? onAssignments;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Material(
              color: context.cs.surface,
              child: Container(
                width: 290,
                decoration: BoxDecoration(border: Border(right: BorderSide(color: context.mc.outline))),
                child: const RtiFilterPanel(),
              ),
            ),
            Expanded(
              child: BlocBuilder<RtiListBloc, RtiListState>(
                builder: (context, s) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                    child: Row(children: [
                      if (Navigator.of(context).canPop()) const BackButton(),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('RTI', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                          Text(
                            s.status == RtiListStatus.success
                                ? 'Showing ${s.visible.length} records · ${RtiListRow.rmFixed(s.totalAmount)}'
                                : rtiRangeLabel(s.applied.fromDate, s.applied.toDate),
                            style: TextStyle(fontSize: 13, color: context.mc.muted),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 320, child: RtiFindBar()),
                      const SizedBox(width: 8),
                      if (onAssignments != null && !s.isDriver)
                        IconButton(tooltip: 'Employee assignments', onPressed: onAssignments, icon: const Icon(Icons.assignment_ind_outlined)),
                      ..._newRti(context, s),
                    ]),
                  ),
                  Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), child: RtiChips(onOpenFilters: () {})),
                  Expanded(
                    child: RtiListStateSwitch(
                      state: s,
                      content: (context) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          Expanded(child: RtiTable(state: s)),
                          const SizedBox(width: 12),
                          SizedBox(width: 340, child: Card(margin: EdgeInsets.zero, child: _previewPane(context, s))),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      );
}
