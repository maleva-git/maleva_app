import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/rti/data/rti_grid_rules.dart';
import 'package:maleva/features/rti/data/rti_mapper.dart';
import 'package:maleva/features/rti/data/rti_save_payload.dart';
import 'package:maleva/features/rti/models/rti_stop.dart';

import 'rti_test_data.dart';

// R/hooks/useRTIState.ts:148-188, R/components/RTIRouteActivitiesGrid.tsx:93-116,
// R/services/rtiService.ts:327-357 and 663-697.
void main() {
  group('add / edit defaults', () {
    test('a new stop: last sequence + 1, the destination as full route, row 1 driver number', () {
      var stops = RtiGridRules.addStop(const [], 'PTP');
      expect([stops.first.sequenceNo, stops.first.fullRoute, stops.first.driverNumber], [1, 'PTP', '']);
      stops = RtiGridRules.editStop(stops, 0, (s) => s.copyWith(driverNumber: '0123', sequenceNo: 10));
      stops = RtiGridRules.addStop(stops, 'PTP');
      expect([stops[1].sequenceNo, stops[1].driverNumber], [11, '0123']);
    });

    test("editing row 1's driver number copies it to every row; other rows do not", () {
      var stops = [const RtiStop(sequenceNo: 1), const RtiStop(sequenceNo: 2), const RtiStop(sequenceNo: 3)];
      stops = RtiGridRules.editStop(stops, 0, (s) => s.copyWith(driverNumber: '999'));
      expect(stops.map((s) => s.driverNumber), ['999', '999', '999']);
      stops = RtiGridRules.editStop(stops, 2, (s) => s.copyWith(driverNumber: '1'));
      expect(stops.map((s) => s.driverNumber), ['999', '999', '1']);
    });

    test('the destination field rewrites every full route', () {
      final stops = RtiGridRules.withDestination([const RtiStop(sequenceNo: 1, fullRoute: 'A'), const RtiStop(sequenceNo: 2)], 'WESTPORT');
      expect(stops.map((s) => s.fullRoute), ['WESTPORT', 'WESTPORT']);
    });

    test('agent: an employee copies the mobile; a typed name clears the id; nothing clears all', () {
      const s = RtiStop(sequenceNo: 1, agentName: 'X');
      final e = RtiGridRules.pickAgent(s, employee: const RtiEmployee(id: 4, fullName: 'Ali', mobileNo: '012'));
      expect([e.employeeRefId, e.agentName, e.agentMobileNo], [4, '', '012']);
      final t = RtiGridRules.pickAgent(e, typed: 'Port agent');
      expect([t.employeeRefId, t.agentName, t.agentMobileNo], [null, 'Port agent', '']);
      final c = RtiGridRules.pickAgent(t);
      expect([c.employeeRefId, c.agentName, c.agentMobileNo], [null, '', '']);
    });
  });

  group('SEAL_AND_BREAK and the saved stop', () {
    test('reads SEAL,BREAK_SEAL as SEAL_AND_BREAK and single types as they are', () {
      expect(RtiMapper.stop({'activityType': 'SEAL,BREAK_SEAL'}).jobType, 'SEAL_AND_BREAK');
      expect(RtiMapper.stop({'activityType': 'BREAK_SEAL'}).jobType, 'BREAK_SEAL');
      expect(RtiMapper.stop({'activityType': 'K8 Clearance'}).jobType, 'K8 Clearance');
      expect(RtiMapper.stop({'activityType': 'SEAL', 'marqisStatus': 0}).marqisStatus, isNull);
    });

    test('saves SEAL_AND_BREAK as SEAL,BREAK_SEAL with the web defaults', () {
      final p = RtiSavePayloadBuilder.build(rtiState(), [rtiJob('1')], const [
        RtiStop(sequenceNo: 1, jobType: 'SEAL_AND_BREAK', eta: '2026-10-03T08:30'),
        RtiStop(sequenceNo: 2, jobType: 'SEAL'),
        RtiStop(sequenceNo: 3, marqisStatus: 0, agentName: ''),
      ], companyId: 6, employeeRefId: 3);
      final a = p.routeActivities;
      expect(a[0]['activityType'], 'SEAL,BREAK_SEAL');
      expect(a[0]['eta'], '2026-10-03T08:30:00');
      expect(a[1]['activityType'], 'SEAL');
      expect(a[1]['eta'], '2026-10-02T00:00:00');
      expect(a[1]['plannedDateTime'], '2026-10-02T00:00:00');
      expect([a[2]['activityType'], a[2]['status'], a[2]['marqisStatus'], a[2]['agentName'], a[2]['active'], a[2]['companyRefId']], ['', 0, null, null, true, 6]);
      expect(a[2].containsKey('id'), isFalse);
      expect(a[2].containsKey('rtiMasterRefId'), isFalse);
    });

    test('an edit carries the RTI id on each stop', () {
      final p = RtiSavePayloadBuilder.build(rtiState(editId: 44), [rtiJob('1')], const [RtiStop(id: 5, sequenceNo: 1)], companyId: 6, employeeRefId: 3);
      expect(p.routeActivities.first, containsPair('rtiMasterRefId', 44));
      expect(p.routeActivities.first, containsPair('id', 5));
    });
  });
}
