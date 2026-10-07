import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/models/rti_dates.dart';
import 'package:maleva/features/rti/models/rti_job_row.dart';
import 'package:maleva/features/rti/models/rti_rules.dart';
import 'package:maleva/features/rti/view/phone/rti_phone_steps.dart';
import 'package:maleva/features/rti/view/tablet/rti_grid_cell.dart';
import 'package:maleva/features/rti/widgets/rti_job_card.dart';

/// The full-width job grid of the tablet (`R/components/RTIGrid.tsx`): S/N · JOB NO ·
/// Customer Name · Vessel Name · Job Qty · JOB DATE · Salary · PPIC · DPIC · PWD · Origin · Destination · PickupDate
/// · DeliveryDate · Action, with the web's keys.
class RtiJobGrid extends StatefulWidget {
  const RtiJobGrid({super.key});

  @override
  State<RtiJobGrid> createState() => _RtiJobGridState();
}

class _RtiJobGridState extends State<RtiJobGrid> implements RtiGridCellHost {
  final Map<String, FocusNode> _nodes = {};
  final _scroll = ScrollController();

  static const _w = <String, double>{
    'sn': 56, 'JobNo': 160, 'customer': 240, 'vessel': 180, 'jobQty': 140, 'jobDate': 110, 'Salary': 110, 'PPIC': 140, 'DPIC': 140, 'PWDType': 90,
    'origin': 170, 'destination': 170, 'pickup': 120, 'delivery': 120, 'action': 64,
  };
  static const _headers = <String, String>{
    'sn': 'S/N', 'JobNo': 'JOB NO', 'customer': 'Customer Name', 'vessel': 'Vessel Name', 'jobQty': 'Job Qty', 'jobDate': 'JOB DATE', 'Salary': 'Salary', 'PPIC': 'PPIC', 'DPIC': 'DPIC',
    'PWDType': 'PWD', 'origin': 'Origin', 'destination': 'Destination', 'pickup': 'PickupDate', 'delivery': 'DeliveryDate', 'action': 'Action',
  };

  RtiEntryBloc get _bloc => context.read<RtiEntryBloc>();

  @override
  int get rowCount => _bloc.state.grid.length;

  @override
  FocusNode focusOf(int row, String column) => _nodes.putIfAbsent('$row-$column', () => FocusNode(debugLabel: 'rti $row $column'));

  @override
  void commit(int row, String column, String value) => _bloc.add(RtiJobCellEdited(row, column, value));

  @override
  void lookup(int row, String jobNo) => _bloc.add(RtiJobLookupRequested(row, jobNo));

  @override
  void addRowAndFocus(int focusRow) {
    _bloc.add(const RtiJobRowAdded());
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) focusOf(focusRow, RtiJobColumns.jobNo).requestFocus();
    });
  }

  @override
  void deleteRow(int row) => confirmDeleteJobRow(context, row);

  @override
  void paste(int row, String column, String text) => _bloc.add(RtiJobCellsPasted(row, column, text));

  @override
  void dispose() {
    for (final n in _nodes.values) {
      n.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<RtiEntryBloc, RtiEntryState>(
        buildWhen: (a, b) => a.grid != b.grid || a.busy != b.busy || a.lookupRow != b.lookupRow || a.reviseChanges != b.reviseChanges,
        builder: (context, s) {
          final mc = context.mc;
          final width = _w.values.fold<double>(0, (a, b) => a + b);
          final placeholder = s.grid.length == 1 && s.grid.first.isPlaceholder;
          return DetailSection(
            title: 'Job Lines',
            trailing: Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
              RtiGridBadges(state: s),
              FilledButton.icon(onPressed: () => addRowAndFocus(s.grid.length), icon: const Icon(Icons.add), label: const Text('Add Row')),
            ]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (placeholder)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('Enter a Job No and press Enter to pull the matching sale-order lines.', style: TextStyle(color: mc.toneFg(StatusTone.warning))),
                ),
              Scrollbar(
                controller: _scroll,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scroll,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: width,
                    child: Column(children: [
                      _header(context),
                      for (var i = 0; i < s.grid.length; i++) _row(context, s, i),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Rows: ${s.grid.length}   ·   Enter: next cell / lookup job   ·   Insert: add row   ·   Ctrl+Delete: delete row   ·   Ctrl+V: paste',
                  style: TextStyle(fontSize: 12, color: mc.muted)),
            ]),
          );
        },
      );

  Widget _header(BuildContext context) => Container(
        color: context.mc.surface2,
        child: Row(children: [
          for (final e in _headers.entries)
            SizedBox(
              width: _w[e.key],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Text(e.value.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: context.mc.muted)),
              ),
            ),
        ]),
      );

  Widget _row(BuildContext context, RtiEntryState s, int i) {
    final r = s.grid[i];
    final mc = context.mc;
    final notFound = r.jobNo.trim().isNotEmpty && r.saleOrderMasterRefId <= 0;
    final changes = s.reviseChanges[r.saleOrderMasterRefId] ?? const [];
    Widget text(String key, String v, {Color? color}) => SizedBox(
          width: _w[key],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(v.isEmpty ? '-' : v, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: color)),
          ),
        );
    Widget cell(String column) => SizedBox(
          width: _w[column],
          child: Padding(padding: const EdgeInsets.all(3), child: RtiGridCell(host: this, row: i, column: column, value: r.cell(column))),
        );
    String changed(String label, String v) => changes.where((c) => c.label == label).isEmpty ? v : '$v (was ${changes.firstWhere((c) => c.label == label).was})';
    final accent = mc.toneFg(StatusTone.accent);
    Color? tint(String label) => changes.any((c) => c.label == label) ? accent : null;
    return Container(
      decoration: BoxDecoration(
        color: i.isOdd ? mc.surface2.withValues(alpha: 0.5) : null,
        border: Border(bottom: BorderSide(color: mc.outline)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          SizedBox(
            width: _w['sn'],
            child: s.lookupRow == i
                ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                : Text('${i + 1}', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700, color: mc.muted)),
          ),
          cell(RtiJobColumns.jobNo),
          text('customer', changed('Customer', r.customerName), color: tint('Customer')),
          text('vessel', r.vesselName),
          text('jobQty', r.jobQuantity),
          text('jobDate', RtiDates.short(r.jobDate), color: tint('Job date')),
          cell(RtiJobColumns.salary),
          cell(RtiJobColumns.ppic),
          cell(RtiJobColumns.dpic),
          cell(RtiJobColumns.pwdType),
          text('origin', changed('Origin', r.originD), color: tint('Origin')),
          text('destination', changed('Destination', r.destinationD), color: tint('Destination')),
          text('pickup', changed('Pickup', RtiDates.short(r.pickupDateD)), color: tint('Pickup')),
          text('delivery', changed('Delivery', RtiDates.short(r.deliveryDateD)), color: tint('Delivery')),
          SizedBox(
            width: _w['action'],
            child: IconButton(
              tooltip: 'Delete row (Ctrl+Delete)',
              icon: Icon(Icons.delete_outline, color: context.cs.error),
              onPressed: () => confirmDeleteJobRow(context, i),
            ),
          ),
        ]),
        if (notFound)
          Padding(
            padding: const EdgeInsets.fromLTRB(64, 0, 8, 8),
            child: Text(RtiRules.rowNotFound(i, r.jobNo), style: TextStyle(color: context.cs.error, fontWeight: FontWeight.w600)),
          ),
      ]),
    );
  }
}
