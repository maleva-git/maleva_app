import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';

class EngineHoursRepository {
  /// Fetches engine hours report data from the backend
  Future<dynamic> fetchEngineHoursReport({
    required Map<String, dynamic> body,
  }) async {
    // ApiClient safely handles the network call, headers, and errors
    return await ApiClient.postRequest(
      ApiConstants.apiSelectEngineHoursReport,
      body,
    );
  }
}