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

  factory SaleOrderUpdateModel.fromJson(Map<String, dynamic> json) {
    return SaleOrderUpdateModel(
      id: json['Id'] ?? 0,
      cNumberDisplay: json['CNumberDisplay'] ?? '',
      saleDate: json['SaleDate'] ?? '',
      remarks1: json['Remarks1'] ?? '',
      origin: json['Origin'] ?? '',
      destination: json['Destination'] ?? '',
      customerName: json['CustomerName'] ?? '',
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
