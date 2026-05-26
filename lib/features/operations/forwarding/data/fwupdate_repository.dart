import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class FWUpdateRepository {
  final int comid = AppPreferences.getComid();
  final int empRefId = AppPreferences.getEmpRefId();

  Future<List<dynamic>> fetchJobNoList() async {
    final result = await ApiClient.postRequest("${objfun.apiGetJobNo}$comid&JobType=3", null);
    return result is List ? result : [];
  }

  Future<Map<String, dynamic>> fetchJobDetailsAndEmployees(int saleOrderId) async {

    final masterRes = await ApiClient.postRequest("${objfun.apiEditSalesOrder}$saleOrderId&CNumber=0", null);

    final empRes = await ApiClient.postRequest("${objfun.apiSelectEmployee}$comid&AccountName=&Type=Operation", null);

    return {
      'master': (masterRes != null && masterRes is List && masterRes.isNotEmpty) ? masterRes[0] : null,
      'employees': empRes is List ? empRes : [],
    };
  }
  Future<List<String>> fetchImages(int saleOrderId, String smkKey) async {
    final imageDir = '/Upload/$comid/SalesOrder/$saleOrderId/$smkKey/';
    final result = await ApiClient.postRequest('${objfun.apiGetimage}$imageDir', null);

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

    final result = await ApiClient.postRequest(objfun.apiDeleteimage, null, headers: header);
    return result != null ? ResponseViewModel.fromJson(result) : null;
  }

  Future<ResponseViewModel?> updateForwarding(Map<String, dynamic> payload) async {
    final result = await ApiClient.postRequest(objfun.apiUpdateForwarding, payload);
    return result != null ? ResponseViewModel.fromJson(result) : null;
  }
}