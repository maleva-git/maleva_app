import 'package:maleva/core/network/api_legacy_helper.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;

class PlanningRepository {
  Future<List<dynamic>> getPlanning(
      String fromDate, String toDate, String planningNo, int empId) async {
    Map<String, dynamic> master = {
      "Comid": AppGlobals.storagenew.getInt('Comid') ?? 0,
      "Fromdate": fromDate,
      "Todate": toDate,
      "Employeeid": empId,
      "Search": planningNo,
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8'
    };

    final resultData = await ApiLegacyHelper.apiAllinoneSelectArray(
        ApiConstants.apiSelectPlanning, master, header, null);
    
    if (resultData == null || resultData == "") {
      return [];
    }
    return resultData as List<dynamic>;
  }

  Future<void> editPlanning(dynamic context, int id, int planningNo) async {
    var comId = AppGlobals.storagenew.getInt('Comid') ?? 0;

    final resultData = await ApiLegacyHelper.apiAllinoneSelect(
        Uri.encodeFull(
            "${ApiConstants.apiEditPlanning}$id&PLANINGNo=$planningNo&Comid=$comId"),
        null,
        null,
        context);

    if (resultData.isNotEmpty) {
      AppGlobals.PlanningEditList = resultData[0]["SaleDetails"].toList();
    } else {
      AppGlobals.PlanningEditList = [];
    }
  }

  Future<Map<String, dynamic>?> getSharePdfUrl(dynamic context, int id, String planningNoDisplay) async {
    Map<String, dynamic> master = {
      'SoId': id,
      'Comid': AppGlobals.Comid,
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8'
    };

    final resultData = await ApiLegacyHelper.apiAllinoneSelectArray(
      "${ApiConstants.apiViewPlanningPdf}$planningNoDisplay",
      master,
      header,
      context,
    );
    
    if (resultData == null || resultData == "") {
      return null;
    }
    return resultData as Map<String, dynamic>;
  }

  Future<void> selectEmployee(dynamic context, String type, String userType) async {
    await OnlineApi.SelectEmployee(context, type, userType);
  }
}
