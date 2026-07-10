import 'dart:convert';
 import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/session_manager.dart';

class SalesOrderAddRepository {
  final DioClient _dioClient;
  final SessionManager _sessionManager;

  SalesOrderAddRepository(this._dioClient, this._sessionManager);

  int get _comId => _sessionManager.companyId;

  Future<String> maxSaleOrderNo(String billType) async {
    try {
      final endpoint = "${ApiConstants.apiMaxSaleOrderNo}$_comId&BillType=$billType";
      final response = await _dioClient.dio.post(endpoint, data: {});
      if (response.data != null && response.data.toString().isNotEmpty) {
        return response.data.toString();
      }
    } catch (e) {
      // Return empty on error
    }
    return "";
  }

  Future<double> loadCustomerCurrency(int customerId) async {
    try {
      final endpoint = "${ApiConstants.apiGetCurrencyValue}$_comId&CustId=$customerId";
      final response = await _dioClient.dio.post(endpoint, data: {});
      if (response.data != null && response.data.toString().isNotEmpty) {
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
      // Ignored
    }
    return 0.0;
  }

  Future<List<dynamic>> selectAddressList() async {
    try {
      final endpoint = "${ApiConstants.apiSelectAddressList}$_comId";
      final response = await _dioClient.dio.post(endpoint, data: {});
      dynamic responseData = response.data;
      if (responseData is String) {
        if (responseData.trim().isEmpty) return [];
        responseData = jsonDecode(responseData);
      }
      if (responseData is List) {
        return responseData;
      }
    } catch (e) { }
    return [];
  }

  Future<List<dynamic>> selectAddressDetails(String keyword) async {
    try {
      final endpoint = "${ApiConstants.apiSelectAddressDetails}$_comId&KeyWord=$keyword";
      final response = await _dioClient.dio.post(endpoint, data: {});
      dynamic responseData = response.data;
      if (responseData is String) {
        if (responseData.trim().isEmpty) return [];
        responseData = jsonDecode(responseData);
      }
      if (responseData is List) {
        return responseData;
      }
    } catch (e) { }
    return [];
  }

  Future<List<dynamic>> selectAgentCompany() async {
    try {
      final endpoint = "${ApiConstants.apiSelectAgentCompany}$_comId";
      final response = await _dioClient.dio.post(endpoint, data: {});
      dynamic responseData = response.data;
      if (responseData is String) {
        if (responseData.trim().isEmpty) return [];
        responseData = jsonDecode(responseData);
      }
      if (responseData is List) {
        return responseData;
      }
    } catch (e) { }
    return [];
  }

  Future<List<dynamic>> selectEmployee(String searchVal, String deptName) async {
    try {
      final endpoint = "${ApiConstants.apiSelectEmployee}$_comId&type=$searchVal&type1=$deptName";
      final response = await _dioClient.dio.post(endpoint, data: {});
      dynamic responseData = response.data;
      if (responseData is String) {
        if (responseData.trim().isEmpty) return [];
        responseData = jsonDecode(responseData);
      }
      if (responseData is List) {
        return responseData;
      }
    } catch (e) { }
    return [];
  }

  Future<Map<String, dynamic>> selectAllJobStatus(int jobId) async {
    try {
      final endpoint = "${ApiConstants.apiSelectAllJobStatus}$_comId&Jobid=$jobId";
      final response = await _dioClient.dio.post(endpoint, data: {});
      dynamic responseData = response.data;
      if (responseData is String) {
        if (responseData.trim().isEmpty) return {};
        responseData = jsonDecode(responseData);
      }
      if (responseData is List && responseData.isNotEmpty) {
        return responseData[0] as Map<String, dynamic>;
      }
    } catch (e) { }
    return {};
  }

  Future<List<dynamic>> selectCustomer() async {
    try {
      final endpoint = "${ApiConstants.apiSelectCustomer}$_comId";
      final response = await _dioClient.dio.post(endpoint, data: {});
      dynamic responseData = response.data;
      if (responseData is String) {
        if (responseData.trim().isEmpty) return [];
        responseData = jsonDecode(responseData);
      }
      if (responseData is List) {
        return responseData;
      }
    } catch (e) { }
    return [];
  }

  Future<List<dynamic>> selectJobType() async {
    try {
      final endpoint = "${ApiConstants.apiSelectJobType}$_comId";
      final response = await _dioClient.dio.post(endpoint, data: {});
      dynamic responseData = response.data;
      if (responseData is String) {
        if (responseData.trim().isEmpty) return [];
        responseData = jsonDecode(responseData);
      }
      if (responseData is List) {
        return responseData;
      }
    } catch (e) { }
    return [];
  }

  Future<List<dynamic>> selectAgentAll(int agentCompanyId) async {
    try {
      final endpoint = "${ApiConstants.apiSelectAgentAll}$_comId&Jobid=$agentCompanyId";
      final response = await _dioClient.dio.post(endpoint, data: {});
      dynamic responseData = response.data;
      if (responseData is String) {
        if (responseData.trim().isEmpty) return [];
        responseData = jsonDecode(responseData);
      }
      if (responseData is List) {
        return responseData;
      }
    } catch (e) { }
    return [];
  }
}
