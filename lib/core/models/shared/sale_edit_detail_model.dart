import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class SaleEditDetailModel {
  int Id;
  int SDId;
  int SaleOrderMasterRefId;
  int ItemMasterRefId;
  double MRP;
  double PurchaseRate;
  double ItemQty;
  double DiscPer;
  double DiscAmount;
  double LandingCost;
  double TaxPercent;
  double TaxAmount;
  double SalesRate;
  double NetSalesRate;
  double Amount;
  String ProductCode;
  String ProductName;
  String UOM;
  double ActualAmount;
  double CurrencyValue;

  SaleEditDetailModel(
      this.Id,
      this.SDId,
      this.SaleOrderMasterRefId,
      this.ItemMasterRefId,
      this.MRP,
      this.PurchaseRate,
      this.ItemQty,
      this.DiscPer,
      this.DiscAmount,
      this.LandingCost,
      this.TaxPercent,
      this.TaxAmount,
      this.SalesRate,
      this.NetSalesRate,
      this.Amount,
      this.ProductCode,
      this.ProductName,
      this.UOM,
      this.ActualAmount,
      this.CurrencyValue);

  SaleEditDetailModel.fromJson(Map<String, dynamic> json)
      : Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        SDId = int.tryParse(json['SDId']?.toString() ?? '') ?? 0,
        SaleOrderMasterRefId =
            int.tryParse(json['SaleOrderMasterRefId']?.toString() ?? '') ?? 0,
        ItemMasterRefId = int.tryParse(json['ItemMasterRefId']?.toString() ?? '') ?? 0,
        MRP = double.parse(json['MRP'].toString()),
        PurchaseRate = double.parse(json['PurchaseRate'].toString()),
        ItemQty = double.parse(json['ItemQty'].toString()),
        DiscPer = double.parse(json['DiscPer'].toString()),
        DiscAmount = double.parse(json['DiscAmount'].toString()),
        LandingCost = double.parse(json['LandingCost'].toString()),
        TaxPercent = double.parse(json['TaxPercent'].toString()),
        TaxAmount = double.parse(json['TaxAmount'].toString()),
        SalesRate = double.parse(json['SalesRate'].toString()),
        NetSalesRate = double.parse(json['NetSalesRate'].toString()),
        Amount = double.parse(json['Amount'].toString()),
        ProductCode = json['ProductCode'] ?? '',
        ProductName = json['ProductName'] ?? '',
        UOM = json['UOM'] ?? '',
        ActualAmount = double.parse(json['ActualAmount'].toString()),
        CurrencyValue = double.parse(json['CurrencyValue'].toString());

  // method
  Map<String, dynamic> toJson() {
    return {
      'Id': Id,
      'SDId': SDId,
      'SaleOrderMasterRefId': SaleOrderMasterRefId,
      'ItemMasterRefId': ItemMasterRefId,
      'MRP': MRP,
      'PurchaseRate': PurchaseRate,
      'ItemQty': ItemQty,
      'DiscPer': DiscPer,
      'DiscAmount': DiscAmount,
      'LandingCost': LandingCost,
      'TaxPercent': TaxPercent,
      'TaxAmount': TaxAmount,
      'SalesRate': SalesRate,
      'NetSalesRate': NetSalesRate,
      'Amount': Amount,
      'ProductCode': ProductCode,
      'ProductName': ProductName,
      'UOM': UOM,
      'ActualAmount': ActualAmount,
      'CurrencyValue': CurrencyValue,
    };
  }

  SaleEditDetailModel.Empty()
      : Id = 0,
        SDId = 0,
        SaleOrderMasterRefId = 0,
        ItemMasterRefId = 0,
        MRP = 0.0,
        PurchaseRate = 0.0,
        ItemQty = 0.0,
        DiscPer = 0.0,
        DiscAmount = 0.0,
        LandingCost = 0.0,
        TaxPercent = 0.0,
        TaxAmount = 0.0,
        SalesRate = 0.0,
        NetSalesRate = 0.0,
        Amount = 0.0,
        ProductCode = '',
        ProductName = '',
        UOM = '',
        ActualAmount = 0.0,
        CurrencyValue = 0.0;
}