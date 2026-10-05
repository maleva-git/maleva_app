import 'package:maleva/core/utils/json_read.dart';

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

  /// A step of a job type (shared Java select-all-data `jobTypeDetails`).
  JobTypeDetailsModel.fromJava(Map<String, dynamic> json)
      : ID = JsonRead.integer(json['id']),
        JobMasterRefId = JsonRead.integer(json['jobMasterRefId']),
        Description = JsonRead.string(json['description']),
        JobName = JsonRead.string(json['jobName']),
        StatusName = JsonRead.string(json['statusName']),
        Active = JsonRead.integer(json['active']),
        Mandatory = JsonRead.integer(json['mandatory']),
        Status = JsonRead.integer(json['status']);

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