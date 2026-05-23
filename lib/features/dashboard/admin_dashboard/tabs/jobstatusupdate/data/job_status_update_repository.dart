import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class JobStatusUpdateRepository {

  // 1. Fetch Job Numbers
  Future<List<Map<String, dynamic>>> fetchJobs(int type) async {
    final comid = AppPreferences.getComid();
    final String url = "${objfun.apiGetJobNo}$comid&Type=$type";

    final response = await ApiClient.postRequest(url, null);
    if (response != null && response is List) {
      return List<Map<String, dynamic>>.from(response);
    }
    return [];
  }

  // 2. Complex Orchestration: Fetch Job Details, Status Name, and Images
  Future<Map<String, dynamic>> fetchJobData(int saleOrderId, int cNumber) async {
    final comid = AppPreferences.getComid();
    int statusId = 0;
    String statusName = '';
    List<String> images = [];

    // A. Fetch Sales Order
    final String editUrl = "${objfun.apiEditSalesOrder}$saleOrderId&CNumber=$cNumber";
    final editResponse = await ApiClient.postRequest(editUrl, null);

    if (editResponse != null && editResponse is List && editResponse.isNotEmpty) {
      final editData = editResponse[0] as Map<String, dynamic>;
      final jStatus = editData['JStatus'];
      final jobMasterRefId = editData['JobMasterRefId'];

      // B. Fetch Job Status List & Find Match
      if (jStatus != null && jStatus != 0) {
        statusId = jStatus as int;
        final String statusUrl = "${objfun.apiSelectAllJobStatus}$comid&JobMasterRefId=$jobMasterRefId";
        final statusResponse = await ApiClient.postRequest(statusUrl, null);

        if (statusResponse != null && statusResponse is List) {
          final match = statusResponse.firstWhere(
                  (s) => s['Status'] == statusId,
              orElse: () => null
          );
          if (match != null) {
            statusName = match['StatusName']?.toString() ?? '';
          }
        }
      }
    }

    // C. Fetch Images
    final imageDir = '/Upload/$comid/SalesOrder/$saleOrderId/Boarding/';
    final String imgUrl = "${objfun.apiGetimage}$imageDir";
    final imageResponse = await ApiClient.postRequest(imgUrl, null);

    if (imageResponse != null && imageResponse is List) {
      images = imageResponse.map((e) => e.toString()).toList();
    }

    return {
      'statusId': statusId,
      'statusName': statusName,
      'images': images,
    };
  }

  // 3. Delete an Image
  Future<ResponseViewModel?> deleteImage(int saleOrderId, String imageName) async {
    final comid = AppPreferences.getComid();
    final filePath = '/Upload/$comid/SalesOrder/$saleOrderId/Boarding/$imageName';

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Comid': comid.toString(),
      'Id': saleOrderId.toString(),
      'FolderName': 'SalesOrder',
      'FileName': filePath,
      'SubFolderName': 'Boarding',
    };

    final response = await ApiClient.postRequest(
        objfun.apiDeleteimage,
        null,
        headers: headers
    );

    return response != null ? ResponseViewModel.fromJson(response) : null;
  }

  // 4. Update Boarding Details
  Future<ResponseViewModel?> updateBoardingDetails(Map<String, dynamic> master) async {
    final response = await ApiClient.postRequest(objfun.apiUpdateBoardingDetails, master);
    return response != null ? ResponseViewModel.fromJson(response) : null;
  }

  // 5. Send Email
  Future<ResponseViewModel?> sendBoardingMail(Map<String, dynamic> master) async {
    final response = await ApiClient.postRequest(objfun.apiBoardingMail, master);
    return response != null ? ResponseViewModel.fromJson(response) : null;
  }
}