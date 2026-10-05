import 'package:maleva/core/utils/json_read.dart';

class AgentCompanyModel {
  int Id;
  String Name;
  int DFlag;
  int Active;

  AgentCompanyModel(this.Id, this.Name, this.DFlag, this.Active);

  /// An agent company of the shared Java `/api/agent-companies/company/{companyId}`.
  AgentCompanyModel.fromJava(Map<String, dynamic> json)
      : Id = JsonRead.integer(json['id']),
        Name = JsonRead.string(json['name']),
        DFlag = JsonRead.integer(JsonRead.field(json, 'dFlag')),
        Active = JsonRead.integer(json['active']);
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'Name': Name,
      'DFlag': DFlag,
      'Active': Active,
    };
  }

  AgentCompanyModel.Empty()
      : Id = 0,
        Name = '',
        DFlag = 0,
        Active = 0;
}