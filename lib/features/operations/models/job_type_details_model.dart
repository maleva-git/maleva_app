import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class JobTypeDetailsModel {
  int ID;
  int JobMasterRefId;
  String Description;
  String JobName;
  String StatusName;
  int Active;
  int Mandatory;
  int Status;

  JobTypeDetailsModel(this.ID, this.JobMasterRefId, this.Description,
      this.JobName, this.StatusName, this.Active, this.Mandatory, this.Status);

  JobTypeDetailsModel.fromJson(Map<String, dynamic> json)
      : ID = int.tryParse(json['ID']?.toString() ?? '') ?? 0,
        JobMasterRefId = int.tryParse(json['JobMasterRefId']?.toString() ?? '') ?? 0,
        Description = json['Description'].toString(),
        JobName = json['JobName'].toString(),
        StatusName = json['StatusName'].toString(),
        Active = int.tryParse(json['Active']?.toString() ?? '') ?? 0,
        Mandatory = int.tryParse(json['Mandatory']?.toString() ?? '') ?? 0,
        Status = int.tryParse(json['Status']?.toString() ?? '') ?? 0;
  Map<String, dynamic> toJson() {
    return {
      'ID': ID,
      'JobMasterRefId': JobMasterRefId,
      'Description': Description,
      'JobName': JobName,
      'StatusName': StatusName,
      'Active': Active,
      'Mandatory': Mandatory,
      'Status': Status
    };
  }

  JobTypeDetailsModel.Empty()
      : ID = 0,
        JobMasterRefId = 0,
        Description = '',
        JobName = '',
        StatusName = '',
        Active = 0,
        Mandatory = 0,
        Status = 0;
}