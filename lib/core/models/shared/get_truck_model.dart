import 'package:maleva/core/utils/json_read.dart';

class GetTruckModel {
  int Id;
  String AccountName;
  String Password;

  GetTruckModel(this.Id, this.AccountName, this.Password);

  /// A combo row of the shared Java `/api/truck-combo` / `/api/driver-combo`
  /// (the Java model writes `Id` and `AccountName`). The password is never read.
  GetTruckModel.fromJava(Map<String, dynamic> json)
      : Id = JsonRead.integer(json['Id']),
        AccountName = JsonRead.string(json['AccountName']),
        Password = '';

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'AccountName': AccountName,
      'Password': Password,
    };
  }
  GetTruckModel.Empty()
      : Id = 0,
        AccountName = '',
        Password = '';

}