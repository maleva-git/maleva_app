import 'package:maleva/features/planning/models/plan_line.dart';
import 'package:maleva/features/planning/models/plan_line_copy.dart';
import 'package:maleva/features/planning/models/rti_batch.dart';

/// The arithmetic behind "Create All RTI", ported from `utils/planningRtiBatch.ts`.
typedef GroupChoices = Map<String, GroupChoice>;

class BatchTally {
  const BatchTally({this.trucks = 0, this.jobs = 0, this.needingDriver = 0, this.skipped = 0, this.leftOut = 0});

  final int trucks;
  final int jobs;
  final int needingDriver;
  final int skipped;
  final int leftOut;

  @override
  bool operator ==(Object other) =>
      other is BatchTally &&
      other.trucks == trucks &&
      other.jobs == jobs &&
      other.needingDriver == needingDriver &&
      other.skipped == skipped &&
      other.leftOut == leftOut;

  @override
  int get hashCode => Object.hash(trucks, jobs, needingDriver, skipped, leftOut);

  @override
  String toString() => 'BatchTally(trucks: $trucks, jobs: $jobs, needingDriver: $needingDriver, skipped: $skipped, leftOut: $leftOut)';
}

abstract final class RtiBatchRules {
  static GroupChoice _fromGroup(RtiBatchGroup g) =>
      GroupChoice(selected: g.driverRefId > 0, driverRefId: g.driverRefId, driverName: g.driverName, outsideDriver: g.outsideDriver);

  /// `initialChoices`: a group starts ticked only when it already has a driver.
  static GroupChoices initialChoices(RtiBatchPreview? preview) =>
      {for (final g in preview?.groups ?? const <RtiBatchGroup>[]) g.groupKey: _fromGroup(g)};

  /// `choiceFor`: the planner's choice, else what the server previewed.
  static GroupChoice choiceFor(RtiBatchGroup g, GroupChoices choices) => choices[g.groupKey] ?? _fromGroup(g);

  /// `isGroupReady`: a truck, a driver and at least one job.
  static bool isGroupReady(RtiBatchGroup g, GroupChoices choices) => g.truckRefId > 0 && choiceFor(g, choices).driverRefId > 0 && g.jobs.isNotEmpty;

  /// `selectedGroups`: ticked and ready.
  static List<RtiBatchGroup> selectedGroups(RtiBatchPreview? preview, GroupChoices choices) =>
      (preview?.groups ?? const <RtiBatchGroup>[]).where((g) => choiceFor(g, choices).selected && isGroupReady(g, choices)).toList();

  /// `buildBatchRequest`: only ids travel; an outside driver's name goes into both outside columns.
  static Map<String, dynamic> buildRequest(RtiBatchPreview? preview, GroupChoices choices,
      {required int companyId, required int employeeRefId, int? userRefId, bool allowDuplicates = false}) {
    final groups = [
      for (final g in selectedGroups(preview, choices))
        () {
          final c = choiceFor(g, choices);
          final outside = c.outsideDriver.trim();
          return {
            'groupKey': g.groupKey,
            'truckRefId': g.truckRefId,
            'driverRefId': c.driverRefId,
            'outsideDriver': outside,
            'outsideTruck': outside,
            'saleOrderMasterRefIds': [for (final j in g.jobs) j.saleOrderMasterRefId],
          };
        }(),
    ];
    return {
      'companyRefId': companyId,
      'employeeRefId': employeeRefId,
      if (userRefId != null) 'userRefId': userRefId,
      'groups': groups,
      'allowDuplicates': allowDuplicates,
    };
  }

  /// `duplicateCount`: jobs in the ticked groups that already sit on an RTI.
  static int duplicateCount(RtiBatchPreview? preview, GroupChoices choices) =>
      selectedGroups(preview, choices).fold(0, (sum, g) => sum + g.jobs.where((j) => j.existingRtiId > 0).length);

  /// `tally`: what will be created and what is left behind.
  static BatchTally tally(RtiBatchPreview? preview, GroupChoices choices) {
    if (preview == null) return const BatchTally();
    final chosen = selectedGroups(preview, choices);
    final jobs = chosen.fold<int>(0, (sum, g) => sum + g.jobs.length);
    return BatchTally(
      trucks: chosen.length,
      jobs: jobs,
      needingDriver: preview.groups.where((g) => !isGroupReady(g, choices)).length,
      skipped: preview.jobsSkipped,
      leftOut: preview.plannedJobs - jobs,
    );
  }

  /// `skipLabel`.
  static String skipLabel(String reason) => switch (reason) {
        'ALREADY_IN_RTI' => 'Already has an RTI',
        'NO_TRUCK' => 'No truck assigned',
        'NO_JOB_REFERENCE' => 'No job reference',
        'DUPLICATE_IN_PLAN' => 'On the plan twice',
        'NOT_CONFIRMED' => 'Truck not ticked',
        _ => 'Not created',
      };

  /// `resultMessage`.
  static String resultMessage(RtiBatchResult? result) {
    if (result == null) return 'Nothing was created.';
    final rtiCount = result.created.length;
    if (rtiCount == 0) return 'No new RTI was created — every job already had one.';
    return '$rtiCount RTI created for ${result.jobsCreated} ${result.jobsCreated == 1 ? 'job' : 'jobs'}';
  }

  /// The info line after a batch (`useCreateAllRti.ts:139-145`), or null.
  static String? leftAloneMessage(RtiBatchResult? result, {required bool includeExisting, required int tallyJobs}) {
    final unexpected = (result?.skipped ?? const <RtiBatchSkip>[]).where((s) => s.reason == 'ALREADY_IN_RTI' && s.existingRtiNo.isNotEmpty).length;
    if (!includeExisting && unexpected > 0 && tallyJobs > (result?.jobsCreated ?? 0)) {
      return '$unexpected job(s) already had an RTI and were left alone.';
    }
    return null;
  }

  /// `applyResultToRows`: the new RTI numbers onto the rows they cover.
  static List<PlanLine> applyResultToRows(List<PlanLine> rows, RtiBatchResult? result, RtiBatchPreview? preview) {
    if (result == null || preview == null) return rows;
    final byJob = <int, RtiBatchCreated>{};
    for (final created in result.created) {
      final group = preview.groups.where((g) => g.truckRefId == created.truckRefId && g.jobs.length == created.jobCount).firstOrNull;
      for (final job in group?.jobs ?? const <RtiBatchJob>[]) {
        byJob[job.saleOrderMasterRefId] = created;
      }
    }
    if (byJob.isEmpty) return rows;
    return [
      for (final row in rows)
        if (byJob[row.saleOrderMasterRefId] case final c?) row.copyWith(rtiNo: c.rtiNo, rtiMasterRefId: c.rtiId) else row,
    ];
  }

  /// `formatDay` of the dialog: `yyyy-MM-dd...` → `dd/MM/yyyy`, else as it is.
  static String day(String value) {
    final t = value.trim();
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(t)) return t;
    return '${t.substring(8, 10)}/${t.substring(5, 7)}/${t.substring(0, 4)}';
  }

  /// `formatTime`: `HH:mm` from a value of 16 characters or more, else ''.
  static String time(String value) {
    final t = value.trim();
    return t.length >= 16 ? t.substring(11, 16) : '';
  }

  /// `jobDays`: the distinct pickup days of a group's jobs.
  static Set<String> jobDays(List<RtiBatchJob> jobs) => {
        for (final j in jobs)
          if (j.pickupDate.trim().length >= 10) j.pickupDate.trim().substring(0, 10)
      };

  /// The driver source badge (`CreateAllRtiModal.tsx:31-36`).
  static String driverSourceLabel(String source) => switch (source) {
        'PLAN' => 'From the plan',
        'LAST_TRIP' => 'Suggested',
        'OUTSIDE' => 'Outside driver',
        'NONE' => 'Pick a driver',
        _ => source,
      };
}
