
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

  /// An item line of the Java edit read (`saleOrderDetails[]`: `id`, `itemMasterRefId`,
  /// `mrp`, `itemQty`, `salesRate`, `amount`, `taxPercent`, `taxAmount`, `productCode`, ...).
  SaleEditDetailModel.fromJava(Map<String, dynamic> j)
      : Id = _int(j['id']),
        SDId = 0,
        SaleOrderMasterRefId = _int(j['saleOrderMasterRefId']),
        ItemMasterRefId = _int(j['itemMasterRefId']),
        MRP = _num(j['mrp']),
        PurchaseRate = _num(j['purchaseRate']),
        ItemQty = _num(j['itemQty']),
        DiscPer = _num(j['discPer']),
        DiscAmount = _num(j['discAmount']),
        LandingCost = _num(j['landingCost']),
        TaxPercent = _num(j['taxPercent']),
        TaxAmount = _num(j['taxAmount']),
        SalesRate = _num(j['salesRate']),
        NetSalesRate = _num(j['netSalesRate']),
        Amount = _num(j['amount']),
        ProductCode = j['productCode']?.toString() ?? '',
        ProductName = j['productName']?.toString() ?? '',
        UOM = j['uom']?.toString() ?? '',
        ActualAmount = _num(j['actualAmount']),
        CurrencyValue = _num(j['currencyValue']);

  /// The line as the Java save takes it (`SaleOrderDetailsDto`).
  Map<String, dynamic> toJava({required int itemMasterRefId}) => {
        'id': Id,
        'saleOrderMasterRefId': SaleOrderMasterRefId,
        'itemMasterRefId': itemMasterRefId,
        'mrp': MRP,
        'purchaseRate': PurchaseRate,
        'itemQty': ItemQty,
        'discPer': DiscPer,
        'discAmount': DiscAmount,
        'landingCost': LandingCost,
        'taxPercent': TaxPercent,
        'taxAmount': TaxAmount,
        'salesRate': SalesRate,
        'netSalesRate': NetSalesRate,
        'amount': Amount,
        'currencyValue': CurrencyValue,
        'actualAmount': ActualAmount,
      };

  static int _int(dynamic v) => v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;
  static double _num(dynamic v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

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