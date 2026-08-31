import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';

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
    final mainRes = await ApiClient.postRequest(
      ApiConstants.apiUpdateSaleOrderSpecific,
      updateData,
    );

    // Call update boarding officer for L and O
    if (updateData.containsKey('LBoardingOfficerRefid') || updateData.containsKey('OBoardingOfficerRefid')) {
      final boardingData = {
        "Id": updateData['Jobid'],
        "LBoardingOfficerRefid": updateData['LBoardingOfficerRefid'] ?? 0,
        "LBoardingOfficer1Refid": updateData['LBoardingOfficer1Refid'] ?? 0,
        "LBoardingOfficer2Refid": updateData['LBoardingOfficer2Refid'] ?? 0,
        "OBoardingOfficerRefid": updateData['OBoardingOfficerRefid'] ?? 0,
        "OBoardingOfficer1Refid": updateData['OBoardingOfficer1Refid'] ?? 0,
        "OBoardingOfficer2Refid": updateData['OBoardingOfficer2Refid'] ?? 0,
        "LBoardingAmount": updateData['LBoardingAmount'] ?? 0.0,
        "LBoardingAmount1": updateData['LBoardingAmount1'] ?? 0.0,
        "LBoardingAmount2": updateData['LBoardingAmount2'] ?? 0.0,
        "OBoardingAmount": updateData['OBoardingAmount'] ?? 0.0,
        "OBoardingAmount1": updateData['OBoardingAmount1'] ?? 0.0,
        "OBoardingAmount2": updateData['OBoardingAmount2'] ?? 0.0,
      };
      await ApiClient.postRequest(
        ApiConstants.apiUpdateBoardingOfficer,
        boardingData,
      );
    }
    if (mainRes is Map && mainRes.containsKey('message')) {
      return mainRes['message'];
    }
    return mainRes;
  }
}
