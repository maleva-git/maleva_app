import 'package:maleva/core/utils/json_read.dart';

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

  /// A row of a job type's status order (shared Java select-all-data `jobStatusDetails`).
  JobAllStatusModel.fromJava(Map<String, dynamic> json)
      : ID = JsonRead.integer(json['id']),
        JobMasterRefId = JsonRead.integer(json['jobMasterRefId']),
        Status = JsonRead.integer(json['status']),
        StatusName = JsonRead.string(json['statusName']),
        MinStatusName = JsonRead.string(json['minStatusName']),
        MinStatus = JsonRead.integer(json['minStatus']),
        Sort = JsonRead.integer(json['sort']);

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