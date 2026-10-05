import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/list/bloc/rti_list_bloc.dart';
import 'package:maleva/features/rti/list/models/rti_list_row.dart';
import 'package:maleva/features/rti/list/widgets/rti_actions.dart';

/// React's RTI table (`RTIViewPage.tsx:275-372`) for a landscape tablet: # · RTI No · Date ·
/// Driver · Truck · Amount · Remarks · Report · Share · Edit. A tap previews, a double tap edits.
class RtiTable extends StatelessWidget {
  const RtiTable({super.key, required this.state});

  final RtiListState state;

  static const _w = <double>[44, 140, 104, 140, 110, 110];

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final rows = state.visible;
    final head = TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: mc.muted);
    return DecoratedBox(
      decoration: BoxDecoration(color: context.cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: mc.outline)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: _WideScroll(minWidth: 900, child: Column(children: [
          Container(
            color: mc.surface2,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              for (final (i, l) in const ['#', 'RTI NO', 'DATE', 'DRIVER', 'TRUCK', 'AMOUNT'].indexed) _cell(Text(l, style: head), _w[i]),
              Expanded(child: _pad(Text('REMARKS', style: head))),
              SizedBox(width: state.isDriver ? 56 : 152, child: Text('ACTIONS', style: head)),
            ]),
          ),
          Expanded(
            child: ListView.builder(itemCount: rows.length, itemBuilder: (context, i) => _row(context, i, rows[i])),
          ),
          Container(
            color: mc.surface2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              Text('Showing ${rows.length} record${rows.length == 1 ? '' : 's'}', style: TextStyle(color: mc.muted, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('Tap to preview · Double tap to edit', style: TextStyle(color: mc.muted)),
            ]),
          ),
        ])),
      ),
    );
  }

  Widget _row(BuildContext context, int index, RtiListRow r) {
    final mc = context.mc;
    final bloc = context.read<RtiListBloc>();
    final selected = state.preview?.id == r.id;
    final hasNo = rtiHasNumber(r);
    Widget busyIcon(bool busy, IconData icon) =>
        busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(icon);
    return Material(
      color: selected ? mc.primarySoft : Colors.transparent,
      child: InkWell(
        onTap: () => bloc.add(RtiListRowSelected(r.id)),
        onDoubleTap: state.isDriver ? null : () => openRtiEdit(context, r.id),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: mc.outline))),
          child: Row(children: [
            _cell(Text('${index + 1}', style: TextStyle(color: mc.muted)), _w[0]),
            _cell(Text(r.rtiNo, style: TextStyle(fontWeight: FontWeight.w800, color: context.cs.primary)), _w[1]),
            _cell(Text(r.dateText), _w[2]),
            _cell(Text(r.driverName.isEmpty ? '-' : r.driverName, overflow: TextOverflow.ellipsis), _w[3]),
            _cell(Text(r.truckName.isEmpty ? '-' : r.truckName, overflow: TextOverflow.ellipsis), _w[4]),
            _cell(
              Text(r.amountText,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: FontWeight.w700, color: r.salaryMissing ? mc.toneFg(StatusTone.warning) : null)),
              _w[5],
            ),
            Expanded(child: _pad(Text(r.remarks.trim().isEmpty ? '-' : r.remarks, maxLines: 1, overflow: TextOverflow.ellipsis))),
            SizedBox(
              width: state.isDriver ? 56 : 152,
              child: Row(children: [
                IconButton(
                  tooltip: 'Open RTI report',
                  onPressed: !hasNo || state.reportBusyId == r.id ? null : () => bloc.add(RtiReportRequested(r)),
                  icon: busyIcon(state.reportBusyId == r.id, Icons.picture_as_pdf_outlined),
                ),
                if (!state.isDriver) ...[
                  IconButton(
                    tooltip: "Send this RTI to the truck's WhatsApp group",
                    onPressed: !hasNo || state.shareBusyId == r.id ? null : () => confirmAndShareRti(context, r),
                    icon: busyIcon(state.shareBusyId == r.id, Icons.send_outlined),
                  ),
                  IconButton(tooltip: 'Edit', onPressed: () => openRtiEdit(context, r.id), icon: const Icon(Icons.edit_outlined)),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  static Widget _pad(Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: child);

  static Widget _cell(Widget child, double width) => SizedBox(width: width, child: _pad(child));
}

/// Lays the table out at least [minWidth] wide and scrolls it sideways when the pane is narrower.
class _WideScroll extends StatelessWidget {
  const _WideScroll({required this.minWidth, required this.child});

  final double minWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) => c.maxWidth >= minWidth
            ? child
            : SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(width: minWidth, height: c.maxHeight, child: child)),
      );
}
