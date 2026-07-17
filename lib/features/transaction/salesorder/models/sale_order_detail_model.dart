import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class SaleOrderDetailModel {
  int Id;
  int SaleRefId;
  String ProductCode;
  String ProductName;
  double MRP;
  double SaleRate;
  double TaxPercent;
  double TaxAmt;
  double DiscountPercent;
  double DiscountAmt;
  double ItemQty;
  double SAmount;
  SaleOrderDetailModel(
      this.Id,
      this.SaleRefId,
      this.ProductCode,
      this.ProductName,
      this.MRP,
      this.SaleRate,
      this.TaxPercent,
      this.TaxAmt,
      this.DiscountPercent,
      this.DiscountAmt,
      this.ItemQty,
      this.SAmount);

  SaleOrderDetailModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        SaleRefId = int.tryParse(json['SaleRefId']?.toString() ?? '') ?? 0,
        ProductCode = json['ProductCode'] ?? '',
        ProductName = json['ProductName'] ?? '',
        MRP = double.parse(json['MRP'].toString()),
        SaleRate = double.parse(json['SaleRate'].toString()),
        TaxPercent = double.parse(json['TaxPercent'].toString()),
        TaxAmt = double.parse(json['TaxAmt'].toString()),
        DiscountPercent = double.parse(json['DiscountPercent'].toString()),
        DiscountAmt = double.parse(json['DiscountAmt'].toString()),
        ItemQty = double.parse(json['ItemQty'].toString()),
        SAmount = double.parse(json['SAmount'].toString());

  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'SaleRefId': SaleRefId,
      'ProductCode': ProductCode,
      'ProductName': ProductName,
      'MRP': MRP,
      'SaleRate': SaleRate,
      'TaxPercent': TaxPercent,
      'TaxAmt': TaxAmt,
      'DiscountPercent': DiscountPercent,
      'DiscountAmt': DiscountAmt,
      'ItemQty': ItemQty,
      'SAmount': SAmount,
    };
  }

  SaleOrderDetailModel.Empty()
      : Id = 0,
        SaleRefId = 0,
        ProductCode = '',
        ProductName = '',
        MRP = 0.0,
        SaleRate = 0.0,
        TaxPercent = 0.0,
        TaxAmt = 0.0,
        DiscountPercent = 0.0,
        DiscountAmt = 0.0,
        ItemQty = 0.0,
        SAmount = 0.0;
}