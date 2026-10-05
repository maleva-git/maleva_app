import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:maleva/core/utils/json_read.dart';

/// One job on a saved plan: a `saledetails` row of `POST /api/planing/select-planning`
/// (Java `PlanningDetailsModel`, .NET names: `Id`, `PLANINGMasterRefId`, `JobNo`, `TruckName`,
/// `DriverName`, `CustomerName`, `JobStatus`, `RTINo`).
class PlanJob extends Equatable {
  const PlanJob({
    required this.id,
    required this.planningId,
    required this.jobNo,
    this.truckName = '',
    this.driverName = '',
    this.customerName = '',
    this.jobStatus = '',
    this.rtiNo = '',
  });

  factory PlanJob.fromJava(Map<String, dynamic> j) => PlanJob(
        id: JsonRead.integer(j['Id']),
        planningId: JsonRead.integer(j['PLANINGMasterRefId'] ?? j['planingMasterRefId'] ?? j['planingId']),
        jobNo: JsonRead.string(j['JobNo']),
        truckName: JsonRead.string(j['TruckName']),
        driverName: JsonRead.string(j['DriverName']),
        customerName: JsonRead.string(j['CustomerName']),
        jobStatus: JsonRead.string(j['JobStatus']),
        rtiNo: JsonRead.string(j['RTINo']),
      );

  final int id;
  final int planningId;
  final String jobNo;
  final String truckName;
  final String driverName;
  final String customerName;
  final String jobStatus;
  final String rtiNo;

  @override
  List<Object?> get props => [id, planningId, jobNo, truckName, driverName, customerName, jobStatus, rtiNo];
}

/// One saved plan as Planning View lists it, read like React's `mapPlanningViewResults`
/// (`P/utils/planningViewMapper.ts:57-124`) from a `salemaster` row (`Id`, `PLANINGNoDisplay`,
/// `PLANINGDate` "dd/MM/yyyy", `EmployeeName`, `TotalOrders`, `Remarks`).
class PlanRow extends Equatable {
  const PlanRow({
    required this.id,
    required this.planningNo,
    required this.planningDate,
    this.rawPlanningDate = '',
    this.employeeName = '',
    this.totalOrders = 0,
    this.remarks = '',
    this.jobs = const [],
  });

  final int id;
  final String planningNo;

  /// "02 Mar 2026" (en-GB day, short month, year), or the raw text when it is not a date.
  final String planningDate;
  final String rawPlanningDate;
  final String employeeName;
  final int totalOrders;
  final String remarks;
  final List<PlanJob> jobs;

  /// `mapPlanningViewResults`: masters with their details (by `PLANINGMasterRefId`).
  static List<PlanRow> fromSelectPlanning(List<Map<String, dynamic>> masters, List<Map<String, dynamic>> details) {
    final jobs = details.map(PlanJob.fromJava).toList();
    return [
      for (var i = 0; i < masters.length; i++) _fromMaster(masters[i], i, jobs),
    ];
  }

  static PlanRow _fromMaster(Map<String, dynamic> m, int index, List<PlanJob> all) {
    final id = JsonRead.intOrNull(m['id'] ?? m['Id'] ?? m['PLANINGMasterRefId']) ?? index + 1;
    final ownJobs = all.where((j) => j.planningId == id).toList();
    final rawDate = _firstText([m['planningDate'], m['SSaleDate'], m['PLANINGDate'], m['Created_Date']]);
    final totalOrders = JsonRead.intOrNull(m['totalOrders'] ?? m['TotalOrders']) ?? ownJobs.length;
    return PlanRow(
      id: id,
      planningNo: _firstText([m['planningNo'], m['CNumber'], m['PLANINGNoDisplay'], m['PLANINGNo']]),
      planningDate: formatPlanningViewDate(rawDate),
      rawPlanningDate: rawDate,
      employeeName: _firstText([m['employeeName'], m['EmployeeName'], m['Modified_By'], m['CreatedBy']]),
      totalOrders: totalOrders,
      remarks: _firstText([m['remarks'], m['Remarks']]),
      jobs: ownJobs,
    );
  }

  /// The first value that is not null (JavaScript `??`), as text.
  static String _firstText(List<dynamic> values) {
    for (final v in values) {
      if (v != null) return v.toString();
    }
    return '';
  }

  static final DateFormat _enGb = DateFormat('dd MMM yyyy', 'en_US');

  /// `formatPlanningViewDate`: "dd/MM/yyyy" (the server's form) or an ISO date → "02 Mar 2026";
  /// '' stays ''; anything else is shown as it is.
  static String formatPlanningViewDate(String value) {
    final s = value.trim();
    if (s.isEmpty) return '';
    final m = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(s);
    if (m != null) {
      final d = DateTime(int.parse(m[3]!), int.parse(m[2]!), int.parse(m[1]!));
      return _enGb.format(d);
    }
    final parsed = DateTime.tryParse(s);
    return parsed == null ? s : _enGb.format(parsed);
  }

  @override
  List<Object?> get props => [id, planningNo, planningDate, rawPlanningDate, employeeName, totalOrders, remarks, jobs];
}
