import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/session_manager.dart';

class EnquiryAddRepository {
  final DioClient _dioClient;
  final SessionManager _sessionManager;

  EnquiryAddRepository(this._dioClient, this._sessionManager);

  int get _comId => _sessionManager.companyId;

  /// Fetch currency value for a specific customer
  Future<double> loadCustomerCurrency(int customerId) async {
    try {
      final endpoint = "${ApiConstants.apiGetCurrencyValue}$_comId&CustId=$customerId";
      final response = await _dioClient.dio.post(endpoint, data: {});
      if (response.data != null && response.data.isNotEmpty) {
        // Data format usually comes as a List for SelectArray, or a specific json. 
        // We handle what the API originally returned (resultData["Data1"] or list mapping).
        final data = response.data;
        if (data is List && data.isNotEmpty) {
          final first = data[0];
          if (first != null && first['Data1'] != null) {
            return double.tryParse(first['Data1'].toString()) ?? 0.0;
          }
        } else if (data is Map && data['Data1'] != null) {
          return double.tryParse(data['Data1'].toString()) ?? 0.0;
        }
      }
    } catch (e) {
      // Return default on error to prevent crashes
    }
    return 0.0;
  }

  /// Fetch all job statuses based on JobId
  Future<List<dynamic>> selectAllJobStatus(int jobId) async {
    try {
      final endpoint = "${ApiConstants.apiSelectAllJobStatus}$_comId&Jobid=$jobId";
      final response = await _dioClient.dio.post(endpoint, data: {});
      if (response.data != null) {
        if (response.data is List && response.data.isNotEmpty) {
           final firstItem = response.data[0];
           if (firstItem != null && firstItem['JobStatusDetails'] != null) {
              return firstItem['JobStatusDetails'];
           }
        }
      }
    } catch (e) {
      // Return empty on error
    }
    return [];
  }

  /// Save Enquiry TR Add Payload
  Future<bool> insertEnquiry(List<Map<String, dynamic>> payload) async {
    try {
      final endpoint = "${ApiConstants.apiInsertEnquiry}?Comid=$_comId";
      final response = await _dioClient.dio.post(endpoint, data: payload);
      if (response.data != null) {
        // Typically returns a JSON string or map
        final data = response.data;
        if (data is Map && data['IsSuccess'] == true) {
          return true;
        } else if (data is String) {
          return data.contains('"IsSuccess":true') || data.contains('"IsSuccess": true');
        }
      }
    } catch (e) {
      throw Exception("Failed to save enquiry: $e");
    }
    return false;
  }
}
