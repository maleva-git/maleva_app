class PlanningDetailModel {
  final int id;
  final int planingMasterRefId;
  final String jobNo;
  final String jobDate;
  final String truckName;
  final int truckRefId;
  final String driverName;
  final int driverRefId;
  final String pickupDate;
  final String deliveryDate;
  final String origin;
  final String destination;
  final String pickupAddress;
  final String deliveryAddress;
  final String package;
  final String weight;
  final String remarks;

  PlanningDetailModel({
    required this.id,
    required this.planingMasterRefId,
    required this.jobNo,
    required this.jobDate,
    required this.truckName,
    required this.truckRefId,
    required this.driverName,
    required this.driverRefId,
    required this.pickupDate,
    required this.deliveryDate,
    required this.origin,
    required this.destination,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.package,
    required this.weight,
    required this.remarks,
  });

  factory PlanningDetailModel.fromJson(Map<String, dynamic> json) {
    return PlanningDetailModel(
      id: json['Id'] ?? 0,
      planingMasterRefId: json['PLANINGMasterRefId'] ?? 0,
      jobNo: (json['JobNo'] ?? json['jobNo'] ?? '').toString(),
      jobDate: (json['JobDate'] ?? json['jobDate'] ?? '').toString(),
      truckName: (json['TruckName'] ?? json['truckName'] ?? '').toString(),
      truckRefId: json['TruckRefid'] ?? 0,
      driverName: (json['DriverName'] ?? json['driverName'] ?? '').toString(),
      driverRefId: json['DriverRefid'] ?? 0,
      pickupDate: (json['PickupDate'] ?? json['pickupdate'] ?? json['pickupDate'] ?? json['SPickupDate'] ?? '').toString(),
      deliveryDate: (json['DeliveryDate'] ?? json['deliverydate'] ?? json['deliveryDate'] ?? json['SDeliveryDate'] ?? '').toString(),
      origin: (json['Origin'] ?? json['origin'] ?? '').toString(),
      destination: (json['Destination'] ?? json['destination'] ?? '').toString(),
      pickupAddress: (json['PickupAddress'] ?? json['pickupAddress'] ?? '').toString(),
      deliveryAddress: (json['DeliveryAddress'] ?? json['deliveryAddress'] ?? '').toString(),
      package: (json['Package'] ?? json['package'] ?? json['pkg'] ?? '').toString(),
      weight: (json['Weight'] ?? json['weight'] ?? '').toString(),
      remarks: (json['Remarks'] ?? json['remarks'] ?? '').toString(),
    );
  }

  PlanningDetailModel copyWith({
    String? truckName,
    int? truckRefId,
    String? driverName,
    int? driverRefId,
    String? pickupDate,
    String? deliveryDate,
    String? pickupAddress,
    String? deliveryAddress,
  }) {
    return PlanningDetailModel(
      id: id,
      planingMasterRefId: planingMasterRefId,
      jobNo: jobNo,
      jobDate: jobDate,
      truckName: truckName ?? this.truckName,
      truckRefId: truckRefId ?? this.truckRefId,
      driverName: driverName ?? this.driverName,
      driverRefId: driverRefId ?? this.driverRefId,
      pickupDate: pickupDate ?? this.pickupDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      origin: origin,
      destination: destination,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      package: package,
      weight: weight,
      remarks: remarks,
    );
  }
}
