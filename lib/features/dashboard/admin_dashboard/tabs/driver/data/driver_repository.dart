import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class DriverRepository {
  /// Fetches driver details data from the backend
  Future<dynamic> fetchDriverDetails({
    required Map<String, dynamic> body,
  }) async {
    // ApiClient automatically handles auth headers and timeouts
    return await ApiClient.postRequest(
        objfun.apiSelectDriverDetails,
        body
    );
  }
}