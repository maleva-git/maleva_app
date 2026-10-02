class SaleOrderUpdateModel {
  int id;
  String cNumberDisplay;
  String saleDate;
  String remarks1;
  String origin;
  String destination;
  String customerName;

  SaleOrderUpdateModel({
    this.id = 0,
    this.cNumberDisplay = '',
    this.saleDate = '',
    this.remarks1 = '',
    this.origin = '',
    this.destination = '',
    this.customerName = '',
  });

  /// A row of the Java `GET /api/sale-orders/trips` (`saleDate` dd/MM/yyyy).
  factory SaleOrderUpdateModel.fromJava(Map<String, dynamic> json) {
    return SaleOrderUpdateModel(
      id: json['id'] ?? 0,
      cNumberDisplay: json['cNumberDisplay'] ?? '',
      saleDate: json['saleDate'] ?? '',
      remarks1: json['remarks1'] ?? '',
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      customerName: json['customerName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'CNumberDisplay': cNumberDisplay,
      'SaleDate': saleDate,
      'Remarks1': remarks1,
      'Origin': origin,
      'Destination': destination,
      'CustomerName': customerName,
    };
  }
}
