import 'package:maleva/core/utils/json_read.dart';

import '../../domain/entities/truck_location_week.dart';

/// JSON in and out of the Java `/api/truck-locations` API, in one place
/// (camelCase, as `TruckLocationWeekResponse` and the request DTOs declare it).
class TruckLocationJson {
  TruckLocationJson._();

  /// `Data1` of the week calls.
  static TruckLocationWeek week(Map<String, dynamic> data) {
    final days = (data['days'] is List)
        ? (data['days'] as List).map(_dateOnly).toList()
        : const <String>[];
    return TruckLocationWeek(
      weekStart: _dateOnly(data['weekStart']),
      days: days,
      rows: JsonRead.listOfMaps(data['rows']).map(_row).toList(),
    );
  }

  static TruckLocationRow _row(Map<String, dynamic> data) {
    final locations = (data['locations'] is List)
        ? (data['locations'] as List).map(JsonRead.string).toList()
        : <String>[];
    while (locations.length < 7) {
      locations.add('');
    }
    return TruckLocationRow(
      truckRefId: JsonRead.integer(data['truckRefId']),
      truckName: JsonRead.string(data['truckName']),
      truckNumber: JsonRead.string(data['truckNumber']),
      truckType: JsonRead.string(data['truckType']),
      truckStatus: JsonRead.string(data['truckStatus']),
      locations: locations,
      lastKnownLocation: JsonRead.string(data['lastKnownLocation']),
      done: JsonRead.boolean(data['done']),
    );
  }

  static Map<String, dynamic> weekQuery({
    required int companyId,
    required String date,
  }) =>
      {'companyRefId': companyId, if (date.isNotEmpty) 'date': date};

  /// The person saving is taken from the session token on the server.
  static Map<String, dynamic> saveRequest({
    required int companyId,
    required String weekStart,
    required List<TruckLocationCellChange> cells,
    required List<TruckLocationDoneTick> doneTicks,
  }) =>
      {
        'companyRefId': companyId,
        'weekStart': weekStart,
        'cells': [
          for (final cell in cells)
            {
              'truckRefId': cell.truckRefId,
              'planDate': cell.planDate,
              'location': cell.location,
            },
        ],
        'doneTicks': [
          for (final tick in doneTicks)
            {'truckRefId': tick.truckRefId, 'done': tick.done},
        ],
        'dayDoneTicks': const <Map<String, dynamic>>[],
      };

  static Map<String, dynamic> orderRequest({
    required int companyId,
    required List<int> truckRefIds,
  }) =>
      {'companyRefId': companyId, 'truckRefIds': truckRefIds};

  /// "2026-09-20" whether the server sent a date or a date-time string.
  static String _dateOnly(dynamic value) {
    final text = JsonRead.string(value);
    return text.length > 10 ? text.substring(0, 10) : text;
  }
}
