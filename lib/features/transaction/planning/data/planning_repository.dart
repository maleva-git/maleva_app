import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;

class PlanningRepository {
  Future<List<dynamic>> getPlanning(
      String fromDate, String toDate, String planningNo, int empId) async {
    Map<String, dynamic> master = {
      "Comid": objfun.storagenew.getInt('Comid') ?? 0,
      "Fromdate": fromDate,
      "Todate": toDate,
      "Employeeid": empId,
      "Search": planningNo,
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8'
    };

    final resultData = await objfun.apiAllinoneSelectArray(
        objfun.apiSelectPlanning, master, header, null);
    
    if (resultData == null || resultData == "") {
      return [];
    }
    return resultData as List<dynamic>;
  }

  Future<void> editPlanning(dynamic context, int id, int planningNo) async {
    var comId = objfun.storagenew.getInt('Comid') ?? 0;

    final resultData = await objfun.apiAllinoneSelect(
        Uri.encodeFull(
            "${objfun.apiEditPlanning}$id&PLANINGNo=$planningNo&Comid=$comId"),
        null,
        null,
        context);

    if (resultData != null && resultData.isNotEmpty) {
      objfun.PlanningEditList = resultData[0]["SaleDetails"].toList();
    } else {
      objfun.PlanningEditList = [];
    }
  }

  Future<Map<String, dynamic>?> getSharePdfUrl(dynamic context, int id, String planningNoDisplay) async {
    Map<String, dynamic> master = {
      'SoId': id,
      'Comid': objfun.Comid,
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8'
    };

    final resultData = await objfun.apiAllinoneSelectArray(
      "${objfun.apiViewPlanningPdf}$planningNoDisplay",
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
