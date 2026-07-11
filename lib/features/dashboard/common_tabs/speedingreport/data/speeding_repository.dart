import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';

class SpeedingRepository {
  /// Fetches speeding report data from the backend
  Future<dynamic> fetchSpeedingReport({
    required Map<String, dynamic> body,
  }) async {
    // ApiClient handles the headers, timeout, and authorization automatically!
    return await ApiClient.postRequest(
      AppGlobals.apiSelectSpeedingReport,
      body,
    );
  }
}