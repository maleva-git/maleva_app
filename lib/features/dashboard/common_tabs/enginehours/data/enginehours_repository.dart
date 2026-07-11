import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';

class EngineHoursRepository {
  /// Fetches engine hours report data from the backend
  Future<dynamic> fetchEngineHoursReport({
    required Map<String, dynamic> body,
  }) async {
    // ApiClient safely handles the network call, headers, and errors
    return await ApiClient.postRequest(
      AppGlobals.apiSelectEangiehoursReport,
      body,
    );
  }
}