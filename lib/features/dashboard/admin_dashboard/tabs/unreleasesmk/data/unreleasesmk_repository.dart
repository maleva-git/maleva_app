import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class UnReleaseSMKRepository {
  Future<List<Map<String, dynamic>>> fetchUnReleaseSMKData() async {
    try {
      final int comid = AppPreferences.getComid();
      final String url = objfun.LoadK8UnReleaseNo;

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
      throw Exception('Failed to fetch UnRelease SMK data: $e');
    }
  }
}