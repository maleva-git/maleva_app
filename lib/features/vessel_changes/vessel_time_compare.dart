import 'package:flutter/material.dart';
import 'package:maleva/core/vessel_changes/vessel_change_look.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';
import 'package:maleva/core/vessel_master/vessel_master_models.dart';

/// The amber of a time PTP changed: only a thin left accent and a faint background, no loud colour.
const Color vesselChangeAccent = Color(0xFFD97706);

/// One job's times, Maleva's against PTP's: "In Maleva" | "PTP now", an ETA and an ETD row. A time that
/// differs is highlighted with PTP's value in semibold and how far it moves ("+8 h later"); a matching
/// time is muted with "✓ same"; a time PTP does not give shows "—".
class VesselTimeCompare extends StatelessWidget {
  const VesselTimeCompare({super.key, required this.call, required this.job});

  final PtpCall call;
  final VesselChangeJob job;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final head = Theme.of(context).textTheme.labelSmall?.copyWith(color: muted);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(_rowPadLeft, 0, 4, 2),
        child: Row(children: [
          const SizedBox(width: _labelWidth),
          Expanded(child: _OneLine('In Maleva', style: head)),
          Expanded(child: _OneLine(sourceNowLabel(call), style: head)),
        ]),
      ),
      _TimeRow(
        key: ValueKey('eta_${job.saleOrderId}_${job.leg}'),
        label: 'ETA',
        current: job.currentEta,
        ptp: job.ptpEta,
        estimated: call.arriveEstimated,
        differs: job.etaDiffers,
      ),
      _TimeRow(
        key: ValueKey('etd_${job.saleOrderId}_${job.leg}'),
        label: 'ETD',
        current: job.currentEtd,
        ptp: job.ptpEtd,
        estimated: call.departEstimated,
        differs: job.etdDiffers,
      ),
    ]);
  }
}

const double _labelWidth = 40;
const double _rowPadLeft = 8;

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    super.key,
    required this.label,
    required this.current,
    required this.ptp,
    required this.estimated,
    required this.differs,
  });

  final String label;
  final String? current;
  final String? ptp;
  final bool estimated;
  final bool differs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final body = theme.textTheme.bodyMedium;
    final small = theme.textTheme.bodySmall?.copyWith(color: muted);
    final match = timeMatch(current: current, ptp: ptp, differs: differs);
    final highlighted = timeMatchHighlighted(match);
    final same = match == TimeMatch.same;
    final rowStyle = same ? body?.copyWith(color: muted) : body;
    final delta = timeDeltaText(current, ptp);

    final Widget mine = match == TimeMatch.notSet
        ? _OneLine('not set', style: body?.copyWith(color: muted, fontStyle: FontStyle.italic))
        : _OneLine(vesselClock(current), style: rowStyle);

    final Widget theirs = switch (match) {
      TimeMatch.noPtp => _OneLine('—', style: rowStyle),
      TimeMatch.same => _OneLine('✓ same', style: rowStyle),
      _ => Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          _OneLine('${vesselClock(ptp)}${estimated ? ' est.' : ''}',
              style: body?.copyWith(fontWeight: FontWeight.w600)),
          if (delta.isNotEmpty) _OneLine(delta, style: small),
        ]),
    };

    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.fromLTRB(_rowPadLeft - 3, 4, 4, 4),
      decoration: BoxDecoration(
        color: highlighted ? vesselChangeAccent.withValues(alpha: 0.07) : null,
        border: Border(
            left: BorderSide(color: highlighted ? vesselChangeAccent : Colors.transparent, width: 3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: _labelWidth, child: _OneLine(label, style: small?.copyWith(fontWeight: FontWeight.w600))),
        Expanded(child: mine),
        Expanded(child: theirs),
      ]),
    );
  }
}

/// A text on one line that shrinks rather than wraps or overflows on a narrow phone.
class _OneLine extends StatelessWidget {
  const _OneLine(this.text, {this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(text, style: style, maxLines: 1, softWrap: false),
        ),
      );
}
