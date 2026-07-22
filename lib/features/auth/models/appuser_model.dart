
class AppuserModel {
  String Username;
  int Id;
  int CompanyRefid;
  String Priv;
  String Password;

  AppuserModel(
      this.Id, this.CompanyRefid, this.Username, this.Password, this.Priv);
  AppuserModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        CompanyRefid = int.tryParse(json['CompanyRefid']?.toString() ?? '') ?? 0,
        Priv = json['Priv'] ?? '',
        Username = json['Username'] ?? '',
        Password = json['Password'] ?? '';
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CompanyRefid': CompanyRefid,
      'Username': Username,
      'Password': Password,
      'Priv': Priv,
    };
  }
}