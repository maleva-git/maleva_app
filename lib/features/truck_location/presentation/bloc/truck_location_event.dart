part of 'truck_location_bloc.dart';

sealed class TruckLocationEvent extends Equatable {
  const TruckLocationEvent();

  @override
  List<Object?> get props => const [];
}

class TruckLocationStarted extends TruckLocationEvent {
  const TruckLocationStarted();
}

/// ‹ / › on the week switcher. The page confirms unsaved edits first; by the
/// time this arrives the edits are forfeit.
class TruckLocationWeekShifted extends TruckLocationEvent {
  const TruckLocationWeekShifted(this.deltaDays);

  final int deltaDays;

  @override
  List<Object?> get props => [deltaDays];
}

class TruckLocationThisWeekPressed extends TruckLocationEvent {
  const TruckLocationThisWeekPressed();
}

/// Pull to refresh: reloads the week and keeps unsaved edits.
class TruckLocationRefreshed extends TruckLocationEvent {
  const TruckLocationRefreshed();
}

/// Retry after a failed load.
class TruckLocationRetryPressed extends TruckLocationEvent {
  const TruckLocationRetryPressed();
}

class TruckLocationDaySelected extends TruckLocationEvent {
  const TruckLocationDaySelected(this.day);

  final String day;

  @override
  List<Object?> get props => [day];
}

class TruckLocationCellEdited extends TruckLocationEvent {
  const TruckLocationCellEdited({
    required this.truckRefId,
    required this.planDate,
    required this.value,
  });

  final int truckRefId;
  final String planDate;
  final String value;

  @override
  List<Object?> get props => [truckRefId, planDate, value];
}

/// "Fill <day> from previous": the hint into every empty cell of the selected
/// day, as unsaved edits.
class TruckLocationFillDayPressed extends TruckLocationEvent {
  const TruckLocationFillDayPressed();
}

class TruckLocationDoneToggled extends TruckLocationEvent {
  const TruckLocationDoneToggled({required this.truckRefId, required this.done});

  final int truckRefId;
  final bool done;

  @override
  List<Object?> get props => [truckRefId, done];
}

/// The one save for cells and Done ticks.
class TruckLocationSaveAllPressed extends TruckLocationEvent {
  const TruckLocationSaveAllPressed();
}

/// A row dragged onto another. Saves the shared order at once, apart from
/// Save All.
class TruckLocationRowMoved extends TruckLocationEvent {
  const TruckLocationRowMoved({required this.movedId, required this.targetId});

  final int movedId;
  final int targetId;

  @override
  List<Object?> get props => [movedId, targetId];
}

class TruckLocationFilterChanged extends TruckLocationEvent {
  const TruckLocationFilterChanged(this.filterKey);

  /// A location chip key, or null for All.
  final String? filterKey;

  @override
  List<Object?> get props => [filterKey];
}

class TruckLocationSearchChanged extends TruckLocationEvent {
  const TruckLocationSearchChanged(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

class TruckLocationSortChanged extends TruckLocationEvent {
  const TruckLocationSortChanged(this.sort);

  final TruckLocationSort sort;

  @override
  List<Object?> get props => [sort];
}

class TruckLocationShowDoneToggled extends TruckLocationEvent {
  const TruckLocationShowDoneToggled();
}
