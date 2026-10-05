import 'package:maleva/core/utils/json_read.dart';

class InventoryModel {
  final String? jobType;
  final String? offVesselName;
  final String? customerName;
  final String? loadingVesselName;
  final String? jobStatus;
  final String? cargoQTY;
  final String? cargoWeight;
  final String? employeeName;
  final String? eta;
  final String? remarks;
  final String? CNumberDisplay;
  final String? awbNo;
  final String? sourceTable;
  final String? oiDateIn;
  final String? odiDateOut;
  final int id;

  InventoryModel({
    this.jobType,
    this.offVesselName,
    this.customerName,
    this.loadingVesselName,
    this.jobStatus,
    this.cargoQTY,
    this.cargoWeight,
    this.employeeName,
    this.eta,
    this.CNumberDisplay,
    this.remarks,
    this.awbNo,
    this.sourceTable,
    this.oiDateIn,
    this.odiDateOut,
    required this.id,
  });

  /// A line of the shared Java `/api/sale-orders/inventory`.
  factory InventoryModel.fromJava(Map<String, dynamic> json) {
    dynamic f(String k) => JsonRead.field(json, k);
    return InventoryModel(
      jobType: JsonRead.stringOrNull(f('jobType')),
      offVesselName: JsonRead.stringOrNull(f('offVesselName')),
      customerName: JsonRead.stringOrNull(f('customerName')),
      loadingVesselName: JsonRead.stringOrNull(f('loadingVesselName')),
      jobStatus: JsonRead.stringOrNull(f('jobStatus')),
      cargoQTY: JsonRead.stringOrNull(f('cargoQty')),
      cargoWeight: JsonRead.stringOrNull(f('cargoWeight')),
      employeeName: JsonRead.stringOrNull(f('employeeName')),
      CNumberDisplay: JsonRead.stringOrNull(f('cNumberDisplay')),
      eta: JsonRead.stringOrNull(f('eta')),
      remarks: JsonRead.stringOrNull(f('remarks')),
      awbNo: JsonRead.stringOrNull(f('awbNo')),
      sourceTable: JsonRead.stringOrNull(f('sourceTable')),
      oiDateIn: JsonRead.stringOrNull(f('oiDateIn')),
      odiDateOut: JsonRead.stringOrNull(f('odiDateOut')),
      id: JsonRead.integer(f('id')),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'JobType': jobType,
      'OffVesselName': offVesselName,
      'CustomerName': customerName,
      'LoadingVesselName': loadingVesselName,
      'Jobstatus': jobStatus,
      'CargoQTY': cargoQTY,
      'Cargoweight': cargoWeight,
      'EmployeeName': employeeName,
      'CNumberDisplay': CNumberDisplay,
      'ETA': eta,
      'Remarks': remarks,
      'AWBNo': awbNo,
      'SourceTable': sourceTable,
      'OIDateIn': oiDateIn,
      'ODIDateOut': odiDateOut,
      'Id': id,
    };
  }
}