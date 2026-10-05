import 'package:maleva/core/fleet/expiry_api.dart';
import 'package:maleva/core/utils/json_read.dart';

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

  /// A truck of the shared Java expiry list (`/api/master-reports/trucks/rows`),
  /// its dates written as .NET TruckReportView wrote them (`yyyy/MM/dd`).
  TruckDetailsModel.fromJavaExpiry(Map<String, dynamic> json)
      : Id = JsonRead.integer(json['id']),
        flag = 0,
        ExpDate = '',
        ExpApadBonam = '',
        FromDate = '',
        CompanyRefId = 0,
        CNumberDisplay = '',
        CNumber = 0,
        TruckName = '',
        TruckNumber = JsonRead.string(json['truckNumber']),
        TruckNumber1 = JsonRead.string(json['truckNumber1']),
        TruckType = JsonRead.string(json['vehicleType']),
        Latitude = '',
        longitude = '',
        Active = 1,
        Created_Date = '',
        Modified_Date = '',
        Modified_By = '',
        RotexMyExp = ExpiryApi.legacyDate(json['rotexMyExp']),
        RotexSGExp = ExpiryApi.legacyDate(json['rotexSGExp']),
        PuspacomExp = ExpiryApi.legacyDate(json['puspacomExp']),
        RotexMyExp1 = ExpiryApi.legacyDate(json['rotexMyExp1']),
        RotexSGExp1 = ExpiryApi.legacyDate(json['rotexSGExp1']),
        PuspacomExp1 = ExpiryApi.legacyDate(json['puspacomExp1']),
        InsuratnceExp = ExpiryApi.legacyDate(json['insuranceExp']),
        BonamExp = ExpiryApi.legacyDate(json['bonamExp']),
        ApadExp = ExpiryApi.legacyDate(json['apadExp']),
        ServiceExp = ExpiryApi.legacyDate(json['serviceExp']),
        AlignmentExp = ExpiryApi.legacyDate(json['alignmentExp']),
        GreeceExp = ExpiryApi.legacyDate(json['greaseExp']),
        AlignmentLast = ExpiryApi.legacyDate(json['alignmentLast']),
        GreeceLast = ExpiryApi.legacyDate(json['greaseLast']),
        GearOilLast = ExpiryApi.legacyDate(json['gearOilLast']),
        ServiceLast = ExpiryApi.legacyDate(json['serviceLast']),
        GearOilExp = ExpiryApi.legacyDate(json['gearOilExp']),
        PTPStickerExp = ExpiryApi.legacyDate(json['ptpStickerExp']),
        SIDExp = ExpiryApi.legacyDate(json['sidExp']);



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