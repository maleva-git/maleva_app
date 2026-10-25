import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/planning/models/regular_driver.dart';

/// Fleet F4: the same cases as the web's regularDrivers.test.ts.
void main() {
  const ids = [1, 2, 3, 4];

  test('puts the truck regular drivers first, most reasons first, the rest unchanged', () {
    final r = RegularDriver.fromJava(const {
      'truckRefId': 7,
      'assignedDriverRefId': 3,
      'lastRtiDriverRefId': 2,
      'mostUsedDriverRefId': 2,
      'mostUsedRtis': 12,
    });
    expect(r.notes[2], 'last RTI · 12 RTIs');
    expect(r.notes[3], 'assigned');
    expect(RegularDriver.regularFirst(ids, (int x) => x, r.notes), [2, 3, 1, 4]);
  });

  test('a truck without regular drivers keeps the list as it is', () {
    expect(RegularDriver.regularFirst(ids, (int x) => x, const {}), [1, 2, 3, 4]);
    expect(RegularDriver.fromJava(const {'truckRefId': 7}).notes, isEmpty);
  });
}
