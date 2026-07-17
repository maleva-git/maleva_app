import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class BillOrderDetail {
  final int id;
  final int saleRefId;
  final String productCode;
  final String productName;
  final double mrp;
  final double saleRate;
  final double taxPercent;
  final double taxAmt;
  final double discountPercent;
  final double discountAmt;
  final double itemQty;
  final double sAmount;
  final double quoteValue;
  final String? RemarksD;
  final String serialNo;

  BillOrderDetail({
    required this.id,
    required this.saleRefId,
    required this.productCode,
    required this.productName,
    required this.mrp,
    required this.saleRate,
    required this.taxPercent,
    required this.taxAmt,
    required this.discountPercent,
    required this.discountAmt,
    required this.itemQty,
    required this.sAmount,
    required this.quoteValue,
    this.RemarksD,
    required this.serialNo,
  });

  factory BillOrderDetail.fromJson(Map<String, dynamic> json) {
    return BillOrderDetail(
      id: int.tryParse(json['Id']?.toString() ?? '') ?? 0,
      saleRefId: int.tryParse(json['SaleRefId']?.toString() ?? '') ?? 0,
      productCode: json['ProductCode']?.toString() ?? '',
      productName: json['ProductName']?.toString() ?? '',
      mrp: double.tryParse(json['MRP']?.toString() ?? '') ?? 0.0,
      saleRate: double.tryParse(json['SaleRate']?.toString() ?? '') ?? 0.0,
      taxPercent: double.tryParse(json['TaxPercent']?.toString() ?? '') ?? 0.0,
      taxAmt: double.tryParse(json['TaxAmt']?.toString() ?? '') ?? 0.0,
      discountPercent: double.tryParse(json['DiscountPercent']?.toString() ?? '') ?? 0.0,
      discountAmt: double.tryParse(json['DiscountAmt']?.toString() ?? '') ?? 0.0,
      itemQty: double.tryParse(json['ItemQty']?.toString() ?? '') ?? 0.0,
      sAmount: double.tryParse(json['SAmount']?.toString() ?? '') ?? 0.0,
      quoteValue: double.tryParse(json['QuoteValue']?.toString() ?? '') ?? 0.0,
      RemarksD: json['RemarksD']?.toString(),
      serialNo: json['SerialNo']?.toString() ?? '',
    );
  }
}