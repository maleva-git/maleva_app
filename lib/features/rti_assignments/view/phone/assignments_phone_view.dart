import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti_assignments/bloc/assignments_bloc.dart';
import 'package:maleva/features/rti_assignments/view/assignments_filter_sheet.dart';
import 'package:maleva/features/rti_assignments/widgets/assignment_card.dart';
import 'package:maleva/features/rti_assignments/widgets/assignments_states.dart';

/// Employee Assignments on a phone: filter sheet (Search / Clear), chips, "{n} jobs", cards.
class AssignmentsPhoneView extends StatelessWidget {
  const AssignmentsPhoneView({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AssignmentsBloc, AssignmentsState>(
        builder: (context, s) => Scaffold(
          appBar: AppBar(
            title: const Text('Employee assignments'),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: s.status == AssignmentsStatus.loading
                    ? null
                    : () => context.read<AssignmentsBloc>().add(const AssignmentsSearchRequested()),
                icon: const Icon(Icons.refresh),
              ),
              AssignmentsFilterButton(count: s.filter.activeCount(Fmt.today()), onPressed: () => showAssignmentsFilterSheet(context)),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: AssignmentsChips(onOpenFilters: () => showAssignmentsFilterSheet(context)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
              child: Text('${s.visible.length} jobs', style: TextStyle(color: context.mc.muted, fontWeight: FontWeight.w600)),
            ),
            Expanded(
              child: AssignmentsStateSwitch(
                state: s,
                content: (context) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: s.visible.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final job = s.visible[i];
                    return AssignmentCard(job: job, reportBusy: s.reportBusyId == job.rtiMasterRefId);
                  },
                ),
              ),
            ),
          ]),
        ),
      );
}
