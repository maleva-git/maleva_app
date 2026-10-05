import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti_assignments/bloc/assignments_bloc.dart';

/// The result area: "Loading assignments...", the error, "No Assignments Found" (also before
/// the first Search, as React), else [content].
class AssignmentsStateSwitch extends StatelessWidget {
  const AssignmentsStateSwitch({super.key, required this.state, required this.content});

  final AssignmentsState state;
  final WidgetBuilder content;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case AssignmentsStatus.loading:
        return Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Semantics(liveRegion: true, child: const Text('Loading assignments...', style: TextStyle(fontWeight: FontWeight.w700))),
          ),
          const Expanded(child: SkeletonList(count: 3)),
        ]);
      case AssignmentsStatus.failure:
        return ErrorState(
          title: state.error.isEmpty ? 'Error loading data' : state.error,
          onRetry: () => context.read<AssignmentsBloc>().add(const AssignmentsSearchRequested()),
        );
      case AssignmentsStatus.idle:
      case AssignmentsStatus.success:
        if (state.visible.isEmpty) {
          return const EmptyState(
            icon: Icons.description_outlined,
            title: 'No Assignments Found',
            message: 'Try adjusting your filters or date range.',
          );
        }
        return content(context);
    }
  }
}

/// The applied filters as chips: the dates (opens the filters) and My Job Only (filters at once).
class AssignmentsChips extends StatelessWidget {
  const AssignmentsChips({super.key, required this.onOpenFilters});

  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) => BlocBuilder<AssignmentsBloc, AssignmentsState>(
        builder: (context, s) {
          final f = s.filter;
          final from = f.fromDate, to = f.toDate;
          final range = from == null || to == null
              ? 'Pick dates'
              : from == to
                  ? Fmt.dMonY(from)
                  : '${Fmt.dMonY(from)} – ${Fmt.dMonY(to)}';
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              ActionChip(avatar: const Icon(Icons.calendar_today_outlined, size: 18), label: Text(range), onPressed: onOpenFilters),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('My Job Only'),
                selected: f.myJobOnly,
                onSelected: (v) => context.read<AssignmentsBloc>().add(AssignmentsFilterChanged(f.copyWith(myJobOnly: v))),
              ),
              if (!f.myJobOnly && f.employeeId != 0) ...[
                const SizedBox(width: 8),
                InputChip(
                  avatar: const Icon(Icons.person_outline, size: 18),
                  label: Text(f.employeeName),
                  onDeleted: () => context.read<AssignmentsBloc>().add(AssignmentsFilterChanged(f.copyWith(employeeId: 0, employeeName: ''))),
                ),
              ],
            ]),
          );
        },
      );
}
