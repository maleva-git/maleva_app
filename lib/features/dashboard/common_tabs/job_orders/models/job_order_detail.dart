import 'package:maleva/core/utils/json_read.dart';

/// A job order's line, from the `details` of a shared Java job order.
class JobOrderDetail {
  final int id;
  final int jobOrderMasterRefId;
  final String problemName;
  final String productUse;
  final int? productRefId;
  final String productName;
  final double cost;
  final String remarks;
  final bool active;

  JobOrderDetail({
    required this.id,
    required this.jobOrderMasterRefId,
    required this.problemName,
    required this.productUse,
    this.productRefId,
    required this.productName,
    required this.cost,
    required this.remarks,
    this.active = true,
  });

  /// [productNames] gives the name of `productRefId` (Java answers only the id).
  factory JobOrderDetail.fromJava(Map<String, dynamic> json, {Map<int, String> productNames = const {}}) {
    final productRefId = JsonRead.intOrNull(json['productRefId']);
    final cost = json['cost'];
    return JobOrderDetail(
      id: JsonRead.integer(json['id']),
      jobOrderMasterRefId: JsonRead.integer(json['jobOrderMasterRefId']),
      problemName: JsonRead.string(json['problemName']),
      productUse: JsonRead.string(json['productUse']),
      productRefId: productRefId,
      productName: productRefId == null ? '' : productNames[productRefId] ?? '',
      cost: cost is num ? cost.toDouble() : double.tryParse('${cost ?? ''}') ?? 0,
      remarks: JsonRead.string(json['remarks']),
      // .NET listed only Active = 1 lines; a missing flag counts as active
      active: json['active'] == null || JsonRead.integer(json['active']) == 1,
    );
  }
}
