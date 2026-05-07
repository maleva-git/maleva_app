import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class PaymentViewRepository {
  /// Fetches Payment Pending data from the server.
  /// Converts the map-based body payload into standard query parameters if needed,
  /// but `ApiClient.postRequest` will seamlessly handle sending JSON bodies.
  Future<dynamic> fetchPaymentPendingData(Map<String, dynamic> body) async {
    // The exact endpoint you used in your BLoC
    final url = "${objfun.apiSelectPaymentPending}?Startindex=0&PageCount=400";

    // Fire the request through our centralized networking layer
    return await ApiClient.postRequest(url, body);
  }
}