import 'package:maleva/core/utils/json_read.dart';

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

  LeaveRequestModel({
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
