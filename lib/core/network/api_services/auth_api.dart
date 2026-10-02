import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/api_constants.dart';

class AuthApi {
  AuthApi._();
  static final AuthApi instance = AuthApi._();

  /// The invoice desk's waiting bills (.NET MasterReportApp/SelectChecksalesinvoice, not moved yet).
  static Future<dynamic> getSalesInvoiceCheck(
      Map<String, dynamic> master) async {

    final result = await ApiClient.postRequest(
      ApiConstants.apiSelectSaleorderinvoicecheck,
      master,
    );

    return result;
  }
}
