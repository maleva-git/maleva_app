import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class FuelFillingsRepository {
  /// Fetches fuel filling report data from the backend
  Future<dynamic> fetchFuelFillingReport({
    required Map<String, dynamic> body,
  }) async {
    // ApiClient handles the headers, timeout, and authorization automatically
    return await ApiClient.postRequest(
      objfun.apiSelectFuelFillingReport,
      body,
    );
  }
}