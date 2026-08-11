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
  final String? eta;
  final String remarks;
  final bool active;
  final String? createdDate;
  final String createdBy;
  final String? modifiedDate;
  final String modifiedBy;
  final String agentMobileNo;
  final String fullRoute;
  final String driverNumber;
  
  // Joined fields
  final String rtiNumber;
  final String employeeName;
  final String rtiMasterRemarks;
  final int marqisStatus;

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
    this.eta,
    required this.remarks,
    required this.active,
    this.createdDate,
    required this.createdBy,
    this.modifiedDate,
    required this.modifiedBy,
    required this.agentMobileNo,
    required this.fullRoute,
    required this.driverNumber,
    required this.rtiNumber,
    required this.employeeName,
    required this.rtiMasterRemarks,
    this.marqisStatus = 0,
  });

  factory RtiRouteActivity.fromJson(Map<String, dynamic> json) {
    return RtiRouteActivity(
      id: json['Id'] ?? 0,
      companyRefId: json['CompanyRefId'] ?? 0,
      rtiMasterRefId: json['RTIMasterRefId'] ?? 0,
      sequenceNo: json['SequenceNo'] ?? 0,
      locationName: json['LocationName'] ?? json['Port'] ?? '',
      activityType: json['ActivityType'] ?? json['JobType'] ?? '',
      employeeRefId: json['EmployeeRefId'] ?? 0,
      status: json['Status'] ?? 0,
      plannedDateTime: json['PlannedDateTime'],
      eta: json['ETA'],
      remarks: json['Remarks'] ?? '',
      active: json['Active'] ?? false,
      createdDate: json['Created_Date'],
      createdBy: json['Created_By'] ?? '',
      modifiedDate: json['Modified_Date'],
      modifiedBy: json['Modified_By'] ?? '',
      agentMobileNo: json['AgentMobileNo'] ?? json['Contact'] ?? '',
      fullRoute: json['FullRoute'] ?? '',
      driverNumber: json['DriverNumber'] ?? '',
      rtiNumber: json['RTINumber'] ?? json['LorryNo'] ?? '',
      employeeName: json['EmployeeName'] ?? json['DriverName'] ?? '',
      rtiMasterRemarks: json['RTIMasterRemarks'] ?? '',
      marqisStatus: json['MarqisStatus'] ?? 0,
    );
  }
}
