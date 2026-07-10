import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/session_manager.dart';

class EnquiryTrRepository {
  final DioClient _dioClient;
  final SessionManager _sessionManager;

  EnquiryTrRepository(this._dioClient, this._sessionManager);

  int get _comId => _sessionManager.companyId;

  /// Fetch currency value for a specific customer
  Future<double> loadCustomerCurrency(int customerId) async {
    try {
      final endpoint = "${ApiConstants.apiGetCurrencyValue}$_comId&CustId=$customerId";
      final response = await _dioClient.dio.post(endpoint, data: {});
      if (response.data != null && response.data.isNotEmpty) {
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
    } catch (e) {}
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
    } catch (e) {}
    return [];
  }

  /// Save Enquiry TR Add Payload
  Future<bool> insertEnquiry(List<Map<String, dynamic>> payload) async {
    try {
      final endpoint = "${ApiConstants.apiInsertEnquiry}?Comid=$_comId";
      final response = await _dioClient.dio.post(endpoint, data: payload);
      if (response.data != null) {
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

  /// Fetch Enquiry Master List
  Future<List<dynamic>> fetchEnquiryMaster(Map<String, dynamic> payload, Map<String, dynamic> header) async {
    try {
      final endpoint = ApiConstants.apiSelectEnquiryMaster;
      final response = await _dioClient.dio.post(
        endpoint,
        data: {"_objModel": payload, "header": header},
      );
      if (response.data != null && response.data is List) {
        return response.data;
      }
    } catch (e) {
      throw Exception("Failed to fetch enquiry master: $e");
    }
    return [];
  }

  /// Cancel Enquiry
  Future<bool> cancelEnquiry(int id) async {
    try {
      final endpoint = "${ApiConstants.apiUpdateEnquiryMaster}$id&Comid=$_comId&StatusName=CANCEL";
      final response = await _dioClient.dio.post(endpoint, data: {});
      if (response.data != null) {
        final data = response.data;
        if (data is Map && data['IsSuccess'] == true) {
          return true;
        } else if (data is String) {
          return data.contains('"IsSuccess":true') || data.contains('"IsSuccess": true');
        }
      }
    } catch (e) {
      throw Exception("Failed to cancel enquiry: $e");
    }
    return false;
  }

  /// Get Planning PDF
  Future<dynamic> getPlanningPdf(String planningNo) async {
    try {
      final endpoint = "${ApiConstants.apiViewPlanningPdf}$planningNo";
      final response = await _dioClient.dio.post(endpoint, data: {});
      return response.data;
    } catch (e) {
      throw Exception("Failed to view planning pdf: $e");
    }
  }

  /// Select Employee list
  Future<List<dynamic>> selectEmployee(String type, String type1) async {
    try {
      final endpoint = "${ApiConstants.apiSelectEmployee}$_comId&type=$type&type1=$type1";
      final response = await _dioClient.dio.post(endpoint, data: {});
      if (response.data != null && response.data is List) {
        return response.data;
      }
    } catch (e) {
      throw Exception("Failed to load employees: $e");
    }
    return [];
  }
}
