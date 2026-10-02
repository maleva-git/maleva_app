// core/network/api_services/reports_api.dart
// Customer balance (the dashboard numbers moved to the Java DashboardApi)

import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/api_constants.dart';

class ReportsApi {
  ReportsApi._();

  // ─── Customer Balance ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getCustomerBalance(
      Map<String, dynamic> master,
      Map<String, String> header) async {

    final result = await ApiClient.postRequest(
      ApiConstants.apiSelectReceipt,
      master,
      headers: header,
    );

    return Map<String, dynamic>.from(result);
  }
}