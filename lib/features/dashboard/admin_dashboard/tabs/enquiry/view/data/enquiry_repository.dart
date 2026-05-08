import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class EnquiryRepository {
  /// Fetches the master list of enquiries
  Future<dynamic> fetchEnquiries(Map<String, dynamic> body) async {
    return await ApiClient.postRequest(objfun.apiSelectEnquiryMaster, body);
  }

  /// Cancels an active enquiry
  Future<dynamic> cancelEnquiry(int id, int comId, String status) async {
    final url = '${objfun.apiUpdateEnquiryMaster}$id&Comid=$comId&StatusName=$status';
    return await ApiClient.postRequest(url, null);
  }
}