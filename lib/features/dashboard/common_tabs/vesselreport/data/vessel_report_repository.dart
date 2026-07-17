import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart'; // Adjust path if needed
import 'package:maleva/core/utils/app_globals.dart';

class VesselReportRepository {
  /// Fetches the vessel planning data from the database using ApiClient
  Future<dynamic> fetchVesselPlanningData({
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    // ApiClient automatically adds the Auth headers, but we pass custom headers just in case
    return await ApiClient.postRequest(
      ApiConstants.VESSELPLANINGDB,
      body,
      headers: headers,
    );
  }

  /// Updates specific vessel dates (ETA/ETB/OETA/OETB)
  Future<dynamic> updateVesselPlanningDates(Map<String, dynamic> updateData) async {
    return await ApiClient.postRequest(
      AppGlobals.apiUpdateSaleOrderSpecific,
      updateData,
    );
  }
}