import 'package:maleva/core/utils/json_read.dart';


class DriverDetailsModel {
  int Id;
  String DriverName;
  String licenseNo;
  String licenseExp;
  String ExpDate;

  DriverDetailsModel(this.Id, this.DriverName, this.licenseNo, this.licenseExp, this.ExpDate);

  /// A driver of the shared Java expiry list (`/api/master-reports/drivers/rows`).
  DriverDetailsModel.fromJava(Map<String, dynamic> json)
      : Id = JsonRead.integer(json['id']),
        DriverName = JsonRead.string(json['driverName']),
        licenseNo = JsonRead.string(json['licenseNo']),
        licenseExp = JsonRead.string(json['licenseExp']),
        ExpDate = '';

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'DriverName': DriverName,
      'licenseNo': licenseNo,
      'licenseExp': licenseExp,
      'ExpDate': ExpDate,
    };
  }

  DriverDetailsModel.Empty()
      : Id = 0,
        DriverName = '',
        licenseNo = '',
        licenseExp = '',
        ExpDate = '';
}