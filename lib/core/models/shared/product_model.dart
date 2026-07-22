
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

  ProductModel.fromJson(Map<String, dynamic> json)
      : ProductName = json['ProductName'].toString(),
        Productcode = json['Productcode'].toString(),
        PrintName = json['PrintName'].toString(),
        SaleRate = double.parse(json['SaleRate'].toString()),
        WholeSaleRate = double.parse(json['WholeSaleRate'].toString()),
        PurRate = double.parse(json['PurRate'].toString()),
        MRP = double.parse(json['MRP'].toString()),
        GST = double.parse(json['GST'].toString()),
        Id = int.tryParse(json['Id']?.toString() ?? '') ?? 0,
        CategoryId = int.tryParse(json['CategoryId']?.toString() ?? '') ?? 0,
        Imagepath = json['Imagepath'].toString();

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