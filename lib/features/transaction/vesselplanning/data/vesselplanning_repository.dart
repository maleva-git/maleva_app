import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;

class VesselPlanningRepository {
  Future<List<dynamic>> getVesselPlanning(
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
        objfun.apiSelectVesselPlanning, master, header, null);
    if (resultData == null || resultData == "") {
      return [];
    }
    return resultData as List<dynamic>;
  }

  Future<void> editVesselPlanning(int id, int planningNo) async {
    var comId = objfun.storagenew.getInt('Comid') ?? 0;
    
    // We fetch the edit data explicitly and store it in objfun's global list
    // to maintain compatibility with VesselPlanningDetailsView
    final resultData = await objfun.apiAllinoneSelect(
        Uri.encodeFull(
            "${objfun.apiEditVesselPlanning}$id&VESSELPLANINGNo=$planningNo&Comid=$comId"),
        null,
        null,
        null); // Pass context as null since it isn't used effectively in apiAllinoneSelect

    if (resultData != null && resultData.isNotEmpty) {
      objfun.VesselPlanningEditList = resultData[0]["SaleDetails"].toList();
    } else {
      objfun.VesselPlanningEditList = [];
    }
  }

  Future<Map<String, dynamic>?> getSharePdfUrl(int id, String planningNoDisplay) async {
    Map<String?, dynamic> master = {
      'SoId': id,
      'Comid': objfun.Comid,
    };
    Map<String, String> header = {
      'Content-Type': 'application/json; charset=UTF-8'
    };

    final resultData = await objfun.apiAllinoneSelectArray(
      "${objfun.apiViewVesselPlanningPdf}$planningNoDisplay",
      master,
      header,
      null,
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
