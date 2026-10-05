import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti_assignments/bloc/assignments_bloc.dart';
import 'package:maleva/features/rti_assignments/view/assignments_filter_sheet.dart';
import 'package:maleva/features/rti_assignments/widgets/assignment_card.dart';
import 'package:maleva/features/rti_assignments/widgets/assignments_states.dart';
import 'package:maleva/features/rti_assignments/widgets/assignments_table.dart';

Widget _refresh(BuildContext context, AssignmentsState s) => FilledButton.icon(
      style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
      onPressed: s.status == AssignmentsStatus.loading ? null : () => context.read<AssignmentsBloc>().add(const AssignmentsSearchRequested()),
      icon: const Icon(Icons.refresh),
      label: const Text('Refresh'),
    );

/// Employee Assignments on a tablet held upright: two columns of cards; filters in a side sheet.
class AssignmentsTabletPortraitView extends StatelessWidget {
  const AssignmentsTabletPortraitView({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AssignmentsBloc, AssignmentsState>(
        builder: (context, s) => Scaffold(
          appBar: AppBar(
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Employee assignments'),
              Text('Manage and track all employee, driver & truck assignments', style: TextStyle(fontSize: 13, color: context.mc.muted)),
            ]),
            actions: [
              AssignmentsFilterButton(label: true, count: s.filter.activeCount(Fmt.today()), onPressed: () => showAssignmentsFilterSheet(context)),
              const SizedBox(width: 8),
              _refresh(context, s),
              const SizedBox(width: 12),
            ],
          ),
          body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(children: [
                Expanded(child: AssignmentsChips(onOpenFilters: () => showAssignmentsFilterSheet(context))),
                Text('${s.visible.length} jobs', style: TextStyle(color: context.mc.muted, fontWeight: FontWeight.w600)),
              ]),
            ),
            Expanded(
              child: AssignmentsStateSwitch(
                state: s,
                content: (context) => GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 330,
                  ),
                  itemCount: s.visible.length,
                  itemBuilder: (context, i) {
                    final job = s.visible[i];
                    return SingleChildScrollView(child: AssignmentCard(job: job, reportBusy: s.reportBusyId == job.rtiMasterRefId));
                  },
                ),
              ),
            ),
          ]),
        ),
      );
}

/// Employee Assignments on a tablet held sideways: filters in a side panel and React's table.
class AssignmentsTabletLandscapeView extends StatelessWidget {
  const AssignmentsTabletLandscapeView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Material(
              color: context.cs.surface,
              child: Container(
                width: 290,
                decoration: BoxDecoration(border: Border(right: BorderSide(color: context.mc.outline))),
                child: const AssignmentsFilterPanel(),
              ),
            ),
            Expanded(
              child: BlocBuilder<AssignmentsBloc, AssignmentsState>(
                builder: (context, s) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                    child: Row(children: [
                      if (Navigator.of(context).canPop()) const BackButton(),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Employee assignments', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                          Text('${s.visible.length} jobs', style: TextStyle(fontSize: 13, color: context.mc.muted)),
                        ]),
                      ),
                      _refresh(context, s),
                    ]),
                  ),
                  Expanded(
                    child: AssignmentsStateSwitch(
                      state: s,
                      content: (context) => Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: AssignmentsTable(rows: s.visible, reportBusyId: s.reportBusyId),
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
