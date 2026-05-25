import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun; // Only used for endpoint strings

class FWUpdateRepository {
  final int comid = AppPreferences.getComid();
  final int empRefId = AppPreferences.getEmpRefId();

  // ─── Fetch Jobs List (Type 3) ────────────────────────────────────────────
  Future<List<dynamic>> fetchJobNoList() async {
    // Replaces OnlineApi.GetJobNoForwarding(null, 3)
    final result = await ApiClient.postRequest("${objfun.apiGetJobNo}$comid&Type=3", null);
    return result is List ? result : [];
  }

  // ─── Fetch Master Data & Employees ───────────────────────────────────────
  Future<Map<String, dynamic>> fetchJobDetailsAndEmployees(int saleOrderId) async {
    // Replaces OnlineApi.EditSalesOrder
    final masterRes = await ApiClient.postRequest("${objfun.apiEditSalesOrder}$saleOrderId&CNumber=0", null);
    // Replaces OnlineApi.SelectEmployee
    final empRes = await ApiClient.postRequest("${objfun.apiSelectEmployee}$comid&AccountName=&Type=Operation", null);

    return {
      'master': (masterRes != null && masterRes is List && masterRes.isNotEmpty) ? masterRes[0] : null,
      'employees': empRes is List ? empRes : [],
    };
  }

  // ─── Fetch Images ────────────────────────────────────────────────────────
  Future<List<String>> fetchImages(int saleOrderId, String smkKey) async {
    final imageDir = '/Upload/$comid/SalesOrder/$saleOrderId/$smkKey/';
    final result = await ApiClient.postRequest('${objfun.apiGetimage}$imageDir', null);

    List<String> images = [];
    if (result != null && result is List) {
      images = result.map((e) => e.toString()).toList();
    }
    return images;
  }

  // ─── Delete Image ────────────────────────────────────────────────────────
  Future<ResponseViewModel?> deleteImage(int saleOrderId, String smkUpload, String networkImg) async {
    final header = {
      'Comid': comid.toString(),
      'Id': saleOrderId.toString(),
      'FolderName': 'SalesOrder',
      'FileName': '/Upload/$comid/SalesOrder/$saleOrderId/$smkUpload/$networkImg',
      'SubFolderName': smkUpload,
    };

    final result = await ApiClient.postRequest(objfun.apiDeleteimage, null, headers: header);
    return result != null ? ResponseViewModel.fromJson(result) : null;
  }

  // ─── Update Forwarding ───────────────────────────────────────────────────
  Future<ResponseViewModel?> updateForwarding(Map<String, dynamic> payload) async {
    final result = await ApiClient.postRequest(objfun.apiUpdateForwarding, payload);
    return result != null ? ResponseViewModel.fromJson(result) : null;
  }
}