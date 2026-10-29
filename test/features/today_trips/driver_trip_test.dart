import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/today_trips/driver_trip.dart';
import 'package:maleva/features/today_trips/today_trips_text.dart';

void main() {
  test('reads the Java trip as it is', () {
    final t = DriverTrip.fromJava({
      'rtiId': 10565, 'rtiNo': 'RTI000010565', 'tripDay': '2026-10-29', 'firstTime': '2026-10-29T07:00:00',
      'truckName': 'VIPS 7151', 'tripOfDay': 1, 'tripsThatDay': 2,
      'stops': [
        {'kind': 'PICKUP', 'stopId': 1, 'time': '2026-10-29T07:00:00', 'place': 'WESTPORT', 'jobNo': 'MY002606308', 'pic': 'HP:+60 16-640 1934'},
        {'kind': 'STOP', 'stopId': 9, 'time': '2026-10-29T08:00:00', 'place': 'WESTPORT', 'activity': 'SEAL', 'agentName': 'SEELAN', 'agentMobile': '012-3456789'},
        {'kind': 'DELIVERY', 'stopId': 2, 'time': '2026-10-29T14:00:00', 'place': 'SINGAPORE', 'jobNo': 'MY002606308'},
      ],
      'jobs': [{'lineId': 5, 'jobId': 7, 'jobNo': 'MY002606308', 'customer': 'ABC'}],
    });
    expect(t.tripOfDay, 1);
    expect(t.tripsThatDay, 2);
    expect(t.stops.map((s) => s.kind), ['PICKUP', 'STOP', 'DELIVERY']);
    expect(tripRoute(t), 'WESTPORT → SINGAPORE');
    expect(t.jobs.single.jobId, 7);
  });

  test('times, with 00:00 shown as no time', () {
    expect(tripClock('2026-10-29T07:05:00'), '07:05');
    expect(tripClock('2026-10-29T00:00:00'), '--:--');
    expect(tripClock(null), '--:--');
  });

  test('finds the phone numbers in a PIC text', () {
    expect(phonesIn('HP:+60 16-640 1934'), ['+60166401934']);
    expect(phonesIn('Ms. Lew 017-4152233 / Koko 011-26264962'), ['0174152233', '01126264962']);
    expect(phonesIn('En. Qamarul'), isEmpty);
    expect(phonesIn(null), isEmpty);
  });

  test('day text for the chips', () {
    expect(isoDay(DateTime(2026, 10, 9)), '2026-10-09');
  });

  test('each place once, its jobs together, correct totals', () {
    final t = DriverTrip.fromJava({
      'rtiId': 1, 'tripDay': '2026-10-29', 'tripOfDay': 1, 'tripsThatDay': 1,
      'stops': [
        {'kind': 'PICKUP', 'time': '2026-10-29T08:30:00', 'place': 'Westport ', 'jobId': 1, 'jobNo': 'J1', 'customer': 'ABC', 'quantity': '2 PLT', 'pic': 'Ali 012-3456789'},
        {'kind': 'PICKUP', 'time': '2026-10-29T08:00:00', 'place': 'WESTPORT', 'jobId': 2, 'jobNo': 'J2', 'customer': 'ABC', 'quantity': '3 PLT'},
        {'kind': 'PICKUP', 'time': '2026-10-29T10:00:00', 'place': 'PTP', 'jobId': 3, 'jobNo': 'J3', 'customer': 'XYZ'},
        {'kind': 'STOP', 'time': '2026-10-29T09:00:00', 'place': 'WESTPORT', 'activity': 'SEAL', 'agentName': 'SEELAN', 'agentMobile': '019-8765432'},
        {'kind': 'DELIVERY', 'time': '2026-10-29T14:00:00', 'place': 'KLANG', 'jobId': 1, 'jobNo': 'J1'},
        {'kind': 'DELIVERY', 'time': '2026-10-29T14:00:00', 'place': 'Klang', 'jobId': 2, 'jobNo': 'J2'},
        {'kind': 'DELIVERY', 'time': '2026-10-29T16:00:00', 'place': 'SHAH ALAM', 'jobId': 3, 'jobNo': 'J3'},
      ],
      'jobs': [],
    });
    final pick = groupStops(t, 'PICKUP');
    expect(pick.map((g) => g.place), ['Westport', 'PTP']);          // Westport twice = one place, earliest first
    expect(pick.first.time, '2026-10-29T08:00:00');
    expect(pick.first.jobNos, ['J1', 'J2']);
    expect(pick.first.quantities, ['2 PLT', '3 PLT']);
    expect(pick.first.phones, ['0123456789']);
    expect(groupStops(t, 'STOP').single.phones, ['0198765432']);
    final c = countTrips([t]);
    expect([c.pickupJobs, c.pickupPlaces, c.deliveryJobs, c.deliveryPlaces, c.stops], [3, 2, 3, 2, 1]);
    expect(jobsAtPlaces(c.pickupJobs, c.pickupPlaces), '3 jobs at 2 places');
    expect(jobsAtPlaces(1, 1), '1 job at 1 place');
    expect(tripRoute(t), 'Westport (+1) → SHAH ALAM (+1)');
  });

  DriverTrip day(List<Map<String, dynamic>> stops, {String? seenAt, List<Map<String, dynamic>> changes = const []}) =>
      DriverTrip.fromJava({'rtiId': 1, 'rtiNo': 'R1', 'tripDay': '2026-10-29', 'tripOfDay': 1, 'tripsThatDay': 1,
        'stops': stops, 'jobs': [], 'seenAt': seenAt, 'changes': changes});

  test('the next stop by time, with 30 minutes grace; past stops are grey', () {
    final t = day([
      {'kind': 'PICKUP', 'time': '2026-10-29T08:00:00', 'place': 'WESTPORT', 'jobNo': 'J1'},
      {'kind': 'STOP', 'time': '2026-10-29T09:00:00', 'place': 'WESTPORT', 'activity': 'SEAL'},
      {'kind': 'DELIVERY', 'time': '2026-10-29T14:00:00', 'place': 'KLANG', 'jobNo': 'J1'},
    ]);
    expect(nextStop([t], DateTime(2026, 10, 29, 7, 0))!.group.place, 'WESTPORT');
    expect(nextStop([t], DateTime(2026, 10, 29, 8, 20))!.group.kind, 'PICKUP');     // 20 min late: still next
    expect(nextStop([t], DateTime(2026, 10, 29, 8, 45))!.group.kind, 'STOP');
    expect(nextStop([t], DateTime(2026, 10, 29, 15, 0)), isNull);
    expect(isPast(groupStops(t, 'PICKUP').first, DateTime(2026, 10, 29, 9, 0)), isTrue);
  });

  test('Got it is asked for a new trip and after a change', () {
    expect(needsGotIt(day([])), isTrue);
    expect(needsGotIt(day([], seenAt: '2026-10-28T21:52:00')), isFalse);
    final changed = day([], seenAt: '2026-10-28T21:52:00', changes: [
      {'at': '2026-10-28T22:10:00', 'kind': 'CHANGED', 'lines': ['Pickup J7 WESTPORT: 29/10 07:00 → 29/10 08:30']},
    ]);
    expect(needsGotIt(changed), isTrue);
    expect(changed.changes.single.lines.single, startsWith('Pickup J7'));
  });

  test('English and Bahasa Malaysia', () {
    expect(const TripText(false).jobsAtPlaces(3, 2), '3 jobs at 2 places');
    expect(const TripText(true).jobsAtPlaces(3, 2), '3 kerja di 2 tempat');
    expect(const TripText(true).tripOf(1, 2), 'Perjalanan 1 / 2');
    expect(const TripText(false).trips(1), '1 trip');
  });
}
