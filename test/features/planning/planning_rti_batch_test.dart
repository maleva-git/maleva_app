import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/features/planning/data/planning_rti_batch.dart';
import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/models/rti_batch.dart';

/// Every case of `P/utils/planningRtiBatch.test.ts`.
RtiBatchJob job(int id, [String existingRtiNo = '']) => RtiBatchJob(
      planningDetailId: id,
      saleOrderMasterRefId: id,
      jobNo: 'SO$id',
      customerName: 'KLIA LOGISTICS',
      origin: 'NORTHPORT',
      destination: 'WESTPORT',
      pickupDate: '2026-08-10 08:00',
      deliveryDate: '2026-08-10 17:00',
      sortBy: id,
      existingRtiId: existingRtiNo.isNotEmpty ? 900 + id : 0,
      existingRtiNo: existingRtiNo,
      existingRtiDate: existingRtiNo.isNotEmpty ? '2026-08-07' : '',
    );

RtiBatchGroup grp({
  String groupKey = '64|2026-08-10',
  int truckRefId = 64,
  String truckName = 'JPM 7151',
  int driverRefId = 85,
  String driverName = 'UGUNTHAN TANGAVELU',
  String driverSource = 'PLAN',
  String outsideDriver = '',
  List<RtiBatchJob>? jobs,
  List<String> warnings = const [],
}) =>
    RtiBatchGroup(
      groupKey: groupKey,
      truckRefId: truckRefId,
      truckName: truckName,
      driverRefId: driverRefId,
      driverName: driverName,
      driverSource: driverSource,
      outsideDriver: outsideDriver,
      pickupDate: '2026-08-10',
      jobs: jobs ?? [job(101), job(102)],
      warnings: warnings,
    );

RtiBatchPreview preview({List<RtiBatchGroup>? groups, int plannedJobs = 3, int jobsSkipped = 0, List<RtiBatchSkip> skipped = const []}) =>
    RtiBatchPreview(
      planningId: 752,
      planningNo: 'PL000000752',
      planningDate: '2026-08-10',
      plannedJobs: plannedJobs,
      jobsToCreate: 3,
      jobsSkipped: jobsSkipped,
      groups: groups ??
          [
            grp(),
            grp(
              groupKey: '13|2026-08-10',
              truckRefId: 13,
              truckName: 'JPM 8020',
              driverRefId: 27,
              driverName: 'NADARAJAH GOVINDARAJOO',
              driverSource: 'LAST_TRIP',
              jobs: [job(103)],
              warnings: ["Driver suggested from this truck's last trip on 2026-08-07 — check it before saving."],
            ),
          ],
      skipped: skipped,
    );

void main() {
  group('initialChoices', () {
    test('ticks every group that already has a driver', () {
      final c = RtiBatchRules.initialChoices(preview());
      expect(c['64|2026-08-10']!.selected, isTrue);
      expect(c['13|2026-08-10']!.driverRefId, 27);
    });

    test('leaves a group with no driver unticked so nobody creates it by accident', () {
      final c = RtiBatchRules.initialChoices(preview(groups: [grp(driverRefId: 0, driverName: '', driverSource: 'NONE')]));
      expect(c['64|2026-08-10']!.selected, isFalse);
    });

    test('survives a missing preview', () => expect(RtiBatchRules.initialChoices(null), isEmpty));
  });

  group('isGroupReady', () {
    test('needs a truck, a driver and at least one job', () {
      final c = RtiBatchRules.initialChoices(preview());
      expect(RtiBatchRules.isGroupReady(grp(), c), isTrue);
      expect(RtiBatchRules.isGroupReady(grp(jobs: []), c), isFalse);
      expect(RtiBatchRules.isGroupReady(grp(truckRefId: 0), c), isFalse);
    });

    test('follows the driver the planner picked, not the one suggested', () {
      final without = grp(groupKey: 'g', driverRefId: 0, driverSource: 'NONE');
      final c = RtiBatchRules.initialChoices(preview(groups: [without]));
      expect(RtiBatchRules.isGroupReady(without, c), isFalse);
      c['g'] = const GroupChoice(selected: true, driverRefId: 100, driverName: 'KESAVAN');
      expect(RtiBatchRules.isGroupReady(without, c), isTrue);
    });
  });

  test('choiceFor falls back to the previewed values when nothing was changed', () {
    expect(
        RtiBatchRules.choiceFor(grp(), {}), const GroupChoice(selected: true, driverRefId: 85, driverName: 'UGUNTHAN TANGAVELU', outsideDriver: ''));
  });

  group('buildBatchRequest', () {
    test('sends one group per ticked truck, with only ids', () {
      final view = preview();
      final r = RtiBatchRules.buildRequest(view, RtiBatchRules.initialChoices(view), companyId: 6, employeeRefId: 4);
      expect(r['companyRefId'], 6);
      expect(r['allowDuplicates'], isFalse);
      expect(r['groups'], hasLength(2));
      expect((r['groups'] as List).first, {
        'groupKey': '64|2026-08-10',
        'truckRefId': 64,
        'driverRefId': 85,
        'outsideDriver': '',
        'outsideTruck': '',
        'saleOrderMasterRefIds': [101, 102],
      });
    });

    test('leaves out an unticked truck', () {
      final view = preview();
      final c = RtiBatchRules.initialChoices(view);
      c['13|2026-08-10'] = c['13|2026-08-10']!.copyWith(selected: false);
      final r = RtiBatchRules.buildRequest(view, c, companyId: 6, employeeRefId: 4);
      expect(r['groups'], hasLength(1));
      expect((r['groups'] as List).first['truckRefId'], 64);
    });

    test('never sends a group that still has no driver', () {
      final view = preview(groups: [grp(driverRefId: 0, driverSource: 'NONE')]);
      final c = RtiBatchRules.initialChoices(view);
      c['64|2026-08-10'] = c['64|2026-08-10']!.copyWith(selected: true);
      expect(RtiBatchRules.buildRequest(view, c, companyId: 6, employeeRefId: 4)['groups'], isEmpty);
    });

    test('writes an outside driver name into both outside columns, like the RTI screen', () {
      final view = preview(groups: [grp(driverRefId: 22, driverName: 'RAJU', driverSource: 'OUTSIDE', outsideDriver: 'RAJU')]);
      final g = (RtiBatchRules.buildRequest(view, RtiBatchRules.initialChoices(view), companyId: 6, employeeRefId: 4)['groups'] as List).first;
      expect([g['outsideDriver'], g['outsideTruck']], ['RAJU', 'RAJU']);
    });
  });

  group('duplicate handling', () {
    test('counts the ticked jobs that already have an RTI', () {
      final view = preview(groups: [
        grp(jobs: [job(101), job(102, 'RTI000000412')])
      ]);
      expect(RtiBatchRules.duplicateCount(view, RtiBatchRules.initialChoices(view)), 1);
    });

    test('counts nothing when the groups holding them are unticked', () {
      final view = preview(groups: [
        grp(jobs: [job(101, 'RTI000000412')])
      ]);
      final c = RtiBatchRules.initialChoices(view);
      c['64|2026-08-10'] = c['64|2026-08-10']!.copyWith(selected: false);
      expect(RtiBatchRules.duplicateCount(view, c), 0);
    });

    test('asks for a second RTI only when the planner turned it on', () {
      final view = preview(groups: [
        grp(jobs: [job(101, 'RTI000000412')])
      ]);
      final c = RtiBatchRules.initialChoices(view);
      expect(RtiBatchRules.buildRequest(view, c, companyId: 6, employeeRefId: 4)['allowDuplicates'], isFalse);
      expect(RtiBatchRules.buildRequest(view, c, companyId: 6, employeeRefId: 4, allowDuplicates: true)['allowDuplicates'], isTrue);
    });
  });

  group('tally', () {
    test('counts what will be created and what will be left behind', () {
      final view = preview();
      expect(RtiBatchRules.tally(view, RtiBatchRules.initialChoices(view)),
          const BatchTally(trucks: 2, jobs: 3, needingDriver: 0, skipped: 0, leftOut: 0));
    });

    test('grows leftOut as trucks are unticked, so nothing goes missing quietly', () {
      final view = preview();
      final c = RtiBatchRules.initialChoices(view);
      c['13|2026-08-10'] = c['13|2026-08-10']!.copyWith(selected: false);
      final t = RtiBatchRules.tally(view, c);
      expect([t.trucks, t.jobs, t.leftOut], [1, 2, 1]);
    });

    test('counts jobs already skipped by the server', () {
      final view = preview(plannedJobs: 4, jobsSkipped: 1, skipped: const [
        RtiBatchSkip(
            planningDetailId: 9,
            saleOrderMasterRefId: 104,
            jobNo: 'SO104',
            customerName: 'X',
            truckName: 'JPM 9000',
            reason: 'ALREADY_IN_RTI',
            message: 'Already in RTI 1',
            existingRtiId: 1,
            existingRtiNo: 'RTI000000001'),
      ]);
      final t = RtiBatchRules.tally(view, RtiBatchRules.initialChoices(view));
      expect([t.skipped, t.leftOut], [1, 1]);
    });

    test('returns zeroes with no preview', () => expect(RtiBatchRules.tally(null, {}), const BatchTally()));
  });

  test('selectedGroups is empty when nothing is ticked', () {
    final view = preview();
    final c = {for (final e in RtiBatchRules.initialChoices(view).entries) e.key: e.value.copyWith(selected: false)};
    expect(RtiBatchRules.selectedGroups(view, c), isEmpty);
  });

  test('skipLabel says why in words a planner reads', () {
    expect(RtiBatchRules.skipLabel('ALREADY_IN_RTI'), 'Already has an RTI');
    expect(RtiBatchRules.skipLabel('NO_TRUCK'), 'No truck assigned');
    expect(RtiBatchRules.skipLabel('NO_JOB_REFERENCE'), 'No job reference');
    expect(RtiBatchRules.skipLabel('DUPLICATE_IN_PLAN'), 'On the plan twice');
    expect(RtiBatchRules.skipLabel('NOT_CONFIRMED'), 'Truck not ticked');
    expect(RtiBatchRules.skipLabel('SOMETHING_NEW'), 'Not created');
  });

  group('resultMessage', () {
    test('reports the RTI and job counts', () {
      const r = RtiBatchResult(planningId: 752, planningNo: 'PL000000752', plannedJobs: 3, jobsCreated: 3, created: [
        RtiBatchCreated(rtiId: 1, rtiNo: 'RTI1', truckRefId: 64, truckName: 'JPM 7151', driverRefId: 85, driverName: 'U', jobCount: 2),
        RtiBatchCreated(rtiId: 2, rtiNo: 'RTI2', truckRefId: 13, truckName: 'JPM 8020', driverRefId: 27, driverName: 'N', jobCount: 1),
      ]);
      expect(RtiBatchRules.resultMessage(r), '2 RTI created for 3 jobs');
    });

    test('says plainly when there was nothing new to create', () {
      expect(RtiBatchRules.resultMessage(const RtiBatchResult(planningId: 1, planningNo: 'PL1', plannedJobs: 2, jobsSkipped: 2)),
          'No new RTI was created — every job already had one.');
      expect(RtiBatchRules.resultMessage(null), 'Nothing was created.');
    });

    test('one job is a job', () {
      const r = RtiBatchResult(jobsCreated: 1, created: [RtiBatchCreated(rtiId: 1, rtiNo: 'R', jobCount: 1)]);
      expect(RtiBatchRules.resultMessage(r), '1 RTI created for 1 job');
    });
  });

  test('the left-alone note shows only when existing jobs were skipped and fewer were created', () {
    const r = RtiBatchResult(jobsCreated: 1, skipped: [RtiBatchSkip(reason: 'ALREADY_IN_RTI', existingRtiNo: 'RTI9')]);
    expect(RtiBatchRules.leftAloneMessage(r, includeExisting: false, tallyJobs: 2), '1 job(s) already had an RTI and were left alone.');
    expect(RtiBatchRules.leftAloneMessage(r, includeExisting: true, tallyJobs: 2), isNull);
    expect(RtiBatchRules.leftAloneMessage(r, includeExisting: false, tallyJobs: 1), isNull);
  });

  group('applyResultToRows', () {
    test('stamps the new RTI number onto the rows it covers', () {
      const r = RtiBatchResult(planningId: 752, jobsCreated: 3, created: [
        RtiBatchCreated(rtiId: 55, rtiNo: 'RTI000000055', truckRefId: 64, truckName: 'JPM 7151', driverRefId: 85, driverName: 'U', jobCount: 2),
      ]);
      final rows = [PlanLine(saleOrderMasterRefId: 101), PlanLine(saleOrderMasterRefId: 103)];
      final next = RtiBatchRules.applyResultToRows(rows, r, preview());
      expect([next[0].rtiNo, next[0].rtiMasterRefId], ['RTI000000055', 55]);
      expect([next[1].rtiNo, next[1].rtiMasterRefId], ['', 0]);
    });

    test('returns the rows untouched when there is no result', () {
      final rows = [PlanLine(saleOrderMasterRefId: 101)];
      expect(identical(RtiBatchRules.applyResultToRows(rows, null, preview()), rows), isTrue);
    });
  });

  test('the dialog dates: dd/MM/yyyy and HH:mm', () {
    expect(RtiBatchRules.day('2026-08-10 08:00'), '10/08/2026');
    expect(RtiBatchRules.time('2026-08-10 08:00'), '08:00');
    expect(RtiBatchRules.time('2026-08-10'), '');
    expect(RtiBatchRules.jobDays([job(1), job(2)]), {'2026-08-10'});
  });

  test('reads the Java preview', () {
    final p = RtiBatchPreview.fromJava({
      'planningId': 752,
      'planningNo': 'PL000000752',
      'plannedJobs': 3,
      'groups': [
        {
          'groupKey': 'g',
          'truckRefId': 64,
          'driverRefId': 0,
          'driverSource': 'NONE',
          'jobs': [
            {'saleOrderMasterRefId': 101, 'jobNo': 'SO101', 'existingRtiId': 3, 'existingRtiNo': 'RTI3'}
          ],
          'warnings': ['w'],
        }
      ],
      'skipped': [
        {'jobNo': 'SO9', 'reason': 'NO_TRUCK'}
      ],
    });
    expect(p.groups.single.jobs.single.existingRtiNo, 'RTI3');
    expect(p.skipped.single.reason, 'NO_TRUCK');
    expect(RtiBatchRules.initialChoices(p)['g']!.selected, isFalse);
  });
}
