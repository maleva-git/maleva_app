import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class PettyCashRepository {
  /// Fetches Petty Cash master and details records from the backend
  Future<dynamic> fetchPettyCashData({
    required int comId,
    required String fromDate,
    required String toDate,
  }) async {
    // Construct the URL with query parameters
    final url = "${objfun.apiGetpettycash}$comId"
        "&Fromdate=$fromDate"
        "&Todate=$toDate" 
        "&Employeeid=0&Search=&PaymentStatus=&PaymentTo";

    // ApiClient seamlessly handles the request
    return await ApiClient.postRequest(url, null);
  }
}