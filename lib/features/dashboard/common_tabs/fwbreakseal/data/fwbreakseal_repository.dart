import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';
import 'package:maleva/core/utils/app_preferences.dart';

/// Forwarding break seal on the shared Java sale order API: the job picker
/// (`/job-numbers`, every bill type), the job (`/edit`) and `PUT /{id}/forwarding`.
class FWBreakSealRepository {
  FWBreakSealRepository({SaleOrderApi? saleOrders}) : _saleOrderApi = saleOrders;

  final SaleOrderApi? _saleOrderApi;
  SaleOrderApi get _saleOrders => _saleOrderApi ?? sl<SaleOrderApi>();

  /// `[{id, cNumber, forwardingSMKNo, forwardingSMKNo2, forwardingSMKNo3, ...}]`.
  Future<List<Map<String, dynamic>>> fetchJobs(int type) => _saleOrders.jobNumbers(type);

  /// The job's master with the Java names (`forwardingExitRef2`, `sealbreakbyRefid3`, ...).
  Future<Map<String, dynamic>> fetchSalesOrderDetails(int id, int cNumber) async =>
      (await _saleOrders.edit(id: id, saleOrderNo: cNumber)).master;

  Future<List<dynamic>> fetchEmployees() async {
    final comid = AppPreferences.getComid();
    final response = await ApiClient.postRequest("${ApiConstants.apiSelectEmployee}$comid&AccountName=&Type=Operation", null);
    return response is List ? response : [];
  }

  /// Only the given fields change; a null text or a 0 officer is left as it is.
  Future<void> updateForwarding(int saleOrderId, Map<String, dynamic> fields) =>
      _saleOrders.updateForwarding(saleOrderId, fields);
}
