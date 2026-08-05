class RtiRouteActivity {
  final int id;
  final int companyRefId;
  final int rtiMasterRefId;
  final int sequenceNo;
  final String locationName;
  final String activityType;
  final int employeeRefId;
  final int status;
  final String? plannedDateTime;
  final String? completedDateTime;
  final String remarks;
  final bool active;
  final String agentMobileNo;

  RtiRouteActivity({
    required this.id,
    required this.companyRefId,
    required this.rtiMasterRefId,
    required this.sequenceNo,
    required this.locationName,
    required this.activityType,
    required this.employeeRefId,
    required this.status,
    this.plannedDateTime,
    this.completedDateTime,
    required this.remarks,
    required this.active,
    required this.agentMobileNo,
  });

  factory RtiRouteActivity.fromJson(Map<String, dynamic> json) {
    return RtiRouteActivity(
      id: json['Id'] ?? 0,
      companyRefId: json['CompanyRefId'] ?? 0,
      rtiMasterRefId: json['RTIMasterRefId'] ?? 0,
      sequenceNo: json['SequenceNo'] ?? 0,
      locationName: json['LocationName'] ?? '',
      activityType: json['ActivityType'] ?? '',
      employeeRefId: json['EmployeeRefId'] ?? 0,
      status: json['Status'] ?? 0,
      plannedDateTime: json['PlannedDateTime'],
      completedDateTime: json['CompletedDateTime'],
      remarks: json['Remarks'] ?? '',
      active: json['Active'] ?? false,
      agentMobileNo: json['AgentMobileNo'] ?? '',
    );
  }
}
