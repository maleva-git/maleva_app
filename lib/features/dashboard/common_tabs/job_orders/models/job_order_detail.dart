class JobOrderDetail {
  final int id;
  final int jobOrderMasterRefId;
  final String problemName;
  final String productUse;
  final int? productRefId;
  final String productName;
  final double cost;
  final String remarks;

  JobOrderDetail({
    required this.id,
    required this.jobOrderMasterRefId,
    required this.problemName,
    required this.productUse,
    this.productRefId,
    required this.productName,
    required this.cost,
    required this.remarks,
  });

  factory JobOrderDetail.fromJson(Map<String, dynamic> json) {
    return JobOrderDetail(
      id: json['Id'] ?? 0,
      jobOrderMasterRefId: json['JobOrderMasterRefId'] ?? 0,
      problemName: json['ProblemName'] ?? '',
      productUse: json['ProductUse'] ?? '',
      productRefId: json['ProductRefId'],
      productName: json['ProductName'] ?? '',
      cost: (json['Cost'] ?? 0.0).toDouble(),
      remarks: json['Remarks'] ?? '',
    );
  }
}
