import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/bloc/plan_state.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/widgets/assign_picker.dart';
import 'package:maleva/features/planning/widgets/job_card.dart';
import 'package:maleva/features/planning/widgets/plan_flows.dart';
import 'package:maleva/features/planning/widgets/plan_menu.dart';

/// A board column (`planningColumns.tsx`): its header, width and how a cell reads.
class BoardColumn {
  const BoardColumn(this.key, this.label, this.width);

  final String key;
  final String label;
  final double width;
}

const boardColumns = <String, BoardColumn>{
  'driver': BoardColumn('driver', 'DRIVER', 170),
  'origin': BoardColumn('origin', 'ORIGIN', 130),
  'dest': BoardColumn('dest', 'DEST', 130),
  'pkg': BoardColumn('pkg', 'PKG / WT', 150),
  'customer': BoardColumn('customer', 'CUSTOMER', 210),
  'pdate': BoardColumn('pdate', 'P.DATE', 150),
  'ddate': BoardColumn('ddate', 'D.DATE', 150),
  'vessel': BoardColumn('vessel', 'VESSEL', 150),
  'pic': BoardColumn('pic', 'PIC', 120),
  'leta': BoardColumn('leta', 'L ETA', 140),
  'oeta': BoardColumn('oeta', 'O ETA', 140),
  'status': BoardColumn('status', 'STATUS', 140),
  'rti': BoardColumn('rti', 'RTI', 160),
  'sort': BoardColumn('sort', 'SORT', 80),
  'remarks': BoardColumn('remarks', 'REMARKS', 200),
  'sPort': BoardColumn('sPort', 'S.PORT', 90),
  'oPort': BoardColumn('oPort', 'O.PORT', 90),
  'awb': BoardColumn('awb', 'AWB NO.', 140),
  'bl': BoardColumn('bl', 'BL COPY', 110),
  'size': BoardColumn('size', 'SIZE', 80),
};

/// Column presets: All · Assign · Route · Cargo · Timing.
const boardPresets = <String, List<String>>{
  'All': ['driver', 'origin', 'dest', 'pkg', 'customer', 'pdate', 'ddate', 'vessel', 'pic', 'leta', 'oeta', 'status', 'rti', 'sort', 'remarks'],
  'Assign': ['driver', 'size', 'pdate', 'ddate', 'status', 'rti', 'remarks'],
  'Route': ['origin', 'dest', 'sPort', 'oPort', 'pdate', 'ddate'],
  'Cargo': ['customer', 'pkg', 'vessel', 'awb', 'bl'],
  'Timing': ['pdate', 'ddate', 'leta', 'oeta'],
};

String _text(PlanLine r, String key) => switch (key) {
      'origin' => r.origin,
      'dest' => r.destination,
      'pkg' => r.packageType,
      'customer' => r.customerName,
      'pdate' => Fmt.planningDateTime(r.sPickupDate),
      'ddate' => Fmt.planningDateTime(r.sDeliveryDate),
      'vessel' => r.vesselName,
      'pic' => r.picName,
      'leta' => Fmt.planningDateTime(r.loadingETA),
      'oeta' => Fmt.planningDateTime(r.offloadingETA),
      'sPort' => r.sPort,
      'oPort' => r.oPort,
      'awb' => r.awbNo,
      'bl' => r.blCopy,
      'size' => r.truckSize,
      'sort' => r.sortByD,
      'remarks' => r.remarks,
      _ => '',
    };

const double _rowH = 48;
const double _tickW = 52;
const double _jobW = 140;
const double _truckW = 170;
const double _menuW = 52;

/// The planning board: 48 dp rows; ✓, JOB NO and TRUCK frozen (unless [frozen] is off);
/// the rest scrolls sideways under one header.
class BoardGrid extends StatefulWidget {
  const BoardGrid({super.key, required this.state, required this.rows, required this.columns, required this.frozen});

  final PlanState state;
  final List<PlanLine> rows;
  final List<String> columns;
  final bool frozen;

  @override
  State<BoardGrid> createState() => _BoardGridState();
}

class _BoardGridState extends State<BoardGrid> {
  final _body = ScrollController();
  final _head = ScrollController();

  @override
  void initState() {
    super.initState();
    _body.addListener(() {
      if (_head.hasClients && _head.offset != _body.offset) _head.jumpTo(_body.offset);
    });
  }

  @override
  void dispose() {
    _body.dispose();
    _head.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final canWrite = s.access.canWrite;
    final cols = [for (final k in widget.columns) boardColumns[k]!];
    final mc = context.mc;
    final headStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: mc.muted);
    Widget headCell(String label, double w) => SizedBox(
        width: w,
        height: 44,
        child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text(label, style: headStyle))));
    final frozenHead = [if (canWrite) headCell('✓', _tickW), headCell('JOB NO', _jobW), headCell('TRUCK', _truckW)];
    final restHead = [for (final c in cols) headCell(c.label, c.width), headCell('', _menuW)];

    Color rowColor(PlanLine r) {
      if (s.selectedUid == r.uid) return mc.primarySoft;
      final sel = s.selected;
      if (r.print) return mc.primarySoft.withValues(alpha: 0.6);
      if (sel != null && s.sameTruckAs(sel).any((o) => o.uid == r.uid)) return mc.primarySoft.withValues(alpha: 0.35);
      return context.cs.surface;
    }

    Widget line(PlanLine r, List<Widget> cells) => Container(
          height: _rowH,
          decoration: BoxDecoration(color: rowColor(r), border: Border(bottom: BorderSide(color: mc.outline))),
          child: Row(children: cells),
        );

    List<Widget> frozenCells(PlanLine r) => [
          if (canWrite)
            SizedBox(
                width: _tickW,
                child: Checkbox(value: r.print, onChanged: (_) => context.read<PlanCubit>().toggleTick(r.uid), semanticLabel: 'Tick ${r.jobNo}')),
          _JobCell(row: r, changed: s.changedUids.contains(r.uid)),
          _AssignCell(row: r, truck: true, state: s, width: _truckW),
        ];

    List<Widget> restCells(PlanLine r) => [
          for (final c in cols) _cell(context, s, r, c),
          SizedBox(width: _menuW, child: RowMenuButton(row: r, state: s)),
        ];

    final frozenW = (canWrite ? _tickW : 0) + _jobW + _truckW;
    final restW = cols.fold<double>(0, (a, c) => a + c.width) + _menuW;
    final header = Container(
      decoration: BoxDecoration(color: mc.surface2, border: Border(bottom: BorderSide(color: mc.outline))),
      child: Row(children: [
        if (widget.frozen) ...frozenHead,
        Expanded(
          child: SingleChildScrollView(
            controller: _head,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(children: [if (!widget.frozen) ...frozenHead, ...restHead]),
          ),
        ),
      ]),
    );
    final body = SingleChildScrollView(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (widget.frozen)
          SizedBox(
            width: frozenW,
            child: Column(children: [for (final r in widget.rows) line(r, frozenCells(r))]),
          ),
        Expanded(
          child: Scrollbar(
            controller: _body,
            child: SingleChildScrollView(
              controller: _body,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: restW + (widget.frozen ? 0 : frozenW),
                child: Column(children: [
                  for (final r in widget.rows) line(r, [if (!widget.frozen) ...frozenCells(r), ...restCells(r)]),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
    return Column(children: [header, Expanded(child: body)]);
  }

  Widget _cell(BuildContext context, PlanState s, PlanLine r, BoardColumn c) {
    final canWrite = s.access.canWrite;
    final cubit = context.read<PlanCubit>();
    Widget box(Widget child) => SizedBox(
        width: c.width,
        height: _rowH,
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Align(alignment: Alignment.centerLeft, child: child)));
    switch (c.key) {
      case 'driver':
        return _AssignCell(row: r, truck: false, state: s, width: c.width);
      case 'status':
        return box(StatusPill(r.status));
      case 'rti':
        return box(
            r.rtiNo.isEmpty ? Text('—', style: TextStyle(color: context.mc.faint)) : RtiBadge(r.rtiNo, onTap: () => PlanFlows.openRti(context, r)));
      case 'sort':
      case 'remarks':
        if (!canWrite) break;
        return box(TextFormField(
          key: ValueKey('${c.key}-${r.uid}'),
          initialValue: c.key == 'sort' ? r.sortByD : r.remarks,
          keyboardType: c.key == 'sort' ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10)),
          onTap: () => cubit.selectRow(r.uid),
          onChanged: (v) => c.key == 'sort' ? cubit.editSort(r.uid, v) : cubit.editRemarks(r.uid, v),
        ));
    }
    final v = _text(r, c.key);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => cubit.selectRow(r.uid),
      onLongPress: v.isEmpty ? null : () => PlanFlows.copy(context, v),
      child: box(Text(v,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14, fontWeight: c.key == 'customer' ? FontWeight.w700 : FontWeight.w500))),
    );
  }
}

class _JobCell extends StatelessWidget {
  const _JobCell({required this.row, required this.changed});

  final PlanLine row;
  final bool changed;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => context.read<PlanCubit>().selectRow(row.uid),
        onLongPress: () => PlanFlows.copy(context, row.jobNo),
        child: SizedBox(
          width: _jobW,
          height: _rowH,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(children: [
              Flexible(
                  child: Text(row.jobNo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w800, color: context.cs.primary, fontSize: 14))),
              if (changed) ...[
                const SizedBox(width: 4),
                Container(width: 7, height: 7, decoration: BoxDecoration(color: context.mc.toneFg(StatusTone.warning), shape: BoxShape.circle))
              ],
            ]),
          ),
        ),
      );
}

/// A TRUCK or DRIVER cell: a tap (or Enter) opens the picker; amber when empty; red / purple
/// / indigo for expiry and leave.
class _AssignCell extends StatelessWidget {
  const _AssignCell({required this.row, required this.truck, required this.state, required this.width});

  final PlanLine row;
  final bool truck;
  final PlanState state;
  final double width;

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final value = truck ? row.truckName : row.driverName;
    final empty = value.trim().isEmpty;
    final color = empty ? mc.toneFg(StatusTone.warning) : severityText(context, truck ? truckSeverityOf(state, row) : driverSeverityOf(state, row));
    final canWrite = state.access.canWrite;
    return Semantics(
      button: canWrite,
      label: '${truck ? 'Truck' : 'Driver'} for ${row.jobNo}: ${empty ? 'Unassigned' : value}',
      child: InkWell(
        onTap: canWrite
            ? () {
                context.read<PlanCubit>().selectRow(row.uid);
                truck ? AssignPicker.truck(context, {row.uid}) : AssignPicker.driver(context, {row.uid});
              }
            : () => context.read<PlanCubit>().selectRow(row.uid),
        onLongPress: empty ? null : () => PlanFlows.copy(context, value),
        child: Container(
          width: width,
          height: _rowH,
          color: empty ? mc.toneBg(StatusTone.warning) : null,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          child: Text(empty ? (canWrite ? 'Assign' : '—') : value,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        ),
      ),
    );
  }
}
