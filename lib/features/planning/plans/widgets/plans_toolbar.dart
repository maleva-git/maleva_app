import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/planning_navigation.dart';
import 'package:maleva/features/planning/plans/bloc/plans_bloc.dart';
import 'package:maleva/features/planning/plans/models/plan_row.dart';
import 'package:maleva/features/planning/plans/widgets/plans_date_field.dart';

/// Opens the plan screen (`/planning/edit/{id}` on the web), then reloads the list.
Future<void> openPlanAndRefresh(BuildContext context, PlanRow plan) async {
  final bloc = context.read<PlansBloc>();
  try {
    await PlanningNavigation.openPlan(context, id: plan.id);
  } on UnimplementedError {
    if (context.mounted) showSnack(context, 'The plan screen is not available yet', kind: SnackKind.info);
    return;
  }
  if (!bloc.isClosed) bloc.add(const PlansRefreshed());
}

/// "04 – 05 Oct 2026".
String plansRangeLabel(DateTime from, DateTime to) => from == to ? Fmt.dMonY(from) : '${Fmt.dMonY(from).substring(0, 2)} – ${Fmt.dMonY(to)}';

/// The plan-number search bar (exact number; ignores the dates).
class PlansSearchBar extends StatefulWidget {
  const PlansSearchBar({super.key});

  @override
  State<PlansSearchBar> createState() => _PlansSearchBarState();
}

class _PlansSearchBarState extends State<PlansSearchBar> {
  late final TextEditingController _c = TextEditingController(text: context.read<PlansBloc>().state.draft.planningNo);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocListener<PlansBloc, PlansState>(
        listenWhen: (a, b) => a.draft.planningNo != b.draft.planningNo,
        listener: (_, s) {
          if (_c.text != s.draft.planningNo) _c.text = s.draft.planningNo;
        },
        child: TextField(
          controller: _c,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Plan no., e.g. PL000000782',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              tooltip: 'Search',
              icon: const Icon(Icons.arrow_forward),
              onPressed: () => context.read<PlansBloc>().add(PlansSearchSubmitted(_c.text)),
            ),
          ),
          onChanged: (v) {
            final bloc = context.read<PlansBloc>();
            bloc.add(PlansDraftChanged(bloc.state.draft.copyWith(planningNo: v)));
          },
          onSubmitted: (v) => context.read<PlansBloc>().add(PlansSearchSubmitted(v)),
        ),
      );
}

/// The applied filters as chips: the dates (opens the filters), Login Employee (toggles and
/// reloads), the employee and plan number (removable), and the Report Date.
class PlansChips extends StatelessWidget {
  const PlansChips({super.key, required this.onOpenFilters});

  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) => BlocBuilder<PlansBloc, PlansState>(
        builder: (context, s) {
          final bloc = context.read<PlansBloc>();
          final a = s.applied;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              ActionChip(
                avatar: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(plansRangeLabel(a.fromDate, a.toDate)),
                onPressed: onOpenFilters,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Login Employee'),
                selected: a.loginEmployee,
                onSelected: (v) => bloc.add(PlansQuickFilterChanged(a.copyWith(reportDate: s.draft.reportDate, loginEmployee: v))),
              ),
              if (!a.loginEmployee && a.employeeId != 0) ...[
                const SizedBox(width: 8),
                InputChip(
                  avatar: const Icon(Icons.person_outline, size: 18),
                  label: Text(a.employeeName),
                  onDeleted: () => bloc.add(PlansQuickFilterChanged(a.copyWith(reportDate: s.draft.reportDate, employeeId: 0, employeeName: ''))),
                ),
              ],
              if (a.planningNo.trim().isNotEmpty) ...[
                const SizedBox(width: 8),
                InputChip(
                  avatar: const Icon(Icons.tag, size: 18),
                  label: Text(a.planningNo),
                  onDeleted: () => bloc.add(PlansQuickFilterChanged(a.copyWith(reportDate: s.draft.reportDate, planningNo: ''))),
                ),
              ],
              const SizedBox(width: 8),
              ActionChip(
                avatar: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: Text('Report ${Fmt.ddMMyyyy(s.draft.reportDate).substring(0, 5)}'),
                tooltip: 'Report Date',
                onPressed: () async {
                  final picked = await pickPlansDate(context, s.draft.reportDate);
                  if (picked != null) bloc.add(PlansReportDateChanged(picked));
                },
              ),
            ]),
          );
        },
      );
}
