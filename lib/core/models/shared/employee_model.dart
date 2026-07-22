
class EmployeeModel {
  int Id;
  String AccountName;
  String Password;

  EmployeeModel(this.Id, this.AccountName, this.Password);

  EmployeeModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        AccountName = json['AccountName'].toString(),
        Password = json['Password'].toString();
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