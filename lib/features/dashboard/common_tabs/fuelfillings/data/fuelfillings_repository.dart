import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';

class FuelFillingsRepository {
  /// Fetches fuel filling report data from the backend
  Future<dynamic> fetchFuelFillingReport({
    required Map<String, dynamic> body,
  }) async {
    // ApiClient handles the headers, timeout, and authorization automatically
    return await ApiClient.postRequest(
      ApiConstants.apiSelectFuelFillingReport,
      body,
    );
  }
}