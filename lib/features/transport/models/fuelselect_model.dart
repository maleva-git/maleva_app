import 'package:intl/intl.dart';
import 'package:maleva/core/utils/json_read.dart';


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

  /// A row of the shared Java fuel list (`/api/fuel-entries`). The difference
  /// columns are the web's: patron minus actual (`DP`), and the server's patron
  /// minus GPS (`diffLiter` / `diffAmount`, the `DG` columns).
  factory FuelselectModel.fromJava(Map<String, dynamic> json) {
    dynamic f(String key) => JsonRead.field(json, key);
    double n(String key) => JsonRead.number(f(key));
    double round2(double v) => (v * 100).roundToDouble() / 100;
    final saleDate = JsonRead.date(f('saleDate'));
    final aliter = n('aliter');
    final pliter = n('pliter');
    return FuelselectModel(
      id: JsonRead.integer(f('id')),
      companyRefId: JsonRead.integer(f('companyRefId')),
      truckRefId: JsonRead.integer(f('truckRefId')),
      driverRefId: JsonRead.integer(f('driverRefId')),
      saleDate: saleDate == null ? '' : "${DateFormat('yyyy-MM-dd').format(saleDate)}T00:00:00",
      sSaleDate: saleDate == null ? '' : DateFormat('dd/MM/yyyy').format(saleDate),
      cNumberDisplay: JsonRead.string(f('cNumberDisplay')),
      cNumber: JsonRead.integer(f('cNumber')),
      remarks: JsonRead.string(f('remarks')),
      active: 1,
      fStatus: JsonRead.integer(f('fStatus')),
      aliter: aliter,
      aAmount: n('aAmount'),
      pliter: pliter,
      pRate: n('pRate'),
      pAmount: n('pAmount'),
      gliter: n('gliter'),
      gAmount: n('gAmount'),
      dPliter: round2(pliter - aliter),
      dPAmount: round2(n('pAmount') - aliter * n('pRate')),
      dGliter: n('diffLiter'),
      dGAmount: n('diffAmount'),
      filePath: JsonRead.string(f('filePath')),
      driverName: JsonRead.string(f('driverName')),
      truckName: JsonRead.string(f('truckName')),
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