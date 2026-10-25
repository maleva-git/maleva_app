import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/planning/data/plan_trips.dart';
import 'package:maleva/features/planning/models/plan_line.dart';

/// Fleet F4: the same cases as the web's planTrips.test.ts, so the app and the web agree.
PlanLine _row(int truck, {int trip = 0, String source = '', String remarks = ''}) =>
    PlanLine(truckRefid: truck, tripNo: trip, tripSource: source, remarks: remarks);

void main() {
  test('reads trips 1-20 only', () {
    expect(PlanTrips.parseTrip('2'), 2);
    expect(PlanTrips.parseTrip(' 20 '), 20);
    expect(PlanTrips.parseTrip('21'), 0);
    expect(PlanTrips.parseTrip(''), 0);
    expect(PlanTrips.parseTrip('x'), 0);
  });

  test('reads Remarks like the backend', () {
    expect(PlanTrips.tripInRemarks('1ST TRIP'), 1);
    expect(PlanTrips.tripInRemarks('2NDNTRIP'), 2);
    expect(PlanTrips.tripInRemarks('trip 3'), 3);
    expect(PlanTrips.tripInRemarks('27TH ETD(2ND TRIP)'), 2);
    expect(PlanTrips.tripInRemarks('URGENT'), 0);
  });

  test('typing a trip fills the blank rows under it on the same truck, up to the next written row', () {
    final rows = [_row(5), _row(5), _row(9), _row(5), _row(5, trip: 3, source: 'TYPED'), _row(5)];
    final out = PlanTrips.applyTripEdit(rows, 0, '2');
    expect(out.map((r) => r.tripNo), [2, 2, 0, 2, 3, 0]);
    expect(out.map((r) => r.tripSource), ['TYPED', 'FILLED', '', 'FILLED', 'TYPED', '']);
    expect(rows[1].tripNo, 0); // old rows untouched
    expect(out[1].uid, rows[1].uid); // same rows, new values
  });

  test('clearing a trip refills the rows under it from the trip above', () {
    var rows = PlanTrips.applyTripEdit([_row(5), _row(5), _row(5)], 0, '1');
    rows = PlanTrips.applyTripEdit(rows, 1, '2');
    expect(rows.map((r) => r.tripNo), [1, 2, 2]);
    rows = PlanTrips.applyTripEdit(rows, 1, '');
    expect(rows.map((r) => r.tripNo), [1, 0, 1]);
    expect(rows[2].tripSource, 'FILLED');
  });

  test('shows typed bold, filled grey, Remarks italic', () {
    expect(PlanTrips.cell(_row(5, trip: 2, source: 'TYPED')).kind, TripKind.typed);
    expect(PlanTrips.cell(_row(5, trip: 2, source: 'AI')).kind, TripKind.typed);
    expect(PlanTrips.cell(_row(5, trip: 2, source: 'BACKFILL')).kind, TripKind.filled);
    final remarks = PlanTrips.cell(_row(5, remarks: '2ND TRIP'));
    expect([remarks.value, remarks.kind], [2, TripKind.remarks]);
    expect(PlanTrips.cell(_row(5)).kind, TripKind.none);
  });

  test('always sends the trip fields, NONE when there is no trip or no truck', () {
    expect(PlanTrips.forSave(_row(5, trip: 2, source: 'FILLED')), {'tripNo': 2, 'tripSource': 'FILLED'});
    expect(PlanTrips.forSave(_row(5, remarks: '1ST TRIP')), {'tripNo': null, 'tripSource': 'NONE'});
    expect(PlanTrips.forSave(_row(0, trip: 2, source: 'TYPED')), {'tripNo': null, 'tripSource': 'NONE'});
  });
}
