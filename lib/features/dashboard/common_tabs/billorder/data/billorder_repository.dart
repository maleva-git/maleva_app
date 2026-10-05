import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/finance/bills_order_api.dart';
import 'package:maleva/core/models/shared/bill_view_model.dart';

/// The pending bills orders of a period (shared Java `/api/bills-order`, was
/// .NET BIllorderApp/SelectBillsOrderApp).
class BillOrderRepository {
  Future<List<BillViewModel>> fetchBillOrders(String fromDate, String toDate) async {
    final rows = await sl<BillsOrderApi>().pending(fromDate: fromDate, toDate: toDate);
    return rows.map(BillViewModel.fromJava).toList();
  }
}
