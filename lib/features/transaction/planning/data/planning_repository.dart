import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_globals.dart';


class PlanningRepository {
  Future<List<dynamic>> getPlanning(
      String fromDate, String toDate, String planningNo, int empId) async {
    Map<String, dynamic> master = {
      "Comid": AppGlobals.storagenew.getInt('Comid') ?? 0,
      "Fromdate": fromDate,
      "Todate": toDate,
      "Employeeid": empId,
      "Search": planningNo,
      "SoId": 0,
      "BillId": 0,
      "Reportdate": "",
      "Category": "",
      "PortName": "",
      "Id": 0,
      "DId": 0,
      "TId": 0,
      "DashboardStatus": 0,
      "Statusid": 0,
      "JId": 0,
      "Id1": 0,
      "completestatusnotshow": false,
      "VessalNameSearch": "",
      "RTIMasterRefId": 0,
    };
    final resultData = await ApiClient.postRequest(ApiConstants.apiSelectPlanning, master);
    
    if (resultData == null || resultData == "") {
      return [];
    }
    return resultData as List<dynamic>;
  }

  Future<List<dynamic>> searchUnplannedOrders(String fromDate, String toDate, String searchKeyword, int empId) async {
    final comid = AppGlobals.storagenew.getInt('Comid') ?? 0;
    Map<String, dynamic> payload = {
      "Comid": comid,
      "Fromdate": fromDate,
      "Todate": toDate,
      "Search": searchKeyword,
      "Employeeid": empId,
    };

    print("\n=== PLANINGSearch Payload ===");
    print("URL: ${ApiConstants.PLANINGSearch}");
    print("Body: $payload");
    print("============================\n");

    try {
      final resultData = await sl<LegacyApiRepository>().apiAllinoneSelectArray(
        ApiConstants.PLANINGSearch,
        payload,
        {'Content-Type': 'application/json; charset=UTF-8'},
        null,
      );

      if (resultData == null) return [];

      // Response is a wrapper object: {IsSuccess, StatusCode, Data1: [...]}
      if (resultData is Map<String, dynamic>) {
        if (resultData['IsSuccess'] == true || resultData['StatusCode'] == 0) {
          final data = resultData['Data1'];
          if (data is List) return data;
        }
        // StatusCode 1 = "Not found" — return empty
        return [];
      }

      // If direct array returned
      if (resultData is List) return resultData;
      return [];
    } catch (e) {
      print("PLANINGSearch error: $e");
      // 500 "Not found" — treat as empty, not a crash
      return [];
    }
  }

  Future<void> editPlanning(dynamic context, int id, int planningNo) async {
    var comId = AppGlobals.storagenew.getInt('Comid') ?? 0;

    final resultData = await sl<LegacyApiRepository>().apiAllinoneSelect(
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

    final resultData = await sl<LegacyApiRepository>().apiAllinoneSelectArray(
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
    await sl<LegacyApiRepository>().SelectEmployee(context, type, userType);
  }
  Future<bool> savePlanning(dynamic state) async {
    try {
      final List<Map<String, dynamic>> payload = [];
      
      for (var master in state.masterList) {
        final details = state.detailsMap[master.id] ?? [];
        final saleDetails = details.map((d) => {
          'Id': d.id,
          'JobNo': d.jobNo,
          'JobDate': d.jobDate,
          'TruckName': d.truckName,
          'TruckRefid': d.truckRefId,
          'DriverName': d.driverName,
          'DriverRefid': d.driverRefId,
          'PickupDate': d.pickupDate,
          'DeliveryDate': d.deliveryDate,
          'Origin': d.origin,
          'Destination': d.destination,
          'PickupAddress': d.pickupAddress,
          'DeliveryAddress': d.deliveryAddress,
          'Package': d.package,
          'Weight': d.weight,
          'Remarks': d.remarks,
        }).toList();

        payload.add({
          'Id': master.id,
          'CompanyRefId': AppGlobals.Comid,
          'SaleDate': master.planningDate, // from state
          'CNumberDisplay': master.planningNoDisplay,
          'Remarks': master.remarks,
          'SaleDetails': saleDetails
        });
      }

    Map<String, String> header = {'Content-Type': 'application/json; charset=UTF-8', 'Comid': AppGlobals.Comid.toString()};
      
      final resultData = await sl<LegacyApiRepository>().apiAllinone(
          "${ApiConstants.port}/api/PLANING/InsertPLANING", payload, header, null);



      print("\n=== PLANINGSearch Payload ===");
      print("URL: ${resultData}");
      print("Body: $payload");
      print("============================\n");

      if (resultData != null && resultData.toString().isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

}



