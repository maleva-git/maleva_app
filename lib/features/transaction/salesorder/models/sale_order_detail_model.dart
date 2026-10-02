
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
        MRP = double.tryParse('${json['MRP'] ?? 0}') ?? 0,
        SaleRate = double.tryParse('${json['SaleRate'] ?? 0}') ?? 0,
        TaxPercent = double.tryParse('${json['TaxPercent'] ?? 0}') ?? 0,
        TaxAmt = double.tryParse('${json['TaxAmt'] ?? 0}') ?? 0,
        DiscountPercent = double.tryParse('${json['DiscountPercent'] ?? 0}') ?? 0,
        DiscountAmt = double.tryParse('${json['DiscountAmt'] ?? 0}') ?? 0,
        ItemQty = double.tryParse('${json['ItemQty'] ?? 0}') ?? 0,
        SAmount = double.tryParse('${json['SAmount'] ?? 0}') ?? 0;

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