import 'package:maleva/core/utils/json_read.dart';

class ProductModel {
  String ProductName;
  String Productcode;
  String PrintName;
  double SaleRate;
  double WholeSaleRate;
  double PurRate;
  double MRP;
  double GST;
  int Id;
  int CategoryId;
  String Imagepath;

  ProductModel(
      this.ProductName,
      this.Productcode,
      this.PrintName,
      this.SaleRate,
      this.WholeSaleRate,
      this.PurRate,
      this.MRP,
      this.GST,
      this.Id,
      this.CategoryId,
      this.Imagepath);

  /// A product of the shared Java `/api/item-masters/company/{companyId}/products`
  /// (it has no print name, wholesale rate, GST, category or image).
  ProductModel.fromJava(Map<String, dynamic> json)
      : ProductName = JsonRead.string(json['productName']),
        Productcode = JsonRead.string(json['productCode']),
        PrintName = '',
        SaleRate = JsonRead.number(json['saleRate']),
        WholeSaleRate = 0,
        PurRate = JsonRead.number(json['purRate']),
        MRP = JsonRead.number(json['mrp']),
        GST = 0,
        Id = JsonRead.integer(json['id']),
        CategoryId = 0,
        Imagepath = '';

  Map<String, dynamic> toJson() {
    return {
      'ProductName': ProductName,
      'Productcode': Productcode,
      'PrintName': PrintName,
      'SaleRate': SaleRate,
      'WholeSaleRate': WholeSaleRate,
      'PurRate': PurRate,
      'MRP': MRP,
      'GST': GST,
      'Id': Id,
      'CategoryId': CategoryId,
      'Imagepath': Imagepath,
    };
  }

  ProductModel.Empty()
      : ProductName = '',
        Productcode = '',
        PrintName = '',
        SaleRate = 0.0,
        WholeSaleRate = 0.0,
        PurRate = 0.0,
        MRP = 0.0,
        GST = 0.0,
        Id = 0,
        CategoryId = 0,
        Imagepath = '';
}