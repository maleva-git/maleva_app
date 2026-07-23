
class LocationModel {
  int Id;
  int CompanyRefId;
  String Location;
  int Active;

  LocationModel(this.Id,this.CompanyRefId, this.Location, this.Active);

  LocationModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        CompanyRefId = int.tryParse(json['CompanyRefId']?.toString() ?? '') ?? 0,
        Location = json['Location'].toString(),
        Active = int.tryParse(json['Active']?.toString() ?? '') ?? 0;
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'CompanyRefId': CompanyRefId,
      'Location': Location,
      'Active': Active,
    };
  }

  LocationModel.Empty()
      : Id = 0,
        CompanyRefId =0,
        Location = '',
        Active = 0;
}