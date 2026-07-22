
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

  AgentModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        CompanyRefId = int.tryParse(json['CompanyRefId']?.toString() ?? '') ?? 0,
        CNumberDisplay = json['CNumberDisplay'].toString(),
        CNumber = int.tryParse(json['CNumber']?.toString() ?? '') ?? 0,
        AgentName = json['AgentName'].toString(),
        Address1 = json['Address1'].toString(),
        AgentCompanyRefId = int.tryParse(json['AgentCompanyRefId']?.toString() ?? '') ?? 0,
        Email = json['Email'].toString(),
        MobileNo = json['MobileNo'].toString(),
        UserName = json['UserName'].toString(),
        Password = json['Password'].toString(),
        TokenId = json['TokenId'].toString(),
        SName = json['SName'].toString(),
        Active = int.tryParse(json['Active']?.toString() ?? '') ?? 0,
        Created_Date = json['Created_Date'].toString(),
        Modified_Date = json['Modified_Date'].toString(),
        Modified_By = json['Modified_By'].toString();

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