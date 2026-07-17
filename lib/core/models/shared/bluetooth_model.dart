import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class BluetoothModel {
  int Id;
  String name;
  String devicename;
  String address;
  String name1;
  String address1;
  String printmodel;
  int type;
  bool connected;

  BluetoothModel(this.Id, this.name, this.address, this.type, this.connected,
      this.devicename, this.printmodel, this.name1, this.address1);

  BluetoothModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        name = json['name'].toString(),
        address = json['address'].toString(),
        type = int.tryParse(json['type']?.toString() ?? '') ?? 0,
        connected = (json['connected'].toString() == '1' ||
            json['connected'].toString() == 'true')
            ? true
            : false,
        devicename = json['devicename'].toString(),
        printmodel = json['printmodel'],
        name1 = json['name1'].toString(),
        address1 = json['address1'].toString();

  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'name': name,
      'address': address,
      'type': type,
      'connected': connected,
      'devicename': devicename,
      'printmodel': printmodel,
      'name1': name1,
      'address1': address1,
    };
  }

  BluetoothModel.Empty()
      : Id = 0,
        name = "",
        address = "",
        type = 0,
        connected =false,
        devicename="",
        printmodel="",
        name1="",
        address1="";


}