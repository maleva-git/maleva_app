import 'package:intl/intl.dart';
import 'package:maleva/core/utils/json_read.dart';

import '../../domain/entities/ir_draft.dart';
import '../../domain/entities/ir_filter.dart';
import '../../domain/entities/ir_lookup.dart';
import '../../domain/entities/ir_report.dart';

/// JSON to entities and back for /api/IRApp.
///
/// The keys are the .NET model property names exactly as IRModel.cs declares
/// them (PascalCase): a key spelled differently binds to nothing on the
/// server and the value is silently dropped.
class IrJson {
  IrJson._();

  static final DateFormat _dateTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
  static final DateFormat _date = DateFormat('yyyy-MM-dd');

  static IrReport report(Map<String, dynamic> json) {
    return IrReport(
      id: JsonRead.integer(json['Id']),
      irDate: JsonRead.date(json['IRDate']) ?? DateTime(1900),
      statusId: JsonRead.integer(json['IRStatusRefId']),
      statusCode: JsonRead.stringOrNull(json['StatusCode']),
      statusName: JsonRead.stringOrNull(json['StatusName']),
      statusColor: JsonRead.stringOrNull(json['StatusColor']),
      description: JsonRead.string(json['Description']),
      reason: JsonRead.stringOrNull(json['Reason']),
      departmentId: JsonRead.integer(json['DepartmentRefId']),
      departmentName: JsonRead.string(json['DepartmentName']),
      vesselName: JsonRead.stringOrNull(json['VesselName']),
      truckId: JsonRead.intOrNull(json['TruckRefId']),
      truckNo: JsonRead.stringOrNull(json['TruckNo']),
      employeeId: JsonRead.intOrNull(json['EmployeeRefId']),
      employeeName: JsonRead.stringOrNull(json['EmployeeName']),
      driverId: JsonRead.intOrNull(json['DriverRefId']),
      driverName: JsonRead.stringOrNull(json['DriverName']),
      actualAmount: JsonRead.intOrNull(json['ActualAmount']),
      reporterId: JsonRead.intOrNull(json['CreateEmployeeRefId']),
      reporterName: JsonRead.stringOrNull(json['CreateEmployeeName']),
      createdBy: JsonRead.stringOrNull(json['Created_By']),
      createdDate: JsonRead.date(json['Created_Date']),
    );
  }

  static IrStatus status(Map<String, dynamic> json) {
    return IrStatus(
      id: JsonRead.integer(json['Id']),
      code: JsonRead.string(json['StatusCode']),
      name: JsonRead.string(json['StatusName']),
      colorCode: JsonRead.stringOrNull(json['ColorCode']),
      finished: JsonRead.boolean(json['Finished']),
    );
  }

  static LookupOption department(Map<String, dynamic> json) {
    return LookupOption(
      id: JsonRead.integer(json['Id']),
      name: JsonRead.string(json['Name']),
    );
  }

  /// A row of TruckApp/GetTruck, DriverApp/GetDriver or EmployeeApp/GetEmployee,
  /// which all answer `{Id, AccountName}`.
  static LookupOption masterRow(Map<String, dynamic> json) {
    return LookupOption(
      id: JsonRead.integer(json['Id']),
      name: JsonRead.string(json['AccountName']).trim(),
    );
  }

  /// Body of IRApp/SelectIR (IRSearchModel).
  static Map<String, dynamic> searchRequest(IrFilter filter, {required int companyId}) {
    return {
      'Comid': companyId,
      'FromDate': filter.fromDate == null ? null : _date.format(filter.fromDate!),
      'ToDate': filter.toDate == null ? null : _date.format(filter.toDate!),
      'IRStatusRefId': filter.statusId,
      'OpenOnly': filter.openOnly,
      'Search': filter.search.trim(),
    };
  }

  /// Body of IRApp/InsertIR (IRSaveModel). Ids are 0 for "not chosen", which the
  /// server treats as null; a typed truck/driver/employee name travels only
  /// with a 0 id.
  static Map<String, dynamic> saveRequest(
    IrDraft draft, {
    required int companyId,
    required int userRefId,
  }) {
    return {
      'Id': draft.id,
      'CompanyRefId': companyId,
      'UserRefId': userRefId,
      'IRDate': draft.irDate == null ? null : _dateTime.format(draft.irDate!),
      'IRStatusRefId': draft.status?.id ?? 0,
      'Description': draft.description.trim(),
      'Reason': draft.reason.trim(),
      'DepartmentRefId': draft.department?.id ?? 0,
      'VesselName': draft.vesselName.trim(),
      'TruckRefId': draft.truck.refId,
      'TruckNo': draft.truck.name,
      'EmployeeRefId': draft.employee.refId,
      'EmployeeName': draft.employee.name,
      'DriverRefId': draft.driver.refId,
      'DriverName': draft.driver.name,
      'ActualAmount': draft.amount,
    };
  }
}
