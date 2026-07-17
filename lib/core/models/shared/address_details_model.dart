import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class AddressDetailsModel {
  int Id;
  String Name;
  String Address;
  String Phone;
  int Active;

  AddressDetailsModel(
      this.Id, this.Name, this.Address, this.Phone, this.Active);

  AddressDetailsModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        Name = json['Name'] ?? '',
        Address = json['Address'] ?? '',
        Phone = json['Phone'] ?? '',
        Active = int.tryParse(json['Active']?.toString() ?? '') ?? 0;
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'Name': Name,
      'Address': Address,
      'Phone': Phone,
      'Active': Active
    };
  }

  AddressDetailsModel.Empty()
      : Id = 0,
        Name = '',
        Address = '',
        Phone = '',
        Active = 0;
}