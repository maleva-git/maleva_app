import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/plans/bloc/plans_bloc.dart';
import 'package:maleva/features/planning/plans/models/plans_filter.dart';
import 'package:maleva/features/planning/plans/widgets/plans_date_field.dart';

/// Planning View's filters (`PlanningView.tsx:286-357`): From / To dates, Planning No,
/// Employee, Login Employee, and the Report Date the report prints. Edits go to the draft;
/// View loads.
class PlansFilterForm extends StatefulWidget {
  const PlansFilterForm({super.key});

  @override
  State<PlansFilterForm> createState() => _PlansFilterFormState();
}

class _PlansFilterFormState extends State<PlansFilterForm> {
  late final TextEditingController _planNo = TextEditingController(text: context.read<PlansBloc>().state.draft.planningNo);

  @override
  void dispose() {
    _planNo.dispose();
    super.dispose();
  }

  void _change(PlansFilter f) => context.read<PlansBloc>().add(PlansDraftChanged(f));

  @override
  Widget build(BuildContext context) => BlocConsumer<PlansBloc, PlansState>(
        listenWhen: (a, b) => a.draft.planningNo != b.draft.planningNo,
        listener: (context, s) {
          if (_planNo.text != s.draft.planningNo) _planNo.text = s.draft.planningNo;
        },
        builder: (context, s) {
          final f = s.draft;
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(child: PlansDateField(label: 'From Date', value: f.fromDate, onChanged: (d) => _change(f.copyWith(fromDate: d)))),
              const SizedBox(width: 12),
              Expanded(child: PlansDateField(label: 'To Date', value: f.toDate, onChanged: (d) => _change(f.copyWith(toDate: d)))),
            ]),
            if (s.dateError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Semantics(
                  liveRegion: true,
                  child: Text(PlansBloc.datesOutOfOrder, style: TextStyle(color: context.cs.error, fontWeight: FontWeight.w700)),
                ),
              ),
            const SizedBox(height: 14),
            TextField(
              controller: _planNo,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(labelText: 'Planning No', hintText: 'Plan number...', prefixIcon: Icon(Icons.search)),
              onChanged: (v) => _change(context.read<PlansBloc>().state.draft.copyWith(planningNo: v)),
              onSubmitted: (_) => context.read<PlansBloc>().add(const PlansApplied()),
            ),
            const SizedBox(height: 14),
            PickerField(
              label: 'Employee',
              value: f.loginEmployee ? '' : f.employeeName,
              hint: 'Select employee...',
              enabled: !f.loginEmployee,
              icon: Icons.person_search_outlined,
              onTap: () async {
                final picked = await showPickerSheet<int>(context,
                    title: 'Employee', options: s.employees, current: f.employeeId == 0 ? null : f.employeeId, allowClear: true);
                if (picked == null || !context.mounted) return;
                final draft = context.read<PlansBloc>().state.draft;
                if (picked.cleared) {
                  _change(draft.copyWith(employeeId: 0, employeeName: ''));
                } else if (picked.value != null) {
                  final label = s.employees.firstWhere((o) => o.value == picked.value).label;
                  _change(draft.copyWith(employeeId: picked.value, employeeName: label));
                }
              },
            ),
            SwitchRow(
              label: 'Login Employee',
              subtitle: 'Only plans made by you',
              value: f.loginEmployee,
              onChanged: (v) => _change(f.copyWith(loginEmployee: v)),
            ),
            const SizedBox(height: 6),
            PlansDateField(
              label: 'Report Date',
              value: f.reportDate,
              onChanged: (d) => context.read<PlansBloc>().add(PlansReportDateChanged(d)),
            ),
          ]);
        },
      );
}

/// The form's Clear / View buttons.
class PlansFilterActions extends StatelessWidget {
  const PlansFilterActions({super.key, this.onDone});

  /// Called after View when the filters are valid (closes the sheet).
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) => BlocBuilder<PlansBloc, PlansState>(
        builder: (context, s) => Row(children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(96, 48)),
            onPressed: () {
              context.read<PlansBloc>().add(const PlansCleared());
              onDone?.call();
            },
            child: const Text('Clear'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: s.loading
                  ? null
                  : () {
                      context.read<PlansBloc>().add(const PlansApplied());
                      if (!s.dateError) onDone?.call();
                    },
              icon: s.loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.visibility_outlined),
              label: const Text('View'),
            ),
          ),
        ]),
      );
}
