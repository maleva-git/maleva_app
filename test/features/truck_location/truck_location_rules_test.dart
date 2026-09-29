import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/truck_location/domain/entities/truck_location_week.dart';
import 'package:maleva/features/truck_location/domain/truck_location_rules.dart';

/// Mirrors the web client's week.test.ts one for one, so the two rule files
/// can be diffed by test name.
TruckLocationRow row({
  int truckRefId = 7,
  String truckName = 'JSD 4521',
  List<String>? locations,
  String lastKnownLocation = 'Yard',
  bool done = false,
}) =>
    TruckLocationRow(
      truckRefId: truckRefId,
      truckName: truckName,
      truckNumber: 'JSD 4521',
      truckType: '40FT',
      truckStatus: 'ACTIVE',
      locations: locations ?? ['Port Klang', '', 'PTP', '', '', '', ''],
      lastKnownLocation: lastKnownLocation,
      done: done,
    );

void main() {
  group('sundayOf', () {
    test('keeps a Sunday', () {
      expect(sundayOf('2026-09-20'), '2026-09-20');
    });

    test('moves a Saturday back six days', () {
      expect(sundayOf('2026-09-26'), '2026-09-20');
    });

    test('crosses a month and a year', () {
      expect(sundayOf('2026-10-01'), '2026-09-27');
      expect(sundayOf('2027-01-01'), '2026-12-27');
    });
  });

  group('weekDays / weekLabel', () {
    test('lists Sunday to Saturday', () {
      final days = weekDays('2026-09-27');
      expect(days, hasLength(7));
      expect(days[0], '2026-09-27');
      expect(days[6], '2026-10-03');
    });

    test('labels the range with the end year', () {
      expect(weekLabel('2026-09-20'), '20 Sep – 26 Sep 2026');
    });
  });

  group('defaultPlanningDay', () {
    final days = weekDays('2026-09-20');

    test('is tomorrow when tomorrow is on screen', () {
      expect(defaultPlanningDay(days, '2026-09-20'), '2026-09-21');
    });

    test('is today on a Saturday, when tomorrow belongs to next week', () {
      expect(defaultPlanningDay(days, '2026-09-26'), '2026-09-26');
    });

    test('is the Sunday for a week that is not this one', () {
      expect(defaultPlanningDay(days, '2026-08-01'), '2026-09-20');
    });
  });

  group('hintFor', () {
    final days = weekDays('2026-09-20');

    test('takes the nearest filled day to the left', () {
      expect(hintFor(row(), 1, days, const {}), 'Port Klang');
      expect(hintFor(row(), 4, days, const {}), 'PTP');
    });

    test('falls back to the last known location on Sunday', () {
      expect(
        hintFor(row(locations: ['', '', '', '', '', '', '']), 0, days, const {}),
        'Yard',
      );
    });

    test('sees an unsaved edit', () {
      final edits = {'7|${days[1]}': 'Senai'};
      expect(hintFor(row(), 2, days, edits), 'Senai');
    });
  });

  group('changedCells', () {
    final days = weekDays('2026-09-20');

    test('sends only cells that differ from what is saved', () {
      final edits = {
        '7|${days[0]}': 'Port Klang ', // typed back to the saved value
        '7|${days[1]}': ' Senai ',
        '7|${days[2]}': '', // cleared
      };
      expect(changedCells([row()], days, edits), [
        TruckLocationCellChange(
            truckRefId: 7, planDate: addDays(days[0], 1), location: 'Senai'),
        TruckLocationCellChange(
            truckRefId: 7, planDate: days[2], location: ''),
      ]);
    });
  });

  group('location filter and order', () {
    final days = weekDays('2026-09-20');
    final rows = [
      row(truckRefId: 1, truckName: 'B', locations: ['Singapore', '', '', '', '', '', '']),
      row(truckRefId: 2, truckName: 'A', locations: ['kl', '', '', '', '', '', '']),
      row(truckRefId: 3, truckName: 'C', locations: ['', '', '', '', '', '', '']),
      row(truckRefId: 4, truckName: 'D', locations: [' KL ', '', '', '', '', '', '']),
    ];

    test('groups one place whatever its case, with not-located last', () {
      expect(locationGroups(rows, 0, days[0], const {}), [
        LocationGroup(key: 'KL', label: 'KL', count: 2),
        LocationGroup(key: 'SINGAPORE', label: 'SINGAPORE', count: 1),
        LocationGroup(key: emptyLocation, label: 'Not located', count: 1),
      ]);
    });

    test('keeps a row under its chip while the cell is being retyped', () {
      final edits = {'2|${days[0]}': 'PT'};
      expect(matchesLocation(rows[1], 0, days[0], edits, 'KL'), isTrue);
      expect(matchesLocation(rows[0], 0, days[0], edits, 'KL'), isFalse);
    });

    test('orders by location then truck, not-located last', () {
      expect(orderByLocation(rows, 0, days[0], const {}), [2, 4, 1, 3]);
    });

    test('applies a saved order and puts unknown trucks at the end', () {
      expect(
        applyOrder(rows, [4, 1]).map((r) => r.truckRefId).toList(),
        [4, 1, 2, 3],
      );
    });

    test('drops a dragged truck into the place of the one it lands on', () {
      expect(moveOnto([1, 2, 3, 4], 4, 2), [1, 4, 2, 3]);
      expect(moveOnto([1, 2, 3, 4], 1, 4), [2, 3, 4, 1]);
      expect(moveOnto([1, 2, 3, 4], 2, 2), [1, 2, 3, 4]);
    });
  });
}
