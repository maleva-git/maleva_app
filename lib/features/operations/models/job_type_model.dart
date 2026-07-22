
class JobTypeModel {
  int Id;
  String Name;
  int DFlag;
  int Active;

  JobTypeModel(this.Id, this.Name, this.DFlag, this.Active);

  JobTypeModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        Name = json['Name'].toString(),
        DFlag = int.tryParse(json['DFlag']?.toString() ?? '') ?? 0,
        Active = int.tryParse(json['Active']?.toString() ?? '') ?? 0;
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'Name': Name,
      'DFlag': DFlag,
      'Active': Active,
    };
  }

  JobTypeModel.Empty()
      : Id = 0,
        Name = '',
        DFlag = 0,
        Active = 0;
}