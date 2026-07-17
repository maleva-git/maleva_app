import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class DriverViewModel {
  String DriverName;
  String Address1;
  String Address2;
  String City;
  int Active;
  String State;
  String Zipcode;
  String Country;
  String GSTNO;
  String Email;
  String MobileNo;
  String UserName;
  String Password;
  String DocumentType;
  String Latitude;
  String Longitude;
  String TokenId;
  String LicenseNo;
  String licenseExp;
  String GDLNo;
  String GDLExp;
  String KuantanPort;
  String NorthportPort;
  String PkfzPort;
  String KliaPort;
  String PguPort;
  String TanjungPort;
  String PenangPort;
  String PtpPort;
  String WestportPort;
  String JoiningDate;
  String LeavingDate;
  String TinNo;
  String SSTNo;
  String MsicCode;
  String ServiceTaxType;
  String KuantanPortStatus;
  String NorthportPortStatus;
  String PkfzPortStatus;
  String KliaPortStatus;
  String PguPortStatus;
  String TanjungPortStatus;
  String PenangPortStatus;
  String PtpPortStatus;
  String WestportPortStatus;

  DriverViewModel(
      this.DriverName,
      this.Address1,
      this.Address2,
      this.City,
      this.Active,
      this.State,
      this.Zipcode,
      this.Country,
      this.GSTNO,
      this.Email,
      this.MobileNo,
      this.UserName,
      this.Password,
      this.DocumentType,
      this.Latitude,
      this.Longitude,
      this.TokenId,
      this.LicenseNo,
      this.licenseExp,
      this.GDLNo,
      this.GDLExp,
      this.KuantanPort,
      this.NorthportPort,
      this.PkfzPort,
      this.KliaPort,
      this.PguPort,
      this.TanjungPort,
      this.PenangPort,
      this.PtpPort,
      this.WestportPort,
      this.JoiningDate,
      this.LeavingDate,
      this.TinNo,
      this.SSTNo,
      this.MsicCode,
      this.ServiceTaxType,
      this.KuantanPortStatus,
      this.NorthportPortStatus,
      this.PkfzPortStatus,
      this.KliaPortStatus,
      this.PguPortStatus,
      this.TanjungPortStatus,
      this.PenangPortStatus,
      this.PtpPortStatus,
      this.WestportPortStatus,
      );

  DriverViewModel.fromJson(Map<String, dynamic> json)
      : DriverName = json['DriverName'] ?? "",
        Address1 = json['Address1'] ?? "",
        Address2 = json['Address2'] ?? "",
        City = json['City'] ?? "",
        Active = json['Active'] ?? 0,
        State = json['State'] ?? "",
        Zipcode = json['Zipcode'] ?? "",
        Country = json['Country'] ?? "",
        GSTNO = json['GSTNO'] ?? "",
        Email = json['Email'] ?? "",
        MobileNo = json['MobileNo'] ?? "",
        UserName = json['UserName'] ?? "",
        Password = json['Password'] ?? "",
        DocumentType = json['DocumentType'] ?? "",
        Latitude = json['Latitude'] ?? "",
        Longitude = json['Longitude'] ?? "",
        TokenId = json['TokenId'] ?? "",
        LicenseNo = json['LicenseNo'] ?? "",
        licenseExp = json['licenseExp'] ?? "",
        GDLNo = json['GDLNo'] ?? "",
        GDLExp = json['GDLExp'] ?? "",
        KuantanPort = json['KuantanPort'] ?? "",
        NorthportPort = json['NorthportPort'] ?? "",
        PkfzPort = json['PkfzPort'] ?? "",
        KliaPort = json['KliaPort'] ?? "",
        PguPort = json['PguPort'] ?? "",
        TanjungPort = json['TanjungPort'] ?? "",
        PenangPort = json['PenangPort'] ?? "",
        PtpPort = json['PtpPort'] ?? "",
        WestportPort = json['WestportPort'] ?? "",
        JoiningDate = json['JoiningDate'] ?? "",
        LeavingDate = json['LeavingDate'] ?? "",
        TinNo = json['TinNo'] ?? "",
        SSTNo = json['SSTNo'] ?? "",
        MsicCode = json['MsicCode'] ?? "",
        ServiceTaxType = json['ServiceTaxType'] ?? "",
        KuantanPortStatus = json['KuantanPortStatus'] ?? "",
        NorthportPortStatus = json['NorthportPortStatus'] ?? "",
        PkfzPortStatus = json['PkfzPortStatus'] ?? "",
        KliaPortStatus = json['KliaPortStatus'] ?? "",
        PguPortStatus = json['PguPortStatus'] ?? "",
        TanjungPortStatus = json['TanjungPortStatus'] ?? "",
        PenangPortStatus = json['PenangPortStatus'] ?? "",
        PtpPortStatus = json['PtpPortStatus'] ?? "",
        WestportPortStatus = json['WestportPortStatus'] ?? "";

  Map<String, dynamic> toJson() {
    return {
      'DriverName': DriverName,
      'Address1': Address1,
      'Address2': Address2,
      'City': City,
      'State': State,
      'Active': Active,
      'Zipcode': Zipcode,
      'Country': Country,
      'GSTNO': GSTNO,
      'Email': Email,
      'MobileNo': MobileNo,
      'UserName': UserName,
      'Password': Password,
      'DocumentType': DocumentType,
      'Latitude': Latitude,
      'Longitude': Longitude,
      'TokenId': TokenId,
      'LicenseNo': LicenseNo,
      'licenseExp': licenseExp,
      'GDLNo': GDLNo,
      'GDLExp': GDLExp,
      'KuantanPort': KuantanPort,
      'NorthportPort': NorthportPort,
      'PkfzPort': PkfzPort,
      'KliaPort': KliaPort,
      'PguPort': PguPort,
      'TanjungPort': TanjungPort,
      'PenangPort': PenangPort,
      'PtpPort': PtpPort,
      'WestportPort': WestportPort,
      'JoiningDate': JoiningDate,
      'LeavingDate': LeavingDate,
      'TinNo': TinNo,
      'SSTNo': SSTNo,
      'MsicCode': MsicCode,
      'ServiceTaxType': ServiceTaxType,
      'KuantanPortStatus': KuantanPortStatus,
      'NorthportPortStatus': NorthportPortStatus,
      'PkfzPortStatus': PkfzPortStatus,
      'KliaPortStatus': KliaPortStatus,
      'PguPortStatus': PguPortStatus,
      'TanjungPortStatus': TanjungPortStatus,
      'PenangPortStatus': PenangPortStatus,
      'PtpPortStatus': PtpPortStatus,
      'WestportPortStatus': WestportPortStatus,
    };
  }

  DriverViewModel.Empty()
      : DriverName = "",
        Address1 = "",
        Address2 = "",
        City = "",
        State = "",
        Active = 0,
        Zipcode = "",
        Country = "",
        GSTNO = "",
        Email = "",
        MobileNo = "",
        UserName = "",
        Password = "",
        DocumentType = "",
        Latitude = "",
        Longitude = "",
        TokenId = "",
        LicenseNo = "",
        licenseExp = "",
        GDLNo = "",
        GDLExp = "",
        KuantanPort = "",
        NorthportPort = "",
        PkfzPort = "",
        KliaPort = "",
        PguPort = "",
        TanjungPort = "",
        PenangPort = "",
        PtpPort = "",
        WestportPort = "",
        JoiningDate = "",
        LeavingDate = "",
        TinNo = "",
        SSTNo = "",
        MsicCode = "",
        ServiceTaxType = "",
        KuantanPortStatus = "",
        NorthportPortStatus = "",
        PkfzPortStatus = "",
        KliaPortStatus = "",
        PguPortStatus = "",
        TanjungPortStatus = "",
        PenangPortStatus = "",
        PtpPortStatus = "",
        WestportPortStatus = "";
}