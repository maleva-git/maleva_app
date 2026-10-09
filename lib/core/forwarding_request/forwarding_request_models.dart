import 'package:maleva/core/utils/json_read.dart';

/// The customs form types a request can ask for.
const List<String> forwardingFormTypes = ['K1', 'K2', 'K3', 'K8'];

/// The ladder, as the Java API derives it; CANCELLED sits outside it.
const List<String> forwardingStatusSteps = [
  'REQUESTED',
  'DOCUMENTS_RECEIVED',
  'DRAFT_CREATED',
  'SUBMITTED',
  'APPROVED',
  'RELEASED',
];

String forwardingStatusLabel(String status) => switch (status) {
      'REQUESTED' => 'Requested',
      'DOCUMENTS_RECEIVED' => 'Documents received',
      'DRAFT_CREATED' => 'Draft created',
      'SUBMITTED' => 'Submitted',
      'APPROVED' => 'Approved',
      'RELEASED' => 'Released',
      'CANCELLED' => 'Cancelled',
      _ => status,
    };

int forwardingStepIndex(String status) => forwardingStatusSteps.indexOf(status);

/// `yyyy-MM-dd HH:mm:ss` (or ISO) from Java → local DateTime; null when blank or unreadable.
DateTime? _dateTime(dynamic v) {
  final s = JsonRead.stringOrNull(v);
  if (s == null || s.trim().isEmpty) return null;
  return DateTime.tryParse(s.trim().replaceFirst(' ', 'T'));
}

String _two(int n) => n.toString().padLeft(2, '0');

/// `yyyy-MM-dd HH:mm:ss`, the shape the Java API takes for date-times.
String toJavaDateTime(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)} ${_two(d.hour)}:${_two(d.minute)}:00';

/// `yyyy-MM-dd`.
String toJavaDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

/// One forwarding request as `/api/forwarding-requests` answers it (ForwardingRequestDto), read as sent.
class ForwardingRequest {
  const ForwardingRequest({
    required this.id,
    required this.saleOrderId,
    required this.jobNo,
    required this.customerName,
    required this.jobType,
    required this.vesselName,
    required this.formType,
    required this.estimatedDate,
    required this.remarks,
    required this.requestedById,
    required this.requestedBy,
    required this.requestedDate,
    required this.documentReceived,
    required this.documentReceivedBy,
    required this.documentReceivedDate,
    required this.draftCreated,
    required this.draftCreatedBy,
    required this.draftCreatedDate,
    required this.draftCNumber,
    required this.submitted,
    required this.submittedBy,
    required this.submittedDate,
    required this.submittedRef,
    required this.approved,
    required this.approvedBy,
    required this.approvedDate,
    required this.released,
    required this.releasedBy,
    required this.releasedDate,
    required this.releaseNo,
    required this.sealById,
    required this.sealBy,
    required this.breakSealById,
    required this.breakSealBy,
    required this.cancelledBy,
    required this.cancelledDate,
    required this.status,
  });

  factory ForwardingRequest.fromJava(Map<String, dynamic> m) => ForwardingRequest(
        id: JsonRead.integer(m['id']),
        saleOrderId: JsonRead.integer(m['saleOrderId']),
        jobNo: JsonRead.string(m['jobNo']),
        customerName: JsonRead.string(m['customerName']),
        jobType: JsonRead.string(m['jobType']),
        vesselName: JsonRead.string(m['vesselName']),
        formType: JsonRead.string(m['formType']),
        estimatedDate: _dateTime(m['estimatedDate']),
        remarks: JsonRead.string(m['remarks']),
        requestedById: JsonRead.intOrNull(m['requestedById']),
        requestedBy: JsonRead.string(m['requestedBy']),
        requestedDate: _dateTime(m['requestedDate']),
        documentReceived: JsonRead.boolean(m['documentReceived']),
        documentReceivedBy: JsonRead.string(m['documentReceivedBy']),
        documentReceivedDate: _dateTime(m['documentReceivedDate']),
        draftCreated: JsonRead.boolean(m['draftCreated']),
        draftCreatedBy: JsonRead.string(m['draftCreatedBy']),
        draftCreatedDate: _dateTime(m['draftCreatedDate']),
        draftCNumber: JsonRead.string(m['draftCNumber']),
        submitted: JsonRead.boolean(m['submitted']),
        submittedBy: JsonRead.string(m['submittedBy']),
        submittedDate: _dateTime(m['submittedDate']),
        submittedRef: JsonRead.string(m['submittedRef']),
        approved: JsonRead.boolean(m['approved']),
        approvedBy: JsonRead.string(m['approvedBy']),
        approvedDate: _dateTime(m['approvedDate']),
        released: JsonRead.boolean(m['released']),
        releasedBy: JsonRead.string(m['releasedBy']),
        releasedDate: _dateTime(m['releasedDate']),
        releaseNo: JsonRead.string(m['releaseNo']),
        sealById: JsonRead.intOrNull(m['sealById']),
        sealBy: JsonRead.string(m['sealBy']),
        breakSealById: JsonRead.intOrNull(m['breakSealById']),
        breakSealBy: JsonRead.string(m['breakSealBy']),
        cancelledBy: JsonRead.string(m['cancelledBy']),
        cancelledDate: _dateTime(m['cancelledDate']),
        status: JsonRead.string(m['status']),
      );

  final int id;
  final int saleOrderId;
  final String jobNo;
  final String customerName;
  final String jobType;
  final String vesselName;
  final String formType;
  final DateTime? estimatedDate;
  final String remarks;
  final int? requestedById;
  final String requestedBy;
  final DateTime? requestedDate;
  final bool documentReceived;
  final String documentReceivedBy;
  final DateTime? documentReceivedDate;
  final bool draftCreated;
  final String draftCreatedBy;
  final DateTime? draftCreatedDate;
  final String draftCNumber;
  final bool submitted;
  final String submittedBy;
  final DateTime? submittedDate;
  final String submittedRef;
  final bool approved;
  final String approvedBy;
  final DateTime? approvedDate;
  final bool released;
  final String releasedBy;
  final DateTime? releasedDate;
  final String releaseNo;
  final int? sealById;
  final String sealBy;
  final int? breakSealById;
  final String breakSealBy;
  final String cancelledBy;
  final DateTime? cancelledDate;
  final String status;

  bool get cancelled => status == 'CANCELLED';

  /// Coral in the lists: the estimate has passed and the draft is still not made.
  bool isOverdue([DateTime? now]) {
    if (cancelled || draftCreated || estimatedDate == null) return false;
    return estimatedDate!.isBefore(now ?? DateTime.now());
  }
}

/// The ladder steps a Save can tick, lowest first.
enum ForwardingStep { documentReceived, draftCreated, submitted, approved, released }

/// One row's Save on the planning page: the five ticks, their references and the seal people,
/// sent together to `PUT /api/forwarding-requests/{id}/ticks`.
class ForwardingRequestTicks {
  const ForwardingRequestTicks({
    this.documentReceived = false,
    this.draftCreated = false,
    this.cNumber = '',
    this.submitted = false,
    this.submittedRef = '',
    this.approved = false,
    this.approvedDate = '',
    this.released = false,
    this.releaseNo = '',
    this.sealById = 0,
    this.breakSealById = 0,
  });

  factory ForwardingRequestTicks.fromRequest(ForwardingRequest r) => ForwardingRequestTicks(
        documentReceived: r.documentReceived,
        draftCreated: r.draftCreated,
        cNumber: r.draftCNumber,
        submitted: r.submitted,
        submittedRef: r.submittedRef,
        approved: r.approved,
        approvedDate: r.approvedDate == null ? '' : toJavaDate(r.approvedDate!),
        released: r.released,
        releaseNo: r.releaseNo,
        sealById: r.sealById ?? 0,
        breakSealById: r.breakSealById ?? 0,
      );

  final bool documentReceived;
  final bool draftCreated;
  final String cNumber;
  final bool submitted;
  final String submittedRef;
  final bool approved;
  /// `yyyy-MM-dd`; blank means today on the server.
  final String approvedDate;
  final bool released;
  final String releaseNo;
  /// Employee ids; 0 means none chosen.
  final int sealById;
  final int breakSealById;

  ForwardingRequestTicks copyWith({
    bool? documentReceived,
    bool? draftCreated,
    String? cNumber,
    bool? submitted,
    String? submittedRef,
    bool? approved,
    String? approvedDate,
    bool? released,
    String? releaseNo,
    int? sealById,
    int? breakSealById,
  }) =>
      ForwardingRequestTicks(
        documentReceived: documentReceived ?? this.documentReceived,
        draftCreated: draftCreated ?? this.draftCreated,
        cNumber: cNumber ?? this.cNumber,
        submitted: submitted ?? this.submitted,
        submittedRef: submittedRef ?? this.submittedRef,
        approved: approved ?? this.approved,
        approvedDate: approvedDate ?? this.approvedDate,
        released: released ?? this.released,
        releaseNo: releaseNo ?? this.releaseNo,
        sealById: sealById ?? this.sealById,
        breakSealById: breakSealById ?? this.breakSealById,
      );

  /// Applies the ladder as the server does: ticking a step ticks every step below it, unticking a
  /// step unticks every step above it. References of unticked steps are cleared; a fresh Approved
  /// gets today. The seal people are a choice, not a step, so they are never touched.
  ForwardingRequestTicks step(ForwardingStep step, bool on, {DateTime? today}) {
    final flags = [documentReceived, draftCreated, submitted, approved, released];
    for (var i = 0; i < flags.length; i++) {
      if (on && i <= step.index) flags[i] = true;
      if (!on && i >= step.index) flags[i] = false;
    }
    final approvedNow = flags[3];
    return copyWith(
      documentReceived: flags[0],
      draftCreated: flags[1],
      cNumber: flags[1] ? cNumber : '',
      submitted: flags[2],
      submittedRef: flags[2] ? submittedRef : '',
      approved: approvedNow,
      approvedDate: !approvedNow ? '' : (approvedDate.isEmpty ? toJavaDate(today ?? DateTime.now()) : approvedDate),
      released: flags[4],
      releaseNo: flags[4] ? releaseNo : '',
    );
  }

  /// What stops a Save: the draft needs a C Number, the release needs a release number.
  String? get blocker {
    if (draftCreated && cNumber.trim().isEmpty) return 'Enter the C Number to save Draft created';
    if (released && releaseNo.trim().isEmpty) return 'Enter the release number to save Released';
    return null;
  }

  Map<String, dynamic> toJava() => {
        'documentReceived': documentReceived,
        'draftCreated': draftCreated,
        'cNumber': draftCreated ? cNumber.trim() : null,
        'submitted': submitted,
        'submittedRef': submitted && submittedRef.trim().isNotEmpty ? submittedRef.trim() : null,
        'approved': approved,
        'approvedDate': approved && approvedDate.trim().isNotEmpty ? approvedDate.trim() : null,
        'released': released,
        'releaseNo': released ? releaseNo.trim() : null,
        'sealByRefId': sealById > 0 ? sealById : null,
        'breakSealByRefId': breakSealById > 0 ? breakSealById : null,
      };
}

/// The planning list's filters, as `POST /api/forwarding-requests/search` takes them.
class ForwardingRequestFilter {
  const ForwardingRequestFilter({
    required this.fromDate,
    required this.toDate,
    this.formTypes = const [],
    this.statuses = const [],
    this.jobNo = '',
    this.mine = false,
  });

  /// The team's list opens on the coming week; "mine" looks a month back and ahead.
  factory ForwardingRequestFilter.defaults({DateTime? now, bool mine = false}) {
    final today = now ?? DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    return ForwardingRequestFilter(
      fromDate: toJavaDate(day.add(Duration(days: mine ? -30 : 0))),
      toDate: toJavaDate(day.add(Duration(days: mine ? 30 : 7))),
      mine: mine,
    );
  }

  /// `yyyy-MM-dd`, inclusive by day; blank means open-ended.
  final String fromDate;
  final String toDate;
  final List<String> formTypes;
  /// Empty means every status except cancelled.
  final List<String> statuses;
  final String jobNo;
  final bool mine;

  int get activeCount => formTypes.length + statuses.length + (jobNo.trim().isEmpty ? 0 : 1);

  ForwardingRequestFilter copyWith({
    String? fromDate,
    String? toDate,
    List<String>? formTypes,
    List<String>? statuses,
    String? jobNo,
    bool? mine,
  }) =>
      ForwardingRequestFilter(
        fromDate: fromDate ?? this.fromDate,
        toDate: toDate ?? this.toDate,
        formTypes: formTypes ?? this.formTypes,
        statuses: statuses ?? this.statuses,
        jobNo: jobNo ?? this.jobNo,
        mine: mine ?? this.mine,
      );

  Map<String, dynamic> toJava() => {
        'fromDate': fromDate.isEmpty ? null : fromDate,
        'toDate': toDate.isEmpty ? null : toDate,
        'formTypes': formTypes,
        'statuses': statuses,
        'jobNo': jobNo.trim().isEmpty ? null : jobNo.trim(),
        'mine': mine,
      };
}
