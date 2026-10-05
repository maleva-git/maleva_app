import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/list/bloc/rti_list_bloc.dart';
import 'package:maleva/features/rti/list/models/rti_list_filter.dart';
import 'package:maleva/features/rti/list/widgets/rti_date_field.dart';

/// The RTI list's filters (`RTIViewPage.tsx:409-486`): From / To Date, Driver, Truck, RTI No,
/// My RTIs and Not Salary Entered RTI. Edits go to the draft; View (or Enter in RTI No) loads.
/// "Not Salary Entered RTI" filters the loaded rows at once.
class RtiFilterForm extends StatefulWidget {
  const RtiFilterForm({super.key});

  @override
  State<RtiFilterForm> createState() => _RtiFilterFormState();
}

class _RtiFilterFormState extends State<RtiFilterForm> {
  late final TextEditingController _rtiNo = TextEditingController(text: context.read<RtiListBloc>().state.draft.rtiNo);

  @override
  void dispose() {
    _rtiNo.dispose();
    super.dispose();
  }

  void _change(RtiListFilter f) => context.read<RtiListBloc>().add(RtiListDraftChanged(f));

  Future<void> _pick(String title, List<PickOption<int>> options, int current, void Function(int id, String name) onPicked) async {
    final picked = await showPickerSheet<int>(context, title: title, options: options, current: current == 0 ? null : current, allowClear: true);
    if (picked == null || !mounted) return;
    if (picked.cleared) {
      onPicked(0, '');
    } else if (picked.value != null) {
      onPicked(picked.value!, options.firstWhere((o) => o.value == picked.value).label);
    }
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<RtiListBloc, RtiListState>(
        listenWhen: (a, b) => a.draft.rtiNo != b.draft.rtiNo,
        listener: (_, s) {
          if (_rtiNo.text != s.draft.rtiNo) _rtiNo.text = s.draft.rtiNo;
        },
        builder: (context, s) {
          final f = s.draft;
          final bloc = context.read<RtiListBloc>();
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Wrap(spacing: 8, children: [
              for (final (label, from, to) in _quickRanges())
                ChoiceChip(
                  label: Text(label),
                  selected: f.fromDate == from && f.toDate == to,
                  onSelected: (_) => _change(bloc.state.draft.copyWith(fromDate: from, toDate: to)),
                ),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: RtiDateField(label: 'From Date', value: f.fromDate, onChanged: (d) => _change(bloc.state.draft.copyWith(fromDate: d)))),
              const SizedBox(width: 12),
              Expanded(child: RtiDateField(label: 'To Date', value: f.toDate, onChanged: (d) => _change(bloc.state.draft.copyWith(toDate: d)))),
            ]),
            if (!s.isDriver) ...[
              const SizedBox(height: 14),
              PickerField(
                label: 'Driver',
                value: f.driverName,
                hint: 'All Drivers',
                icon: Icons.person_search_outlined,
                onTap: () => _pick('Driver', s.drivers, f.driverId,
                    (id, name) => _change(bloc.state.draft.copyWith(driverId: id, driverName: name))),
              ),
              const SizedBox(height: 14),
              PickerField(
                label: 'Truck',
                value: f.truckName,
                hint: 'All Trucks',
                icon: Icons.local_shipping_outlined,
                onTap: () => _pick('Truck', s.trucks, f.truckId,
                    (id, name) => _change(bloc.state.draft.copyWith(truckId: id, truckName: name))),
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _rtiNo,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(labelText: 'RTI No', hintText: 'Search RTI...', prefixIcon: Icon(Icons.search)),
              onChanged: (v) => _change(bloc.state.draft.copyWith(rtiNo: v)),
              onSubmitted: (_) => bloc.add(const RtiListApplied()),
            ),
            const SizedBox(height: 6),
            if (!s.isDriver)
              SwitchRow(label: 'My RTIs', value: f.myRtis, onChanged: (v) => _change(bloc.state.draft.copyWith(myRtis: v))),
            SwitchRow(
              label: 'Not Salary Entered RTI',
              subtitle: 'Amount is RM 0.00',
              value: f.notSalary,
              onChanged: (v) => bloc.add(RtiListNotSalaryToggled(v)),
            ),
          ]);
        },
      );

  /// Today / Tomorrow / This week (Monday to Sunday), a mobile shortcut for the dates.
  static List<(String, DateTime, DateTime)> _quickRanges() {
    final t = Fmt.today();
    final monday = t.subtract(Duration(days: t.weekday - 1));
    final tomorrow = DateTime(t.year, t.month, t.day + 1);
    return [
      ('Today', t, t),
      ('Tomorrow', tomorrow, tomorrow),
      ('This week', monday, DateTime(monday.year, monday.month, monday.day + 6)),
    ];
  }
}

/// The form's Clear / View buttons.
class RtiFilterActions extends StatelessWidget {
  const RtiFilterActions({super.key, this.onDone});

  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) => BlocBuilder<RtiListBloc, RtiListState>(
        builder: (context, s) => Row(children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: const Size(96, 48)),
            onPressed: () {
              context.read<RtiListBloc>().add(const RtiListCleared());
              onDone?.call();
            },
            child: const Text('Clear'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: () {
                context.read<RtiListBloc>().add(const RtiListApplied());
                onDone?.call();
              },
              icon: s.loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.search),
              label: const Text('View'),
            ),
          ),
        ]),
      );
}
