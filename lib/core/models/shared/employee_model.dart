import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

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