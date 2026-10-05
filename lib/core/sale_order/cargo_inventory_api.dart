import 'package:dio/dio.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The cargo inventory by port, from the shared Java `/api/sale-orders/inventory`
/// (ported from .NET CustomerApp/SelectAllInventoryt, change
/// `inventory-on-shared-java-api`). A line is a job (`sourceTable`
/// SaleOrderMaster) or a spot sale order not yet a job (SportSaleOrder):
/// `id`, `cnumberDisplay`, `jobStatus`, `jobType`, `customerName`,
/// `offVesselName`, `loadingVesselName`, `eta`, `oeta`, `cargoQty`,
/// `cargoWeight`, `employeeName`, `remarks`, `awbNo`, `oiDateIn`, `odiDateOut`.
class CargoInventoryApi {
  CargoInventoryApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  /// [portType]: 1 PTP, 2 Westport, 3 Northport, 4 Southport, 5 status 3 at
  /// any port, 6 Pasir Gudang, 0 every port. [pending]: every pending line, no
  /// dates; otherwise [fromDate]..[toDate] (`yyyy-MM-dd`, whole days).
  Future<List<Map<String, dynamic>>> lines({
    required int portType,
    int customerId = 0,
    bool pending = false,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final response = await _dio.get<dynamic>('/api/sale-orders/inventory', queryParameters: {
        'companyId': companyId,
        'portType': portType,
        'customerId': customerId,
        'pending': pending,
        if (!pending && fromDate != null) 'fromDate': fromDate,
        if (!pending && toDate != null) 'toDate': toDate,
      });
      return JsonRead.listOfMaps(JavaResponse.data(response.data));
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
