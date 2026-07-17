import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';

class BoCheckRepository {
  /// Fetches Boarding Officer Check data from the backend
  Future<dynamic> fetchBocData({
    required Map<String, dynamic> body,
  }) async {
    // ApiClient handles the headers, timeout, and authorization automatically
    return await ApiClient.postRequest(
      ApiConstants.apiselectBillordercheck,
      body,
    );
  }
}