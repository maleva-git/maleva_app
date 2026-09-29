import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show ValueGetter;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/truck_location_week.dart';
import '../../domain/repositories/truck_location_repository.dart';
import '../../domain/truck_location_rules.dart' as rules;
import '../truck_location_view_status.dart';

part 'truck_location_event.dart';
part 'truck_location_state.dart';

/// One bloc behind both tabs (DAY and WEEK), so an edit in one shows in the
/// other. Loaded data and unsaved edits are held apart (rule 10): a refresh
/// replaces the data and leaves the typing alone.
class TruckLocationBloc extends Bloc<TruckLocationEvent, TruckLocationState> {
  TruckLocationBloc({
    required TruckLocationRepository repository,
    String Function()? today,
  })  : _repository = repository,
        _today = today ?? rules.todayString,
        super(const TruckLocationState()) {
    on<TruckLocationStarted>(_onStarted, transformer: droppable());
    on<TruckLocationWeekShifted>(_onWeekShifted, transformer: sequential());
    on<TruckLocationThisWeekPressed>(_onThisWeek, transformer: sequential());
    on<TruckLocationRefreshed>(_onRefreshed, transformer: droppable());
    on<TruckLocationRetryPressed>(_onRetry, transformer: droppable());
    on<TruckLocationDaySelected>(_onDaySelected);
    on<TruckLocationCellEdited>(_onCellEdited);
    on<TruckLocationFillDayPressed>(_onFillDay);
    on<TruckLocationDoneToggled>(_onDoneToggled);
    on<TruckLocationSaveAllPressed>(_onSaveAll, transformer: droppable());
    on<TruckLocationRowMoved>(_onRowMoved, transformer: sequential());
    on<TruckLocationFilterChanged>(_onFilterChanged);
    on<TruckLocationSearchChanged>(_onSearchChanged);
    on<TruckLocationSortChanged>(_onSortChanged);
    on<TruckLocationShowDoneToggled>(_onShowDoneToggled);
  }

  final TruckLocationRepository _repository;

  /// Injectable clock, so tests can pin "today".
  final String Function() _today;

  Future<void> _onStarted(
      TruckLocationStarted event, Emitter<TruckLocationState> emit) =>
      _load(_today(), keepEdits: false, emit: emit);

  Future<void> _onWeekShifted(
      TruckLocationWeekShifted event, Emitter<TruckLocationState> emit) {
    final anchor = state.week?.weekStart ?? _today();
    return _load(rules.addDays(anchor, event.deltaDays),
        keepEdits: false, emit: emit);
  }

  Future<void> _onThisWeek(
      TruckLocationThisWeekPressed event, Emitter<TruckLocationState> emit) =>
      _load(_today(), keepEdits: false, emit: emit);

  Future<void> _onRetry(
      TruckLocationRetryPressed event, Emitter<TruckLocationState> emit) =>
      _load(state.week?.weekStart ?? _today(), keepEdits: true, emit: emit);

  /// Pull to refresh: replaces the loaded week, keeps the unsaved edits, and
  /// never blanks the board - a failure is a snackbar, not an error screen.
  Future<void> _onRefreshed(
      TruckLocationRefreshed event, Emitter<TruckLocationState> emit) async {
    final anchor = state.week?.weekStart;
    if (anchor == null) return _load(_today(), keepEdits: true, emit: emit);
    try {
      final week = await _repository.week(anchor);
      emit(state.copyWith(status: TruckLocationStatus.success, week: week));
    } catch (error) {
      emit(state.copyWith(
        message: () =>
            TruckLocationUiMessage(describeTruckLocationError(error), isError: true),
      ));
    }
  }

  Future<void> _load(
    String date, {
    required bool keepEdits,
    required Emitter<TruckLocationState> emit,
  }) async {
    emit(state.copyWith(
      status: TruckLocationStatus.loading,
      errorMessage: () => null,
    ));
    try {
      final week = await _repository.week(date);
      final selected = keepEdits && week.days.contains(state.selectedDay)
          ? state.selectedDay
          : rules.defaultPlanningDay(week.days, _today());
      emit(state.copyWith(
        status: TruckLocationStatus.success,
        week: week,
        selectedDay: selected,
        edits: keepEdits ? null : const {},
        doneEdits: keepEdits ? null : const {},
        filterKey: keepEdits ? null : () => null,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: TruckLocationStatus.failure,
        errorMessage: () => describeTruckLocationError(error),
      ));
    }
  }

  void _onDaySelected(
      TruckLocationDaySelected event, Emitter<TruckLocationState> emit) {
    if (event.day == state.selectedDay) return;
    // The chips describe one day; a filter must not survive into another.
    emit(state.copyWith(selectedDay: event.day, filterKey: () => null));
  }

  void _onCellEdited(
      TruckLocationCellEdited event, Emitter<TruckLocationState> emit) {
    final edits = Map<String, String>.of(state.edits);
    edits[rules.cellKey(event.truckRefId, event.planDate)] = event.value;
    emit(state.copyWith(edits: edits));
  }

  /// Rule 7: the hint into every empty cell of the selected day, as unsaved
  /// edits. Rows already ticked Done are off the board and left alone.
  void _onFillDay(
      TruckLocationFillDayPressed event, Emitter<TruckLocationState> emit) {
    final dayIndex = state.selectedDayIndex;
    if (dayIndex < 0) return;

    final edits = Map<String, String>.of(state.edits);
    var filled = 0;
    for (final row in state.rows) {
      if (state.effectiveDone(row)) continue;
      if (rules.cellValue(row, dayIndex, state.selectedDay, state.edits)
          .trim()
          .isNotEmpty) {
        continue;
      }
      final hint =
          rules.hintFor(row, dayIndex, state.days, state.edits).trim();
      if (hint.isEmpty) continue;
      edits[rules.cellKey(row.truckRefId, state.selectedDay)] = hint;
      filled++;
    }

    if (filled == 0) {
      emit(state.copyWith(
        message: () => TruckLocationUiMessage('Nothing to fill'),
      ));
      return;
    }
    emit(state.copyWith(
      edits: edits,
      message: () => TruckLocationUiMessage(
          'Filled $filled truck${filled == 1 ? '' : 's'} - not saved yet'),
    ));
  }

  void _onDoneToggled(
      TruckLocationDoneToggled event, Emitter<TruckLocationState> emit) {
    final row = _rowOf(event.truckRefId);
    if (row == null) return;
    final doneEdits = Map<int, bool>.of(state.doneEdits);
    if (event.done == row.done) {
      doneEdits.remove(event.truckRefId); // back to what is saved: nothing to send
    } else {
      doneEdits[event.truckRefId] = event.done;
    }
    emit(state.copyWith(doneEdits: doneEdits));
  }

  /// Save All: only what changed (rule 4). The server answers with the week as
  /// it now stands; edits that match it are done with, ones typed while the
  /// save ran stay unsaved.
  Future<void> _onSaveAll(
      TruckLocationSaveAllPressed event, Emitter<TruckLocationState> emit) async {
    final week = state.week;
    if (week == null) return;
    final cells = state.pendingCells;
    final ticks = state.pendingTicks;
    if (cells.isEmpty && ticks.isEmpty) {
      emit(state.copyWith(
        message: () => TruckLocationUiMessage('Nothing to save'),
      ));
      return;
    }

    emit(state.copyWith(saving: true));
    try {
      final saved = await _repository.saveWeek(
        weekStart: week.weekStart,
        cells: cells,
        doneTicks: ticks,
      );
      final count = cells.length + ticks.length;
      emit(state.copyWith(
        saving: false,
        week: saved,
        edits: _pruneEdits(state.edits, saved),
        doneEdits: _pruneDoneEdits(state.doneEdits, saved),
        message: () => TruckLocationUiMessage(
            '$count change${count == 1 ? '' : 's'} saved'),
      ));
    } catch (error) {
      // The server's own message (a 400 names the truck or the date), shown
      // as it came, never replaced by a generic text.
      emit(state.copyWith(
        saving: false,
        message: () =>
            TruckLocationUiMessage(describeTruckLocationError(error), isError: true),
      ));
    }
  }

  /// Rule 9: the whole board's ids, hidden rows too; optimistic, and the row
  /// goes back where it was when the save fails.
  Future<void> _onRowMoved(
      TruckLocationRowMoved event, Emitter<TruckLocationState> emit) async {
    final week = state.week;
    if (week == null || !state.reorderEnabled) return;

    final order = [for (final row in week.rows) row.truckRefId];
    final next = rules.moveOnto(order, event.movedId, event.targetId);
    if (identical(next, order)) return;

    final before = week;
    emit(state.copyWith(
      week: week.copyWith(rows: rules.applyOrder(week.rows, next)),
      savingOrder: true,
    ));
    try {
      await _repository.saveOrder(next);
      emit(state.copyWith(savingOrder: false));
    } catch (error) {
      emit(state.copyWith(
        week: before,
        savingOrder: false,
        message: () =>
            TruckLocationUiMessage(describeTruckLocationError(error), isError: true),
      ));
    }
  }

  void _onFilterChanged(
      TruckLocationFilterChanged event, Emitter<TruckLocationState> emit) {
    emit(state.copyWith(filterKey: () => event.filterKey));
  }

  void _onSearchChanged(
      TruckLocationSearchChanged event, Emitter<TruckLocationState> emit) {
    emit(state.copyWith(search: event.text.trim()));
  }

  void _onSortChanged(
      TruckLocationSortChanged event, Emitter<TruckLocationState> emit) {
    emit(state.copyWith(sort: event.sort));
  }

  void _onShowDoneToggled(
      TruckLocationShowDoneToggled event, Emitter<TruckLocationState> emit) {
    emit(state.copyWith(showDone: !state.showDone));
  }

  TruckLocationRow? _rowOf(int truckRefId) {
    for (final row in state.rows) {
      if (row.truckRefId == truckRefId) return row;
    }
    return null;
  }

  /// Keeps only edits that still differ from what the server now holds.
  static Map<String, String> _pruneEdits(
      Map<String, String> edits, TruckLocationWeek saved) {
    final byId = {for (final row in saved.rows) row.truckRefId: row};
    final kept = <String, String>{};
    edits.forEach((key, value) {
      final separator = key.indexOf('|');
      final truckRefId = int.tryParse(key.substring(0, separator));
      final planDate = key.substring(separator + 1);
      final row = byId[truckRefId];
      final dayIndex = saved.days.indexOf(planDate);
      final savedValue = (row != null &&
              dayIndex >= 0 &&
              dayIndex < row.locations.length)
          ? row.locations[dayIndex]
          : '';
      if (value.trim() != savedValue.trim()) {
        kept[key] = value;
      }
    });
    return kept;
  }

  static Map<int, bool> _pruneDoneEdits(
      Map<int, bool> doneEdits, TruckLocationWeek saved) {
    final byId = {for (final row in saved.rows) row.truckRefId: row};
    final kept = <int, bool>{};
    doneEdits.forEach((truckRefId, done) {
      final row = byId[truckRefId];
      if (row != null && row.done != done) {
        kept[truckRefId] = done;
      }
    });
    return kept;
  }
}
