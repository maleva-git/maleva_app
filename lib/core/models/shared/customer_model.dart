import 'package:maleva/core/utils/json_read.dart';

class CustomerModel {
  int Id;
  String AccountName;
  String Password;

  CustomerModel(this.Id, this.AccountName, this.Password);

  /// A customer option of the shared Java `/api/customers/options`: the label
  /// (name with code) as the picker shows it.
  CustomerModel.fromJava(Map<String, dynamic> json)
      : Id = JsonRead.integer(json['id']),
        AccountName = JsonRead.string(json['label'] ?? json['customerName']),
        Password = '';
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'AccountName': AccountName,
      'Password': Password,
    };
  }

  CustomerModel.Empty()
      : Id = 0,
        AccountName = '',
        Password = '';
}