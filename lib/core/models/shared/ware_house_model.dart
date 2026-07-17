import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class WareHouseModel {
  int Id;
  String PortName;

  WareHouseModel(this.Id,this.PortName);

  WareHouseModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        PortName = json['PortName'].toString();
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'PortName': PortName,
    };
  }
  WareHouseModel.Empty()
      : Id = 0,
        PortName = '';
}