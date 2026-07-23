import 'package:maleva/core/models/shared/bill_order_detail.dart';
import 'package:maleva/core/models/shared/bill_order_master.dart';

class BoDetailResponse {
  final List<BillOrderMaster> masters;
  final List<BillOrderDetail> details;

  BoDetailResponse({required this.masters, required this.details});

  factory BoDetailResponse.fromJson(Map<String, dynamic> json) {
    var mastersJson = json['BillsOrderMaster'] as List? ?? [];
    var detailsJson = json['BillsOrderDetails'] as List? ?? [];

    return BoDetailResponse(
      masters: mastersJson.map((e) => BillOrderMaster.fromJson(e)).toList(),
      details: detailsJson.map((e) => BillOrderDetail.fromJson(e)).toList(),
    );
  }
}