import 'package:maleva/core/models/shared/bill_order_detail.dart';
import 'package:maleva/core/models/shared/bill_order_master.dart';

class BoDetailResponse {
  final List<BillOrderMaster> masters;
  final List<BillOrderDetail> details;

  BoDetailResponse({required this.masters, required this.details});

  /// The `data` of the Java `POST /api/bills-order/select-bills-order-view`.
  factory BoDetailResponse.fromJava(Map<String, dynamic> json) {
    var mastersJson = json['billsOrderMaster'] as List? ?? [];
    var detailsJson = json['billsOrderDetails'] as List? ?? [];

    return BoDetailResponse(
      masters: mastersJson.map((e) => BillOrderMaster.fromJava(e)).toList(),
      details: detailsJson.map((e) => BillOrderDetail.fromJava(e)).toList(),
    );
  }
}