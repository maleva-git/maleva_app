import 'package:maleva/core/network/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'leave_request_model.dart';

class LeaveRequestApi {
  static const String _baseUrl = '${ApiConstants.port}/api/LeaveRequestApp';

  static Future<bool> addLeaveRequest(BuildContext context, {
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
        "CompanyRefId": AppGlobals.Comid,
        "ApplicantType": applicantType,
        "ApplicantRefId": applicantRefId,
        "LeaveTypeRefId": leaveTypeRefId,
        "FromDate": fromDate.toIso8601String(),
        "ToDate": toDate.toIso8601String(),
        "TotalDays": totalDays,
        "Reason": reason,
        "CreatedBy": AppGlobals.EmpRefId,
        "Active": 1,
        "StatusRefId": 1,
      };

      final response = await ApiClient.postRequest('$_baseUrl/SaveLeaveRequest', body);
      return response['IsSuccess'] == true;
    } catch (e) {
      debugPrint("Error AddLeaveRequest: $e");
      return false;
    }
  }

  static Future<List<LeaveRequestModel>> getLeaveRequests(BuildContext context, {
    int? applicantType,
    int? applicantRefId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      String url = '$_baseUrl/GetLeaveRequests?comid=${AppGlobals.Comid}';
      if (applicantType != null) url += '&applicantType=$applicantType';
      if (applicantRefId != null) url += '&applicantRefId=$applicantRefId';
      if (fromDate != null) url += '&fromDate=$fromDate';
      if (toDate != null) url += '&toDate=$toDate';

      debugPrint("Calling API: $url");
      final response = await ApiClient.postRequest(url, {});
      
      if (response != null && response is Map && response['IsSuccess'] == true && response['Data1'] != null) {
        List data = response['Data1'];
        return data.map((e) => LeaveRequestModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error GetLeaveRequests: $e");
      return [];
    }
  }

  static Future<bool> updateLeaveStatus(BuildContext context, {
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

      final response = await ApiClient.postRequest('$_baseUrl/UpdateLeaveStatus', body);
      return response['IsSuccess'] == true;
    } catch (e) {
      debugPrint("Error UpdateLeaveStatus: $e");
      return false;
    }
  }

  static Future<List<LeaveTypeModel>> getLeaveTypes(BuildContext context) async {
    try {
      String url = '$_baseUrl/GetLeaveTypes?comid=${AppGlobals.Comid}';
      debugPrint("🚀 API REQUEST");
      debugPrint("➡️ URL: $url");
      
      final response = await ApiClient.postRequest(url, {});
      
      debugPrint("✅ API RESPONSE");
      debugPrint("⬅️ Body: $response");
      
      if (response != null && response is Map) {
        if (response['IsSuccess'] == true && response['Data1'] != null) {
          List data = response['Data1'];
          return data.map((e) => LeaveTypeModel.fromJson(e)).toList();
        } else {
          debugPrint("⚠️ API Returned IsSuccess = false or Data1 is null");
        }
      } else {
        debugPrint("⚠️ Invalid Response Type");
      }
      return [];
    } catch (e) {
      debugPrint("❌ Error GetLeaveTypes: $e");
      return [];
    }
  }

  static Future<List<LeaveTypeModel>> getLeaveStatus(BuildContext context) async {
    try {
      String url = '$_baseUrl/GetLeaveStatus?comid=${AppGlobals.Comid}';
      final response = await ApiClient.postRequest(url, {});
      if (response != null && response is Map && response['IsSuccess'] == true && response['Data1'] != null) {
        List data = response['Data1'];
        return data.map((e) => LeaveTypeModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error GetLeaveStatus: $e");
      return [];
    }
  }
}
