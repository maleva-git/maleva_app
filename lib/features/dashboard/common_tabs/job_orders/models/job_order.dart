import 'package:maleva/core/utils/json_read.dart';

/// A job order as the shared Java `/api/job-orders/list` answers it.
class JobOrder {
  final int id;
  final int companyRefId;
  final int statusRefId;
  final String cNumberDisplay;
  final int truckMasterRefId;
  final String truckName;
  final int driverMasterRefId;
  final String driverName;
  final String vendorName;
  final String statusName;
  final String jobTypeName;
  final String priorityName;
  final String problemName;
  final String productUse;
  final String remarks;
  final String jobDate;
  final String sJobDate;
  final String targetDate;
  final double estimatedCost;
  final double actualCost;

  JobOrder({
    required this.id,
    required this.companyRefId,
    required this.statusRefId,
    required this.cNumberDisplay,
    required this.truckMasterRefId,
    required this.truckName,
    required this.driverMasterRefId,
    required this.driverName,
    required this.vendorName,
    required this.statusName,
    required this.jobTypeName,
    required this.priorityName,
    required this.problemName,
    required this.productUse,
    required this.remarks,
    required this.jobDate,
    required this.sJobDate,
    required this.targetDate,
    required this.estimatedCost,
    required this.actualCost,
  });

  factory JobOrder.fromJava(Map<String, dynamic> json) {
    final jobDate = JsonRead.string(json['jobDate']);
    return JobOrder(
      id: JsonRead.integer(json['id']),
      companyRefId: JsonRead.integer(json['companyRefId']),
      statusRefId: JsonRead.integer(json['statusRefId']),
      // Jackson writes the Lombok getter getCNumberDisplay as cnumberDisplay
      cNumberDisplay: JsonRead.string(json['cNumberDisplay'] ?? json['cnumberDisplay']),
      truckMasterRefId: JsonRead.integer(json['truckMasterRefId']),
      truckName: JsonRead.string(json['truckName']),
      driverMasterRefId: JsonRead.integer(json['driverMasterRefId']),
      driverName: JsonRead.string(json['driverName']),
      vendorName: JsonRead.string(json['vendorName']),
      statusName: JsonRead.string(json['statusName']),
      jobTypeName: JsonRead.string(json['jobTypeName']),
      priorityName: JsonRead.string(json['priorityName']),
      problemName: JsonRead.string(json['problemName']),
      productUse: JsonRead.string(json['productUse']),
      remarks: JsonRead.string(json['remarks']),
      jobDate: jobDate,
      sJobDate: formatDate(jobDate),
      targetDate: formatDate(JsonRead.string(json['expectedCompletionDate'])),
      estimatedCost: _num(json['estimatedCost']),
      actualCost: _num(json['actualCost']),
    );
  }

  static double _num(dynamic v) => v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

  /// `2026-10-04` (or an ISO date-time) as `04/10/2026`; anything else as it is.
  static String formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }
}
