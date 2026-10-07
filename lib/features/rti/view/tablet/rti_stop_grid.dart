import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/models/rti_stop.dart';
import 'package:maleva/features/rti/widgets/rti_stop_fields.dart';

/// The full-width route-activity grid of the tablet (`R/components/RTIRouteActivitiesGrid.tsx`):
/// Seq No · Destination · Vessel Name · Job Qty · Agent Name · Agent Mobile No · Driver Number · Job Type · Full
/// Destination · Marqis Clearance · Remarks · ETA · Created Date · Action.
class RtiStopGrid extends StatefulWidget {
  const RtiStopGrid({super.key});

  @override
  State<RtiStopGrid> createState() => _RtiStopGridState();
}

class _RtiStopGridState extends State<RtiStopGrid> {
  final _scroll = ScrollController();

  static const _cols = <(String, double)>[
    ('Seq No', 80), ('Destination', 190), ('Vessel Name', 200), ('Job Qty', 170), ('Agent Name', 210), ('Agent Mobile No', 150), ('Driver Number', 150), ('Job Type', 180),
    ('Full Destination', 200), ('Marqis Clearance', 96), ('Remarks', 200), ('ETA', 260), ('Created Date', 150), ('Action', 64),
  ];

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<RtiEntryBloc, RtiEntryState>(
        buildWhen: (a, b) => a.stops != b.stops || a.refs != b.refs,
        builder: (context, s) {
          final mc = context.mc;
          final width = _cols.fold<double>(0, (a, c) => a + c.$2);
          return DetailSection(
            title: 'Route Activities',
            trailing: FilledButton.icon(
              onPressed: () => context.read<RtiEntryBloc>().add(const RtiStopAdded()),
              icon: const Icon(Icons.add),
              label: const Text('Add Activity'),
            ),
            child: s.stops.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('No route activities defined. Click "Add Activity" to create milestones.', textAlign: TextAlign.center, style: TextStyle(color: mc.muted)),
                  )
                : Scrollbar(
                    controller: _scroll,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scroll,
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: width,
                        child: Column(children: [
                          Container(
                            color: mc.surface2,
                            child: Row(children: [
                              for (final c in _cols)
                                SizedBox(
                                  width: c.$2,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                    child: Text(c.$1.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: mc.muted)),
                                  ),
                                ),
                            ]),
                          ),
                          for (var i = 0; i < s.stops.length; i++) _row(context, i, s.stops[i]),
                        ]),
                      ),
                    ),
                  ),
          );
        },
      );

  Widget _row(BuildContext context, int i, RtiStop st) {
    Widget cell(int col, Widget child) => SizedBox(width: _cols[col].$2, child: Padding(padding: const EdgeInsets.all(4), child: child));
    return Container(
      key: ValueKey('stop-row-$i'),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.mc.outline))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        cell(0, RtiStopFields.sequence(context, i, st, dense: true)),
        cell(1, RtiStopFields.location(context, i, st)),
        cell(2, RtiStopFields.vessel(context, i, st)),
        cell(3, RtiStopFields.jobQuantity(context, i, st, dense: true)),
        cell(4, RtiStopFields.agent(context, i, st)),
        cell(5, RtiStopFields.mobile(context, i, st, dense: true)),
        cell(6, RtiStopFields.driverNumber(context, i, st, dense: true)),
        cell(7, RtiStopFields.jobType(context, i, st)),
        cell(8, RtiStopFields.fullRoute(context, i, st, dense: true)),
        cell(
          9,
          Checkbox(
            value: st.marqisStatus == 1,
            onChanged: (v) => context.read<RtiEntryBloc>().add(RtiStopEdited(i, (x) => x.copyWith(marqisStatus: v == true ? 1 : 0))),
          ),
        ),
        cell(10, RtiStopFields.remarks(context, i, st, dense: true)),
        cell(11, RtiStopFields.eta(context, i, st)),
        cell(12, Text(RtiStopFields.created(st).isEmpty ? '-' : RtiStopFields.created(st), style: TextStyle(color: context.mc.muted))),
        cell(
          13,
          IconButton(tooltip: 'Delete activity', icon: Icon(Icons.delete_outline, color: context.cs.error), onPressed: () => RtiStopFields.confirmDelete(context, i)),
        ),
      ]),
    );
  }
}
