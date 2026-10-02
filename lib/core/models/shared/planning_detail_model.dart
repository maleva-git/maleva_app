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

  /// A row of the Java `POST /api/planing/select-planning` (`saledetails`): the planned
  /// pickup/delivery are `PickupDateD`/`DeliveryDateD`, the places `OriginD`/`DestinationD`.
  factory PlanningDetailModel.fromJson(Map<String, dynamic> json) {
    String text(String key) => (json[key] ?? '').toString();
    return PlanningDetailModel(
      id: json['Id'] ?? 0,
      planingMasterRefId: json['PLANINGMasterRefId'] ?? 0,
      jobNo: text('JobNo'),
      jobDate: text('JobDate'),
      truckName: text('TruckName'),
      truckRefId: json['TruckRefid'] ?? 0,
      driverName: text('DriverName'),
      driverRefId: json['DriverRefid'] ?? 0,
      pickupDate: text('PickupDateD'),
      deliveryDate: text('DeliveryDateD'),
      origin: text('OriginD'),
      destination: text('DestinationD'),
      pickupAddress: text('PickupAddress'),
      deliveryAddress: text('DeliveryAddress'),
      package: text('pkg'),
      weight: text('Weight'),
      remarks: text('Remarks'),
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
