import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class PlanningDetailModel {
  final int planingMasterRefId;
  final String jobNo;
  final String jobDate;
  final String truckName;
  final String driverName;
  final String pickupDate;
  final String deliveryDate;
  final String origin;
  final String destination;
  final String package;
  final String weight;
  final String remarks;

  PlanningDetailModel({
    required this.planingMasterRefId,
    required this.jobNo,
    required this.jobDate,
    required this.truckName,
    required this.driverName,
    required this.pickupDate,
    required this.deliveryDate,
    required this.origin,
    required this.destination,
    required this.package,
    required this.weight,
    required this.remarks,
  });

  factory PlanningDetailModel.fromJson(Map<String, dynamic> json) {
    return PlanningDetailModel(
      planingMasterRefId: json['PLANINGMasterRefId'] ?? 0,
      jobNo: (json['JobNo'] ?? json['jobNo'] ?? '').toString(),
      jobDate: (json['JobDate'] ?? json['jobDate'] ?? '').toString(),
      truckName: (json['TruckName'] ?? json['truckName'] ?? '').toString(),
      driverName: (json['DriverName'] ?? json['driverName'] ?? '').toString(),
      pickupDate: (json['PickupDate'] ?? json['pickupdate'] ?? json['pickupDate'] ?? json['SPickupDate'] ?? '').toString(),
      deliveryDate: (json['DeliveryDate'] ?? json['deliverydate'] ?? json['deliveryDate'] ?? json['SDeliveryDate'] ?? '').toString(),
      origin: (json['Origin'] ?? json['origin'] ?? '').toString(),
      destination: (json['Destination'] ?? json['destination'] ?? '').toString(),
      package: (json['Package'] ?? json['package'] ?? json['pkg'] ?? '').toString(),
      weight: (json['Weight'] ?? json['weight'] ?? '').toString(),
      remarks: (json['Remarks'] ?? json['remarks'] ?? '').toString(),
    );
  }
}