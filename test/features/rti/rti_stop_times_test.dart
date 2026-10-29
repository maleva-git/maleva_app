import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/rti/rti_api.dart';
import 'package:maleva/features/rti/list/widgets/rti_stop_times.dart';

void main() {
  test('reads the Java site visit as it is', () {
    final v = SiteVisit.fromJava({
      'rtiId': 1, 'kind': 'DELIVERY', 'stopId': 9, 'jobNo': 'J1', 'place': 'WESTPORT', 'arrived': '2026-10-01T09:12:00',
      'left': '2026-10-01T11:40:00', 'minutes': 148, 'status': 'MATCHED', 'workStart': null,
    });
    expect(v.stopId, 9);
    expect(siteVisitLine(v), 'Arrived 09:12 · Left 11:40 · 2 h 28');
  });

  test('says still there and why a stop has no time', () {
    expect(siteVisitLine(const SiteVisit(kind: 'PICKUP', stopId: 1, arrived: '2026-10-01T09:12:00', status: 'MATCHED')),
        'Arrived 09:12 · Still there');
    expect(siteVisitLine(const SiteVisit(kind: 'PICKUP', stopId: 1, status: 'NO_PIN')), 'Address not pinned');
    expect(siteVisitDuration(45), '45 min');
    expect(siteVisitDuration(120), '2 h');
  });

  test('the driver taps in order: check in, start, done', () {
    expect(siteVisitNextTap(const SiteVisit(kind: 'PICKUP', stopId: 1, status: 'PENDING'))!.label, 'Check in at gate');
    expect(siteVisitNextTap(const SiteVisit(kind: 'PICKUP', stopId: 1, status: 'MATCHED', checkIn: '2026-10-01T09:00:00'))!.label,
        'Start loading');
    expect(siteVisitNextTap(const SiteVisit(kind: 'DELIVERY', stopId: 1, status: 'MATCHED', checkIn: '2026-10-01T09:00:00'))!.action,
        'work-start');
    expect(siteVisitNextTap(const SiteVisit(kind: 'DELIVERY', stopId: 1, status: 'MATCHED', checkIn: 'a', workStart: 'b'))!.label, 'Done');
    expect(siteVisitNextTap(const SiteVisit(kind: 'DELIVERY', stopId: 1, status: 'MATCHED', checkIn: 'a', workStart: 'b', done: 'c')), isNull);
    // already left without a check-in: nothing to tap (the office corrects it)
    expect(siteVisitNextTap(const SiteVisit(kind: 'DELIVERY', stopId: 1, status: 'MATCHED', left: '2026-10-01T11:00:00')), isNull);
  });

  test('reads the tap answer', () {
    final t = SiteVisitTap.fromJava({'saved': true, 'message': 'Checked in', 'atGate': true, 'metresFromPin': 40});
    expect(t.saved, isTrue);
    expect(t.message, 'Checked in');
  });
}
