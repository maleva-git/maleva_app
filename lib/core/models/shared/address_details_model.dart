import 'package:maleva/core/utils/json_read.dart';

class AddressDetailsModel {
  int Id;
  String Name;
  String Address;
  String Phone;
  int Active;

  AddressDetailsModel(
      this.Id, this.Name, this.Address, this.Phone, this.Active);

  /// An address of the shared Java `/api/addresses/company/{companyId}/search`.
  AddressDetailsModel.fromJava(Map<String, dynamic> json)
      : Id = JsonRead.integer(json['id']),
        Name = JsonRead.string(json['name']),
        Address = JsonRead.string(json['address']),
        Phone = JsonRead.string(json['phone']),
        Active = JsonRead.integer(json['active']);
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'Name': Name,
      'Address': Address,
      'Phone': Phone,
      'Active': Active
    };
  }

  AddressDetailsModel.Empty()
      : Id = 0,
        Name = '',
        Address = '',
        Phone = '',
        Active = 0;
}