import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/models/shared/license_view_model.dart';

class LicenseRepository {
  Future<List<LicenseViewModel>> fetchLicenseRecords() async {
    try {
      final comid = AppPreferences.getComid();
      const keyword = '';

      // Constructing the URL with parameters exactly like your old code
      final apiUrl = "${ApiConstants.apiDriverViewRecords}$comid&Startindex=0&PageCount=100&keyword=$keyword&Column=";

      // Make the API call, passing null for the body since parameters are in the URL
      final responseData = await ApiClient.postRequest(apiUrl, null);

      // Parse the response safely
      if (responseData != null && responseData is Map<String, dynamic>) {
        final dataList = responseData['Data1'];

        if (dataList != null && dataList is List && dataList.isNotEmpty) {
          return dataList
              .map((item) => LicenseViewModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load license records: $e');
    }
  }
}