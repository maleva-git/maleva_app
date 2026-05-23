import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class PlanningDetailsRepository {
  Future<List<dynamic>> fetchPlanningDetails() async {
    try {
      final int comid = AppPreferences.getComid();
      final int empRefId = AppPreferences.getEmpRefId(); // Replaces objfun.EmpRefId

      final Map<String, dynamic> body = {
        'Comid': comid,
        'Employeeid': empRefId,
        'Fromdate': null,
        'Todate': null,
      };

      // Make the API call
      final response = await ApiClient.postRequest(
        ApiConstants.PLANINGSearch,
        body,
      );

      if (response != null && response is List && response.isNotEmpty) {
        final list = List<dynamic>.from(response);

        // Keep global list in sync for any legacy pages that still rely on it
        objfun.PlanningEditList = list;

        return list;
      } else {
        objfun.PlanningEditList = [];
        return [];
      }
    } catch (e) {
      throw Exception('Failed to fetch planning details: $e');
    }
  }
}