import 'package:maleva/core/utils/json_read.dart';

import 'leave_calendar.dart';
import 'leave_duration.dart';

class LeaveRequestModel {
  final int id;
  final int applicantType;
  final int applicantRefId;
  final String applicantName;
  final int leaveTypeRefId;
  final DateTime fromDate;
  final DateTime toDate;
  final int totalDays;
  final String reason;
  final int statusRefId;
  final String statusName;
  final String reviewRemark;
  final int reviewedBy;
  final String reviewedByName;
  final DateTime createdDate;

  /// HR Sprint 2, sent only when the server counts working days: FULL / AM / PM / HOURS.
  final String? part;

  /// Working days on the company calendar (Sunday / holidays 0).
  final double? workingDays;

  LeaveRequestModel({
    this.part,
    this.workingDays,
    required this.id,
    required this.applicantType,
    required this.applicantRefId,
    required this.applicantName,
    required this.leaveTypeRefId,
    required this.fromDate,
    required this.toDate,
    required this.totalDays,
    required this.reason,
    required this.statusRefId,
    required this.statusName,
    required this.reviewRemark,
    required this.reviewedBy,
    required this.reviewedByName,
    required this.createdDate,
  });

  /// The status by `statusName`, the company's own wording; the usual ids 1 / 2 / 3 only when the
  /// name is missing; no status is pending (openspec change `leave-dates-and-decisions`).
  LeaveDecision get status {
    final name = statusName.trim().toUpperCase();
    if (name == 'APPROVED') return LeaveDecision.approved;
    if (name == 'REJECTED') return LeaveDecision.rejected;
    if (name == 'PENDING') return LeaveDecision.pending;
    if (name.isEmpty && statusRefId == 2) return LeaveDecision.approved;
    if (name.isEmpty && statusRefId == 3) return LeaveDecision.rejected;
    return LeaveDecision.pending;
  }

  bool get isPending => status == LeaveDecision.pending;

  /// "2½ Days", "½ Day (morning)", "2 Hours", else the calendar length as before.
  String get lengthLabel {
    final days = workingDays;
    if (days != null) {
      switch ((part ?? '').toUpperCase()) {
        case 'AM':
          return '½ Day (morning)';
        case 'PM':
          return '½ Day (afternoon)';
        case 'FULL':
          return '${dayCount(days)} ${days == 1 ? "Day" : "Days"}';
      }
    }
    return leaveDurationLabel(fromDate, toDate);
  }

  /// A request of the shared Java `/api/leave/search`.
  factory LeaveRequestModel.fromJava(Map<String, dynamic> json) {
    dynamic f(String k) => JsonRead.field(json, k);
    return LeaveRequestModel(
      id: JsonRead.integer(f('id')),
      applicantType: JsonRead.integer(f('applicantType')),
      applicantRefId: JsonRead.integer(f('applicantRefId')),
      applicantName: JsonRead.string(f('applicantName')),
      leaveTypeRefId: JsonRead.integer(f('leaveTypeRefId')),
      fromDate: JsonRead.date(f('fromDate')) ?? DateTime.now(),
      toDate: JsonRead.date(f('toDate')) ?? DateTime.now(),
      totalDays: JsonRead.integer(f('totalDays')),
      reason: JsonRead.string(f('reason')),
      statusRefId: JsonRead.integer(f('statusRefId')),
      statusName: JsonRead.string(f('statusName')),
      reviewRemark: JsonRead.string(f('reviewRemark')),
      reviewedBy: JsonRead.integer(f('reviewedBy')),
      reviewedByName: JsonRead.string(f('reviewedByName')),
      createdDate: JsonRead.date(f('createdDate')) ?? JsonRead.date(f('fromDate')) ?? DateTime.now(),
      part: f('part') == null ? null : JsonRead.string(f('part')),
      workingDays: f('workingDays') == null ? null : (num.tryParse('${f('workingDays')}')?.toDouble()),
    );
  }
}

class LeaveTypeModel {
  final int id;
  final String name;
  LeaveTypeModel({required this.id, required this.name});
  /// A type of the shared Java `/api/leave/types`.
  factory LeaveTypeModel.fromJava(Map<String, dynamic> json) =>
      LeaveTypeModel(id: JsonRead.integer(json['id']), name: JsonRead.string(json['name']));
}

/// Where a leave request stands.
enum LeaveDecision { pending, approved, rejected }
