class JobOrder {
  final int id;
  final int companyRefId;
  final int statusRefId;
  final String cNumberDisplay;
  final int truckMasterRefId;
  final String truckName;
  final int driverMasterRefId;
  final String driverName;
  final String vendorName;
  final String statusName;
  final String jobTypeName;
  final String priorityName;
  final String problemName;
  final String productUse;
  final String remarks;
  final String jobDate;
  final String sJobDate;
  final double estimatedCost;
  final double actualCost;

  JobOrder({
    required this.id,
    required this.companyRefId,
    required this.statusRefId,
    required this.cNumberDisplay,
    required this.truckMasterRefId,
    required this.truckName,
    required this.driverMasterRefId,
    required this.driverName,
    required this.vendorName,
    required this.statusName,
    required this.jobTypeName,
    required this.priorityName,
    required this.problemName,
    required this.productUse,
    required this.remarks,
    required this.jobDate,
    required this.sJobDate,
    required this.estimatedCost,
    required this.actualCost,
  });

  factory JobOrder.fromJson(Map<String, dynamic> json) {
    return JobOrder(
      id: json['Id'] ?? 0,
      companyRefId: json['CompanyRefId'] ?? 0,
      statusRefId: json['StatusRefId'] ?? 0,
      cNumberDisplay: json['CNumberDisplay'] ?? '',
      truckMasterRefId: json['TruckMasterRefId'] ?? 0,
      truckName: json['TruckName'] ?? '',
      driverMasterRefId: json['DriverMasterRefId'] ?? 0,
      driverName: json['DriverName'] ?? '',
      vendorName: json['VendorName'] ?? '',
      statusName: json['StatusName'] ?? '',
      jobTypeName: json['JobTypeName'] ?? '',
      priorityName: json['PriorityName'] ?? '',
      problemName: json['ProblemName'] ?? '',
      productUse: json['ProductUse'] ?? '',
      remarks: json['Remarks'] ?? '',
      jobDate: json['JobDate'] ?? '',
      sJobDate: json['SJobDate'] ?? '',
      estimatedCost: (json['EstimatedCost'] ?? 0.0).toDouble(),
      actualCost: (json['ActualCost'] ?? 0.0).toDouble(),
    );
  }
}
