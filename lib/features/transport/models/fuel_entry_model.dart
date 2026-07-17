import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class FuelEntryModel {
  int Id;
  int CompanyRefId;
  double Aliter;
  double AAmount;
  String SSaleDate;


  FuelEntryModel(this.Id,
      this.CompanyRefId,
      this.Aliter,
      this.AAmount,
      this.SSaleDate,);

  FuelEntryModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        CompanyRefId = int.tryParse(json['CompanyRefId']?.toString() ?? '') ?? 0,
        AAmount = double.parse(json['AAmount'].toString()),
        Aliter = double.parse(json['Aliter'].toString()),
        SSaleDate=json['SSaleDate'].toString();

  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CompanyRefId': CompanyRefId,
      'Aliter': Aliter,
      'AAmount': AAmount,
      'SSaleDate':SSaleDate,
    };
  }

  FuelEntryModel.Empty()
      : Id = 0,
        CompanyRefId = 0,
        Aliter = 0,
        AAmount = 0,
        SSaleDate='';
}