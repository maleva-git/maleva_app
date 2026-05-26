import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class TruckRepository {
  Future<dynamic> fetchTruckDetails({
    required Map<String, dynamic> body,
  }) async {
    return await ApiClient.postRequest(
        objfun.apiSelectTruckDetails,
        body
    );
  }
}