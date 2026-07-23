import 'package:maleva/features/transaction/salesorder/models/sale_order_master_model.dart';
import 'package:maleva/features/transaction/salesorder/models/sale_order_detail_model.dart';

class SaleOrderModel {
  List<SaleOrderMasterModel> SM;
  List<SaleOrderDetailModel> SD;
  SaleOrderModel(this.SM, this.SD);
  SaleOrderModel.fromJson(Map<String, dynamic> json)
      : SM = json['SM'],
        SD = json['SD'];
  // method
  Map<String, dynamic> toJson() {
    return {
      'SM': SM,
      'SD': SD,
    };
  }

  SaleOrderModel.Empty()
      : SM = <SaleOrderMasterModel>[SaleOrderMasterModel.Empty()],
        SD = <SaleOrderDetailModel>[SaleOrderDetailModel.Empty()];
}