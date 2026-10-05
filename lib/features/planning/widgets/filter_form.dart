import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/models/plan_header.dart';
import 'package:maleva/features/planning/widgets/date_fields.dart';

/// Every field of the web's search form (`PlanningFilters.tsx:375-535`) plus Today / Tomorrow /
/// This week. The buttons (Clear all, Search) belong to the sheet or panel around it.
class FilterForm extends StatelessWidget {
  const FilterForm({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<PlanCubit, PlanState>(
        buildWhen: (a, b) =>
            a.header != b.header ||
            a.searchError != b.searchError ||
            a.fetchingPlan != b.fetchingPlan ||
            a.employees != b.employees ||
            a.ports != b.ports ||
            a.actions != b.actions ||
            a.editId != b.editId,
        builder: (context, s) {
          final cubit = context.read<PlanCubit>();
          final h = s.header;
          final locked = !s.access.canWrite;
          final today = PlanHeader.ymd(cubit.today);
          final tomorrow = PlanHeader.ymd(cubit.today.add(const Duration(days: 1)));
          final weekEnd = PlanHeader.ymd(cubit.today.add(Duration(days: DateTime.sunday - cubit.today.weekday)));
          String quick() {
            if (h.pickupFromDate == today && h.pickupToDate == today) return 'today';
            if (h.pickupFromDate == tomorrow && h.pickupToDate == tomorrow) return 'tomorrow';
            if (h.pickupFromDate == today && h.pickupToDate == weekEnd) return 'week';
            return '';
          }

          final employee = s.employees.where((e) => '${e.id}' == h.employee).firstOrNull;
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (s.searchError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Semantics(
                  liveRegion: true,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: context.mc.dangerSoft, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      Icon(Icons.error_outline, color: context.cs.error),
                      const SizedBox(width: 8),
                      Expanded(child: Text(s.searchError!, style: TextStyle(color: context.cs.error, fontWeight: FontWeight.w700))),
                    ]),
                  ),
                ),
              ),
            _PlanNoField(value: h.planningNo, busy: s.fetchingPlan),
            const SizedBox(height: 14),
            DateField(
              label: 'Plan date',
              required: true,
              value: h.planningDate,
              enabled: !locked,
              errorText: h.planningDate.isEmpty ? 'Required' : null,
              onChanged: (v) => cubit.updateHeader((x) => x.copyWith(planningDate: v), counts: true),
            ),
            const SizedBox(height: 14),
            Text('PICKUP DATES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: context.mc.muted)),
            const SizedBox(height: 6),
            SegmentedChoice<String>(
              values: const ['today', 'tomorrow', 'week'],
              selected: quick(),
              labelOf: (v) => switch (v) { 'today' => 'Today', 'tomorrow' => 'Tomorrow', _ => 'This week' },
              onChanged: cubit.setQuickRange,
            ),
            const SizedBox(height: 8),
            DateField(
                label: 'From', value: h.pickupFromDate, clearable: true, onChanged: (v) => cubit.updateHeader((x) => x.copyWith(pickupFromDate: v))),
            const SizedBox(height: 8),
            DateField(label: 'To', value: h.pickupToDate, clearable: true, onChanged: (v) => cubit.updateHeader((x) => x.copyWith(pickupToDate: v))),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: PickerField(
                  label: 'Port',
                  value: h.port,
                  hint: 'Select port...',
                  onTap: () async {
                    final r = await showPickerSheet<String>(context,
                        title: 'Port',
                        options: [for (final p in s.ports) PickOption(value: p, label: p)],
                        current: h.port.isEmpty ? null : h.port,
                        allowClear: true);
                    if (r == null || cubit.isClosed) return;
                    cubit.updateHeader((x) => x.copyWith(port: r.cleared ? '' : r.value));
                  },
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(onPressed: cubit.appendPort, icon: const Icon(Icons.add), label: const Text('Add')),
            ]),
            const SizedBox(height: 14),
            PickerField(
              label: 'Employee',
              value: employee?.name ?? '',
              hint: 'Select employee...',
              icon: Icons.search,
              onTap: () async {
                final r = await showPickerSheet<int>(context,
                    title: 'Employee',
                    options: [for (final e in s.employees) PickOption(value: e.id, label: e.name)],
                    current: employee?.id,
                    allowClear: true,
                    searchHint: 'Search employee...');
                if (r == null || cubit.isClosed) return;
                cubit.updateHeader((x) => x.copyWith(employee: r.cleared ? '' : '${r.value}'), counts: true);
              },
            ),
            const SizedBox(height: 14),
            _SyncedText(
              label: 'Search',
              hint: 'Job numbers, comma separated...',
              value: h.searchText,
              icon: Icons.search,
              onChanged: (v) => cubit.updateHeader((x) => x.copyWith(searchText: v)),
              onSubmitted: (_) => cubit.search(),
            ),
            const SizedBox(height: 14),
            _SyncedText(
              label: 'Remarks',
              hint: locked ? '' : 'Enter notes and remarks...',
              value: h.remarks,
              readOnly: locked,
              onChanged: (v) => cubit.updateHeader((x) => x.copyWith(remarks: v), counts: true),
            ),
          ]);
        },
      );
}

/// The removable chips for what the search form holds (dates, each search value, employee).
List<ActiveFilter> activeFilters(PlanCubit cubit, PlanState s) {
  final h = s.header;
  String day(String v) => v.isEmpty ? '…' : Fmt.planningDateTime(v);
  final values = h.searchText.split(',').map((v) => v.trim()).where((v) => v.isNotEmpty).toList();
  final employee = s.employees.where((e) => '${e.id}' == h.employee).firstOrNull;
  return [
    if (h.pickupFromDate.isNotEmpty || h.pickupToDate.isNotEmpty)
      ActiveFilter(
          '${day(h.pickupFromDate)} – ${day(h.pickupToDate)}', () => cubit.updateHeader((x) => x.copyWith(pickupFromDate: '', pickupToDate: '')),
          icon: Icons.event),
    for (final v in values)
      ActiveFilter(
          v,
          () => cubit.updateHeader((x) => x.copyWith(
                  searchText: [
                for (final o in values)
                  if (o != v) o
              ].join(',')))),
    if (h.employee.isNotEmpty)
      ActiveFilter(employee?.name ?? h.employee, () => cubit.updateHeader((x) => x.copyWith(employee: ''), counts: true), icon: Icons.person_outline),
  ];
}

/// Clear all: the search fields only (the plan's own fields stay).
void clearFilters(PlanCubit cubit) => cubit.updateHeader((x) => x.copyWith(pickupFromDate: '', pickupToDate: '', searchText: '', employee: ''));

class _PlanNoField extends StatelessWidget {
  const _PlanNoField({required this.value, required this.busy});

  final String value;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlanCubit>();
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: _SyncedText(
          label: 'Plan no.',
          hint: 'e.g. 782 or PL000000782',
          value: value,
          keyboard: TextInputType.number,
          action: TextInputAction.go,
          busy: busy,
          onChanged: (v) => cubit.updateHeader((x) => x.copyWith(planningNo: v)),
          onSubmitted: cubit.openPlanNumber,
        ),
      ),
      const SizedBox(width: 8),
      FilledButton.tonal(onPressed: busy ? null : () => cubit.openPlanNumber(cubit.state.header.planningNo), child: const Text('Open')),
    ]);
  }
}

/// A text box that follows the form when the plan changes, without losing what is being typed.
class _SyncedText extends StatefulWidget {
  const _SyncedText({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.icon,
    this.readOnly = false,
    this.keyboard,
    this.action,
    this.onSubmitted,
    this.busy = false,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final IconData? icon;
  final bool readOnly;
  final TextInputType? keyboard;
  final TextInputAction? action;
  final ValueChanged<String>? onSubmitted;
  final bool busy;

  @override
  State<_SyncedText> createState() => _SyncedTextState();
}

class _SyncedTextState extends State<_SyncedText> {
  late final TextEditingController _c = TextEditingController(text: widget.value);
  final FocusNode _focus = FocusNode();

  @override
  void didUpdateWidget(covariant _SyncedText old) {
    super.didUpdateWidget(old);
    if (!_focus.hasFocus && _c.text != widget.value) _c.text = widget.value;
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        label: widget.busy ? '${widget.label}, loading' : null,
        child: TextField(
          controller: _c,
          focusNode: _focus,
          readOnly: widget.readOnly,
          keyboardType: widget.keyboard,
          textInputAction: widget.action,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            prefixIcon: widget.icon == null ? null : Icon(widget.icon),
            suffixIcon: widget.busy
                ? const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                : null,
          ),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
      );
}
