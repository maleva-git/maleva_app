import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/vessel_changes/vessel_change_look.dart';
import 'package:maleva/core/vessel_changes/vessel_changes_models.dart';

import '../vessel_master/vessel_master_api_test.dart' show callJson;
import 'vessel_changes_api_test.dart' show jobJson;

VesselChangeGroup callGroup({Map<String, dynamic> call = callJson, String? lastChangedAt = '2026-10-13T16:05'}) =>
    VesselChangeGroup.fromJava({'call': call, 'lastChangedAt': lastChangedAt, 'changes': const [], 'jobs': const []});

/// The texts of the Vessel changes screen (vessel-master-and-ptp-schedule, task 4.11).
void main() {
  group('vesselClock', () {
    test('one line, "—" for none, the value when unreadable', () {
      expect(vesselClock('2026-10-12T20:15'), '12 Oct 20:15');
      expect(vesselClock('2026-10-03T05:00'), '3 Oct 05:00');
      expect(vesselClock(null), '—');
      expect(vesselClock(' '), '—');
      expect(vesselClock('soon'), 'soon');
    });
  });

  group('card header', () {
    test('title is the vessel and voyage', () {
      expect(vesselCallTitle(callGroup(call: {...callJson, 'vesselName': 'TOCONAO MAERSK', 'voyage': '636N'}).call),
          'TOCONAO MAERSK 636N');
      expect(vesselCallTitle(callGroup(call: {...callJson, 'voyage': null}).call), 'MAERSK RIO NEGRO');
    });

    test('arrives and departs, "(est.)" only after an estimated time, then when it changed', () {
      expect(vesselCallSubline(callGroup()),
          'PTP: arrives 10 Oct 06:30 (est.) · departs 11 Oct 17:00 · changed 13 Oct 16:05');
      expect(
          vesselCallSubline(callGroup(call: {...callJson, 'arriveEstimated': false, 'departEstimated': true})),
          'PTP: arrives 10 Oct 06:30 · departs 11 Oct 17:00 (est.) · changed 13 Oct 16:05');
    });

    test('a missing time shows "—" (no est.); no change time means no "changed" part, never "PTP changed -"', () {
      final text = vesselCallSubline(
          callGroup(call: {...callJson, 'departAt': null, 'departEstimated': true}, lastChangedAt: null));
      expect(text, 'PTP: arrives 10 Oct 06:30 (est.) · departs —');
      expect(text, isNot(contains('changed')));
    });

    test('a call PTP no longer lists says so', () {
      expect(vesselCallSubline(callGroup(call: {...callJson, 'listed': false})), endsWith(' · no longer listed by PTP'));
    });

    test('the card button names the jobs', () {
      expect(updateAllLabel(1), 'Update this job to PTP');
      expect(updateAllLabel(3), 'Update all 3 jobs to PTP');
    });
  });

  group('timeMatch', () {
    test('differs, not set, same, no PTP time', () {
      expect(timeMatch(current: '2026-10-13T08:00', ptp: '2026-10-15T08:00', differs: true), TimeMatch.differs);
      expect(timeMatch(current: null, ptp: '2026-10-15T08:00', differs: true), TimeMatch.notSet);
      expect(timeMatch(current: '2026-10-21T16:00', ptp: '2026-10-21T16:00', differs: false), TimeMatch.same);
      expect(timeMatch(current: '2026-10-13T08:00', ptp: null, differs: false), TimeMatch.noPtp);
      expect(timeMatch(current: null, ptp: null, differs: false), TimeMatch.noPtp);
    });

    test('only a change to make is highlighted', () {
      expect(timeMatchHighlighted(TimeMatch.differs), isTrue);
      expect(timeMatchHighlighted(TimeMatch.notSet), isTrue);
      expect(timeMatchHighlighted(TimeMatch.same), isFalse);
      expect(timeMatchHighlighted(TimeMatch.noPtp), isFalse);
    });
  });

  group('timeDeltaText', () {
    test('hours, rounded', () {
      expect(timeDeltaText('2026-10-12T12:15', '2026-10-12T20:15'), '+8 h later');
      expect(timeDeltaText('2026-10-10T06:30', '2026-10-11T02:00'), '+20 h later', reason: '19 h 30 min rounds up');
      expect(timeDeltaText('2026-10-12T12:00', '2026-10-12T13:29'), '+1 h later');
    });

    test('days and hours from 24 h, earlier with a minus sign', () {
      expect(timeDeltaText('2026-10-14T08:00', '2026-10-12T05:00'), '−2 d 3 h earlier');
      expect(timeDeltaText('2026-10-13T08:00', '2026-10-15T08:00'), '+2 d later');
      expect(timeDeltaText('2026-10-12T00:00', '2026-10-12T23:40'), '+1 d later', reason: '23 h 40 min rounds to 24 h');
    });

    test('minutes only under an hour', () {
      expect(timeDeltaText('2026-10-12T20:15', '2026-10-12T21:00'), '+45 min later');
      expect(timeDeltaText('2026-10-12T20:15', '2026-10-12T19:45'), '−30 min earlier');
    });

    test('"to fill" when Maleva has none; nothing when PTP has none, it cannot be read or is the same', () {
      expect(timeDeltaText(null, '2026-10-12T20:15'), 'to fill');
      expect(timeDeltaText('2026-10-12T20:15', null), '');
      expect(timeDeltaText('soon', '2026-10-12T20:15'), '');
      expect(timeDeltaText('2026-10-12T20:15', '2026-10-12T20:15'), '');
    });
  });

  group('updatedText', () {
    VesselChangeJob job(int id, {String? jobNo}) =>
        VesselChangeJob.fromJava({...jobJson(id: id), if (jobNo != null) 'jobNo': jobNo});

    test('one job by number, several by count', () {
      expect(updatedText([job(2605808, jobNo: 'MY002605808')]), "MY002605808 updated to PTP's times");
      expect(updatedText([job(1), job(2), job(3)]), "3 jobs updated to PTP's times");
      expect(updatedText([job(7, jobNo: '')]), "#7 updated to PTP's times");
    });
  });
}
