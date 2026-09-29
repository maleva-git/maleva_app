/// Week arithmetic and grid rules for the Truck Location Board.
///
/// A one-for-one port of the web client's `week.ts`, so the app and the browser
/// agree about hints, dirty cells, chips and order. Everything works on
/// `yyyy-MM-dd` strings and date-only values - dates are normalised through
/// `DateTime.utc`, never local time, so the grid does not depend on the
/// device's time zone.
library;

import 'entities/truck_location_week.dart';

const List<String> dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

const List<String> _monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _pad(int value) => value.toString().padLeft(2, '0');

List<int> _parts(String dateString) =>
    dateString.split('-').map(int.parse).toList();

/// Normalises an out-of-range day (day 0, day 32) the way the web's
/// `new Date(year, month, day)` does.
String _toDateString(int year, int month, int day) {
  final normalised = DateTime.utc(year, month, day);
  return '${normalised.year.toString().padLeft(4, '0')}-'
      '${_pad(normalised.month)}-${_pad(normalised.day)}';
}

String todayString() {
  final now = DateTime.now();
  return _toDateString(now.year, now.month, now.day);
}

String addDays(String dateString, int days) {
  final parts = _parts(dateString);
  return _toDateString(parts[0], parts[1], parts[2] + days);
}

/// The Sunday on or before [dateString].
String sundayOf(String dateString) {
  final parts = _parts(dateString);
  // DateTime.weekday is Mon=1..Sun=7; % 7 gives the web's getDay() (Sun=0).
  final dayOfWeek = DateTime.utc(parts[0], parts[1], parts[2]).weekday % 7;
  return _toDateString(parts[0], parts[1], parts[2] - dayOfWeek);
}

/// The seven dates of the week starting at [weekStart].
List<String> weekDays(String weekStart) =>
    List.generate(7, (index) => addDays(weekStart, index));

/// `21 Sep`
String shortDate(String dateString) {
  final parts = _parts(dateString);
  return '${parts[2]} ${_monthNames[parts[1] - 1]}';
}

/// `20 Sep – 26 Sep 2026`
String weekLabel(String weekStart) {
  final end = addDays(weekStart, 6);
  return '${shortDate(weekStart)} – ${shortDate(end)} ${end.substring(0, 4)}';
}

/// The day the planner is most likely working on: tomorrow, because Monday's
/// plan is made on Sunday. Falls back to the first day when tomorrow is
/// outside the week on screen.
String defaultPlanningDay(List<String> days, String today) {
  final tomorrow = addDays(today, 1);
  if (days.contains(tomorrow)) return tomorrow;
  if (days.contains(today)) return today;
  return days.isEmpty ? today : days.first;
}

String cellKey(int truckRefId, String planDate) => '$truckRefId|$planDate';

/// What a cell shows: the unsaved edit when there is one, otherwise the saved
/// value.
String cellValue(
  TruckLocationRow row,
  int dayIndex,
  String planDate,
  Map<String, String> edits,
) {
  final edited = edits[cellKey(row.truckRefId, planDate)];
  if (edited != null) return edited;
  return dayIndex < row.locations.length ? row.locations[dayIndex] : '';
}

/// The grey hint for an empty cell: the nearest filled day to its left this
/// week, else the truck's last known location from before the week.
String hintFor(
  TruckLocationRow row,
  int dayIndex,
  List<String> days,
  Map<String, String> edits,
) {
  for (var index = dayIndex - 1; index >= 0; index -= 1) {
    final value = cellValue(row, index, days[index], edits).trim();
    if (value.isNotEmpty) return value;
  }
  return row.lastKnownLocation;
}

/// Edits that differ from what is saved. Typing a value and then typing it
/// back leaves nothing to save, so it is dropped here rather than sent.
List<TruckLocationCellChange> changedCells(
  List<TruckLocationRow> rows,
  List<String> days,
  Map<String, String> edits,
) {
  final changes = <TruckLocationCellChange>[];
  for (final row in rows) {
    for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
      final planDate = days[dayIndex];
      final edited = edits[cellKey(row.truckRefId, planDate)];
      if (edited == null) continue;
      final saved = dayIndex < row.locations.length ? row.locations[dayIndex] : '';
      if (edited.trim() == saved.trim()) continue;
      changes.add(TruckLocationCellChange(
        truckRefId: row.truckRefId,
        planDate: planDate,
        location: edited.trim(),
      ));
    }
  }
  return changes;
}

/// Filter key for trucks with nothing typed on the planning day.
const String emptyLocation = '(empty)';

/// KL, kl and " Kl " are one place.
String locationKey(String value) {
  final key = value.trim().toUpperCase();
  return key.isEmpty ? emptyLocation : key;
}

class LocationGroup {
  LocationGroup({required this.key, required this.label, required this.count});

  final String key;
  final String label;
  int count;

  @override
  bool operator ==(Object other) =>
      other is LocationGroup &&
      other.key == key &&
      other.label == label &&
      other.count == count;

  @override
  int get hashCode => Object.hash(key, label, count);

  @override
  String toString() => 'LocationGroup($key, $label, $count)';
}

/// The places typed on one day, with how many trucks are at each - the filter
/// chips. Alphabetical, with the not-yet-located trucks last.
List<LocationGroup> locationGroups(
  List<TruckLocationRow> rows,
  int dayIndex,
  String planDate,
  Map<String, String> edits,
) {
  final groups = <String, LocationGroup>{};
  for (final row in rows) {
    final value = cellValue(row, dayIndex, planDate, edits).trim();
    final key = locationKey(value);
    final group = groups[key];
    if (group != null) {
      group.count += 1;
    } else {
      groups[key] = LocationGroup(
        key: key,
        label: key == emptyLocation ? 'Not located' : value.toUpperCase(),
        count: 1,
      );
    }
  }
  return groups.values.toList()
    ..sort((a, b) {
      if (a.key == emptyLocation) return 1;
      if (b.key == emptyLocation) return -1;
      return a.key.compareTo(b.key);
    });
}

/// Whether a row belongs under a location chip. The saved value counts as well
/// as the one on screen, so a row does not vanish from under the cursor while
/// its cell is being retyped - it leaves the filter once the change is saved.
bool matchesLocation(
  TruckLocationRow row,
  int dayIndex,
  String planDate,
  Map<String, String> edits,
  String filterKey,
) {
  if (locationKey(cellValue(row, dayIndex, planDate, edits)) == filterKey) {
    return true;
  }
  final saved = dayIndex < row.locations.length ? row.locations[dayIndex] : '';
  return locationKey(saved) == filterKey;
}

/// Truck ids ordered by that day's location, then truck name; not-located
/// trucks last.
List<int> orderByLocation(
  List<TruckLocationRow> rows,
  int dayIndex,
  String planDate,
  Map<String, String> edits,
) {
  final indexed = rows.asMap().entries.toList()
    ..sort((a, b) {
      final keyA = locationKey(cellValue(a.value, dayIndex, planDate, edits));
      final keyB = locationKey(cellValue(b.value, dayIndex, planDate, edits));
      if (keyA != keyB) {
        if (keyA == emptyLocation) return 1;
        if (keyB == emptyLocation) return -1;
        return keyA.compareTo(keyB);
      }
      final byName = a.value.truckName.compareTo(b.value.truckName);
      // List.sort is not stable; the original index keeps ties in place, the
      // way the web's stable Array.sort does.
      return byName != 0 ? byName : a.key - b.key;
    });
  return indexed.map((entry) => entry.value.truckRefId).toList();
}

/// Rows in the planner's own order. A truck the order has never seen (newly
/// flagged orderable) goes to the end, in the server's order.
List<TruckLocationRow> applyOrder(List<TruckLocationRow> rows, List<int> order) {
  if (order.isEmpty) return rows;
  final position = <int, int>{
    for (var index = 0; index < order.length; index++) order[index]: index,
  };
  const unknown = 1 << 30;
  final indexed = rows.asMap().entries.toList()
    ..sort((a, b) {
      final byPosition = (position[a.value.truckRefId] ?? unknown) -
          (position[b.value.truckRefId] ?? unknown);
      return byPosition != 0 ? byPosition : a.key - b.key;
    });
  return indexed.map((entry) => entry.value).toList();
}

/// [order] after dragging [movedId] onto [targetId]. The dragged truck takes
/// the target's place: dropped above where it came from it lands before the
/// target, dropped below it lands after - so the last row is reachable too.
List<int> moveOnto(List<int> order, int movedId, int targetId) {
  final from = order.indexOf(movedId);
  final to = order.indexOf(targetId);
  if (from < 0 || to < 0 || from == to) return order;
  final next = order.where((id) => id != movedId).toList();
  next.insert(to, movedId);
  return next;
}
