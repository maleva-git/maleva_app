import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/list/widgets/rti_date_field.dart';
import 'package:maleva/features/rti_assignments/bloc/assignments_bloc.dart';
import 'package:maleva/features/rti_assignments/models/assignments_filter.dart';

/// From / To Date (required), Employee ("All Employees", disabled with My Job Only) and
/// "My Job Only" (`EmployeeAssignmentsPage.tsx:140-235`).
class AssignmentsFilterForm extends StatelessWidget {
  const AssignmentsFilterForm({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AssignmentsBloc, AssignmentsState>(
        builder: (context, s) {
          final bloc = context.read<AssignmentsBloc>();
          final f = s.filter;
          void change(AssignmentsFilter n) => bloc.add(AssignmentsFilterChanged(n));
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                child: RtiDateField(
                  label: 'From Date',
                  required: true,
                  value: f.fromDate,
                  onChanged: (d) => change(bloc.state.filter.copyWith(fromDate: () => d)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RtiDateField(
                  label: 'To Date',
                  required: true,
                  value: f.toDate,
                  onChanged: (d) => change(bloc.state.filter.copyWith(toDate: () => d)),
                ),
              ),
            ]),
            const SizedBox(height: 14),
            PickerField(
              label: 'Employee',
              value: f.employeeName,
              hint: 'All Employees',
              enabled: !f.myJobOnly,
              icon: Icons.person_search_outlined,
              onTap: () async {
                final picked = await showPickerSheet<int>(context,
                    title: 'Employee', options: s.employees, current: f.employeeId == 0 ? null : f.employeeId, allowClear: true);
                if (picked == null || !context.mounted) return;
                if (picked.cleared) {
                  change(bloc.state.filter.copyWith(employeeId: 0, employeeName: ''));
                } else if (picked.value != null) {
                  final label = s.employees.firstWhere((o) => o.value == picked.value).label;
                  change(bloc.state.filter.copyWith(employeeId: picked.value, employeeName: label));
                }
              },
            ),
            SwitchRow(
              label: 'My Job Only',
              value: f.myJobOnly,
              onChanged: (v) => change(bloc.state.filter.copyWith(myJobOnly: v)),
            ),
          ]);
        },
      );
}

/// Clear (does not search) and Search.
class AssignmentsFilterActions extends StatelessWidget {
  const AssignmentsFilterActions({super.key, this.onDone});

  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) => BlocBuilder<AssignmentsBloc, AssignmentsState>(
        builder: (context, s) => Row(children: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(minimumSize: const Size(96, 48)),
            onPressed: () => context.read<AssignmentsBloc>().add(const AssignmentsCleared()),
            icon: const Icon(Icons.refresh),
            label: const Text('Clear'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: s.status == AssignmentsStatus.loading
                  ? null
                  : () {
                      context.read<AssignmentsBloc>().add(const AssignmentsSearchRequested());
                      if (s.filter.fromDate != null && s.filter.toDate != null) onDone?.call();
                    },
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
          ),
        ]),
      );
}
