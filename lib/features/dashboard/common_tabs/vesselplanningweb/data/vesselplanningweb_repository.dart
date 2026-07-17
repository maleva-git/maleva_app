import 'package:maleva/core/network/api_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/utils/app_globals.dart';
import '../../../../../core/network/api_client.dart';
import '../models/vesselplanningweb_model.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';

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

    try {
      final jsonResponse = await ApiClient.postRequest(
        ApiConstants.apiVesselPlanningSearch,
        requestBody,
        headers: {'Comid': AppGlobals.Comid.toString()},
      );

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
      }
      return [];
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('404') || errorMsg.contains('500') || errorMsg.contains('server error')) {
        return [];
      }
      rethrow;
    }
  }

  Future<String> updateSpecificJob(Map<String, dynamic> updateData) async {
    try {
      final jsonResponse = await ApiClient.postRequest(
        ApiConstants.apiUpdateSaleOrderSpecific,
        updateData,
        headers: {'Comid': AppGlobals.Comid.toString()},
      );

      if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse['ok'] == true || jsonResponse['status'] == 'success') {
          return jsonResponse['message'] ?? 'Success';
        } else if (jsonResponse.containsKey('ok') && jsonResponse['ok'] == false) {
          throw Exception(jsonResponse['message'] ?? 'Failed to update');
        }
      }
      return 'Success';
    } catch (e) {
      if (e.toString().contains('Failed to update')) rethrow;
      return 'Success';
    }
  }

  Future<String> saveVesselPlanning(List<Map<String, dynamic>> planningList) async {
    try {
      final jsonResponse = await ApiClient.postRequest(
        ApiConstants.apiInsertVesselPlanning,
        planningList,
        headers: {'Comid': AppGlobals.Comid.toString()},
      );

      if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse['ok'] == true || jsonResponse['status'] == 'success') {
          return jsonResponse['message'] ?? 'Success';
        } else if (jsonResponse.containsKey('ok') && jsonResponse['ok'] == false) {
          throw Exception(jsonResponse['message'] ?? 'Failed to save');
        }
      }
      return 'Success';
    } catch (e) {
      if (e.toString().contains('Failed to save')) rethrow;
      return 'Success';
    }
  }

  Future<String> deleteVesselPlanning(int id) async {
    final Map<String, dynamic> requestBody = {
      "Id": id,
      "Comid": AppGlobals.Comid,
    };

    try {
      final jsonResponse = await ApiClient.postRequest(
        '${ApiConstants.apiDeleteVesselPlanning}$id&Comid=${AppGlobals.Comid}',
        requestBody,
        headers: {'Comid': AppGlobals.Comid.toString()},
      );

      if (jsonResponse is Map<String, dynamic>) {
        if (jsonResponse['ok'] == true || jsonResponse['status'] == 'success') {
          return jsonResponse['message'] ?? 'Success';
        } else if (jsonResponse.containsKey('ok') && jsonResponse['ok'] == false) {
          throw Exception(jsonResponse['message'] ?? 'Failed to save');
        }
      }
      return 'Success';
    } catch (e) {
      if (e.toString().contains('Failed to save')) rethrow;
      return 'Success';
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

    try {
      final jsonResponse = await ApiClient.postRequest(
        ApiConstants.apiSelectVesselPlanning,
        requestBody,
        headers: {'Comid': AppGlobals.Comid.toString()},
      );

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
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('404') || errorMsg.contains('500') || errorMsg.contains('server error')) {
        return [];
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPlanningById(int id) async {
    try {
      final jsonResponse = await ApiClient.postRequest(
        '${ApiConstants.apiEditVesselPlanning}$id&VESSELPLANINGNo=0&Comid=${AppGlobals.Comid}',
        null,
        headers: {'Comid': AppGlobals.Comid.toString()},
      );

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
    } catch (e) {
      throw Exception('Server Error: ${e.toString()}');
    }
  }

  Future<String> getMaxVesselPlanningNo() async {
    try {
      final comId = AppGlobals.storagenew.getInt('Comid') ?? 0;
      final url = '${ApiConstants.apiMaxVesselPlanningNo}?Comid=$comId&BillType=VP';
      final jsonResponse = await ApiClient.postRequest(url, null);
      
      if (jsonResponse != null && jsonResponse['ok'] == true && jsonResponse['No'] != null) {
        return jsonResponse['No'].toString();
      }
    } catch (e) {
      // ignore
    }
    return "";
  }

  Future<String?> fetchVesselPlanningPdfUrl({
    required int soId,
    required String planningNo,
  }) async {
    final Map<String, dynamic> body = {
      'SoId': soId,
      'Comid': AppGlobals.Comid,
    };

    final result = await ApiClient.postRequest("${ApiConstants.apiViewVesselPlanningPdf}$planningNo", body);

    if (result != null && result.toString().isNotEmpty) {
      ResponseViewModel value = ResponseViewModel.fromJson(result);
      if (value.IsSuccess == true) {
        return value.data1;
      }
    }
    return null;
  }
}
