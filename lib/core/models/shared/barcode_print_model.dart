import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class BarcodePrintModel {
  String CompanyName_Data;
  String ShipName_Data;
  String ShipName_Data2;
  String Barcode_Data;
  String Date_Data;
  String Port_Data ;
  String JobNo_Data;
  String Pkg_Data ;


  BarcodePrintModel(this.CompanyName_Data,
      this.ShipName_Data,
      this.ShipName_Data2,
      this.Barcode_Data,
      this.Date_Data,
      this.Port_Data ,
      this.JobNo_Data,
      this.Pkg_Data ,
      );

  BarcodePrintModel.fromJson(Map<String, dynamic> json)
      :
        CompanyName_Data=json['CompanyName_Data'].toString(),
        ShipName_Data=json['ShipName_Data'].toString(),
        ShipName_Data2=json['ShipName_Data2'].toString(),
        Barcode_Data=json['Barcode_Data'].toString(),
        Date_Data=json['Date_Data'].toString(),
        Port_Data=json['Port_Data'].toString(),
        JobNo_Data=json['JobNo_Data'].toString(),
        Pkg_Data=json['Pkg_Data'].toString();


  // method
  Map<String, dynamic> toJson() {
    return {
      'CompanyName_Data': CompanyName_Data,
      'ShipName_Data': ShipName_Data,
      'ShipName_Data2': ShipName_Data2,
      'Barcode_Data': Barcode_Data,
      'Date_Data': Date_Data,
      'Port_Data ':Port_Data ,
      'JobNo_Data': JobNo_Data,
      'Pkg_Data ':Pkg_Data ,
    };
  }

  BarcodePrintModel.Empty()
      : CompanyName_Data = "",
        ShipName_Data = "",
        ShipName_Data2 = "",
        Barcode_Data = "",
        Date_Data = "",
        Port_Data ="",
        JobNo_Data = "",
        Pkg_Data ="";
}