import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';

class EngineHoursRepository {

  Future<dynamic> fetchEngineHoursReport({
    required Map<String, dynamic> body,
  }) async {

    return await ApiClient.postRequest(
      ApiConstants.apiSelectEngineHoursReport,
      body,
    );
  }
}