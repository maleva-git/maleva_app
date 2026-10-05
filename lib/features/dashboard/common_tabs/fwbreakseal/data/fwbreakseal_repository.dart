import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/employee/employee_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';

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

  /// The Operation employees, from the shared Java employee list.
  Future<List<EmployeeModel>> fetchEmployees() => GetIt.instance<EmployeeApi>().dropdown(type: 'Operation');

  /// Only the given fields change; a null text or a 0 officer is left as it is.
  Future<void> updateForwarding(int saleOrderId, Map<String, dynamic> fields) =>
      _saleOrders.updateForwarding(saleOrderId, fields);
}
