import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

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

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      jobType: json['JobType']?.toString(),
      offVesselName: json['OffVesselName']?.toString(),
      customerName: json['CustomerName']?.toString(),
      loadingVesselName: json['LoadingVesselName']?.toString(),
      jobStatus: json['Jobstatus']?.toString(),
      cargoQTY: json['CargoQTY']?.toString(),
      cargoWeight: json['Cargoweight']?.toString(),
      employeeName: json['EmployeeName']?.toString(),
      CNumberDisplay: json['CNumberDisplay']?.toString(),
      eta: json['ETA']?.toString(),
      remarks: json['Remarks']?.toString(),
      awbNo: json['AWBNo']?.toString(),
      sourceTable: json['SourceTable']?.toString(),
      oiDateIn: json['OIDateIn']?.toString(),
      odiDateOut: json['ODIDateOut']?.toString(),
      id: (json['Id'] ?? 0).toInt(),
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