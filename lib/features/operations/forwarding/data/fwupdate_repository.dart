import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';

import '../../../../core/network/api_constants.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';

class FWUpdateRepository {
  final int comid = AppPreferences.getComid();
  final int empRefId = AppPreferences.getEmpRefId();

  Future<List<dynamic>> fetchJobNoList() async {
    final result = await ApiClient.postRequest("${ApiConstants.apiGetJobNo}$comid&JobType=3", null);
    return result is List ? result : [];
  }

  Future<Map<String, dynamic>> fetchJobDetailsAndEmployees(int saleOrderId) async {

    final masterRes = await ApiClient.postRequest("${ApiConstants.apiEditSalesOrder}$saleOrderId&CNumber=0", null);

    final empRes = await ApiClient.postRequest("${ApiConstants.apiSelectEmployee}$comid&AccountName=&Type=Operation", null);

    return {
      'master': (masterRes != null && masterRes is List && masterRes.isNotEmpty) ? masterRes[0] : null,
      'employees': empRes is List ? empRes : [],
    };
  }
  Future<List<String>> fetchImages(int saleOrderId, String smkKey) async {
    final imageDir = '/Upload/$comid/SalesOrder/$saleOrderId/$smkKey/';
    final result = await ApiClient.postRequest('${ApiConstants.apiGetImage}$imageDir', null);

    List<String> images = [];
    if (result != null && result is List) {
      images = result.map((e) => e.toString()).toList();
    }
    return images;
  }

  Future<ResponseViewModel?> deleteImage(int saleOrderId, String smkUpload, String networkImg) async {
    final header = {
      'Comid': comid.toString(),
      'Id': saleOrderId.toString(),
      'FolderName': 'SalesOrder',
      'FileName': '/Upload/$comid/SalesOrder/$saleOrderId/$smkUpload/$networkImg',
      'SubFolderName': smkUpload,
    };

    final result = await ApiClient.postRequest(ApiConstants.apiDeleteImage, null, headers: header);
    return result != null ? ResponseViewModel.fromJson(result) : null;
  }

  Future<ResponseViewModel?> updateForwarding(Map<String, dynamic> payload) async {
    final result = await ApiClient.postRequest(ApiConstants.apiUpdateForwarding, payload);
    return result != null ? ResponseViewModel.fromJson(result) : null;
  }
}