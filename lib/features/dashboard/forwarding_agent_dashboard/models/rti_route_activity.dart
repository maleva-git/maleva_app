import 'package:maleva/core/utils/json_read.dart';

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

  /// One stop of the shared Java route list (`/api/rti-route-activities`);
  /// the screen's lorry, driver and contact columns come from its joins.
  factory RtiRouteActivity.fromJava(Map<String, dynamic> json) {
    String text(String key) => JsonRead.string(json[key]);
    return RtiRouteActivity(
      id: JsonRead.integer(json['id']),
      companyRefId: 0,
      rtiMasterRefId: JsonRead.integer(json['rtiMasterRefId']),
      sequenceNo: 0,
      locationName: text('port'),
      activityType: text('jobType'),
      employeeRefId: 0,
      status: JsonRead.integer(json['status']),
      eta: JsonRead.stringOrNull(json['eta']),
      remarks: text('remarks'),
      active: true,
      createdBy: '',
      modifiedBy: '',
      agentMobileNo: text('contact'),
      fullRoute: text('fullRoute'),
      driverNumber: text('driverNumber'),
      rtiNumber: text('lorryNo'),
      employeeName: text('driverName'),
      rtiMasterRemarks: '',
      marqisStatus: JsonRead.integer(json['marqisStatus']),
    );
  }
}
