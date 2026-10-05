import 'package:maleva/features/planning/data/js_values.dart';

/// "Create All RTI": the server's preview and result (`P/api/planningRtiBatchApi.ts`), read
/// with the Java field names.
class RtiBatchJob {
  const RtiBatchJob({
    this.planningDetailId = 0,
    required this.saleOrderMasterRefId,
    this.jobNo = '',
    this.customerName = '',
    this.origin = '',
    this.destination = '',
    this.pickupDate = '',
    this.deliveryDate = '',
    this.sortBy = 0,
    this.remarks = '',
    this.existingRtiId = 0,
    this.existingRtiNo = '',
    this.existingRtiDate = '',
  });

  factory RtiBatchJob.fromJava(Map<String, dynamic> m) => RtiBatchJob(
        planningDetailId: Js.intOr0(m['planningDetailId']),
        saleOrderMasterRefId: Js.intOr0(m['saleOrderMasterRefId']),
        jobNo: Js.text(m['jobNo']),
        customerName: Js.text(m['customerName']),
        origin: Js.text(m['origin']),
        destination: Js.text(m['destination']),
        pickupDate: Js.text(m['pickupDate']),
        deliveryDate: Js.text(m['deliveryDate']),
        sortBy: Js.intOr0(m['sortBy']),
        remarks: Js.text(m['remarks']),
        existingRtiId: Js.intOr0(m['existingRtiId']),
        existingRtiNo: Js.text(m['existingRtiNo']),
        existingRtiDate: Js.text(m['existingRtiDate']),
      );

  final int planningDetailId;
  final int saleOrderMasterRefId;
  final String jobNo;
  final String customerName;
  final String origin;
  final String destination;
  final String pickupDate;
  final String deliveryDate;
  final int sortBy;
  final String remarks;
  final int existingRtiId;
  final String existingRtiNo;
  final String existingRtiDate;
}

/// Where a group's driver came from: PLAN, LAST_TRIP, OUTSIDE or NONE.
class RtiBatchGroup {
  const RtiBatchGroup({
    required this.groupKey,
    this.truckRefId = 0,
    this.truckName = '',
    this.driverRefId = 0,
    this.driverName = '',
    this.driverSource = 'NONE',
    this.outsideDriver = '',
    this.pickupDate = '',
    this.tripLabel = '',
    this.jobs = const [],
    this.warnings = const [],
  });

  factory RtiBatchGroup.fromJava(Map<String, dynamic> m) => RtiBatchGroup(
        groupKey: Js.text(m['groupKey']),
        truckRefId: Js.intOr0(m['truckRefId']),
        truckName: Js.text(m['truckName']),
        driverRefId: Js.intOr0(m['driverRefId']),
        driverName: Js.text(m['driverName']),
        driverSource: Js.text(m['driverSource']),
        outsideDriver: Js.text(m['outsideDriver']),
        pickupDate: Js.text(m['pickupDate']),
        tripLabel: Js.text(m['tripLabel']),
        jobs: [
          for (final j in (m['jobs'] is List ? m['jobs'] as List : const []))
            if (j is Map) RtiBatchJob.fromJava(Map<String, dynamic>.from(j))
        ],
        warnings: [for (final w in (m['warnings'] is List ? m['warnings'] as List : const [])) Js.text(w)],
      );

  final String groupKey;
  final int truckRefId;
  final String truckName;
  final int driverRefId;
  final String driverName;
  final String driverSource;
  final String outsideDriver;
  final String pickupDate;
  final String tripLabel;
  final List<RtiBatchJob> jobs;
  final List<String> warnings;
}

class RtiBatchSkip {
  const RtiBatchSkip({
    this.planningDetailId = 0,
    this.saleOrderMasterRefId = 0,
    this.jobNo = '',
    this.customerName = '',
    this.truckName = '',
    this.reason = '',
    this.message = '',
    this.existingRtiId = 0,
    this.existingRtiNo = '',
  });

  factory RtiBatchSkip.fromJava(Map<String, dynamic> m) => RtiBatchSkip(
        planningDetailId: Js.intOr0(m['planningDetailId']),
        saleOrderMasterRefId: Js.intOr0(m['saleOrderMasterRefId']),
        jobNo: Js.text(m['jobNo']),
        customerName: Js.text(m['customerName']),
        truckName: Js.text(m['truckName']),
        reason: Js.text(m['reason']),
        message: Js.text(m['message']),
        existingRtiId: Js.intOr0(m['existingRtiId']),
        existingRtiNo: Js.text(m['existingRtiNo']),
      );

  final int planningDetailId;
  final int saleOrderMasterRefId;
  final String jobNo;
  final String customerName;
  final String truckName;
  final String reason;
  final String message;
  final int existingRtiId;
  final String existingRtiNo;
}

List<T> _list<T>(dynamic v, T Function(Map<String, dynamic>) read) => [
      for (final e in (v is List ? v : const []))
        if (e is Map) read(Map<String, dynamic>.from(e))
    ];

class RtiBatchPreview {
  const RtiBatchPreview({
    this.planningId = 0,
    this.planningNo = '',
    this.planningDate = '',
    this.plannedJobs = 0,
    this.jobsToCreate = 0,
    this.jobsSkipped = 0,
    this.groups = const [],
    this.skipped = const [],
    this.warnings = const [],
  });

  factory RtiBatchPreview.fromJava(Map<String, dynamic> m) => RtiBatchPreview(
        planningId: Js.intOr0(m['planningId']),
        planningNo: Js.text(m['planningNo']),
        planningDate: Js.text(m['planningDate']),
        plannedJobs: Js.intOr0(m['plannedJobs']),
        jobsToCreate: Js.intOr0(m['jobsToCreate']),
        jobsSkipped: Js.intOr0(m['jobsSkipped']),
        groups: _list(m['groups'], RtiBatchGroup.fromJava),
        skipped: _list(m['skipped'], RtiBatchSkip.fromJava),
        warnings: [for (final w in (m['warnings'] is List ? m['warnings'] as List : const [])) Js.text(w)],
      );

  final int planningId;
  final String planningNo;
  final String planningDate;
  final int plannedJobs;
  final int jobsToCreate;
  final int jobsSkipped;
  final List<RtiBatchGroup> groups;
  final List<RtiBatchSkip> skipped;
  final List<String> warnings;
}

class RtiBatchCreated {
  const RtiBatchCreated(
      {required this.rtiId,
      this.rtiNo = '',
      this.truckRefId = 0,
      this.truckName = '',
      this.driverRefId = 0,
      this.driverName = '',
      this.jobCount = 0});

  factory RtiBatchCreated.fromJava(Map<String, dynamic> m) => RtiBatchCreated(
        rtiId: Js.intOr0(m['rtiId']),
        rtiNo: Js.text(m['rtiNo']),
        truckRefId: Js.intOr0(m['truckRefId']),
        truckName: Js.text(m['truckName']),
        driverRefId: Js.intOr0(m['driverRefId']),
        driverName: Js.text(m['driverName']),
        jobCount: Js.intOr0(m['jobCount']),
      );

  final int rtiId;
  final String rtiNo;
  final int truckRefId;
  final String truckName;
  final int driverRefId;
  final String driverName;
  final int jobCount;
}

class RtiBatchResult {
  const RtiBatchResult(
      {this.planningId = 0,
      this.planningNo = '',
      this.plannedJobs = 0,
      this.jobsCreated = 0,
      this.jobsSkipped = 0,
      this.created = const [],
      this.skipped = const []});

  factory RtiBatchResult.fromJava(Map<String, dynamic> m) => RtiBatchResult(
        planningId: Js.intOr0(m['planningId']),
        planningNo: Js.text(m['planningNo']),
        plannedJobs: Js.intOr0(m['plannedJobs']),
        jobsCreated: Js.intOr0(m['jobsCreated']),
        jobsSkipped: Js.intOr0(m['jobsSkipped']),
        created: _list(m['created'], RtiBatchCreated.fromJava),
        skipped: _list(m['skipped'], RtiBatchSkip.fromJava),
      );

  final int planningId;
  final String planningNo;
  final int plannedJobs;
  final int jobsCreated;
  final int jobsSkipped;
  final List<RtiBatchCreated> created;
  final List<RtiBatchSkip> skipped;
}

/// A planner's changes to one previewed group (`planningRtiBatch.ts` `GroupChoice`).
class GroupChoice {
  const GroupChoice({required this.selected, required this.driverRefId, this.driverName = '', this.outsideDriver = ''});

  final bool selected;
  final int driverRefId;
  final String driverName;
  final String outsideDriver;

  GroupChoice copyWith({bool? selected, int? driverRefId, String? driverName, String? outsideDriver}) => GroupChoice(
        selected: selected ?? this.selected,
        driverRefId: driverRefId ?? this.driverRefId,
        driverName: driverName ?? this.driverName,
        outsideDriver: outsideDriver ?? this.outsideDriver,
      );

  @override
  bool operator ==(Object other) =>
      other is GroupChoice &&
      other.selected == selected &&
      other.driverRefId == driverRefId &&
      other.driverName == driverName &&
      other.outsideDriver == outsideDriver;

  @override
  int get hashCode => Object.hash(selected, driverRefId, driverName, outsideDriver);
}
