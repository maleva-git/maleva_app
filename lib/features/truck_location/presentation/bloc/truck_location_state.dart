part of 'truck_location_bloc.dart';

class TruckLocationState extends Equatable {
  const TruckLocationState({
    this.status = TruckLocationStatus.initial,
    this.week,
    this.edits = const {},
    this.doneEdits = const {},
    this.selectedDay = '',
    this.filterKey,
    this.search = '',
    this.sort = TruckLocationSort.shared,
    this.showDone = false,
    this.saving = false,
    this.savingOrder = false,
    this.errorMessage,
    this.message,
  });

  final TruckLocationStatus status;

  /// The loaded week, rows in the shared order. Unsaved edits live apart from
  /// it (rule 10), so a refresh never wipes typing.
  final TruckLocationWeek? week;

  /// cellKey -> the text on screen. Present only for cells the user touched.
  final Map<String, String> edits;

  /// truckRefId -> the unsaved Done tick. Present only when it differs from
  /// what was loaded... or was put back to it (then pruned on toggle).
  final Map<int, bool> doneEdits;

  /// yyyy-MM-dd of the DAY tab's selected day.
  final String selectedDay;

  /// A location chip key ([rules.locationKey] form), or null for All.
  final String? filterKey;

  final String search;
  final TruckLocationSort sort;
  final bool showDone;
  final bool saving;
  final bool savingOrder;

  /// Why the load failed - the error screen with Retry.
  final String? errorMessage;

  /// A one-off snackbar.
  final TruckLocationUiMessage? message;

  List<String> get days => week?.days ?? const [];

  List<TruckLocationRow> get rows => week?.rows ?? const [];

  int get selectedDayIndex => days.indexOf(selectedDay);

  /// Edits that differ from what is saved - what Save All will send.
  List<TruckLocationCellChange> get pendingCells =>
      rules.changedCells(rows, days, edits);

  /// Done ticks that differ from what is saved.
  List<TruckLocationDoneTick> get pendingTicks => [
        for (final row in rows)
          if (doneEdits.containsKey(row.truckRefId) &&
              doneEdits[row.truckRefId] != row.done)
            TruckLocationDoneTick(
              truckRefId: row.truckRefId,
              done: doneEdits[row.truckRefId]!,
            ),
      ];

  int get unsavedCount => pendingCells.length + pendingTicks.length;

  bool get hasUnsaved => unsavedCount > 0;

  /// Done as shown: the unsaved tick over the loaded one.
  bool effectiveDone(TruckLocationRow row) =>
      doneEdits[row.truckRefId] ?? row.done;

  int get doneCount => rows.where(effectiveDone).length;

  /// Whether this cell holds an unsaved change (the amber border).
  bool isCellDirty(TruckLocationRow row, int dayIndex, String planDate) {
    final edited = edits[rules.cellKey(row.truckRefId, planDate)];
    if (edited == null) return false;
    final saved = dayIndex < row.locations.length ? row.locations[dayIndex] : '';
    return edited.trim() != saved.trim();
  }

  /// Dragging is only allowed on the full, shared-order list: a partial list
  /// must never define the order every planner shares.
  bool get reorderEnabled =>
      filterKey == null && search.isEmpty && sort == TruckLocationSort.shared;

  /// The chips for the selected day, over every truck on the board.
  List<rules.LocationGroup> get groupsForSelectedDay {
    final dayIndex = selectedDayIndex;
    if (dayIndex < 0) return const [];
    return rules.locationGroups(rows, dayIndex, selectedDay, edits);
  }

  bool _matchesSearch(TruckLocationRow row) {
    if (search.isEmpty) return true;
    final needle = search.toLowerCase();
    return row.truckName.toLowerCase().contains(needle) ||
        row.truckNumber.toLowerCase().contains(needle);
  }

  /// The DAY tab's list: done rows out (unless shown), then chip filter,
  /// search and sort.
  List<TruckLocationRow> get visibleDayRows {
    final dayIndex = selectedDayIndex;
    if (dayIndex < 0) return const [];

    var visible = rows
        .where((row) => showDone || !effectiveDone(row))
        .where(_matchesSearch)
        .where((row) =>
            filterKey == null ||
            rules.matchesLocation(row, dayIndex, selectedDay, edits, filterKey!))
        .toList();

    switch (sort) {
      case TruckLocationSort.shared:
        break; // rows already carry the shared order
      case TruckLocationSort.byLocation:
        final ordered = rules.orderByLocation(visible, dayIndex, selectedDay, edits);
        visible = rules.applyOrder(visible, ordered);
      case TruckLocationSort.byTruck:
        visible.sort((a, b) =>
            a.truckName.toLowerCase().compareTo(b.truckName.toLowerCase()));
    }
    return visible;
  }

  /// The WEEK tab's list: done rows out (unless shown) and search only.
  List<TruckLocationRow> get visibleWeekRows => rows
      .where((row) => showDone || !effectiveDone(row))
      .where(_matchesSearch)
      .toList();

  TruckLocationState copyWith({
    TruckLocationStatus? status,
    TruckLocationWeek? week,
    Map<String, String>? edits,
    Map<int, bool>? doneEdits,
    String? selectedDay,
    ValueGetter<String?>? filterKey,
    String? search,
    TruckLocationSort? sort,
    bool? showDone,
    bool? saving,
    bool? savingOrder,
    ValueGetter<String?>? errorMessage,
    ValueGetter<TruckLocationUiMessage?>? message,
  }) {
    return TruckLocationState(
      status: status ?? this.status,
      week: week ?? this.week,
      edits: edits ?? this.edits,
      doneEdits: doneEdits ?? this.doneEdits,
      selectedDay: selectedDay ?? this.selectedDay,
      filterKey: filterKey != null ? filterKey() : this.filterKey,
      search: search ?? this.search,
      sort: sort ?? this.sort,
      showDone: showDone ?? this.showDone,
      saving: saving ?? this.saving,
      savingOrder: savingOrder ?? this.savingOrder,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      message: message != null ? message() : this.message,
    );
  }

  @override
  List<Object?> get props => [
        status, week, edits, doneEdits, selectedDay, filterKey, search,
        sort, showDone, saving, savingOrder, errorMessage, message,
      ];
}
