import 'package:equatable/equatable.dart';

abstract class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object?> get props => [];
}

class FetchLeaveData extends LeaveEvent {
  final int applicantType;
  final int applicantRefId;
  final String fromDate;
  final String toDate;

  const FetchLeaveData({
    required this.applicantType,
    required this.applicantRefId,
    required this.fromDate,
    required this.toDate,
  });

  @override
  List<Object?> get props => [applicantType, applicantRefId, fromDate, toDate];
}

class SubmitLeaveRequest extends LeaveEvent {
  final int leaveTypeRefId;
  final DateTime fromDate;
  final DateTime toDate;
  final int totalDays;
  final String reason;
  final int applicantRefId;
  final int applicantType;

  const SubmitLeaveRequest({
    required this.leaveTypeRefId,
    required this.fromDate,
    required this.toDate,
    required this.totalDays,
    required this.reason,
    required this.applicantRefId,
    required this.applicantType,
  });

  @override
  List<Object?> get props => [
        leaveTypeRefId,
        fromDate,
        toDate,
        totalDays,
        reason,
        applicantRefId,
        applicantType,
      ];
}

class UpdateLeaveStatusEvent extends LeaveEvent {
  final int id;
  final int statusRefId;
  final String reviewRemark;
  final int reviewedBy;

  const UpdateLeaveStatusEvent({
    required this.id,
    required this.statusRefId,
    required this.reviewRemark,
    required this.reviewedBy,
  });

  @override
  List<Object?> get props => [id, statusRefId, reviewRemark, reviewedBy];
}
