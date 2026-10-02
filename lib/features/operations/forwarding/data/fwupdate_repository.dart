import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/files/attachments_api.dart';
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
  /// The job's photos under [smkKey], from the shared Java `/api/attachments`.
  Future<List<String>> fetchImages(int saleOrderId, String smkKey) =>
      sl<AttachmentsApi>().imageNames(folder: 'SalesOrder', recordId: saleOrderId, subFolder: smkKey);

  /// Deletes one photo (shared Java `/api/attachments`); throws when refused.
  Future<void> deleteImage(int saleOrderId, String smkUpload, String networkImg) async {
    await sl<AttachmentsApi>().delete([networkImg], folder: 'SalesOrder', recordId: saleOrderId, subFolder: smkUpload);
  }

  Future<ResponseViewModel?> updateForwarding(Map<String, dynamic> payload) async {
    final result = await ApiClient.postRequest(ApiConstants.apiUpdateForwarding, payload);
    return result != null ? ResponseViewModel.fromJson(result) : null;
  }
}