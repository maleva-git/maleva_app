import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';

class DriverRepository {
  /// Fetches driver details data from the backend
  Future<dynamic> fetchDriverDetails({
    required Map<String, dynamic> body,
  }) async {
    // ApiClient automatically handles auth headers and timeouts
    return await ApiClient.postRequest(
        AppGlobals.apiSelectDriverDetails,
        body
    );
  }
}