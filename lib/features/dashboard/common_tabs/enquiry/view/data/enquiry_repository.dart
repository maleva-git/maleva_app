import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';

class EnquiryRepository {

  Future<dynamic> fetchEnquiries(Map<String, dynamic> body) async {
    return await ApiClient.postRequest(ApiConstants.apiSelectEnquiryMaster, body);
  }

  Future<dynamic> cancelEnquiry(int id, int comId, String status) async {
    final url = '${ApiConstants.apiUpdateEnquiryMaster}$id&Comid=$comId&StatusName=$status';
    return await ApiClient.postRequest(url, null);
  }
}