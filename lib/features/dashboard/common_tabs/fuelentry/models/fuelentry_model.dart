
import '../../../../../core/utils/app_preferences.dart';

class FuelEntryModel {
  int id;
  String entryNo;
  String entryDate;
  int truckId;
  String truckName;
  int driverId;
  String driverName;
  String remarks;
  
  double aLiter;
  double aAmount;
  
  double pLiter;
  double pRate;
  double pAmount;
  
  double gLiter;
  double gAmount;
  
  double dpLiter;
  double dpAmount;
  double dgLiter;
  double dgAmount;
  
  int comid;

  FuelEntryModel({
    this.id = 0,
    this.entryNo = '',
    this.entryDate = '',
    this.truckId = 0,
    this.truckName = '',
    this.driverId = 0,
    this.driverName = '',
    this.remarks = '',
    this.aLiter = 0.0,
    this.aAmount = 0.0,
    this.pLiter = 0.0,
    this.pRate = 0.0,
    this.pAmount = 0.0,
    this.gLiter = 0.0,
    this.gAmount = 0.0,
    this.dpLiter = 0.0,
    this.dpAmount = 0.0,
    this.dgLiter = 0.0,
    this.dgAmount = 0.0,
    this.comid = 0,
  });

  factory FuelEntryModel.fromJson(Map<String, dynamic> json) {
    return FuelEntryModel(
      id: json['Id'] ?? 0,
      entryNo: json['CNumberDisplay'] ?? '',
      entryDate: json['SSaleDate'] ?? '',
      truckId: json['TruckRefid'] ?? 0,
      truckName: json['TruckName'] ?? '',
      driverId: json['DriverRefId'] ?? 0,
      driverName: json['DriverName'] ?? '',
      remarks: json['Remarks'] ?? '',
      aLiter: (json['Aliter'] ?? 0.0).toDouble(),
      aAmount: (json['AAmount'] ?? 0.0).toDouble(),
      pLiter: (json['Pliter'] ?? 0.0).toDouble(),
      pRate: (json['PRate'] ?? 0.0).toDouble(),
      pAmount: (json['PAmount'] ?? 0.0).toDouble(),
      gLiter: (json['Gliter'] ?? 0.0).toDouble(),
      gAmount: (json['GAmount'] ?? 0.0).toDouble(),
      dpLiter: (json['DPliter'] ?? 0.0).toDouble(),
      dpAmount: (json['DPAmount'] ?? 0.0).toDouble(),
      dgLiter: (json['DGliter'] ?? 0.0).toDouble(),
      dgAmount: (json['DGAmount'] ?? 0.0).toDouble(),
      comid: json['CompanyRefId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    String formattedDate = entryDate;
    try {
      if (entryDate.contains('/')) {
        final parts = entryDate.split('/');
        if (parts.length == 3) {
          formattedDate = "${parts[2]}-${parts[1]}-${parts[0]}T00:00:00.000";
        }
      }
    } catch (_) {}

    return {
      'Id': id,
      'CNumberDisplay': entryNo,
      'CNumber': 0,
      'SaleDate': formattedDate,
      'TruckRefid': truckId,
      'DriverRefId': driverId,
      'UserRefId': null,
      'EmployeeRefId': AppPreferences.getEmpRefId() == 0 ? null : AppPreferences.getEmpRefId(),
      'Remarks': remarks,
      'Aliter': aLiter,
      'AAmount': aAmount,
      'Pliter': pLiter,
      'PRate': pRate,
      'PAmount': pAmount,
      'Gliter': gLiter,
      'GAmount': gAmount,
      'DPliter': dpLiter,
      'DPAmount': dpAmount,
      'DGliter': dgLiter,
      'DGAmount': dgAmount,
      'CompanyRefId': comid,
    };
  }
}
