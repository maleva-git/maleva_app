import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/app_globals.dart';

class VesselPlanningDetailsRepository {

  // ─── Fetch Legacy Preloaded Data ───────────────────────────────────────────
  List<dynamic> getPreloadedData() {
    return AppGlobals.VesselPlanningEditList;
  }

  // ─── Fetch Network Data ────────────────────────────────────────────────────
  Future<List<dynamic>> fetchVesselPlanningData(int masterId) async {
    try {
      final int comid = AppPreferences.getComid();
      final int empRefId = AppPreferences.getEmpRefId();

      final Map<String, dynamic> body = {
        'Comid': comid,
        'Employeeid': empRefId,
        'Fromdate': null,
        'Todate': null,
      };

      final response = await ApiClient.postRequest(ApiConstants.VESSELPLANINGDB, body);

      if (response != null && response is Map<String, dynamic>) {
        if (response['IsSuccess'] == true && response['Data2'] != null) {
          final allDetails = List<dynamic>.from(response['Data2']);
          
          // Filter details for this specific Master ID
          final filteredList = allDetails.where((detail) {
            return detail['VESSELPLANINGMasterRefId'] == masterId;
          }).toList();

          AppGlobals.VesselPlanningEditList = filteredList;
          return filteredList;
        }
      }

      AppGlobals.VesselPlanningEditList = [];
      return [];
    } catch (e) {
      throw Exception('Failed to fetch Vessel Planning details: $e');
    }
  }
}