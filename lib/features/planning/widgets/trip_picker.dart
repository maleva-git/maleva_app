import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/widgets/ui/ui.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/data/plan_trips.dart';
import 'package:maleva/features/planning/models/plan_line.dart';

/// Fleet F4: the TRIP of a plan row (the web's TRIP column). Tap → 1 … 12 or "No trip"; the rows under it on the
/// same truck fill in (grey). Typed / AI in bold, filled grey, read from Remarks grey italic, nothing without a truck.
class TripPicker extends StatelessWidget {
  const TripPicker({super.key, required this.row, required this.canWrite, this.compact = false});

  final PlanLine row;
  final bool canWrite;

  /// The job card's chip ("Trip 2"); otherwise the board cell (just the number).
  final bool compact;

  static const _choices = 12;

  @override
  Widget build(BuildContext context) {
    if (!row.hasTruck || row.truckRefid <= 0) return const SizedBox.shrink();
    final cell = PlanTrips.cell(row);
    final mc = context.mc;
    final style = TextStyle(
      fontSize: compact ? 12 : 14,
      fontWeight: cell.kind == TripKind.typed ? FontWeight.w800 : FontWeight.w500,
      fontStyle: cell.kind == TripKind.remarks ? FontStyle.italic : FontStyle.normal,
      color: cell.kind == TripKind.typed ? null : mc.faint,
    );
    final text = cell.value > 0 ? (compact ? 'Trip ${cell.value}' : cell.label) : (compact ? '' : '—');
    final label = Semantics(label: 'Trip', value: cell.label, child: Text(text, style: style));
    if (!canWrite) {
      return compact && cell.value == 0 ? const SizedBox.shrink() : Tooltip(message: cell.hint, child: label);
    }
    return PopupMenuButton<int>(
      tooltip: cell.hint,
      initialValue: cell.kind == TripKind.typed || cell.kind == TripKind.filled ? cell.value : null,
      onSelected: (n) => context.read<PlanCubit>().editTrip(row.uid, n == 0 ? '' : '$n'),
      itemBuilder: (_) => [
        for (var n = 1; n <= _choices; n++) PopupMenuItem<int>(value: n, height: 40, child: Text('Trip $n')),
        const PopupMenuDivider(),
        const PopupMenuItem<int>(value: 0, height: 40, child: Text('No trip')),
      ],
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 2 : 10),
        child: compact && cell.value == 0 ? Text('+ Trip', style: TextStyle(fontSize: 12, color: mc.faint)) : label,
      ),
    );
  }
}
