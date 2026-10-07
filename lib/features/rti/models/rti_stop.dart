import 'package:equatable/equatable.dart';

const Object _keep = Object();

/// One route activity of the RTI (`R/types/rti.ts` `RTIRouteActivityRow`), named as the
/// Java `RTIRouteActivitiesDto`. [jobType] holds the web's form value (`SEAL_AND_BREAK`
/// for the pair the server stores as `SEAL,BREAK_SEAL`).
class RtiStop extends Equatable {
  const RtiStop({
    this.id,
    required this.sequenceNo,
    this.locationName = '',
    this.employeeRefId,
    this.agentName,
    this.agentMobileNo = '',
    this.jobType = '',
    this.remarks = '',
    this.fullRoute = '',
    this.driverNumber = '',
    this.marqisStatus,
    this.vesselName = '',
    this.jobQuantity = '',
    this.status = 0,
    this.eta,
    this.plannedDateTime,
    this.completedDateTime,
    this.createdDate,
  });

  final int? id;
  final int sequenceNo;
  final String locationName;
  final int? employeeRefId;
  final String? agentName;
  final String agentMobileNo;
  final String jobType;
  final String remarks;
  final String fullRoute;
  final String driverNumber;
  final int? marqisStatus;

  /// The vessel this stop is for: one of the job lines' vessels, or typed
  /// (`RTIRouteActivitiesDto.vesselName`).
  final String vesselName;

  /// That vessel's job quantity, filled from the job lines when it is picked; editable
  /// (`RTIRouteActivitiesDto.jobQuantity`).
  final String jobQuantity;
  final int status;

  /// `yyyy-MM-ddTHH:mm[:ss]` as typed / loaded, or null.
  final String? eta;
  final String? plannedDateTime;
  final String? completedDateTime;
  final String? createdDate;

  RtiStop copyWith({
    Object? id = _keep,
    int? sequenceNo,
    String? locationName,
    Object? employeeRefId = _keep,
    Object? agentName = _keep,
    String? agentMobileNo,
    String? jobType,
    String? remarks,
    String? fullRoute,
    String? driverNumber,
    Object? marqisStatus = _keep,
    String? vesselName,
    String? jobQuantity,
    int? status,
    Object? eta = _keep,
  }) =>
      RtiStop(
        id: identical(id, _keep) ? this.id : id as int?,
        sequenceNo: sequenceNo ?? this.sequenceNo,
        locationName: locationName ?? this.locationName,
        employeeRefId: identical(employeeRefId, _keep) ? this.employeeRefId : employeeRefId as int?,
        agentName: identical(agentName, _keep) ? this.agentName : agentName as String?,
        agentMobileNo: agentMobileNo ?? this.agentMobileNo,
        jobType: jobType ?? this.jobType,
        remarks: remarks ?? this.remarks,
        fullRoute: fullRoute ?? this.fullRoute,
        driverNumber: driverNumber ?? this.driverNumber,
        marqisStatus: identical(marqisStatus, _keep) ? this.marqisStatus : marqisStatus as int?,
        vesselName: vesselName ?? this.vesselName,
        jobQuantity: jobQuantity ?? this.jobQuantity,
        status: status ?? this.status,
        eta: identical(eta, _keep) ? this.eta : eta as String?,
        plannedDateTime: plannedDateTime,
        completedDateTime: completedDateTime,
        createdDate: createdDate,
      );

  @override
  List<Object?> get props => [
        id, sequenceNo, locationName, employeeRefId, agentName, agentMobileNo, jobType, remarks, fullRoute,
        driverNumber, marqisStatus, vesselName, jobQuantity, status, eta, plannedDateTime, completedDateTime, createdDate,
      ];
}

/// An employee for the route activities' agent picker (`R/hooks/useRTIEmployees.ts`).
class RtiEmployee extends Equatable {
  const RtiEmployee({required this.id, required this.fullName, this.mobileNo});

  final int id;
  final String fullName;
  final String? mobileNo;

  @override
  List<Object?> get props => [id, fullName, mobileNo];
}
