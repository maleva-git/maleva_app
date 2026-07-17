import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ProductViewModel {
  String ProductName;
  String Productcode;
  double SaleRate;
  double GST;
  int Qty;
  double Amount;
  ProductViewModel(this.ProductName, this.Productcode, this.SaleRate, this.GST,
      this.Qty, this.Amount);
  ProductViewModel.fromJson(Map<String, dynamic> json)
      : ProductName = json['ProductName'].toString(),
        Productcode = json['Productcode'].toString(),
        SaleRate = double.parse(json['SaleRate'].toString()),
        GST = double.parse(json['GST'].toString()),
        Qty = int.tryParse(json['Qty']?.toString() ?? '') ?? 0,
        Amount = double.parse(json['Amount'].toString());

  Map<String, dynamic> toJson() {
    return {
      'ProductName': ProductName,
      'Productcode': Productcode,
      'SaleRate': SaleRate,
      'GST': GST,
      'Qty': Qty,
      'Amount': Amount,
    };
  }

  ProductViewModel.Empty()
      : ProductName = '',
        Productcode = '',
        SaleRate = 0.0,
        GST = 0.0,
        Qty = 0,
        Amount = 0.0;
}