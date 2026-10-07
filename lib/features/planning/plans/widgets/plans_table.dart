import 'package:flutter/material.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/plans/models/plan_row.dart';
import 'package:maleva/features/planning/plans/widgets/plan_card.dart';

/// React's Planning Logs table (`PlanningView.tsx:131-224`) for a landscape tablet: ID ·
/// Planning No (opens the plan) · Planning Date · Employee · Total Orders · Remarks · Report ·
/// Edit. A tap previews; a double tap opens the plan (React's double-click).
class PlansTable extends StatelessWidget {
  const PlansTable({
    super.key,
    required this.rows,
    required this.selectedId,
    required this.reportBusyId,
    required this.onSelect,
    required this.onOpen,
    required this.onReport,
  });

  final List<PlanRow> rows;
  final int? selectedId;
  final int? reportBusyId;
  final ValueChanged<PlanRow> onSelect;
  final ValueChanged<PlanRow> onOpen;
  final ValueChanged<PlanRow> onReport;

  static const _widths = <double>[64, 140, 120, 140, 110];

  @override
  Widget build(BuildContext context) {
    final mc = context.mc;
    final head = TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: mc.muted);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mc.outline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: _WideScroll(minWidth: 860, child: Column(children: [
          Container(
            color: mc.surface2,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              for (final (i, label) in const ['ID', 'PLANNING NO', 'PLANNING DATE', 'EMPLOYEE', 'TOTAL ORDERS'].indexed)
                _cell(Text(label, style: head), _widths[i]),
              Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('REMARKS', style: head))),
              SizedBox(width: 104, child: Text('REPORT · EDIT', style: head, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis)),
            ]),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: rows.length,
              itemBuilder: (context, i) => _row(context, rows[i]),
            ),
          ),
          Container(
            color: mc.surface2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              Text('Rows: ${rows.length}', style: TextStyle(color: mc.muted, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('Double tap a row to edit its details.', style: TextStyle(color: mc.muted)),
            ]),
          ),
        ])),
      ),
    );
  }

  Widget _row(BuildContext context, PlanRow p) {
    final mc = context.mc;
    final selected = p.id == selectedId;
    final busy = reportBusyId == p.id;
    return Material(
      color: selected ? mc.primarySoft : Colors.transparent,
      child: InkWell(
        onTap: () => onSelect(p),
        onDoubleTap: () => onOpen(p),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: mc.outline))),
          child: Row(children: [
            _cell(Text('#${p.id}', style: TextStyle(color: mc.muted, fontWeight: FontWeight.w700)), _widths[0]),
            _cell(
              TextButton(
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 44), alignment: Alignment.centerLeft),
                onPressed: () => onOpen(p),
                child: Text(p.planningNo, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              _widths[1],
            ),
            _cell(Text(p.planningDate, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis), _widths[2]),
            _cell(Text(p.employeeName.isEmpty ? '-' : p.employeeName, overflow: TextOverflow.ellipsis), _widths[3]),
            _cell(FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: PlanOrdersBadge(p.totalOrders)), _widths[4]),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(p.remarks.isEmpty ? '-' : p.remarks, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
            SizedBox(
              width: 104,
              child: Row(children: [
                if (p.planningNo.trim().isEmpty)
                  const SizedBox(width: 48, child: Center(child: Text('-')))
                else
                  IconButton(
                    tooltip: 'Open Planning report',
                    onPressed: busy ? null : () => onReport(p),
                    icon: busy
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.picture_as_pdf_outlined),
                  ),
                IconButton(tooltip: 'Edit', onPressed: () => onOpen(p), icon: const Icon(Icons.edit_outlined)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  static Widget _cell(Widget child, double width) =>
      SizedBox(width: width, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: child));
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
