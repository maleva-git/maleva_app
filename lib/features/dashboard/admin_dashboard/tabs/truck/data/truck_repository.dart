import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class TruckRepository {
  /// Fetches truck details data from the backend
  Future<dynamic> fetchTruckDetails({
    required Map<String, dynamic> body,
  }) async {
    // We use your centralized ApiClient to handle headers, timeouts, and auth automatically
    return await ApiClient.postRequest(
        objfun.apiSelectTruckDetails,
        body
    );
  }
}