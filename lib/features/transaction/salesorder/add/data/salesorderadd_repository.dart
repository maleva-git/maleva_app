import 'dart:convert';
 import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/session_manager.dart';

class SalesOrderAddRepository {
  final DioClient _dioClient;
  final SessionManager _sessionManager;

  SalesOrderAddRepository(this._dioClient, this._sessionManager);

  int get _comId => _sessionManager.companyId;

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
    } catch (e) {
      print("Error in selectAddressList: $e");
    }
    return [];
  }

  Future<List<dynamic>> selectAddressDetails(String keyword) async {
    try {
      final endpoint = "${ApiConstants.apiSelectAddressDetails}$_comId&KeyWord=${Uri.encodeComponent(keyword)}";
      final response = await _dioClient.dio.post(endpoint, data: {});
      dynamic responseData = response.data;
      if (responseData is String) {
        if (responseData.trim().isEmpty) return [];
        responseData = jsonDecode(responseData);
      }
      if (responseData is List) {
        return responseData;
      }
    } catch (e) {
      print("Error in selectAddressDetails: $e");
    }
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
    } catch (e) {
      print("Error in selectAgentCompany: $e");
    }
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
    } catch (e) {
      print("Error in selectEmployee: $e");
    }
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
    } catch (e) {
      print("Error in selectAllJobStatus: $e");
    }
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
    } catch (e) {
      print("Error in selectCustomer: $e");
    }
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
    } catch (e) {
      print("Error in selectJobType: $e");
    }
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
    } catch (e) {
      print("Error in selectAgentAll: $e");
    }
    return [];
  }
}
