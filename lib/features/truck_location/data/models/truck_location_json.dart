import 'package:maleva/core/utils/json_read.dart';

import '../../domain/entities/truck_location_week.dart';

/// JSON in and out of TruckLocationApp, in one place. The wire names are the
/// .NET model's PascalCase properties.
class TruckLocationJson {
  TruckLocationJson._();

  /// Data1 of SelectWeek / SaveWeek.
  static TruckLocationWeek week(Map<String, dynamic> data) {
    final days = (data['Days'] is List)
        ? (data['Days'] as List).map(_dateOnly).toList()
        : const <String>[];
    return TruckLocationWeek(
      weekStart: _dateOnly(data['WeekStart']),
      days: days,
      rows: JsonRead.listOfMaps(data['Rows']).map(_row).toList(),
    );
  }

  static TruckLocationRow _row(Map<String, dynamic> data) {
    final locations = (data['Locations'] is List)
        ? (data['Locations'] as List).map(JsonRead.string).toList()
        : <String>[];
    while (locations.length < 7) {
      locations.add('');
    }
    return TruckLocationRow(
      truckRefId: JsonRead.integer(data['TruckRefId']),
      truckName: JsonRead.string(data['TruckName']),
      truckNumber: JsonRead.string(data['TruckNumber']),
      truckType: JsonRead.string(data['TruckType']),
      truckStatus: JsonRead.string(data['TruckStatus']),
      locations: locations,
      lastKnownLocation: JsonRead.string(data['LastKnownLocation']),
      done: JsonRead.boolean(data['Done']),
    );
  }

  static Map<String, dynamic> weekRequest({
    required int companyId,
    required String date,
  }) =>
      {'CompanyRefId': companyId, 'Date': date};

  static Map<String, dynamic> saveRequest({
    required int companyId,
    required int userRefId,
    required String weekStart,
    required List<TruckLocationCellChange> cells,
    required List<TruckLocationDoneTick> doneTicks,
  }) =>
      {
        'CompanyRefId': companyId,
        'UserRefId': userRefId,
        'WeekStart': weekStart,
        'Cells': [
          for (final cell in cells)
            {
              'TruckRefId': cell.truckRefId,
              'PlanDate': cell.planDate,
              'Location': cell.location,
            },
        ],
        'DoneTicks': [
          for (final tick in doneTicks)
            {'TruckRefId': tick.truckRefId, 'Done': tick.done},
        ],
      };

  static Map<String, dynamic> orderRequest({
    required int companyId,
    required int userRefId,
    required List<int> truckRefIds,
  }) =>
      {
        'CompanyRefId': companyId,
        'UserRefId': userRefId,
        'TruckRefIds': truckRefIds,
      };

  /// "2026-09-20" whether the server sent a date or a date-time string.
  static String _dateOnly(dynamic value) {
    final text = JsonRead.string(value);
    return text.length > 10 ? text.substring(0, 10) : text;
  }
}
