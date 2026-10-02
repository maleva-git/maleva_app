
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

  /// A row of the Java `POST /api/bills-order/select-bills-order-view` (camelCase).
  factory BillOrderDetail.fromJava(Map<String, dynamic> json) {
    return BillOrderDetail(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      saleRefId: int.tryParse(json['saleRefId']?.toString() ?? '') ?? 0,
      productCode: json['productCode']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      mrp: double.tryParse(json['mrp']?.toString() ?? '') ?? 0.0,
      saleRate: double.tryParse(json['saleRate']?.toString() ?? '') ?? 0.0,
      taxPercent: double.tryParse(json['taxPercent']?.toString() ?? '') ?? 0.0,
      taxAmt: double.tryParse(json['taxAmt']?.toString() ?? '') ?? 0.0,
      discountPercent: double.tryParse(json['discountPercent']?.toString() ?? '') ?? 0.0,
      discountAmt: double.tryParse(json['discountAmt']?.toString() ?? '') ?? 0.0,
      itemQty: double.tryParse(json['itemQty']?.toString() ?? '') ?? 0.0,
      sAmount: double.tryParse(json['sAmount']?.toString() ?? '') ?? 0.0,
      quoteValue: double.tryParse(json['quoteValue']?.toString() ?? '') ?? 0.0,
      RemarksD: json['remarksD']?.toString(),
      serialNo: json['serialNo']?.toString() ?? '',
    );
  }
}