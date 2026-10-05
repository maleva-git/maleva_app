import 'package:maleva/core/utils/json_read.dart';

class AgentModel {
  int Id;
  int CompanyRefId;
  String CNumberDisplay;
  int CNumber;
  String AgentName;
  String Address1;
  int AgentCompanyRefId;
  String Email;
  String MobileNo;
  String UserName;
  String Password;
  String TokenId;
  String SName;
  int Active;
  String Created_Date;
  String Modified_Date;
  String Modified_By;

  AgentModel(
      this.Id,
      this.CompanyRefId,
      this.CNumberDisplay,
      this.CNumber,
      this.AgentName,
      this.Address1,
      this.AgentCompanyRefId,
      this.Email,
      this.MobileNo,
      this.UserName,
      this.Password,
      this.TokenId,
      this.SName,
      this.Active,
      this.Created_Date,
      this.Modified_Date,
      this.Modified_By);

  /// An agent of the shared Java `/api/agents/select-all`.
  AgentModel.fromJava(Map<String, dynamic> json)
      : Id = JsonRead.integer(json['id']),
        CompanyRefId = JsonRead.integer(json['companyRefId']),
        CNumberDisplay = JsonRead.string(JsonRead.field(json, 'cNumberDisplay')),
        CNumber = JsonRead.integer(JsonRead.field(json, 'cNumber')),
        AgentName = JsonRead.string(JsonRead.field(json, 'name')),
        Address1 = JsonRead.string(json['address1']),
        AgentCompanyRefId = JsonRead.integer(json['agentCompanyRefId']),
        Email = JsonRead.string(json['email']),
        MobileNo = JsonRead.string(json['mobileNo']),
        UserName = JsonRead.string(json['userName']),
        Password = '',
        TokenId = '',
        SName = '',
        Active = JsonRead.integer(json['active']),
        Created_Date = JsonRead.string(json['createdDate']),
        Modified_Date = JsonRead.string(json['modifiedDate']),
        Modified_By = JsonRead.string(json['modifiedBy']);

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CompanyRefId': CompanyRefId,
      'CNumberDisplay': CNumberDisplay,
      'CNumber': CNumber,
      'AgentName': AgentName,
      'Address1': Address1,
      'AgentCompanyRefId': AgentCompanyRefId,
      'Email': Email,
      'MobileNo': MobileNo,
      'UserName': UserName,
      'Password': Password,
      'TokenId': TokenId,
      'SName': SName,
      'Active': Active,
      'Created_Date': Created_Date,
      'Modified_Date': Modified_Date,
      'Modified_By': Modified_By,
    };
  }

  AgentModel.Empty()
      : Id = 0,
        CompanyRefId = 0,
        CNumberDisplay = '',
        CNumber = 0,
        AgentName = '',
        Address1 = '',
        AgentCompanyRefId = 0,
        Email = '',
        MobileNo = '',
        UserName = '',
        Password = '',
        TokenId = '',
        SName = '',
        Active = 0,
        Created_Date = '',
        Modified_Date = '',
        Modified_By = '';
}