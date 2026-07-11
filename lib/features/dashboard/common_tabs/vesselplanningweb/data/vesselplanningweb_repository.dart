import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/utils/app_globals.dart';
import '../models/vesselplanningweb_model.dart';

class VesselPlanningWebRepository {
  Future<List<VesselPlanningWebModel>> getVesselPlanningSearch({
    required String fromDate,
    required String toDate,
    required int etaType,
    required String searchPorts,
    required bool deliveryDone,
    required int employeeId,
  }) async {
    final Map<String, dynamic> requestBody = {
      "Comid": AppGlobals.Comid,
      "Fromdate": fromDate,
      "Todate": toDate,
      "ETAType": etaType,
      "Search": searchPorts,
      "DeliveryDone": deliveryDone,
      "Employeeid": employeeId,
    };

    print("========== VESSEL PLANNING WEB (SEARCH) ==========");
    print("API URL: ${AppGlobals.apiVesselPlanningSearch}");
    print("Headers: {'Content-Type': 'application/json; charset=UTF-8', 'Comid': '${AppGlobals.Comid}'}");
    print("Body: ${jsonEncode(requestBody)}");
    print("==================================================");

    final response = await http.post(
      Uri.parse(AppGlobals.apiVesselPlanningSearch),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid': AppGlobals.Comid.toString(),
      },
      body: jsonEncode(requestBody),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse is List) {
        return jsonResponse.map((json) => VesselPlanningWebModel.fromJson(json)).toList();
      } else if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse['ok'] == true && jsonResponse['Data'] != null) {
          List<dynamic> data = jsonResponse['Data'];
          return data.map((json) => VesselPlanningWebModel.fromJson(json)).toList();
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to load data');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }

  Future<String> updateSpecificJob(List<Map<String, dynamic>> updateList) async {
    print("========== VESSEL PLANNING WEB (UPDATE) ==========");
    print("API URL: ${AppGlobals.apiUpdateSaleOrderSpecific}");
    print("Headers: {'Content-Type': 'application/json; charset=UTF-8', 'Comid': '${AppGlobals.Comid}'}");
    print("Body: ${jsonEncode(updateList)}");
    print("==================================================");

    final response = await http.post(
      Uri.parse(AppGlobals.apiUpdateSaleOrderSpecific),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid': AppGlobals.Comid.toString(),
      },
      body: jsonEncode(updateList),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['ok'] == true) {
        return jsonResponse['message'] ?? 'Success';
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to update');
      }
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }

  Future<String> saveVesselPlanning(List<Map<String, dynamic>> planningList) async {
    print("========== VESSEL PLANNING WEB (SAVE NEW) ==========");
    print("API URL: ${AppGlobals.apiInsertVesselPlanning}");
    print("Headers: {'Content-Type': 'application/json; charset=UTF-8', 'Comid': '${AppGlobals.Comid}'}");
    print("Body: ${jsonEncode(planningList)}");
    print("==================================================");

    final response = await http.post(
      Uri.parse(AppGlobals.apiInsertVesselPlanning),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid': AppGlobals.Comid.toString(),
      },
      body: jsonEncode(planningList),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['ok'] == true) {
        return jsonResponse['message'] ?? 'Success';
      } else {
        throw Exception(jsonResponse['message'] ?? 'Failed to save');
      }
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }
}
