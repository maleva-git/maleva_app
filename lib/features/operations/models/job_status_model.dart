import 'package:maleva/core/utils/json_read.dart';

class JobStatusModel {
  int Id;
  String Name;
  int DFlag;
  int Svalue;
  int Active;

  JobStatusModel(this.Id, this.Name, this.DFlag, this.Svalue, this.Active);

  /// A status of the shared Java `/api/job-status-master/select/{companyId}/`.
  JobStatusModel.fromJava(Map<String, dynamic> json)
      : Id = JsonRead.integer(json['id']),
        Name = JsonRead.string(json['name']),
        DFlag = JsonRead.integer(JsonRead.field(json, 'dFlag')),
        Svalue = JsonRead.integer(json['svalue']),
        Active = JsonRead.integer(json['active']);

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'Name': Name,
      'DFlag': DFlag,
      'Svalue': Svalue,
      'Active': Active,
    };
  }

  JobStatusModel.Empty()
      : Id = 0,
        Name = '',
        DFlag = 0,
        Svalue = 0,
        Active = 0;
}