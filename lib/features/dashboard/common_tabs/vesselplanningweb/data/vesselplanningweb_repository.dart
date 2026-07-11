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

  Future<List<dynamic>> getSavedPlannings({
    required String fromDate,
    required String toDate,
    required String search,
    required int employeeId,
  }) async {
    final Map<String, dynamic> requestBody = {
      "Comid": AppGlobals.Comid,
      "Fromdate": fromDate,
      "Todate": toDate,
      "Search": search,
      "Employeeid": employeeId,
    };

    print("========== VESSEL PLANNING WEB (GET SAVED PLANNINGS) ==========");
    print("API URL: ${AppGlobals.apiSelectVesselPlanning}");
    print("Headers: {'Content-Type': 'application/json; charset=UTF-8', 'Comid': '${AppGlobals.Comid}'}");
    print("Body: ${jsonEncode(requestBody)}");
    print("===============================================================");

    final response = await http.post(
      Uri.parse(AppGlobals.apiSelectVesselPlanning),
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
      List<dynamic> extractEnrichedMaster(dynamic firstObj) {
        if (firstObj is Map && firstObj['salemaster'] != null) {
          List<dynamic> masters = firstObj['salemaster'];
          List<dynamic> details = firstObj['saledetails'] ?? [];
          for (var m in masters) {
            m['saledetails'] = details.where((d) => d['VESSELPLANINGMasterRefId'] == m['Id']).toList();
          }
          return masters;
        }
        return [];
      }

      if (jsonResponse is List) {
        if (jsonResponse.isNotEmpty) {
          final firstObj = jsonResponse[0];
          final masters = extractEnrichedMaster(firstObj);
          if (masters.isNotEmpty) return masters;
        }
        return jsonResponse;
      } else if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse['Data1'] != null) {
          final data1 = jsonResponse['Data1'];
          if (data1 is List && data1.isNotEmpty) {
            final firstObj = data1[0];
            final masters = extractEnrichedMaster(firstObj);
            if (masters.isNotEmpty) return masters;
          }
        }
        if (jsonResponse['Data'] != null) {
          return jsonResponse['Data'];
        }
      }
      return [];
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }

  Future<List<VesselPlanningWebModel>> getPlanningById(int id) async {
    final response = await http.post(
      Uri.parse('${AppGlobals.apiEditVesselPlanning}$id&VESSELPLANINGNo=0&Comid=${AppGlobals.Comid}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid': AppGlobals.Comid.toString(),
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // Depending on how backend returns Edit data. Usually it returns the master object with SaleDetails array,
      // or just the SaleDetails directly. Assuming it returns a list of items for the grid:
      List<dynamic> data = [];
      if (jsonResponse is List) {
        if (jsonResponse.isNotEmpty && jsonResponse[0] is Map && jsonResponse[0]['SaleDetails'] != null) {
          data = jsonResponse[0]['SaleDetails'];
        } else {
          data = jsonResponse;
        }
      } else if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse['Data1'] != null) {
          final data1 = jsonResponse['Data1'];
          if (data1 is List && data1.isNotEmpty && data1[0] is Map && data1[0]['SaleDetails'] != null) {
            data = data1[0]['SaleDetails'];
          }
        } else if (jsonResponse['SaleDetails'] != null) {
          data = jsonResponse['SaleDetails'];
        } else if (jsonResponse['Data'] != null) {
          data = jsonResponse['Data'];
        }
      }
      return data.map((json) => VesselPlanningWebModel.fromJson(json)).toList();
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }
}
