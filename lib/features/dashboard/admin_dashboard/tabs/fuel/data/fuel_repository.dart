import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class FuelRepository {
  /// Fetches Fuel Difference report data from the backend
  Future<dynamic> fetchFuelDifference({
    required Map<String, dynamic> body,
  }) async {
    // ApiClient seamlessly handles the headers, timeout, and authorization
    return await ApiClient.postRequest(
      objfun.apiSelectFuelEntry,
      body,
    );
  }
}