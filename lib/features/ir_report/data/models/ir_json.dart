import 'package:intl/intl.dart';
import 'package:maleva/core/utils/json_read.dart';

import '../../domain/entities/ir_draft.dart';
import '../../domain/entities/ir_filter.dart';
import '../../domain/entities/ir_lookup.dart';
import '../../domain/entities/ir_report.dart';

/// JSON to entities and back for the Java `/api/ir` API (camelCase, as
/// `IrDetailDto`, `IrSaveRequest` and the option DTOs declare it).
class IrJson {
  IrJson._();

  static final DateFormat _dateTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
  static final DateFormat _date = DateFormat('yyyy-MM-dd');

  static IrReport report(Map<String, dynamic> json) {
    return IrReport(
      id: JsonRead.integer(json['id']),
      irDate: JsonRead.date(json['irDate']) ?? DateTime(1900),
      statusId: JsonRead.integer(json['irStatusRefId']),
      statusCode: JsonRead.stringOrNull(json['statusCode']),
      statusName: JsonRead.stringOrNull(json['statusName']),
      statusColor: JsonRead.stringOrNull(json['statusColor']),
      description: JsonRead.string(json['description']),
      reason: JsonRead.stringOrNull(json['reason']),
      departmentId: JsonRead.integer(json['departmentRefId']),
      departmentName: JsonRead.string(json['departmentName']),
      vesselName: JsonRead.stringOrNull(json['vesselName']),
      truckId: JsonRead.intOrNull(json['truckRefId']),
      truckNo: JsonRead.stringOrNull(json['truckNo']),
      employeeId: JsonRead.intOrNull(json['employeeRefId']),
      employeeName: JsonRead.stringOrNull(json['employeeName']),
      driverId: JsonRead.intOrNull(json['driverRefId']),
      driverName: JsonRead.stringOrNull(json['driverName']),
      actualAmount: JsonRead.intOrNull(json['actualAmount']),
      reporterId: JsonRead.intOrNull(json['createEmployeeRefId']),
      reporterName: JsonRead.stringOrNull(json['createEmployeeName']),
      createdBy: JsonRead.stringOrNull(json['createdBy']),
      createdDate: JsonRead.date(json['createdDate']),
      documentRemarks: JsonRead.stringOrNull(json['documentRemarks']),
    );
  }

  static IrStatus status(Map<String, dynamic> json) {
    return IrStatus(
      id: JsonRead.integer(json['id']),
      code: JsonRead.string(json['statusCode']),
      name: JsonRead.string(json['statusName']),
      colorCode: JsonRead.stringOrNull(json['colorCode']),
      finished: JsonRead.boolean(json['finished']),
    );
  }

  static LookupOption department(Map<String, dynamic> json) {
    return LookupOption(
      id: JsonRead.integer(json['id']),
      name: JsonRead.string(json['name']),
    );
  }

  /// A row of TruckApp/GetTruck or DriverApp/GetDriver: `{Id, AccountName}`.
  static LookupOption masterRow(Map<String, dynamic> json) {
    return LookupOption(
      id: JsonRead.integer(json['Id']),
      name: JsonRead.string(json['AccountName']).trim(),
    );
  }

  /// A row of `/api/employees/company/{id}/all`.
  static LookupOption employee(Map<String, dynamic> json) {
    return LookupOption(
      id: JsonRead.integer(json['id']),
      name: JsonRead.string(json['employeeName']).trim(),
    );
  }

  /// Query of `GET /api/ir`. "Every status" and a blank search are left out,
  /// as the web screen does.
  static Map<String, dynamic> searchQuery(IrFilter filter, {required int companyId}) {
    final search = filter.search.trim();
    return {
      'companyRefId': companyId,
      if (filter.fromDate != null) 'fromDate': _date.format(filter.fromDate!),
      if (filter.toDate != null) 'toDate': _date.format(filter.toDate!),
      if (filter.statusId != 0) 'irStatusRefId': filter.statusId,
      if (filter.openOnly) 'openOnly': true,
      if (search.isNotEmpty) 'search': search,
    };
  }

  /// Body of `POST /api/ir` (IrSaveRequest). A picker left empty is null; a
  /// typed truck/driver/employee name travels only without an id. The author
  /// is the signed-in user, set by the server.
  static Map<String, dynamic> saveRequest(IrDraft draft, {required int companyId}) {
    int? idOrNull(int id) => id == 0 ? null : id;
    String? textOrNull(String text) => text.trim().isEmpty ? null : text.trim();
    return {
      'id': idOrNull(draft.id),
      'companyRefId': companyId,
      'irDate': draft.irDate == null ? null : _dateTime.format(draft.irDate!),
      'irStatusRefId': draft.status?.id,
      'description': draft.description.trim(),
      'reason': textOrNull(draft.reason),
      'departmentRefId': draft.department?.id,
      'vesselName': textOrNull(draft.vesselName),
      'truckRefId': idOrNull(draft.truck.refId),
      'truckNo': textOrNull(draft.truck.name),
      'employeeRefId': idOrNull(draft.employee.refId),
      'employeeName': textOrNull(draft.employee.name),
      'driverRefId': idOrNull(draft.driver.refId),
      'driverName': textOrNull(draft.driver.name),
      'actualAmount': draft.amount,
      'documentRemarks': draft.documentRemarks,
    };
  }
}
