import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class CompanyModel {
  int Id;
  int ParentId;
  int CCode;
  String CompanyName;
  int CStatus;
  int Active;
  String Address1;
  String Address2;
  String City;
  String Pincode;
  String MobileNo;
  String GSTinNo;
  String Email;
  String Website;
  String Landmark;
  String FooterMsg1;
  String FooterMsg2;
  String TopSolgan1;
  String TopSolgan2;
  String TaxType;
  String BillNoType;
  String BillPerfix;
  String TCompanyName;
  String TAddress1;
  String TAddress2;
  String TCity;
  int productauto;
  String screentype;

  CompanyModel(
      this.Id,
      this.ParentId,
      this.CCode,
      this.CompanyName,
      this.CStatus,
      this.Active,
      this.Address1,
      this.Address2,
      this.City,
      this.Pincode,
      this.MobileNo,
      this.GSTinNo,
      this.Email,
      this.Website,
      this.Landmark,
      this.FooterMsg1,
      this.FooterMsg2,
      this.TopSolgan1,
      this.TopSolgan2,
      this.TaxType,
      this.BillNoType,
      this.BillPerfix,
      this.TCompanyName,
      this.TAddress1,
      this.TAddress2,
      this.TCity,
      this.productauto,
      this.screentype);

  CompanyModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        ParentId = int.tryParse(json['ParentId']?.toString() ?? '') ?? 0,
        CCode = int.tryParse(json['CCode']?.toString() ?? '') ?? 0,
        CompanyName = json['CompanyName'] ?? '',
        CStatus = (json['CStatus'].toString() == "1" ||
            json['CStatus'].toString() == "true")
            ? 1
            : 0,
        Active = int.tryParse(json['Active']?.toString() ?? '') ?? 0,
        Address1 = json['Address1'] ?? '',
        Address2 = json['Address2'] ?? '',
        City = json['City'] ?? '',
        Pincode = json['Pincode'] ?? '',
        MobileNo = json['MobileNo'] ?? '',
        GSTinNo = json['GSTinNo'] ?? '',
        Email = json['Email'] ?? '',
        Website = json['Website'] ?? '',
        Landmark = json['Landmark'] ?? '',
        FooterMsg1 = json['FooterMsg1'] ?? '',
        FooterMsg2 = json['FooterMsg2'] ?? '',
        TopSolgan1 = json['TopSolgan1'] ?? '',
        TopSolgan2 = json['TopSolgan2'] ?? '',
        TaxType = json['TaxType'] ?? '',
        BillNoType = json['BillNoType'],
        BillPerfix = json['BillPerfix'] ?? '',
        TCompanyName = json['TCompanyName'] ?? '',
        TAddress1 = json['TAddress1'] ?? '',
        TAddress2 = json['TAddress2'] ?? '',
        TCity = json['TCity'] ?? '',
        productauto = int.tryParse(json['productauto']?.toString() ?? '') ?? 0,
        screentype = json['screentype'] ?? '';
  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'ParentId': ParentId,
      'CCode': CCode,
      'CompanyName': CompanyName,
      'CStatus': CStatus,
      'Active': Active,
      'Address1': Address1,
      'Address2': Address2,
      'City': City,
      'Pincode': Pincode,
      'MobileNo': MobileNo,
      'GSTinNo': GSTinNo,
      'Email': Email,
      'Website': Website,
      'Landmark': Landmark,
      'FooterMsg1': FooterMsg2,
      'FooterMsg2': FooterMsg2,
      'TopSolgan1': TopSolgan1,
      'TopSolgan2': TopSolgan2,
      'TaxType': TaxType,
      'BillNoType': BillNoType,
      'BillPerfix': BillPerfix,
      'TCompanyName': TCompanyName,
      'TAddress1': TAddress1,
      'TAddress2': TAddress2,
      'TCity': TCity,
      'productauto': productauto,
      'screentype': screentype,
    };
  }
}