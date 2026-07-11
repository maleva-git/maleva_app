import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';

class FuelRepository {
  /// Fetches Fuel Difference report data from the backend
  Future<dynamic> fetchFuelDifference({
    required Map<String, dynamic> body,
  }) async {
    // ApiClient seamlessly handles the headers, timeout, and authorization
    return await ApiClient.postRequest(
      AppGlobals.apiSelectFuelEntry,
      body,
    );
  }
}