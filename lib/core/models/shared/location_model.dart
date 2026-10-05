import 'package:maleva/core/utils/json_read.dart';

class LocationModel {
  int Id;
  int CompanyRefId;
  String Location;
  int Active;

  LocationModel(this.Id,this.CompanyRefId, this.Location, this.Active);

  /// A location of the shared Java `/api/location-master/company/{id}/active`.
  LocationModel.fromJava(Map<String, dynamic> json)
      : Id = JsonRead.integer(JsonRead.field(json, 'id')),
        CompanyRefId = JsonRead.integer(JsonRead.field(json, 'companyRefId')),
        Location = JsonRead.string(JsonRead.field(json, 'location')),
        Active = JsonRead.integer(JsonRead.field(json, 'active'));
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