import 'package:maleva/core/utils/json_read.dart';


class EmployeeModel {
  int Id;
  String AccountName;
  String Password;

  EmployeeModel(this.Id, this.AccountName, this.Password);

  /// An employee of the shared Java list (`/api/employees/company/{id}/all`),
  /// shown as `Name-Type` like .NET's AccountName. The Java list never sends
  /// passwords.
  EmployeeModel.fromJava(Map<String, dynamic> json)
      : Id = JsonRead.integer(json['id']),
        AccountName = [JsonRead.string(json['employeeName']), JsonRead.string(json['employeeType'])]
            .where((s) => s.isNotEmpty)
            .join('-'),
        Password = '';

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'AccountName': AccountName,
      'Password': Password,
    };
  }

  EmployeeModel.Empty()
      : Id = 0,
        AccountName = '',
        Password = '';
}