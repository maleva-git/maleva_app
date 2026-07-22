
class DriverDetailsModel {
  int Id;
  String DriverName;
  String licenseNo;
  String licenseExp;
  String ExpDate;

  DriverDetailsModel(this.Id, this.DriverName, this.licenseNo, this.licenseExp, this.ExpDate);

  DriverDetailsModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id'].toString()) ?? 0,
        DriverName = json['DriverName']?.toString() ?? '',
        licenseNo = json['licenseNo']?.toString() ?? '',
        licenseExp = json['licenseExp']?.toString() ?? '',
        ExpDate = json['ExpDate']?.toString() ?? '';

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