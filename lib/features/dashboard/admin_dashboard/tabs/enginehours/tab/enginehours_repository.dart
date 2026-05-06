import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class EngineHoursRepository {
  /// Fetches engine hours report data from the backend
  Future<dynamic> fetchEngineHoursReport({
    required Map<String, dynamic> body,
  }) async {
    // ApiClient safely handles the network call, headers, and errors
    return await ApiClient.postRequest(
      objfun.apiSelectEangiehoursReport,
      body,
    );
  }
}