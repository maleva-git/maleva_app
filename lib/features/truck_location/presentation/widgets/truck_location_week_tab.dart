import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/app_form_fields.dart';

import '../../domain/entities/truck_location_week.dart';
import '../../domain/truck_location_rules.dart' as rules;
import '../bloc/truck_location_bloc.dart';

/// The WEEK tab: one expandable card per truck to read and check the whole
/// week. Collapsed, a 7-dot row says which days are located; expanded, all
/// seven fields with the same hint and amber rules as the DAY tab.
class TruckLocationWeekTab extends StatefulWidget {
  const TruckLocationWeekTab({
    super.key,
    required this.expandAll,
    required this.expandAllVersion,
  });

  /// What the app bar's Expand all / Collapse all last asked for.
  final bool expandAll;

  /// Bumped on every press, so asking for the same thing twice still applies.
  final int expandAllVersion;

  @override
  State<TruckLocationWeekTab> createState() => _TruckLocationWeekTabState();
}

class _TruckLocationWeekTabState extends State<TruckLocationWeekTab> {
  final Set<int> _expanded = {};
  bool _allExpanded = false;

  @override
  void didUpdateWidget(covariant TruckLocationWeekTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expandAllVersion != oldWidget.expandAllVersion) {
      setState(() {
        _allExpanded = widget.expandAll;
        _expanded.clear();
      });
    }
  }

  bool _isExpanded(int truckRefId) =>
      _allExpanded ? !_expanded.contains(truckRefId) : _expanded.contains(truckRefId);

  void _toggle(int truckRefId) {
    setState(() {
      if (_expanded.contains(truckRefId)) {
        _expanded.remove(truckRefId);
      } else {
        _expanded.add(truckRefId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TruckLocationBloc, TruckLocationState>(
      builder: (context, state) {
        final visible = state.visibleWeekRows;
        return RefreshIndicator(
          onRefresh: () async => context
              .read<TruckLocationBloc>()
              .add(const TruckLocationRefreshed()),
          child: visible.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        state.rows.isEmpty
                            ? 'No orderable trucks. Tick Orderable truck in Truck Master.'
                            : 'Every truck is done for this week.',
                        textAlign: TextAlign.center,
                        style:
                            AppTypography.bodyMedium(color: AppTokens.textMuted),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final row = visible[index];
                    return _WeekCard(
                      key: ValueKey('week_${row.truckRefId}'),
                      row: row,
                      state: state,
                      expanded: _isExpanded(row.truckRefId),
                      onToggle: () => _toggle(row.truckRefId),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({
    super.key,
    required this.row,
    required this.state,
    required this.expanded,
    required this.onToggle,
  });

  final TruckLocationRow row;
  final TruckLocationState state;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final done = state.effectiveDone(row);
    final hasDirty = List.generate(state.days.length,
            (index) => state.isCellDirty(row, index, state.days[index]))
        .any((dirtyDay) => dirtyDay);

    return Opacity(
      opacity: done ? 0.55 : 1,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        elevation: 0,
        color: AppTokens.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                hasDirty ? AppTokens.statusWarning : AppTokens.surfaceCardBorder,
          ),
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.truckName,
                        style: AppTypography.bodyLarge(
                            color: AppTokens.textPrimary,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    _DotRow(row: row, state: state),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: AppTokens.textDim,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: [
                    for (var dayIndex = 0;
                        dayIndex < state.days.length;
                        dayIndex++)
                      _WeekDayField(row: row, dayIndex: dayIndex, state: state),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The compact seven dots: filled = located, amber = unsaved, outline = empty.
class _DotRow extends StatelessWidget {
  const _DotRow({required this.row, required this.state});

  final TruckLocationRow row;
  final TruckLocationState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var dayIndex = 0; dayIndex < state.days.length; dayIndex++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Builder(builder: (context) {
              final day = state.days[dayIndex];
              final dirty = state.isCellDirty(row, dayIndex, day);
              final located =
                  rules.cellValue(row, dayIndex, day, state.edits).trim().isNotEmpty;
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dirty
                      ? AppTokens.statusWarning
                      : located
                          ? AppTokens.brandPrimary
                          : Colors.transparent,
                  border: dirty || located
                      ? null
                      : Border.all(color: AppTokens.surfaceBorder),
                ),
              );
            }),
          ),
      ],
    );
  }
}

class _WeekDayField extends StatelessWidget {
  const _WeekDayField({
    required this.row,
    required this.dayIndex,
    required this.state,
  });

  final TruckLocationRow row;
  final int dayIndex;
  final TruckLocationState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TruckLocationBloc>();
    final done = state.effectiveDone(row);
    final day = state.days[dayIndex];
    final value = rules.cellValue(row, dayIndex, day, state.edits);
    final dirty = state.isCellDirty(row, dayIndex, day);
    final hint = rules.hintFor(row, dayIndex, state.days, state.edits).trim();
    final showUse = !done && value.trim().isEmpty && hint.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              '${rules.dayNames[dayIndex]} ${day.substring(8)}',
              style: AppTypography.bodySmall(
                color: dirty ? AppTokens.statusWarning : AppTokens.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: 44,
              child: _WeekCellField(
                key: ValueKey('weekcell_${row.truckRefId}_$day'),
                value: value,
                hint: hint.isEmpty ? 'Location' : hint,
                enabled: !done,
                dirty: dirty,
                onChanged: (text) => bloc.add(TruckLocationCellEdited(
                    truckRefId: row.truckRefId, planDate: day, value: text)),
                useHint: showUse
                    ? () => bloc.add(TruckLocationCellEdited(
                        truckRefId: row.truckRefId, planDate: day, value: hint))
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Same controller discipline as the DAY tab's field: the text is rewritten
/// only when the bloc's value changes from outside, so typing never loses the
/// cursor.
class _WeekCellField extends StatefulWidget {
  const _WeekCellField({
    super.key,
    required this.value,
    required this.hint,
    required this.enabled,
    required this.dirty,
    required this.onChanged,
    required this.useHint,
  });

  final String value;
  final String hint;
  final bool enabled;
  final bool dirty;
  final ValueChanged<String> onChanged;
  final VoidCallback? useHint;

  @override
  State<_WeekCellField> createState() => _WeekCellFieldState();
}

class _WeekCellFieldState extends State<_WeekCellField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant _WeekCellField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      textCapitalization: TextCapitalization.characters,
      maxLength: 200,
      onChanged: widget.onChanged,
      style: AppTypography.bodyLarge(color: AppTokens.textPrimary),
      decoration: appInputDecoration(
        hint: widget.hint,
        enabled: widget.enabled,
      ).copyWith(
        fillColor:
            widget.dirty ? AppTokens.statusWarning.withValues(alpha: 0.06) : null,
        suffixIcon: widget.useHint != null
            ? TextButton(onPressed: widget.useHint, child: const Text('use'))
            : null,
      ),
    );
  }
}
