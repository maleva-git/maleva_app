import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';

class TruckRepository {
  Future<dynamic> fetchTruckDetails({
    required Map<String, dynamic> body,
  }) async {
    return await ApiClient.postRequest(
        ApiConstants.apiSelectTruckDetails,
        body
    );
  }
}