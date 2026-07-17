import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class TruckDetailsModel {
  int Id;
  int flag;
  String ExpDate;
  String ExpApadBonam;
  String FromDate;
  int CompanyRefId;
  String CNumberDisplay;
  int CNumber;
  String TruckName;
  String TruckNumber;
  String TruckNumber1;
  String TruckType;
  String Latitude;
  String longitude;
  int Active;
  String Created_Date;
  String Modified_Date;
  String Modified_By;
  String RotexMyExp;
  String RotexSGExp;
  String PuspacomExp;
  String RotexMyExp1;
  String RotexSGExp1;
  String PuspacomExp1;
  String InsuratnceExp;
  String BonamExp;
  String ApadExp;
  String ServiceExp;
  String AlignmentExp;
  String GreeceExp;
  String AlignmentLast;
  String GreeceLast;
  String GearOilLast;
  String ServiceLast;
  String GearOilExp;
  String PTPStickerExp;
  String SIDExp;

  TruckDetailsModel(
      this.Id,
      this.flag,
      this.ExpDate,
      this.ExpApadBonam,
      this.FromDate,
      this.CompanyRefId,
      this.CNumberDisplay,
      this.CNumber,
      this.TruckName,
      this.TruckNumber,
      this.TruckNumber1,
      this.TruckType,
      this.Latitude,
      this.longitude,
      this.Active,
      this.Created_Date,
      this.Modified_Date,
      this.Modified_By,
      this.RotexMyExp,
      this.RotexSGExp,
      this.PuspacomExp,
      this.RotexMyExp1,
      this.RotexSGExp1,
      this.PuspacomExp1,
      this.InsuratnceExp,
      this.BonamExp,
      this.ApadExp,
      this.ServiceExp,
      this.AlignmentExp,
      this.GreeceExp,
      this.AlignmentLast,
      this.GreeceLast,
      this.GearOilLast,
      this.ServiceLast,
      this.GearOilExp,
      this.PTPStickerExp,
      this.SIDExp
      );

  TruckDetailsModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        flag = json['flag'] == null ? 0 :int.tryParse(json['flag']?.toString() ?? '') ?? 0,
        ExpDate = json['ExpDate']== null ? "" :json['ExpDate'].toString(),
        ExpApadBonam = json['ExpApadBonam']== null ? "" :json['ExpApadBonam'].toString(),
        FromDate = json['FromDate'] == null ? "" : json['FromDate'].toString(),
        CompanyRefId = int.tryParse(json['CompanyRefId']?.toString() ?? '') ?? 0,
        CNumberDisplay = json['CNumberDisplay'].toString(),
        CNumber = json['CNumber'] == null ? 0 : int.tryParse(json['CNumber']?.toString() ?? '') ?? 0,
        TruckName = json['TruckName'] == null ? "" : json['TruckName'].toString(),
        TruckNumber = json['TruckNumber'].toString(),
        TruckNumber1 = json['TruckNumber1'].toString(),
        TruckType = json['TruckType'] == null ? "" : json['TruckType'].toString(),
        Latitude = json['Latitude'] == null ? "" : json['Latitude'].toString(),
        longitude = json['longitude'] == null ? "" : json['longitude'].toString(),
        Active = int.tryParse(json['Active']?.toString() ?? '') ?? 0,
        Created_Date = json['Created_Date'].toString(),
        Modified_Date = json['Modified_Date'].toString(),
        Modified_By = json['Modified_By'] == null ? "" : json['Modified_By'].toString(),
        RotexMyExp = json['RotexMyExp'].toString(),
        RotexSGExp = json['RotexSGExp'].toString(),
        PuspacomExp = json['PuspacomExp'].toString(),
        RotexMyExp1 = json['RotexMyExp1'].toString(),
        RotexSGExp1 = json['RotexSGExp1'].toString(),
        PuspacomExp1 = json['PuspacomExp1'].toString(),
        InsuratnceExp = json['InsuratnceExp'].toString(),
        BonamExp = json['BonamExp'].toString(),
        ApadExp = json['ApadExp'].toString(),
        ServiceExp = json['ServiceExp'].toString(),
        AlignmentExp = json['AlignmentExp'].toString(),
        GreeceExp = json['GreeceExp'].toString(),
        AlignmentLast = json['AlignmentLast'].toString() ,
        GreeceLast = json['GreeceLast'].toString() ,
        GearOilLast = json['GearOilLast'].toString() ,
        ServiceLast = json['ServiceLast'].toString() ,
        GearOilExp = json['GearOilExp'].toString() ,
        PTPStickerExp = json['PTPStickerExp'].toString() ,
        SIDExp = json['SIDExp'].toString() ;


  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'flag': flag,
      'ExpDate': ExpDate,
      'CNumber': CNumber,
      'ExpApadBonam': ExpApadBonam,
      'FromDate': FromDate,
      'CompanyRefId': CompanyRefId,
      'CNumberDisplay': CNumberDisplay,
      'CNumber': CNumber,
      'TruckName': TruckName,
      'TruckNumber': TruckNumber,
      'TruckNumber1': TruckNumber1,
      'TruckType': TruckType,
      'Latitude': Latitude,
      'longitude': longitude,
      'Active': Active,
      'Created_Date': Created_Date,
      'Modified_Date': Modified_Date,
      'Modified_By': Modified_By,
      'RotexMyExp': RotexMyExp,
      'RotexSGExp': RotexSGExp,
      'PuspacomExp': PuspacomExp,
      'RotexMyExp1': RotexMyExp1,
      'RotexSGExp1': RotexSGExp1,
      'PuspacomExp1': PuspacomExp1,
      'InsuratnceExp': InsuratnceExp,
      'BonamExp': BonamExp,
      'ApadExp': ApadExp,
      'ServiceExp': ServiceExp,
      'AlignmentExp': AlignmentExp,
      'GreeceExp': GreeceExp,
      'AlignmentLast': AlignmentLast,
      'GreeceLast': GreeceLast,
      'GearOilLast': GearOilLast,
      'ServiceLast': ServiceLast,
      'GearOilExp': GearOilExp,
      'PTPStickerExp': PTPStickerExp,
      'SIDExp': SIDExp,

    };
  }

  TruckDetailsModel.Empty()
      : Id = 0,
        flag = 0,
        ExpDate = '',
        ExpApadBonam = '',
        FromDate = '',
        CompanyRefId = 0,
        CNumberDisplay = '',
        CNumber = 0,
        TruckName = '',
        TruckNumber = '',
        TruckNumber1 = '',
        TruckType = '',
        Latitude = '',
        longitude = '',
        Active = 0,
        Created_Date = '',
        Modified_Date = '',
        Modified_By = '',
        RotexMyExp = '',
        RotexSGExp = '',
        PuspacomExp = '',
        RotexMyExp1 = '',
        RotexSGExp1 = '',
        PuspacomExp1 = '',
        InsuratnceExp = '',
        BonamExp = '',
        ApadExp = '',
        ServiceExp = '',
        AlignmentExp = '',
        GreeceExp = '',
        AlignmentLast = '',
        GreeceLast = '',
        GearOilLast = '',
        ServiceLast = '',
        GearOilExp = '',
        PTPStickerExp = '',
        SIDExp = '';
}