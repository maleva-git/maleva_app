import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/app_globals.dart';

class UnReleaseRepository {
  Future<List<Map<String, dynamic>>> fetchUnReleaseData(int type) async {
    try {
      final comid = AppPreferences.getComid();
      final String url = type == 1 ? ApiConstants.LoadK8UnReleaseNo : ApiConstants.LoadUnReleaseNo;

      final Map<String, dynamic> body = {
        'Comid': comid,
      };

      final response = await ApiClient.postRequest(url, body);

      if (response != null && response is List && response.isNotEmpty) {
        return List<Map<String, dynamic>>.from(
          response.map((e) => Map<String, dynamic>.from(e as Map)),
        );
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch unrelease data: $e');
    }
  }
}