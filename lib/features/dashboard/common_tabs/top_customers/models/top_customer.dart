class TopCustomer {
  final int customerRefId;
  final String customerName;
  final String cNumberDisplay;
  final double revenue;
  final int volume;

  TopCustomer({
    required this.customerRefId,
    required this.customerName,
    required this.cNumberDisplay,
    required this.revenue,
    required this.volume,
  });

  factory TopCustomer.fromJson(Map<String, dynamic> json) {
    return TopCustomer(
      customerRefId: int.tryParse(json['CustomerRefId']?.toString() ?? '0') ?? 0,
      cNumberDisplay: json['CNumberDisplay']?.toString() ?? '',
      customerName: json['CustomerName']?.toString() ?? '',
      revenue: double.tryParse(json['Revenue']?.toString() ?? '0.0') ?? 0.0,
      volume: int.tryParse(json['Volume']?.toString() ?? '0') ?? 0,
    );
  }
}
