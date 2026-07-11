import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';

class TruckRepository {
  Future<dynamic> fetchTruckDetails({
    required Map<String, dynamic> body,
  }) async {
    return await ApiClient.postRequest(
        AppGlobals.apiSelectTruckDetails,
        body
    );
  }
}