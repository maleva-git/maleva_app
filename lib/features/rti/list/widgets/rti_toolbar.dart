import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/list/bloc/rti_list_bloc.dart';

/// "03 – 05 Oct 2026", or one day.
String rtiRangeLabel(DateTime from, DateTime to) =>
    from == to ? Fmt.dMonY(from) : '${Fmt.dMonY(from).substring(0, 2)} – ${Fmt.dMonY(to)}';

/// The search bar: finds an RTI or job number among the loaded RTIs (client side). The server's
/// exact RTI No search is in the filters.
class RtiFindBar extends StatefulWidget {
  const RtiFindBar({super.key});

  @override
  State<RtiFindBar> createState() => _RtiFindBarState();
}

class _RtiFindBarState extends State<RtiFindBar> {
  late final TextEditingController _c = TextEditingController(text: context.read<RtiListBloc>().state.find);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _c,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'RTI no. or job no.',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: ValueListenableBuilder(
            valueListenable: _c,
            builder: (context, v, _) => v.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _c.clear();
                      context.read<RtiListBloc>().add(const RtiListFindChanged(''));
                    },
                    icon: const Icon(Icons.close),
                  ),
          ),
        ),
        onChanged: (v) => context.read<RtiListBloc>().add(RtiListFindChanged(v)),
      );
}

/// The applied filters as chips: dates (opens the filters), My RTIs (toggles and reloads), Not
/// salary entered (filters at once), and the driver, truck and RTI number (removable).
class RtiChips extends StatelessWidget {
  const RtiChips({super.key, required this.onOpenFilters});

  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) => BlocBuilder<RtiListBloc, RtiListState>(
        builder: (context, s) {
          final bloc = context.read<RtiListBloc>();
          final a = s.applied;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              ActionChip(
                avatar: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(a.rtiNo.trim().isNotEmpty ? 'Any date' : rtiRangeLabel(a.fromDate, a.toDate)),
                onPressed: onOpenFilters,
              ),
              if (!s.isDriver) ...[
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('My RTIs'),
                  selected: a.myRtis,
                  onSelected: (v) => bloc.add(RtiListQuickFilterChanged(a.copyWith(myRtis: v))),
                ),
              ],
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Not salary entered'),
                selected: a.notSalary,
                onSelected: (v) => bloc.add(RtiListNotSalaryToggled(v)),
              ),
              if (a.driverId != 0) ...[
                const SizedBox(width: 8),
                InputChip(
                  avatar: const Icon(Icons.person_outline, size: 18),
                  label: Text(a.driverName),
                  onDeleted: () => bloc.add(RtiListQuickFilterChanged(a.copyWith(driverId: 0, driverName: ''))),
                ),
              ],
              if (a.truckId != 0) ...[
                const SizedBox(width: 8),
                InputChip(
                  avatar: const Icon(Icons.local_shipping_outlined, size: 18),
                  label: Text(a.truckName),
                  onDeleted: () => bloc.add(RtiListQuickFilterChanged(a.copyWith(truckId: 0, truckName: ''))),
                ),
              ],
              if (a.rtiNo.trim().isNotEmpty) ...[
                const SizedBox(width: 8),
                InputChip(
                  avatar: const Icon(Icons.tag, size: 18),
                  label: Text(a.rtiNo),
                  onDeleted: () => bloc.add(RtiListQuickFilterChanged(a.copyWith(rtiNo: ''))),
                ),
              ],
              const SizedBox(width: 4),
              TextButton(onPressed: () => bloc.add(const RtiListCleared()), child: const Text('Clear')),
            ]),
          );
        },
      );
}
