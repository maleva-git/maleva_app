import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/rti/data/rti_grid_rules.dart';
import 'package:maleva/features/rti/data/rti_mapper.dart';
import 'package:maleva/features/rti/data/rti_save_payload.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/models/rti_job_info.dart';
import 'package:maleva/features/rti/models/rti_job_row.dart';
import 'package:maleva/features/rti/models/rti_stop.dart';

/// Vessel name and job quantity on RTI job lines and route activities, read from the
/// shared Java API (`RTIDetailsDto` / `RTIRouteActivitiesDto` `vesselName`, `jobQuantity`).
void main() {
  final now = DateTime(2026, 10, 6, 12);

  group('vessel rule', () {
    String vessel(int type, DateTime? loadingEta, DateTime? offEta) => RtiJobInfo.vesselName(
        jobTypeId: type, loadingVessel: 'MTT SENARI', offVessel: 'KOTA NAZAR', loadingEta: loadingEta, offEta: offEta, now: now);

    test('other job types show the loading vessel, else the off vessel', () {
      expect(vessel(3, null, now), 'MTT SENARI');
      expect(RtiJobInfo.vesselName(jobTypeId: 3, loadingVessel: ' ', offVessel: 'KOTA NAZAR', now: now), 'KOTA NAZAR');
    });

    test('job type 11 shows the vessel whose ETA is nearest now', () {
      expect(vessel(11, DateTime(2026, 10, 20), DateTime(2026, 10, 7)), 'KOTA NAZAR');
      expect(vessel(11, DateTime(2026, 10, 5), DateTime(2026, 10, 10)), 'MTT SENARI');
      expect(vessel(11, null, DateTime(2027)), 'KOTA NAZAR');
    });

    test('a saved line shows the stored values; a looked-up line previews them', () {
      final so = {
        'id': 9,
        'jobMasterRefId': 11,
        'loadingvesselname': 'MTT SENARI',
        'offvesselname': 'KOTA NAZAR',
        'eta': '2099-01-01T00:00:00',
        'oeta': DateTime.now().toIso8601String(),
        'quantity': '1x20',
        'totalWeight': '12000',
      };
      final looked = RtiMapper.fromSaleOrder(so);
      expect(looked.vesselName, 'KOTA NAZAR');
      expect(looked.jobQuantity, '1x20 / 12000');

      final saved = RtiMapper.fromDetail({'saleOrderMasterRefId': 9, 'vesselName': 'STORED', 'jobQuantity': '2x40'}, so);
      expect(saved.vesselName, 'STORED');
      expect(saved.jobQuantity, '2x40');
    });

    test('planning rows get their vessel from their sale order', () {
      final rows = RtiMapper.withJobInfo(const [RtiJobRow(jobNo: 'TR1', saleOrderMasterRefId: 9), RtiJobRow(jobNo: 'TR2', saleOrderMasterRefId: 7)], {
        9: {'loadingvesselname': 'MTT SENARI', 'quantity': '1x20'},
      });
      expect(rows.map((r) => r.vesselName), ['MTT SENARI', '']);
      expect(rows.first.jobQuantity, '1x20');
    });
  });

  group('route activity vessel', () {
    const grid = [
      RtiJobRow(jobNo: 'TR1', vesselName: 'MTT SENARI', jobQuantity: '2x40 / 24000', saleOrderMasterRefId: 1),
      RtiJobRow(jobNo: 'TR2', vesselName: 'KOTA NAZAR', jobQuantity: '1x20', saleOrderMasterRefId: 2),
      RtiJobRow(jobNo: 'TR3', vesselName: 'MTT SENARI', jobQuantity: '1x20 / 9000', saleOrderMasterRefId: 3),
    ];

    test('the choices are the job lines vessels, each once', () {
      expect(RtiGridRules.vesselOptions(grid), ['MTT SENARI', 'KOTA NAZAR']);
    });

    test('picking a vessel brings the quantities of its lines; a typed one brings none', () {
      final picked = RtiGridRules.pickVessel(const RtiStop(sequenceNo: 1), 'MTT SENARI', grid);
      expect(picked.vesselName, 'MTT SENARI');
      expect(picked.jobQuantity, '2x40 / 24000, 1x20 / 9000');
      expect(RtiGridRules.pickVessel(picked, 'OTHER', grid).jobQuantity, '');
    });

    test('a new stop starts with the vessel when the RTI has one', () {
      final one = RtiGridRules.addStop(const [], 'PTP', grid: [grid.first]);
      expect(one.single.vesselName, 'MTT SENARI');
      expect(one.single.jobQuantity, '2x40 / 24000');
      expect(RtiGridRules.addStop(const [], 'PTP', grid: grid).single.vesselName, '');
    });

    test('the stop is read from and saved to the route activity', () {
      final stop = RtiMapper.stop({'sequenceNo': 1, 'activityType': 'SEAL', 'vesselName': 'MTT SENARI', 'jobQuantity': '2x40'});
      expect(stop.vesselName, 'MTT SENARI');
      expect(stop.jobQuantity, '2x40');

      final payload = RtiSavePayloadBuilder.build(RtiForm.initial(), grid, [stop, const RtiStop(sequenceNo: 2)], companyId: 6, employeeRefId: 1);
      expect(payload.routeActivities.map((a) => a['vesselName']), ['MTT SENARI', null]);
      expect(payload.routeActivities.map((a) => a['jobQuantity']), ['2x40', null]);
      expect(payload.details.every((d) => !d.containsKey('vesselName') && !d.containsKey('jobQuantity')), isTrue);
    });
  });
}
