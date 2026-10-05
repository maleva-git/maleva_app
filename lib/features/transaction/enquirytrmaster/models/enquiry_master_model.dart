import 'package:intl/intl.dart';

class EnquiryMasterModel {
  final int id;
  final int customerRefId;
  final String customerName;
  final int jobMasterRefId;
  final String jobType;
  final String forwardingDate;
  final String sForwardingDate;
  final String pickupDate;
  final String sPickupDate;
  final String deliveryDate;
  final String sDeliveryDate;
  final int originRefId;
  final String origin;
  final int destinationRefId;
  final String destination;
  final String quantity;
  final String totalWeight;
  final String sPort;
  final String oPort;

  EnquiryMasterModel({
    required this.id,
    required this.customerRefId,
    required this.customerName,
    required this.jobMasterRefId,
    required this.jobType,
    required this.forwardingDate,
    required this.sForwardingDate,
    required this.pickupDate,
    required this.sPickupDate,
    required this.deliveryDate,
    required this.sDeliveryDate,
    required this.originRefId,
    required this.origin,
    required this.destinationRefId,
    required this.destination,
    required this.quantity,
    required this.totalWeight,
    required this.sPort,
    required this.oPort,
  });

  /// A Java enquiry row (`/api/enquiry-masters/search`).
  factory EnquiryMasterModel.fromJava(Map<String, dynamic> json) {
    String formatDate(dynamic dateStr) {
      if (dateStr == null || dateStr.toString().isEmpty) return '';
      try {
        return DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(dateStr.toString()));
      } catch (e) {
        return dateStr.toString();
      }
    }

    return EnquiryMasterModel(
      id: json['id'] ?? 0,
      customerRefId: json['customerRefId'] ?? 0,
      customerName: json['customerName']?.toString() ?? '',
      jobMasterRefId: json['jobMasterRefId'] ?? 0,
      jobType: json['jobType']?.toString() ?? '',
      forwardingDate: json['forwardingDate']?.toString() ?? '',
      sForwardingDate: formatDate(json['forwardingDate']),
      pickupDate: json['pickupDate']?.toString() ?? '',
      sPickupDate: formatDate(json['pickupDate']),
      deliveryDate: json['deliveryDate']?.toString() ?? '',
      sDeliveryDate: formatDate(json['deliveryDate']),
      originRefId: json['originRefId'] ?? 0,
      origin: json['origin']?.toString() ?? '',
      destinationRefId: json['destinationRefId'] ?? 0,
      destination: json['destination']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      totalWeight: json['totalWeight']?.toString() ?? '',
      sPort: json['sport']?.toString() ?? '',
      oPort: json['oport']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'CustomerRefId': customerRefId,
      'CustomerName': customerName,
      'JobMasterRefId': jobMasterRefId,
      'JobType': jobType,
      'ForwardingDate': forwardingDate == '' ? null : forwardingDate,
      'PickupDate': pickupDate == '' ? null : pickupDate,
      'DeliveryDate': deliveryDate == '' ? null : deliveryDate,
      'OriginRefId': originRefId,
      'Origin': origin,
      'DestinationRefId': destinationRefId,
      'Destination': destination,
      'Quantity': quantity,
      'TotalWeight': totalWeight,
      'SPort': sPort,
      'OPort': oPort,
    };
  }
}