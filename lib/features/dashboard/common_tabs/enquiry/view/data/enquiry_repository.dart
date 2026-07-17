import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';

class EnquiryRepository {
  /// Fetches the master list of enquiries
  Future<dynamic> fetchEnquiries(Map<String, dynamic> body) async {
    return await ApiClient.postRequest(ApiConstants.apiSelectEnquiryMaster, body);
  }

  /// Cancels an active enquiry
  Future<dynamic> cancelEnquiry(int id, int comId, String status) async {
    final url = '${ApiConstants.apiUpdateEnquiryMaster}$id&Comid=$comId&StatusName=$status';
    return await ApiClient.postRequest(url, null);
  }
}