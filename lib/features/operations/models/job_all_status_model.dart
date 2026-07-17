import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class JobAllStatusModel {
  int ID;
  int JobMasterRefId;
  int Status;
  String StatusName;
  String MinStatusName;
  int MinStatus;
  int Sort;

  JobAllStatusModel(this.ID, this.JobMasterRefId, this.Status, this.StatusName,
      this.MinStatusName, this.MinStatus, this.Sort);

  JobAllStatusModel.fromJson(Map<String, dynamic> json)
      : ID = int.tryParse(json['ID']?.toString() ?? '') ?? 0,
        JobMasterRefId = int.tryParse(json['JobMasterRefId']?.toString() ?? '') ?? 0,
        Status = int.tryParse(json['Status']?.toString() ?? '') ?? 0,
        StatusName = json['StatusName'].toString(),
        MinStatusName = json['MinStatusName'].toString(),
        MinStatus = int.tryParse(json['MinStatus']?.toString() ?? '') ?? 0,
        Sort = int.tryParse(json['Sort']?.toString() ?? '') ?? 0;
  Map<String, dynamic> toJson() {
    return {
      'ID': ID,
      'JobMasterRefId': JobMasterRefId,
      'Status': Status,
      'StatusName': StatusName,
      'MinStatusName': MinStatusName,
      'MinStatus': MinStatus,
      'Sort': Sort,
    };
  }

  JobAllStatusModel.Empty()
      : ID = 0,
        JobMasterRefId = 0,
        Status = 0,
        StatusName = '',
        MinStatusName = '',
        MinStatus = 0,
        Sort = 0;
}