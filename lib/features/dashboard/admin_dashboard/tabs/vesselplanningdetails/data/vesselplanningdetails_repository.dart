import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class VesselPlanningDetailsRepository {

  // ─── Fetch Legacy Preloaded Data ───────────────────────────────────────────
  List<dynamic> getPreloadedData() {
    return objfun.VesselPlanningEditList;
  }

  // ─── Fetch Network Data ────────────────────────────────────────────────────
  Future<List<dynamic>> fetchVesselPlanningData() async {
    try {
      final int comid = AppPreferences.getComid();
      final int empRefId = AppPreferences.getEmpRefId();

      final Map<String, dynamic> body = {
        'Comid': comid,
        'Employeeid': empRefId,
        'Fromdate': null,
        'Todate': null,
      };

      // ApiClient automatically manages the JSON headers and decoding
      final response = await ApiClient.postRequest(ApiConstants.VESSELPLANINGDB, body);

      if (response != null && response is List && response.isNotEmpty) {
        final list = List<dynamic>.from(response);

        // Keep global list in sync for legacy pages that still read it
        objfun.VesselPlanningEditList = list;
        return list;
      }

      objfun.VesselPlanningEditList = [];
      return [];
    } catch (e) {
      throw Exception('Failed to fetch Vessel Planning details: $e');
    }
  }
}