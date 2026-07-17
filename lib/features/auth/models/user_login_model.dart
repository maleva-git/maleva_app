import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class UserLoginModel {
  int Id;
  String UserName;
  int roleId;
  int permissionId;

  UserLoginModel(this.Id, this.UserName, this.roleId, this.permissionId);

  UserLoginModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        UserName = json['UserName']?.toString() ?? '',
        roleId = int.tryParse(json['role_id']?.toString() ?? '') ?? 0,
        permissionId = int.tryParse(json['PermisionId']?.toString() ?? '') ?? 0;
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'AccountName': UserName,
      'role_id': roleId,
      'PermisionId': permissionId,
    };
  }
}