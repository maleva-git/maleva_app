import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maleva/core/theme/app_typography.dart';
import 'package:maleva/core/theme/tokens.dart';
import 'package:maleva/core/widgets/app_form_fields.dart';

import '../../domain/entities/truck_location_week.dart';
import '../../domain/truck_location_rules.dart' as rules;
import '../bloc/truck_location_bloc.dart';

/// The DAY tab: one card per truck with yesterday and tomorrow either side of
/// the day being typed. This is where the planning happens.
class TruckLocationDayTab extends StatefulWidget {
  const TruckLocationDayTab({super.key});

  @override
  State<TruckLocationDayTab> createState() => _TruckLocationDayTabState();
}

class _TruckLocationDayTabState extends State<TruckLocationDayTab> {
  /// One focus node per truck, so the keyboard's "next" walks the list.
  final Map<int, FocusNode> _focusNodes = {};

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  FocusNode _nodeFor(int truckRefId) =>
      _focusNodes.putIfAbsent(truckRefId, FocusNode.new);

  void _focusNext(List<TruckLocationRow> visible, int truckRefId) {
    final index = visible.indexWhere((row) => row.truckRefId == truckRefId);
    if (index >= 0 && index + 1 < visible.length) {
      _nodeFor(visible[index + 1].truckRefId).requestFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TruckLocationBloc, TruckLocationState>(
      builder: (context, state) {
        final bloc = context.read<TruckLocationBloc>();
        final dayIndex = state.selectedDayIndex;
        if (dayIndex < 0) return const SizedBox.shrink();
        final visible = state.visibleDayRows;

        return Column(
          children: [
            _WeekSwitcher(state: state),
            _DayStrip(state: state),
            _LocationChips(state: state),
            const SizedBox(height: 4),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async =>
                    bloc.add(const TruckLocationRefreshed()),
                child: visible.isEmpty
                    ? _emptyList(state)
                    : _cardList(context, state, visible, dayIndex),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _emptyList(TruckLocationState state) {
    final filtered = state.filterKey != null || state.search.isNotEmpty;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            state.rows.isEmpty
                ? 'No orderable trucks. Tick Orderable truck in Truck Master.'
                : filtered
                    ? 'No trucks match this filter.'
                    : 'Every truck is done for this week.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(color: AppTokens.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _cardList(BuildContext context, TruckLocationState state,
      List<TruckLocationRow> visible, int dayIndex) {
    final bloc = context.read<TruckLocationBloc>();

    if (!state.reorderEnabled) {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        itemCount: visible.length,
        itemBuilder: (context, index) => _card(state, visible, visible[index],
            dayIndex, reorderIndex: null),
      );
    }

    return ReorderableListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      buildDefaultDragHandles: false,
      itemCount: visible.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;
        if (newIndex == oldIndex) return;
        bloc.add(TruckLocationRowMoved(
          movedId: visible[oldIndex].truckRefId,
          targetId: visible[newIndex].truckRefId,
        ));
      },
      itemBuilder: (context, index) =>
          _card(state, visible, visible[index], dayIndex, reorderIndex: index),
    );
  }

  Widget _card(TruckLocationState state, List<TruckLocationRow> visible,
      TruckLocationRow row, int dayIndex, {required int? reorderIndex}) {
    final done = state.effectiveDone(row);
    final card = _TruckDayCard(
      key: ValueKey('truck_${row.truckRefId}'),
      row: row,
      dayIndex: dayIndex,
      state: state,
      focusNode: _nodeFor(row.truckRefId),
      onSubmitted: () => _focusNext(visible, row.truckRefId),
      reorderIndex: reorderIndex,
    );

    if (done) return card; // shown dimmed via "Show done"; no swipe

    return Dismissible(
      key: ValueKey('dismiss_${row.truckRefId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppTokens.statusSuccess,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.check_circle_outline, color: Colors.white),
      ),
      onDismissed: (_) => context.read<TruckLocationBloc>().add(
          TruckLocationDoneToggled(truckRefId: row.truckRefId, done: true)),
      child: card,
    );
  }
}

class _WeekSwitcher extends StatelessWidget {
  const _WeekSwitcher({required this.state});

  final TruckLocationState state;

  /// Changing week with unsaved edits asks first (rule 10).
  Future<void> _change(BuildContext context, TruckLocationEvent event) async {
    if (state.hasUnsaved && !await confirmDiscardChanges(context)) return;
    if (context.mounted) context.read<TruckLocationBloc>().add(event);
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = state.week?.weekStart ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous week',
            iconSize: 22,
            icon: const Icon(Icons.chevron_left),
            color: AppTokens.textMuted,
            onPressed: () =>
                _change(context, const TruckLocationWeekShifted(-7)),
          ),
          Expanded(
            child: Text(
              weekStart.isEmpty ? '' : rules.weekLabel(weekStart),
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge(
                color: AppTokens.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Next week',
            iconSize: 22,
            icon: const Icon(Icons.chevron_right),
            color: AppTokens.textMuted,
            onPressed: () =>
                _change(context, const TruckLocationWeekShifted(7)),
          ),
          TextButton(
            onPressed: () =>
                _change(context, const TruckLocationThisWeekPressed()),
            child: const Text('This week'),
          ),
        ],
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  const _DayStrip({required this.state});

  final TruckLocationState state;

  @override
  Widget build(BuildContext context) {
    final today = rules.todayString();
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: state.days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final day = state.days[index];
          final selected = day == state.selectedDay;
          final parts = day.split('-');
          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => context
                .read<TruckLocationBloc>()
                .add(TruckLocationDaySelected(day)),
            child: Container(
              constraints: const BoxConstraints(minWidth: 52, minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppTokens.brandPrimary : AppTokens.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? AppTokens.brandPrimary : AppTokens.surfaceBorder,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${rules.dayNames[index % 7]} ${int.parse(parts[2])}',
                    style: AppTypography.bodySmall(
                      color: selected ? Colors.white : AppTokens.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: day == today
                          ? (selected ? Colors.white : AppTokens.brandPrimary)
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LocationChips extends StatelessWidget {
  const _LocationChips({required this.state});

  final TruckLocationState state;

  @override
  Widget build(BuildContext context) {
    final groups = state.groupsForSelectedDay;
    final total = state.rows.length;
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _chip(context, label: 'All $total', selected: state.filterKey == null,
              onTap: () => context
                  .read<TruckLocationBloc>()
                  .add(const TruckLocationFilterChanged(null))),
          for (final group in groups)
            _chip(
              context,
              label: '${group.label} ${group.count}',
              selected: state.filterKey == group.key,
              onTap: () => context.read<TruckLocationBloc>().add(
                  TruckLocationFilterChanged(
                      state.filterKey == group.key ? null : group.key)),
            ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context,
      {required String label, required bool selected, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 6, top: 4, bottom: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: AppTypography.bodySmall(
          color: selected ? Colors.white : AppTokens.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        selectedColor: AppTokens.brandPrimary,
        backgroundColor: AppTokens.surfaceCard,
        side: BorderSide(
            color: selected ? AppTokens.brandPrimary : AppTokens.surfaceBorder),
        showCheckmark: false,
      ),
    );
  }
}

/// One truck: name and type on top, then yesterday - the field being typed -
/// tomorrow. The whole point of the screen.
class _TruckDayCard extends StatelessWidget {
  const _TruckDayCard({
    super.key,
    required this.row,
    required this.dayIndex,
    required this.state,
    required this.focusNode,
    required this.onSubmitted,
    required this.reorderIndex,
  });

  final TruckLocationRow row;
  final int dayIndex;
  final TruckLocationState state;
  final FocusNode focusNode;
  final VoidCallback onSubmitted;

  /// Non-null when dragging is allowed; the handle's index for the list.
  final int? reorderIndex;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TruckLocationBloc>();
    final done = state.effectiveDone(row);
    final day = state.days[dayIndex];
    final value = rules.cellValue(row, dayIndex, day, state.edits);
    final dirty = state.isCellDirty(row, dayIndex, day);
    final hint = rules.hintFor(row, dayIndex, state.days, state.edits).trim();
    final showUse = value.trim().isEmpty && hint.isNotEmpty;

    return Opacity(
      opacity: done ? 0.55 : 1,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        elevation: 0,
        color: AppTokens.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: dirty ? AppTokens.statusWarning : AppTokens.surfaceCardBorder,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(row.truckName,
                            style: AppTypography.bodyLarge(
                                color: AppTokens.textPrimary,
                                fontWeight: FontWeight.w700)),
                        if (row.truckType.trim().isNotEmpty)
                          Text(row.truckType,
                              style: AppTypography.bodySmall(
                                  color: AppTokens.textMuted)),
                        if (row.truckStatus.toUpperCase() == 'WORKSHOP')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTokens.statusWarning.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Workshop',
                                style: AppTypography.badgeText(
                                    color: AppTokens.statusWarning,
                                    fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: done ? 'Not done' : 'Done for the week',
                    iconSize: 22,
                    icon: Icon(
                      done ? Icons.check_circle : Icons.check_circle_outline,
                      color: done ? AppTokens.statusSuccess : AppTokens.textDim,
                    ),
                    onPressed: () => bloc.add(TruckLocationDoneToggled(
                        truckRefId: row.truckRefId, done: !done)),
                  ),
                  if (reorderIndex != null)
                    ReorderableDelayedDragStartListener(
                      index: reorderIndex!,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: Icon(Icons.drag_handle,
                            size: 22, color: AppTokens.textDim),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _sideCell(context, dayIndex - 1),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.arrow_forward,
                        size: 14, color: AppTokens.textDim),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_dayLabel(dayIndex),
                            style: AppTypography.bodySmall(
                                color: dirty
                                    ? AppTokens.statusWarning
                                    : AppTokens.textMuted,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        _CellField(
                          key: ValueKey('cell_${row.truckRefId}_$day'),
                          value: value,
                          hint: hint.isEmpty ? 'Location' : hint,
                          enabled: !done,
                          dirty: dirty,
                          focusNode: focusNode,
                          onChanged: (text) => bloc.add(TruckLocationCellEdited(
                              truckRefId: row.truckRefId,
                              planDate: day,
                              value: text)),
                          onSubmitted: onSubmitted,
                          useHint: showUse && !done
                              ? () => bloc.add(TruckLocationCellEdited(
                                  truckRefId: row.truckRefId,
                                  planDate: day,
                                  value: hint))
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.arrow_forward,
                        size: 14, color: AppTokens.textDim),
                  ),
                  _sideCell(context, dayIndex + 1),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dayLabel(int index) {
    if (index < 0 || index >= state.days.length) {
      // Outside the week on screen: the neighbouring calendar day.
      final base = state.days[dayIndex];
      return rules.shortDate(rules.addDays(base, index - dayIndex));
    }
    return '${rules.dayNames[index]} ${rules.shortDate(state.days[index]).split(' ').first}';
  }

  /// The read-only day either side of the field: muted, "—" when empty. Before
  /// Sunday it shows the last known location - where the truck was left.
  Widget _sideCell(BuildContext context, int index) {
    String text;
    if (index < 0) {
      text = row.lastKnownLocation.trim();
    } else if (index >= state.days.length) {
      text = '';
    } else {
      text = rules
          .cellValue(row, index, state.days[index], state.edits)
          .trim();
    }
    return SizedBox(
      width: 78,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_dayLabel(index),
              style: AppTypography.bodySmall(color: AppTokens.textDim)),
          const SizedBox(height: 4),
          Text(
            text.isEmpty ? '—' : text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall(color: AppTokens.textMuted),
          ),
        ],
      ),
    );
  }
}

/// A location cell driven by the bloc's value. Owns its controller and only
/// rewrites the text when the value changes from outside ("use", Fill day, a
/// save), so the cursor never jumps while typing - the AppTextInput pattern,
/// plus the focus chain, the hint's "use" button and the amber dirty tint.
class _CellField extends StatefulWidget {
  const _CellField({
    super.key,
    required this.value,
    required this.hint,
    required this.enabled,
    required this.dirty,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.useHint,
  });

  final String value;
  final String hint;
  final bool enabled;
  final bool dirty;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback? useHint;

  @override
  State<_CellField> createState() => _CellFieldState();
}

class _CellFieldState extends State<_CellField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(covariant _CellField oldWidget) {
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
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.characters,
        maxLength: 200,
        onChanged: widget.onChanged,
        onSubmitted: (_) => widget.onSubmitted(),
        style: AppTypography.bodyLarge(color: AppTokens.textPrimary),
        decoration: appInputDecoration(
          hint: widget.hint,
          enabled: widget.enabled,
        ).copyWith(
          fillColor:
              widget.dirty ? AppTokens.statusWarning.withValues(alpha: 0.06) : null,
          suffixIcon: widget.useHint != null
              ? TextButton(
                  onPressed: widget.useHint,
                  child: const Text('use'),
                )
              : null,
        ),
      ),
    );
  }
}

/// "You have N unsaved changes. Leave without saving?" Used by the page's
/// back handling and the week switcher.
Future<bool> confirmDiscardChanges(BuildContext context) async {
  final bloc = context.read<TruckLocationBloc>();
  final count = bloc.state.unsavedCount;
  final leave = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Unsaved changes'),
      content: Text(
          'You have $count unsaved change${count == 1 ? '' : 's'}. '
          'Leave without saving?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Stay'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: TextButton.styleFrom(foregroundColor: AppTokens.statusDanger),
          child: const Text('Discard'),
        ),
      ],
    ),
  );
  return leave ?? false;
}
