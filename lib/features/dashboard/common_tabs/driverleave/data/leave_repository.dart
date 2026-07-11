import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/utils/session_manager.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'leave_request_model.dart';

class LeaveRepository {
  final DioClient _dioClient;
  final SessionManager _sessionManager;
  late final String _baseUrl;

  LeaveRepository(this._dioClient, this._sessionManager) {
    _baseUrl = '${ApiConstants.port}/api/LeaveRequestApp';
  }

  Future<bool> addLeaveRequest({
    required int leaveTypeRefId,
    required DateTime fromDate,
    required DateTime toDate,
    required int totalDays,
    required String reason,
    required int applicantRefId,
    int applicantType = 2,
  }) async {
    try {
      final body = {
        "CompanyRefId": _sessionManager.companyId,
        "ApplicantType": applicantType,
        "ApplicantRefId": applicantRefId,
        "LeaveTypeRefId": leaveTypeRefId,
        "FromDate": fromDate.toIso8601String(),
        "ToDate": toDate.toIso8601String(),
        "TotalDays": totalDays,
        "Reason": reason,
        "CreatedBy": _sessionManager.empRefId,
        "Active": 1,
        "StatusRefId": 1,
      };

      final response = await _dioClient.dio.post('$_baseUrl/SaveLeaveRequest', data: body);
      return response.data['IsSuccess'] == true;
    } catch (e) {
      debugPrint("Error AddLeaveRequest: $e");
      return false;
    }
  }

  Future<List<LeaveRequestModel>> getLeaveRequests({
    int? applicantType,
    int? applicantRefId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final queryParams = {
        'comid': _sessionManager.companyId,
        if (applicantType != null) 'applicantType': applicantType,
        if (applicantRefId != null) 'applicantRefId': applicantRefId,
        if (fromDate != null) 'fromDate': fromDate,
        if (toDate != null) 'toDate': toDate,
      };

      final response = await _dioClient.dio.post(
        '$_baseUrl/GetLeaveRequests', 
        queryParameters: queryParams,
        data: {}, // Sometimes backend requires empty body for POST
      );
      
      if (response.data != null && response.data['IsSuccess'] == true && response.data['Data1'] != null) {
        List data = response.data['Data1'];
        return data.map((e) => LeaveRequestModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error GetLeaveRequests: $e");
      return [];
    }
  }

  Future<bool> updateLeaveStatus({
    required int id,
    required int statusRefId,
    required String reviewRemark,
    required int reviewedBy,
  }) async {
    try {
      final body = {
        "Id": id,
        "StatusRefId": statusRefId,
        "ReviewedBy": reviewedBy,
        "ReviewRemark": reviewRemark,
      };

      final response = await _dioClient.dio.post('$_baseUrl/UpdateLeaveStatus', data: body);
      return response.data['IsSuccess'] == true;
    } catch (e) {
      debugPrint("Error UpdateLeaveStatus: $e");
      return false;
    }
  }

  Future<List<LeaveTypeModel>> getLeaveTypes() async {
    try {
      final response = await _dioClient.dio.post(
        '$_baseUrl/GetLeaveTypes', 
        queryParameters: {'comid': _sessionManager.companyId},
        data: {},
      );
      
      if (response.data != null && response.data['IsSuccess'] == true && response.data['Data1'] != null) {
        List data = response.data['Data1'];
        return data.map((e) => LeaveTypeModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error GetLeaveTypes: $e");
      return [];
    }
  }
}
