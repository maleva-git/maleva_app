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
    required this.createdDate,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['Id'] ?? 0,
      applicantType: json['ApplicantType'] ?? 0,
      applicantRefId: json['ApplicantRefId'] ?? 0,
      applicantName: json['ApplicantName'] ?? '',
      leaveTypeRefId: json['LeaveTypeRefId'] ?? 0,
      fromDate: DateTime.tryParse(json['FromDate'] ?? '') ?? DateTime.now(),
      toDate: DateTime.tryParse(json['ToDate'] ?? '') ?? DateTime.now(),
      totalDays: json['TotalDays'] ?? 0,
      reason: json['Reason'] ?? '',
      statusRefId: json['StatusRefId'] ?? 0,
      statusName: json['StatusName'] ?? '',
      reviewRemark: json['ReviewRemark'] ?? '',
      createdDate: DateTime.tryParse(json['Created_Date'] ?? '') ?? DateTime.now(),
    );
  }
}

class LeaveTypeModel {
  final int id;
  final String name;
  LeaveTypeModel({required this.id, required this.name});
  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(id: json['Id'] ?? 0, name: json['Name'] ?? '');
  }
}
