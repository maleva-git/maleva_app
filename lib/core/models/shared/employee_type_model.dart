import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class EmployeeTypeModel {
  int Id;
  String CustomerName;

  EmployeeTypeModel(this.Id, this.CustomerName);

  EmployeeTypeModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '0') ?? 0,
        CustomerName = json['CustomerName'].toString();

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CustomerName': CustomerName,
    };
  }

  EmployeeTypeModel.Empty()
      : Id = 0,
        CustomerName = '';
}