import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/models/shared/inventory_model.dart';
import 'package:maleva/core/sale_order/cargo_inventory_api.dart';

class InventoryReportRepository {
  /// Fetches the Customer List for the dropdown/selection
  Future<dynamic> fetchCustomers(int comId) async {
    return await ApiClient.postRequest("${ApiConstants.apiSelectCustomer}$comId", null);
  }

  /// The cargo inventory lines (shared Java `/api/sale-orders/inventory`, was
  /// .NET CustomerApp/SelectAllInventoryt).
  Future<List<InventoryModel>> fetchInventoryReport({
    required int portType,
    required int customerId,
    required bool pending,
    required String fromDate,
    required String toDate,
  }) async {
    final rows = await sl<CargoInventoryApi>().lines(
        portType: portType, customerId: customerId, pending: pending, fromDate: fromDate, toDate: toDate);
    return rows.map(InventoryModel.fromJava).toList();
  }
}
