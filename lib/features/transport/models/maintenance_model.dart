import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class MaintenanceModel {
  int Id;
  int PStatus;
  String SupplierName;
  String TruckNumber;
  String DriverName;
  String SDueDate;
  double Amount;
  String Description;

  MaintenanceModel(this.Id, this.PStatus,this.SupplierName,this.TruckNumber,this.DriverName, this.SDueDate, this.Amount, this.Description);

  MaintenanceModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id'].toString()) ?? 0,
        PStatus = int.tryParse(json['PStatus'].toString()) ?? 0,
        SupplierName = json['SupplierName']?.toString() ?? '',
        TruckNumber = json['TruckNumber']?.toString() ?? '',
        DriverName = json['DriverName']?.toString() ?? '',
        SDueDate = json['SDueDate']?.toString() ?? '',
        Amount = double.tryParse(json['Amount']?.toString() ?? '0') ?? 0.0,
        Description = json['Description']?.toString() ?? '';

  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'PStatus': PStatus,
      'SupplierName': SupplierName,
      'TruckNumber': TruckNumber,
      'DriverName': DriverName,
      'SDueDate': SDueDate,
      'Amount': Amount,
      'Description': Description,
    };
  }

  MaintenanceModel.Empty()
      : Id = 0,
        PStatus = 0,
        SupplierName = '',
        TruckNumber = '',
        DriverName = '',
        SDueDate = '',
        Amount = 0.0,
        Description = '';
}