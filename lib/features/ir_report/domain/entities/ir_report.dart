import 'package:equatable/equatable.dart';

/// One incident report: something that cost the company money outside normal
/// operations - a spare dropped into the sea, a truck accident, a police
/// compound.
class IrReport extends Equatable {
  const IrReport({
    required this.id,
    required this.irDate,
    required this.statusId,
    required this.description,
    required this.departmentId,
    required this.departmentName,
    this.statusCode,
    this.statusName,
    this.statusColor,
    this.reason,
    this.vesselName,
    this.truckId,
    this.truckNo,
    this.employeeId,
    this.employeeName,
    this.driverId,
    this.driverName,
    this.actualAmount,
    this.reporterId,
    this.reporterName,
    this.createdBy,
    this.createdDate,
    this.documentRemarks,
  });

  final int id;

  /// When the incident happened, not when it was typed in.
  final DateTime irDate;

  final int statusId;
  final String? statusCode;
  final String? statusName;
  final String? statusColor;

  final String description;
  final String? reason;

  /// UserRoles role id and its name as stored with the report.
  final int departmentId;
  final String departmentName;

  final String? vesselName;

  /// Null ids with a name are the typed cases: a hired lorry, an outside driver.
  final int? truckId;
  final String? truckNo;
  final int? employeeId;
  final String? employeeName;
  final int? driverId;
  final String? driverName;

  /// Whole ringgit.
  final int? actualAmount;

  /// EmployeeMaster.Id and name of the employee who filed it.
  final int? reporterId;
  final String? reporterName;

  /// User name stamped by the server; the fallback when there is no employee.
  final String? createdBy;
  final DateTime? createdDate;

  /// Notes on the attached documents, edited on the web. The app does not show
  /// them but carries them through an edit, so saving here never clears them.
  final String? documentRemarks;

  /// Who filed it, for display.
  String get reporter => reporterName ?? createdBy ?? '';

  @override
  List<Object?> get props => [
        id,
        irDate,
        statusId,
        statusCode,
        statusName,
        statusColor,
        description,
        reason,
        departmentId,
        departmentName,
        vesselName,
        truckId,
        truckNo,
        employeeId,
        employeeName,
        driverId,
        driverName,
        actualAmount,
        reporterId,
        reporterName,
        createdBy,
        createdDate,
        documentRemarks,
      ];
}
