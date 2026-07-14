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
      if (response.body.isEmpty || response.body == 'null') return [];
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is List) {
        return jsonResponse.map((json) => VesselPlanningWebModel.fromJson(json)).toList();
      } else if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse['ok'] == true && jsonResponse['Data'] != null) {
          List<dynamic> data = jsonResponse['Data'];
          return data.map((json) => VesselPlanningWebModel.fromJson(json)).toList();
        } else {
          final msg = (jsonResponse['message'] ?? '').toString().toLowerCase();
          if (msg.contains('not found') || msg.contains('no data')) {
            return [];
          }
          throw Exception(jsonResponse['message'] ?? 'Failed to load data');
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } else if (response.statusCode == 404 || response.statusCode == 500) {
      return [];
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }

  Future<String> updateSpecificJob(Map<String, dynamic> updateData) async {
    print("========== VESSEL PLANNING WEB (UPDATE) ==========");
    print("API URL: ${AppGlobals.apiUpdateSaleOrderSpecific}");
    print("Headers: {'Content-Type': 'application/json; charset=UTF-8', 'Comid': '${AppGlobals.Comid}'}");
    print("Body: ${jsonEncode(updateData)}");
    print("==================================================");

    final response = await http.post(
      Uri.parse(AppGlobals.apiUpdateSaleOrderSpecific),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid': AppGlobals.Comid.toString(),
      },
      body: jsonEncode(updateData),
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == 'null') return 'Success';
      try {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse['ok'] == true || jsonResponse['status'] == 'success') {
            return jsonResponse['message'] ?? 'Success';
          } else if (jsonResponse.containsKey('ok') && jsonResponse['ok'] == false) {
            throw Exception(jsonResponse['message'] ?? 'Failed to update');
          }
        }
        return 'Success';
      } catch (e) {
        return 'Success';
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
      if (response.body.isEmpty || response.body == 'null') {
        return 'Success';
      }
      try {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse['ok'] == true || jsonResponse['status'] == 'success') {
            return jsonResponse['message'] ?? 'Success';
          } else if (jsonResponse.containsKey('ok') && jsonResponse['ok'] == false) {
            throw Exception(jsonResponse['message'] ?? 'Failed to save');
          }
        }
        return 'Success';
      } catch (e) {
        return 'Success';
      }
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }

  Future<String> deleteVesselPlanning(int id) async {
    final Map<String, dynamic> requestBody = {
      "Id": id,
      "Comid": AppGlobals.Comid,
    };

    print("========== VESSEL PLANNING WEB (DELETE) ==========");
    print("API URL: ${AppGlobals.apiDeleteVesselPlanning}$id");
    print("Headers: {'Content-Type': 'application/json; charset=UTF-8', 'Comid': '${AppGlobals.Comid}'}");
    print("Body: ${jsonEncode(requestBody)}");
    print("==================================================");

    final response = await http.post(
      Uri.parse('${AppGlobals.apiDeleteVesselPlanning}$id&Comid=${AppGlobals.Comid}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid': AppGlobals.Comid.toString(),
      },
      body: jsonEncode(requestBody),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == 'null') {
        return 'Success';
      }
      try {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is Map<String, dynamic>) {
          if (jsonResponse['ok'] == true || jsonResponse['status'] == 'success') {
            return jsonResponse['message'] ?? 'Success';
          } else if (jsonResponse.containsKey('ok') && jsonResponse['ok'] == false) {
            throw Exception(jsonResponse['message'] ?? 'Failed to save');
          }
        }
        return 'Success';
      } catch (e) {
        return 'Success';
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
      if (response.body.isEmpty || response.body == 'null') return [];
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
    } else if (response.statusCode == 404 || response.statusCode == 500) {
      return [];
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getPlanningById(int id) async {
    final response = await http.post(
      Uri.parse('${AppGlobals.apiEditVesselPlanning}$id&VESSELPLANINGNo=0&Comid=${AppGlobals.Comid}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Comid': AppGlobals.Comid.toString(),
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == 'null') return {'master': null, 'details': <VesselPlanningWebModel>[]};
      final jsonResponse = jsonDecode(response.body);
      
      Map<String, dynamic>? masterData;
      List<dynamic> data = [];
      
      if (jsonResponse is List) {
        if (jsonResponse.isNotEmpty && jsonResponse[0] is Map) {
          masterData = jsonResponse[0] as Map<String, dynamic>;
          if (masterData['SaleDetails'] != null) {
            data = masterData['SaleDetails'];
          }
        } else {
          data = jsonResponse;
        }
      } else if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse['Data1'] != null) {
          final data1 = jsonResponse['Data1'];
          if (data1 is List && data1.isNotEmpty && data1[0] is Map) {
            masterData = data1[0] as Map<String, dynamic>;
            if (masterData['SaleDetails'] != null) {
              data = masterData['SaleDetails'];
            }
          }
        } else {
          masterData = jsonResponse;
          if (jsonResponse['SaleDetails'] != null) {
            data = jsonResponse['SaleDetails'];
          } else if (jsonResponse['Data'] != null) {
            data = jsonResponse['Data'];
          }
        }
      }
      return {
        'master': masterData,
        'details': data.map((json) => VesselPlanningWebModel.fromJson(json)).toList()
      };
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }

  Future<String> getMaxVesselPlanningNo() async {
    try {
      final comId = AppGlobals.storagenew.getInt('Comid') ?? 0;
      final url = '${AppGlobals.apiMaxVesselPlanningNo}?Comid=$comId&BillType=VP';
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded != null && decoded['ok'] == true && decoded['No'] != null) {
          return decoded['No'].toString();
        }
      }
    } catch (e) {
      // ignore
    }
    return "";
  }
}
