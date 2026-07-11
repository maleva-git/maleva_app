import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/api_services/auth_api.dart';
import 'package:maleva/core/utils/app_globals.dart';

class SalesOrderRepository {


  Future<dynamic> fetchSalesData(int type) async {
    return await AuthApi.getSalesData(type);
  }

  Future<dynamic> fetchSalesInvoiceCheck(Map<String, dynamic> master) async {
    return await AuthApi.getSalesInvoiceCheck(master);
  }

  Future<dynamic> fetchEmployeeSalesData(int type) async {
    return await AuthApi.getEmployeeSalesData(type: type);
  }

  Future<dynamic> fetchWaitingBills(Map<String, dynamic> master) async {
    return await ApiClient.postRequest(
      AppGlobals.apiSelectSaleorderinvoicecheck,
      master,
    );
  }

  Future<dynamic> fetchEmployeeInvData(int type, dynamic comId) async {
    return await ApiClient.postRequest(
      "${AppGlobals.apiGetEmployeeInvData}$comId&type=$type",
      null,
    );
  }
}