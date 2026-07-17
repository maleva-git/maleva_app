import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/models/shared/response_view_model.dart';

class RTIViewRepository {
  /// Fetches the RTI Master and Details records
  Future<dynamic> fetchRTIRecords({
    required int comId,
    required String fromDate,
    required String toDate,
  }) async {
    final url = "${ApiConstants.apiSelectRTIView}$comId&Fromdate=$fromDate&Todate=$toDate&DId=0&TId=0&Employeeid=0&Search=";
    return await ApiClient.postRequest(url, null);
  }

  /// Fetches the PDF URL for a specific RTI
  Future<String?> fetchRTIPdfUrl({
    required int soId,
    required String rtiNo,
    required int comId,
  }) async {
    final Map<String, dynamic> body = {
      'SoId': soId,
      'Comid': comId,
    };

    final result = await ApiClient.postRequest("${ApiConstants.apiViewRTIPdf}$rtiNo", body);

    if (result != null && result.toString().isNotEmpty) {
      ResponseViewModel value = ResponseViewModel.fromJson(result);
      if (value.IsSuccess == true) {
        return value.data1; // This is the URL
      }
    }
    return null;
  }
}