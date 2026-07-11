import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';

class FuelFillingsRepository {
  /// Fetches fuel filling report data from the backend
  Future<dynamic> fetchFuelFillingReport({
    required Map<String, dynamic> body,
  }) async {
    // ApiClient handles the headers, timeout, and authorization automatically
    return await ApiClient.postRequest(
      AppGlobals.apiSelectFuelFillingReport,
      body,
    );
  }
}