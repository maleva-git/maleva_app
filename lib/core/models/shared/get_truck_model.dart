import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class GetTruckModel {
  int Id;
  String AccountName;
  String Password;

  GetTruckModel(this.Id, this.AccountName, this.Password);

  GetTruckModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        AccountName = json['AccountName'].toString(),
        Password = json['Password'] == null ? '' : json['Password'].toString();
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