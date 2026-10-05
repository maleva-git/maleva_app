import 'package:flutter/material.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/rti_assignments/models/employee_assignment.dart';
import 'package:maleva/features/rti_assignments/widgets/assignment_card.dart';

/// React's table (`EmployeeAssignmentsPage.tsx:300-430`) for a landscape tablet: # · RTI / SO
/// Details · Route & Dates · Cargo Details · Counts · Assignment Details · Vehicle Details ·
/// Status, with each job's remarks on a row below. Scrolls sideways when narrow.
class AssignmentsTable extends StatelessWidget {
  const AssignmentsTable({super.key, required this.rows, required this.reportBusyId});

  final List<EmployeeAssignment> rows;
  final int? reportBusyId;

  static const _cols = <(String, double)>[
    ('#', 44),
    ('RTI / SO DETAILS', 190),
    ('ROUTE & DATES', 230),
    ('CARGO DETAILS', 190),
    ('COUNTS', 100),
    ('ASSIGNMENT DETAILS', 170),
    ('VEHICLE DETAILS', 150),
    ('STATUS', 130),
  ];

  static double get _width => _cols.fold(0, (w, c) => w + c.$2);

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final head = TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: mc.muted);
    return DecoratedBox(
      decoration: BoxDecoration(color: context.cs.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: mc.outline)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: c.maxWidth > _width ? c.maxWidth : _width,
              child: Column(children: [
                Container(
                  color: mc.surface2,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(children: [for (final col in _cols) _cell(Text(col.$1, style: head), col.$2)]),
                ),
                Expanded(
                  child: ListView.builder(itemCount: rows.length, itemBuilder: (context, i) => _row(context, i, rows[i])),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, int i, EmployeeAssignment j) {
    final mc = context.mc;
    final muted = TextStyle(color: mc.muted, fontSize: 13);
    String d(String v) => EmployeeAssignment.orDash(v);
    Widget lines(List<(String, String)> items) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final (label, value) in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text.rich(TextSpan(children: [
                TextSpan(text: '$label  ', style: muted.copyWith(fontWeight: FontWeight.w700)),
                TextSpan(text: value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ])),
            ),
        ]);
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: mc.outline))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _cell(Text('${i + 1}', style: muted), _cols[0].$2),
            _cell(
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: lines([('RTI Number', d(j.rtiNumber))])),
                  AssignmentReportButton(job: j, busy: reportBusyId == j.rtiMasterRefId),
                ]),
                lines([('SO Number', d(j.saleOrderNumber)), ('Customer', d(j.customerName))]),
              ]),
              _cols[1].$2,
            ),
            _cell(
              lines([
                ('Pickup', EmployeeAssignment.formatDateTime(j.pickupDateD)),
                ('Delivery', EmployeeAssignment.formatDateTime(j.deliveryDateD)),
                ('Origin', d(j.originD)),
                ('Destination', d(j.destinationD)),
              ]),
              _cols[2].$2,
            ),
            _cell(
              lines([('Vessel', d(j.vesselNameRaw)), ('Commodity', d(j.commodity)), ('Quantity', d(j.quantity)), ('Truck Size:', d(j.truckSize))]),
              _cols[3].$2,
            ),
            _cell(lines([('${j.pickupCount}', 'Pickups'), ('${j.dropCount}', 'Drops')]), _cols[4].$2),
            _cell(lines([('Employee', d(j.employeeName)), ('Driver', d(j.driverName))]), _cols[5].$2),
            _cell(lines([('Truck Number', d(j.truckNumber)), ('Truck Type', d(j.truckType))]), _cols[6].$2),
            _cell(const Align(alignment: Alignment.centerLeft, child: AssignmentStatusPill()), _cols[7].$2),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(54, 0, 10, 10),
          child: Text.rich(TextSpan(children: [
            TextSpan(text: 'Remarks: ', style: muted.copyWith(fontWeight: FontWeight.w700)),
            TextSpan(
              text: j.remarks.isEmpty ? 'No remarks provided.' : j.remarks,
              style: muted.copyWith(fontStyle: j.remarks.isEmpty ? FontStyle.italic : FontStyle.normal),
            ),
          ])),
        ),
      ]),
    );
  }

  static Widget _cell(Widget child, double width) =>
      SizedBox(width: width, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: child));
}
