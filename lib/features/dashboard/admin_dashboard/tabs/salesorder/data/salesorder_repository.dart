import '../../../../../../core/network/api_client.dart';
import '../../../../../../core/network/api_services/auth_api.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class SalesOrderRepository {

  // Fetches the main sales data
  Future<dynamic> fetchSalesData(int type) async {
    return await AuthApi.getSalesData(type);
  }

  // Fetches the invoice check data (used in initial load)
  Future<dynamic> fetchSalesInvoiceCheck(Map<String, dynamic> master) async {
    return await AuthApi.getSalesInvoiceCheck(master);
  }

  // Fetches waiting bills specifically
  Future<dynamic> fetchWaitingBills(Map<String, dynamic> master) async {
    return await ApiClient.postRequest(
      objfun.apiSelectSaleorderinvoicecheck,
      master,
    );
  }

  // Fetches employee inventory data
  Future<dynamic> fetchEmployeeInvData(int type, dynamic comId) async {
    return await ApiClient.postRequest(
      "${objfun.apiGetEmployeeInvData}$comId&type=$type",
      null,
    );
  }
}