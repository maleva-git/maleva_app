import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/vessel_master/vessel_master_models.dart';

/// `GET /api/vessel-changes`: jobs whose dates differ from PTP's schedule, one group per vessel call
/// (backend change vessel-master-and-ptp-schedule). Read as Java answers it.
class VesselChanges {
  const VesselChanges({this.lastGoodReadAt, this.groups = const [], this.lastReadAtByPort = const {}});

  factory VesselChanges.fromJava(Map<String, dynamic> m) => VesselChanges(
        lastGoodReadAt: JsonRead.stringOrNull(m['lastGoodReadAt']),
        groups: JsonRead.listOfMaps(m['groups']).map(VesselChangeGroup.fromJava).toList(),
        lastReadAtByPort: {
          for (final e in JsonRead.map(m['lastReadAtByPort']).entries) e.key: JsonRead.stringOrNull(e.value),
        },
      );

  /// When PTP was last read successfully; null if never.
  final String? lastGoodReadAt;
  final List<VesselChangeGroup> groups;

  /// The last good read per source (`PTP`, `WESTPORTS`: the last good upload, `MMSW`); empty in older answers.
  final Map<String, String?> lastReadAtByPort;

  /// When [port]'s schedule was last read well; PTP falls back to [lastGoodReadAt].
  String? lastReadAt(String port) =>
      lastReadAtByPort[port] ?? (port == VesselSource.ptp ? lastGoodReadAt : null);

  bool get isEmpty => groups.every((g) => g.jobs.isEmpty);
}

/// One vessel call and the jobs on it that differ from PTP.
class VesselChangeGroup {
  const VesselChangeGroup({required this.call, this.lastChangedAt, this.changes = const [], this.jobs = const []});

  factory VesselChangeGroup.fromJava(Map<String, dynamic> m) => VesselChangeGroup(
        call: PtpCall.fromJava(JsonRead.map(m['call'])),
        lastChangedAt: JsonRead.stringOrNull(m['lastChangedAt']),
        changes: JsonRead.listOfMaps(m['changes']).map(PtpChange.fromJava).toList(),
        jobs: JsonRead.listOfMaps(m['jobs']).map(VesselChangeJob.fromJava).toList(),
      );

  final PtpCall call;
  final String? lastChangedAt;
  final List<PtpChange> changes;
  final List<VesselChangeJob> jobs;

  VesselChangeGroup withJobs(List<VesselChangeJob> jobs) =>
      VesselChangeGroup(call: call, lastChangedAt: lastChangedAt, changes: changes, jobs: jobs);
}

/// What the schedule changed on the call (`field` e.g. `ARRIVE`, `DEPART`, `SCN`, `STATUS`).
class PtpChange {
  /// Westports' status changed (e.g. `Not Arrived` -> `Omitted`).
  static const String statusField = 'STATUS';

  const PtpChange({required this.field, this.oldValue, this.newValue, this.seenAt});

  factory PtpChange.fromJava(Map<String, dynamic> m) => PtpChange(
        field: JsonRead.string(m['field']),
        oldValue: JsonRead.stringOrNull(m['oldValue']),
        newValue: JsonRead.stringOrNull(m['newValue']),
        seenAt: JsonRead.stringOrNull(m['seenAt']),
      );

  final String field;
  final String? oldValue;
  final String? newValue;
  final String? seenAt;

  bool get isStatus => field == statusField;
}

/// One job's leg on a vessel call: Maleva's times against PTP's.
/// Times are the Java strings (`yyyy-MM-dd'T'HH:mm`) so PTP's can be sent back unchanged.
class VesselChangeJob {
  const VesselChangeJob({
    required this.saleOrderId,
    required this.jobNo,
    this.customerName,
    this.employeeId,
    this.employeeName,
    required this.leg,
    this.vesselName,
    this.currentEta,
    this.currentEtd,
    this.currentScn,
    this.ptpEta,
    this.ptpEtd,
    this.ptpScn,
    this.etaDiffers = false,
    this.etdDiffers = false,
    this.scnDiffers = false,
    this.boardingMonthFrom,
    this.boardingMonthTo,
    this.port,
    this.terminal,
  });

  factory VesselChangeJob.fromJava(Map<String, dynamic> m) => VesselChangeJob(
        saleOrderId: JsonRead.integer(m['saleOrderId']),
        jobNo: JsonRead.string(m['jobNo']),
        customerName: JsonRead.stringOrNull(m['customerName']),
        employeeId: JsonRead.intOrNull(m['employeeId']),
        employeeName: JsonRead.stringOrNull(m['employeeName']),
        leg: JsonRead.string(m['leg']),
        vesselName: JsonRead.stringOrNull(m['vesselName']),
        currentEta: JsonRead.stringOrNull(m['currentEta']),
        currentEtd: JsonRead.stringOrNull(m['currentEtd']),
        currentScn: JsonRead.stringOrNull(m['currentScn']),
        ptpEta: JsonRead.stringOrNull(m['ptpEta']),
        ptpEtd: JsonRead.stringOrNull(m['ptpEtd']),
        ptpScn: JsonRead.stringOrNull(m['ptpScn']),
        etaDiffers: JsonRead.boolean(m['etaDiffers']),
        etdDiffers: JsonRead.boolean(m['etdDiffers']),
        scnDiffers: JsonRead.boolean(m['scnDiffers']),
        boardingMonthFrom: JsonRead.stringOrNull(m['boardingMonthFrom']),
        boardingMonthTo: JsonRead.stringOrNull(m['boardingMonthTo']),
        port: JsonRead.stringOrNull(m['port']),
        terminal: JsonRead.stringOrNull(m['terminal']),
      );

  final int saleOrderId;
  final String jobNo;
  final String? customerName;
  final int? employeeId;
  final String? employeeName;

  /// `LOADING` or `OFF`.
  final String leg;
  final String? vesselName;
  final String? currentEta;
  final String? currentEtd;
  final String? currentScn;
  final String? ptpEta;
  final String? ptpEtd;
  final String? ptpScn;
  final bool etaDiffers;
  final bool etdDiffers;
  final bool scnDiffers;
  /// `2026-10` / `2026-11` when the boarding pay would move to another month.
  final String? boardingMonthFrom;
  final String? boardingMonthTo;

  /// The leg's port as typed on the job ("WESTPORT-B18"); null in older answers.
  final String? port;

  /// The Westports terminal from [port] ("B18", "LBT B7X") or the MMSW call's terminal ("Northport KCT");
  /// null for PTP or a bare WESTPORT.
  final String? terminal;

  bool get isLoading => leg == VesselLeg.loading;

  /// The boarding pay would move to another month: the row waits for the user's confirmation.
  bool get boardingMonthChanges => boardingMonthFrom != null || boardingMonthTo != null;
}

/// One line of the bulk update answer (`VesselPlanningSaleOrderBulkUpdateResponse.JobResult`).
class BulkJobResult {
  const BulkJobResult({required this.saleOrderId, this.jobNo, required this.ok, this.message});

  factory BulkJobResult.fromJava(Map<String, dynamic> m) => BulkJobResult(
        saleOrderId: JsonRead.integer(m['saleOrderId']),
        jobNo: JsonRead.stringOrNull(m['jobNo']),
        ok: JsonRead.boolean(m['ok']),
        message: JsonRead.stringOrNull(m['message']),
      );

  final int saleOrderId;
  final String? jobNo;
  final bool ok;
  final String? message;
}

/// `POST /api/ptp/vessel-schedules/read` ("Read PTP now", any employee).
class PtpReadResult {
  const PtpReadResult({required this.ok, this.rows = 0, this.changes = 0, this.message, this.startedAt, this.recent = false});

  factory PtpReadResult.fromJava(Map<String, dynamic> m) => PtpReadResult(
        ok: JsonRead.boolean(m['ok']),
        rows: JsonRead.integer(m['rows']),
        changes: JsonRead.integer(m['changes']),
        message: JsonRead.stringOrNull(m['message']),
        startedAt: JsonRead.stringOrNull(m['startedAt']),
        recent: JsonRead.boolean(m['recent']),
      );

  final bool ok;
  final int rows;
  final int changes;
  final String? message;

  /// `yyyy-MM-ddTHH:mm` of the read shown.
  final String? startedAt;

  /// PTP was read a few minutes ago, so that read is shown instead of asking PTP again.
  final bool recent;
}

/// `POST /api/vessel-plannings/sale-order-update-many` answer (not wrapped in ApiResponse).
class BulkUpdateResult {
  const BulkUpdateResult({this.requested = 0, this.updated = 0, this.skipped = 0, this.results = const []});

  factory BulkUpdateResult.fromJava(Map<String, dynamic> m) => BulkUpdateResult(
        requested: JsonRead.integer(m['requested']),
        updated: JsonRead.integer(m['updated']),
        skipped: JsonRead.integer(m['skipped']),
        results: JsonRead.listOfMaps(m['results']).map(BulkJobResult.fromJava).toList(),
      );

  final int requested;
  final int updated;
  final int skipped;
  final List<BulkJobResult> results;
}

/// The kind of a vessel alert (`kind` of `GET /api/vessel-changes/alerts`).
class VesselAlertKind {
  VesselAlertKind._();

  /// A job's times differ from PTP's (the alert of before; also when `kind` is missing).
  static const String eta = 'ETA';

  /// A job at PTP is not linked to its PTP voyage ("Pick the PTP voyage: job ...").
  static const String link = 'LINK';

  /// The linked call is Omitted at Westports: handled on Vessel changes like [eta] (another vessel or
  /// voyage on the job, or dismiss); never closed with "Not this vessel".
  static const String omitted = 'OMITTED';
}

/// `GET /api/vessel-changes/alerts`: one vessel alert still to handle (`VesselAlertDto`). An ETA alert
/// stays open until the job's ETA matches PTP's or the row is dismissed on Vessel changes; a LINK alert
/// until the job is linked to its PTP voyage or closed ("Not this vessel"). The server checks the jobs on
/// every call, so a handled alert is gone on the next fetch.
class VesselAlert {
  const VesselAlert({
    required this.id,
    this.ptpVesselCallId,
    required this.vesselName,
    this.voyage,
    this.arriveAt,
    this.arriveEstimated = false,
    this.departAt,
    this.departEstimated = false,
    this.jobs = 0,
    this.employeeId = 0,
    this.employeeName,
    this.mine = true,
    this.sentAt,
    this.reminders = 0,
    this.escalated = false,
    this.kind = VesselAlertKind.eta,
    this.saleOrderId,
    this.jobNo,
    this.unassigned = false,
    this.port,
    this.portLabel,
    this.terminal,
  });

  factory VesselAlert.fromJava(Map<String, dynamic> m) => VesselAlert(
        id: JsonRead.integer(m['id']),
        ptpVesselCallId: JsonRead.intOrNull(m['ptpVesselCallId']),
        vesselName: JsonRead.string(m['vesselName']),
        voyage: JsonRead.stringOrNull(m['voyage']),
        arriveAt: JsonRead.stringOrNull(m['arriveAt']),
        arriveEstimated: JsonRead.boolean(m['arriveEstimated']),
        departAt: JsonRead.stringOrNull(m['departAt']),
        departEstimated: JsonRead.boolean(m['departEstimated']),
        jobs: JsonRead.integer(m['jobs']),
        employeeId: JsonRead.integer(m['employeeId']),
        employeeName: JsonRead.stringOrNull(m['employeeName']),
        mine: JsonRead.boolean(m['mine']),
        sentAt: JsonRead.stringOrNull(m['sentAt']),
        reminders: JsonRead.integer(m['reminders']),
        escalated: JsonRead.boolean(m['escalated']),
        kind: JsonRead.stringOrNull(m['kind']) ?? VesselAlertKind.eta,
        saleOrderId: JsonRead.intOrNull(m['saleOrderId']),
        jobNo: JsonRead.stringOrNull(m['jobNo']),
        unassigned: JsonRead.boolean(m['unassigned']),
        port: JsonRead.stringOrNull(m['port']),
        portLabel: JsonRead.stringOrNull(m['portLabel']),
        terminal: JsonRead.stringOrNull(m['terminal']),
      );

  final int id;

  /// ETA: the PTP call. LINK: the voyage PTP lists for the job's vessel (may be null).
  final int? ptpVesselCallId;

  /// ETA: PTP's vessel. LINK: the name typed on the job.
  final String vesselName;

  /// LINK: the suggested PTP voyage (may be null).
  final String? voyage;

  /// PTP's times (`yyyy-MM-dd'T'HH:mm`); for LINK the suggested voyage's (may be null).
  final String? arriveAt;
  final bool arriveEstimated;
  final String? departAt;
  final bool departEstimated;

  /// Jobs on the call whose ETA does not match PTP yet.
  final int jobs;
  final int employeeId;

  /// "No employee" when [unassigned].
  final String? employeeName;

  /// True: the caller's own jobs. False: a team member's alert escalated to the caller (their leader).
  final bool mine;

  /// When the first notice went out (`yyyy-MM-dd'T'HH:mm`).
  final String? sentAt;

  /// Reminders sent so far (every 30 min in working hours).
  final int reminders;

  /// Not handled in time: the team leader was told.
  final bool escalated;

  /// One of [VesselAlertKind] (`ETA` when the server did not send one).
  final String kind;

  /// LINK, or ETA jobs with no employee: the job to open.
  final int? saleOrderId;
  final String? jobNo;

  /// The jobs have no employee: the alert went to a Super Admin.
  final bool unassigned;

  /// The call's source (`PTP` / `WESTPORTS` / `MMSW`) and its label; null when the call is unknown or in older answers.
  final String? port;
  final String? portLabel;

  /// The jobs' Westports terminals ("B18, LBT B7X") or the MMSW terminal ("Northport KCT"); null for none.
  final String? terminal;

  bool get isMmsw => port?.toUpperCase() == VesselSource.mmsw;

  bool get isLink => kind == VesselAlertKind.link;

  bool get isOmitted => kind == VesselAlertKind.omitted;

  /// Only a LINK alert can be closed with "Not this vessel".
  bool get canClose => isLink;

  /// "PTP" or "Westports" (an OMITTED alert is always Westports').
  String get sourceLabel => VesselSource.labelOf(isOmitted && port == null && portLabel == null ? VesselSource.westports : port,
      label: portLabel);

  /// "MMSW · Northport KCT" for an MMSW alert with a terminal; [sourceLabel] otherwise.
  String get sourceText => isMmsw ? VesselSource.withTerminal(sourceLabel, terminal) : sourceLabel;

  String get vesselText => voyage == null ? vesselName : '$vesselName $voyage';
}
