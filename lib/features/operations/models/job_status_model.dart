
class JobStatusModel {
  int Id;
  String Name;
  int DFlag;
  int Svalue;
  int Active;

  JobStatusModel(this.Id, this.Name, this.DFlag, this.Svalue, this.Active);

  JobStatusModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        Name = json['Name'].toString(),
        DFlag = int.tryParse(json['DFlag']?.toString() ?? '') ?? 0,
        Svalue = int.tryParse(json['Svalue']?.toString() ?? '') ?? 0,
        Active = int.tryParse(json['Active']?.toString() ?? '') ?? 0;
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