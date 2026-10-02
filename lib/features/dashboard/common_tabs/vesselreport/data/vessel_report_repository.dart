import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';

class VesselReportRepository {
  VesselReportRepository({DashboardApi? api}) : _api = api;

  final DashboardApi? _api;

  /// The vessel planning board, from the shared Java `POST /api/dashboard/vessel-planning`
  /// (ported from .NET VESSELPLANINGDB); camelCase rows with every boarding officer.
  Future<List<Map<String, dynamic>>> fetchVesselPlanningData({
    required int comid,
    required String fromDate,
    required String toDate,
    String search = '',
  }) =>
      (_api ?? sl<DashboardApi>()).vesselPlanning(comid, fromDate: fromDate, toDate: toDate, search: search);

  // The date and boarding officer saves below still go to .NET (sale order update, not moved yet).

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
