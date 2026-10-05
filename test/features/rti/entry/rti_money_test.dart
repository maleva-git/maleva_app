import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/rti/data/rti_save_payload.dart';
import 'package:maleva/features/rti/models/rti_form.dart';
import 'package:maleva/features/rti/models/rti_job_row.dart';
import 'package:maleva/features/rti/models/rti_rules.dart';

import 'rti_test_data.dart';

// Every case of R/services/rtiMoney.test.ts: the RTI (driver trip pay) money rules.
double total(RtiForm s, List<RtiJobRow> g) => RtiRules.total(s, g);
RtiSavePayload save(RtiForm s, List<RtiJobRow> g) => RtiSavePayloadBuilder.build(s, g, const [], companyId: 6, employeeRefId: 3);

void main() {
  group('RTI total: job salaries + fixed allowances', () {
    test('is the sum of the job salaries with no allowances', () => expect(total(rtiState(), [rtiJob('120'), rtiJob('80.5')]), 200.5));
    test('sleeping YES adds 50', () => expect(total(rtiState(sleeping: 'YES'), [rtiJob('100')]), 150));
    test('empty exit adds 80 or 50', () {
      expect(total(rtiState(exitYN: 'EMPTY 80'), [rtiJob('100')]), 180);
      expect(total(rtiState(exitYN: 'EMPTY 50'), [rtiJob('100')]), 150);
    });
    test('empty delivery adds 80 or 50', () {
      expect(total(rtiState(emptyDeliveryYN: 'EMPTY 80'), [rtiJob('100')]), 180);
      expect(total(rtiState(emptyDeliveryYN: 'EMPTY 50'), [rtiJob('100')]), 150);
    });
    test('manpower 1 adds 50, manpower 2 adds 100', () {
      expect(total(rtiState(manpw: '1'), [rtiJob('100')]), 150);
      expect(total(rtiState(manpw: '2'), [rtiJob('100')]), 200);
    });
    test('pickup and drop add 30 per count, only when switched on', () {
      expect(total(rtiState(pickup: 'YES', pickupCount: '3'), [rtiJob('100')]), 190);
      expect(total(rtiState(addDrop: 'YES', dropCount: '2'), [rtiJob('100')]), 160);
      expect(total(rtiState(pickupCount: '3', dropCount: '2'), [rtiJob('100')]), 100);
    });
    test('everything at once', () {
      final s = rtiState(sleeping: 'YES', exitYN: 'EMPTY 80', emptyDeliveryYN: 'EMPTY 50', manpw: '2', pickup: 'YES', pickupCount: '2', addDrop: 'YES', dropCount: '1');
      expect(total(s, [rtiJob('200'), rtiJob('100')]), 670);
    });
    test('accepts salaries typed as text and rounds the total to 2 places', () {
      expect(total(rtiState(), [rtiJob('120.555'), rtiJob('0.001')]), 120.56);
    });
  });

  group('RTI save: amounts sent to the backend', () {
    test('sends each allowance separately, as legacy did', () {
      final m = save(rtiState(sleeping: 'YES', exitYN: 'EMPTY 80', emptyDeliveryYN: 'EMPTY 50', manpw: '1', pickup: 'YES', pickupCount: '2', addDrop: 'YES', dropCount: '3'), [rtiJob('100')]).master;
      expect(m, containsPair('amount', 100 + 50 + 80 + 50 + 50 + 60 + 90));
      for (final e in {
        'sleeping': 1, 'sleepingAmount': 50, 'exitYN': 1, 'exitAmount': 80, 'emptyDeliveryYN': 2, 'emptyDeliveryAmount': 50, 'manpw': 1,
        'manpwAmount': 50, 'pickup': 1, 'pickupCount': 2, 'pickupAmount': 60, 'addDrop': 1, 'dropCount': 3, 'dropAmount': 90,
      }.entries) {
        expect(m[e.key], e.value, reason: e.key);
      }
    });

    test('sends 0 for every allowance that is off', () {
      final m = save(rtiState(), [rtiJob('100')]).master;
      expect(m['amount'], 100);
      for (final k in ['sleepingAmount', 'exitAmount', 'emptyDeliveryAmount', 'manpwAmount', 'pickupAmount', 'dropAmount']) {
        expect(m[k], 0, reason: k);
      }
    });

    test('a pickup count typed while pickup is NO is stored, but not paid', () {
      final m = save(rtiState(pickupCount: '4'), [rtiJob('100')]).master;
      expect([m['pickup'], m['pickupCount'], m['pickupAmount'], m['amount']], [0, 4, 0, 100]);
    });

    test('the saved RTI amount always equals saved salaries + saved allowances', () {
      for (final sleeping in ['NO', 'YES']) {
        for (final exitYN in ['NO', 'EMPTY 80', 'EMPTY 50']) {
          for (final emptyDeliveryYN in ['NO', 'EMPTY 80', 'EMPTY 50']) {
            for (final manpw in ['NO', '1', '2']) {
              for (final pickup in ['NO', 'YES']) {
                for (final addDrop in ['NO', 'YES']) {
                  final p = save(
                    rtiState(sleeping: sleeping, exitYN: exitYN, emptyDeliveryYN: emptyDeliveryYN, manpw: manpw, pickup: pickup, pickupCount: '2', addDrop: addDrop, dropCount: '1'),
                    [rtiJob('150.25'), rtiJob('49.75', saleOrderId: 20501, jobNo: 'TR002601395')],
                  );
                  final m = p.master;
                  final parts = p.details.fold<num>(0, (a, d) => a + (d['salary'] as num)) +
                      (m['sleepingAmount'] as num) + (m['exitAmount'] as num) + (m['emptyDeliveryAmount'] as num) +
                      (m['manpwAmount'] as num) + (m['pickupAmount'] as num) + (m['dropAmount'] as num);
                  expect((m['amount'] as num).toDouble(), closeTo(parts.toDouble(), 1e-10));
                }
              }
            }
          }
        }
      }
    });

    test('sends each job row with its salary', () {
      final d = save(rtiState(), [rtiJob('120', id: 7), rtiJob('80', saleOrderId: 20501)]).details;
      expect([for (final x in d) [x['saleOrderMasterRefId'], x['salary'], x['id']]], [
        [20498, 120, 7],
        [20501, 80, null],
      ]);
    });

    test('a row whose job was typed or pasted but never looked up is refused before save', () {
      final grid = [rtiJob('100'), rtiJob('60', saleOrderId: 0, jobNo: 'TR002699999')];
      final p = save(rtiState(), grid);
      expect(RtiRules.validate(rtiState(), grid), contains('Row 2: job TR002699999 was not found. Press Enter in Job No to look it up, or remove the row.'));
      expect(p.master['amount'], isNot(p.details.fold<num>(0, (a, d) => a + (d['salary'] as num))));
    });

    test('keeps the exact master and detail fields the backend expects (rtiMoney.test.ts.snap)', () {
      final p = save(rtiState(), [rtiJob('100')]);
      expect(p.master.keys.toList(), [
        'companyRefId', 'employeeRefId', 'saleDate', 'CNumberDisplay', 'CNumber', 'remarks', 'eLink', 'exLink', 'active', 'sleeping',
        'sleepingAmount', 'amount', 'truckRefId', 'driverRefId', 'pickup', 'pickupCount', 'pickupAmount', 'dropCount', 'dropAmount',
        'addDrop', 'exitYN', 'exitAmount', 'destination', 'sealBy', 'breakSealBy', 'emptyDeliveryYN', 'emptyDeliveryAmount', 'comments',
        'outsideDriver', 'outsideTruck', 'manpw', 'manpwAmount', 'pckHandling', 'punctuality', 'documentSub', 'createdBy', 'modifiedBy',
      ]);
      expect(p.master.length, 37);
      expect(p.details.first.keys.toList(), [
        'saleOrderMasterRefId', 'salary', 'ppic', 'dpic', 'pwdType', 'pickupDateD', 'deliveryDateD', 'originD', 'destinationD',
        'pickupAddressD', 'deliveryAddressD', 'pickupAddressTimelistD', 'pickupAddressQuantityD', 'deliveryAddressQuantityD',
        'deliveryAddressdatelistD',
      ]);
    });

    test('the master values: date at midnight, number, actor, no id on a new RTI', () {
      final m = save(rtiState(), [rtiJob('100')]).master;
      expect(m['saleDate'], '2026-10-02T00:00:00');
      expect(m['CNumberDisplay'], 'RTI000009542');
      expect(m['CNumber'], 9542);
      expect(m['createdBy'], '3');
      expect(m['companyRefId'], 6);
      expect(m['employeeRefId'], 3);
      expect(m.containsKey('id'), isFalse);
      final edit = save(rtiState(editId: 44), [rtiJob('100', id: 9)]);
      expect(edit.master['id'], 44);
      expect(edit.details.first['rtiMasterRefId'], 44);
      expect(RtiSavePayloadBuilder.build(rtiState(), [rtiJob('1')], const [], companyId: 6, employeeRefId: 0).master['createdBy'], 'system');
    });
  });

  group('the save request (rtiApi.save)', () {
    test('a new RTI sends no number and no non-positive ids', () {
      final r = RtiSavePayloadBuilder.request(save(rtiState(), [rtiJob('100')]));
      expect(r.containsKey('CNumber'), isFalse);
      expect(r.containsKey('CNumberDisplay'), isFalse);
      expect((r['rtiDetails'] as List).first.containsKey('rtiMasterRefId'), isFalse);
      expect((r['rtiDetails'] as List).first.containsKey('id'), isFalse);
    });

    test('an edit sends the number in both spellings and the RTI id on lines', () {
      final r = RtiSavePayloadBuilder.request(save(rtiState(editId: 44), [rtiJob('100', id: 9)]));
      expect([r['id'], r['CNumber'], r['cNumber'], r['cNumberDisplay']], [44, 9542, 9542, 'RTI000009542']);
      expect((r['rtiDetails'] as List).first, containsPair('rtiMasterRefId', 44));
      expect((r['rtiDetails'] as List).first, containsPair('id', 9));
    });
  });
}
