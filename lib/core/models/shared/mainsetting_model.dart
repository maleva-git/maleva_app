import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class MainsettingModel {
  String VariableName;
  int Id;
  int CompanyRefid;

  int Status;

  String SValue;

  MainsettingModel(
      this.Id, this.CompanyRefid, this.VariableName, this.SValue, this.Status);
  MainsettingModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        CompanyRefid = int.tryParse(json['CompanyRefid']?.toString() ?? '') ?? 0,
        Status = (json['Status'].toString() == "1" ||
            json['Status'].toString() == "true")
            ? 1
            : 0,
        VariableName = json['VariableName'] ?? '',
        SValue = json['SValue'] ?? '';
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CompanyRefid': CompanyRefid,
      'VariableName': VariableName,
      'SValue': SValue,
      'Status': Status,
    };
  }
}