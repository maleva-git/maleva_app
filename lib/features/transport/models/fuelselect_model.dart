
class FuelselectModel {
  int? id;
  int? companyRefId;
  int? userRefId;
  int? employeeRefId;
  int? lastEmployeeRefId;
  int? truckRefId;
  int? driverRefId;
  String? saleDate;
  String? sSaleDate;
  String? cNumberDisplay;
  int? cNumber;
  String? remarks;
  int? active;
  int? fStatus;
  double? aliter;
  double? aAmount;
  double? pliter;
  double? pRate;
  double? pAmount;
  double? gliter;
  double? gAmount;
  double? dPliter;
  double? dPAmount;
  double? dGliter;
  double? dGAmount;
  String? filePath;
  String? createdDate;
  String? createdBy;
  String? modifiedDate;
  String? modifiedBy;
  String? driverName;
  String? truckName;

  FuelselectModel({
    this.id,
    this.companyRefId,
    this.userRefId,
    this.employeeRefId,
    this.lastEmployeeRefId,
    this.truckRefId,
    this.driverRefId,
    this.saleDate,
    this.sSaleDate,
    this.cNumberDisplay,
    this.cNumber,
    this.remarks,
    this.active,
    this.fStatus,
    this.aliter,
    this.aAmount,
    this.pliter,
    this.pRate,
    this.pAmount,
    this.gliter,
    this.gAmount,
    this.dPliter,
    this.dPAmount,
    this.dGliter,
    this.dGAmount,
    this.filePath,
    this.createdDate,
    this.createdBy,
    this.modifiedDate,
    this.modifiedBy,
    this.driverName,
    this.truckName,
  });

  factory FuelselectModel.fromJson(Map<String, dynamic> json) {
    return FuelselectModel(
      id: json['Id'] ?? 0,
      companyRefId: json['CompanyRefId'] ?? 0,
      userRefId: json['UserRefId'] ?? 0,
      employeeRefId: json['EmployeeRefId'] ?? 0,
      lastEmployeeRefId: json['LastEmployeeRefId'] ?? 0,
      truckRefId: json['TruckRefid'] ?? 0,
      driverRefId: json['DriverRefId'] ?? 0,
      saleDate: json['SaleDate'] ?? '',
      sSaleDate: json['SSaleDate'] ?? '',
      cNumberDisplay: json['CNumberDisplay'] ?? '',
      cNumber: json['CNumber'] ?? 0,
      remarks: json['Remarks'] ?? '',
      active: json['Active'] ?? 0,
      fStatus: json['FStatus'] ?? 0,
      aliter: (json['Aliter'] ?? 0).toDouble(),
      aAmount: (json['AAmount'] ?? 0).toDouble(),
      pliter: (json['Pliter'] ?? 0).toDouble(),
      pRate: (json['PRate'] ?? 0).toDouble(),
      pAmount: (json['PAmount'] ?? 0).toDouble(),
      gliter: (json['Gliter'] ?? 0).toDouble(),
      gAmount: (json['GAmount'] ?? 0).toDouble(),
      dPliter: (json['DPliter'] ?? 0).toDouble(),
      dPAmount: (json['DPAmount'] ?? 0).toDouble(),
      dGliter: (json['DGliter'] ?? 0).toDouble(),
      dGAmount: (json['DGAmount'] ?? 0).toDouble(),
      filePath: json['FilePath'] ?? '',
      createdDate: json['Created_Date'] ?? '',
      createdBy: json['Created_By'] ?? '',
      modifiedDate: json['Modified_Date'] ?? '',
      modifiedBy: json['Modified_By'] ?? '',
      driverName: json['DriverName'] ?? '',
      truckName: json['TruckName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'CompanyRefId': companyRefId,
      'UserRefId': userRefId,
      'EmployeeRefId': employeeRefId,
      'LastEmployeeRefId': lastEmployeeRefId,
      'TruckRefid': truckRefId,
      'DriverRefId': driverRefId,
      'SaleDate': saleDate,
      'SSaleDate': sSaleDate,
      'CNumberDisplay': cNumberDisplay,
      'CNumber': cNumber,
      'Remarks': remarks,
      'Active': active,
      'FStatus': fStatus,
      'Aliter': aliter,
      'AAmount': aAmount,
      'Pliter': pliter,
      'PRate': pRate,
      'PAmount': pAmount,
      'Gliter': gliter,
      'GAmount': gAmount,
      'DPliter': dPliter,
      'DPAmount': dPAmount,
      'DGliter': dGliter,
      'DGAmount': dGAmount,
      'FilePath': filePath,
      'Created_Date': createdDate,
      'Created_By': createdBy,
      'Modified_Date': modifiedDate,
      'Modified_By': modifiedBy,
      'DriverName': driverName,
      'TruckName': truckName,
    };
  }
}