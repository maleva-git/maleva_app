import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/network/OnlineApi.dart' as OnlineApi;
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/app_globals.dart';

class ForwardingSalaryRepository {
  final int comid = AppPreferences.getComid();

  // ─── Initialize Data ───────────────────────────────────────────────────────
  Future<Map<String, dynamic>> initializeData() async {
    // We execute the legacy OnlineApi wrappers to populate the lists,
    // but return them so the BLoC can cache them locally instead of referencing globals.
    await OnlineApi.GetRTINoForwarding(null, 0);
    await OnlineApi.SelectEmployee(null, '', 'Operation');
    await OnlineApi.loadComboS1(null, 0);

    return {
      'jobNoList': AppGlobals.JobNoList,
      'employeeList': AppGlobals.EmployeeList,
    };
  }

  // ─── Fetch RTIs by Bill Type ───────────────────────────────────────────────
  Future<List<dynamic>> fetchRTINoForwarding(int billType) async {
    await OnlineApi.GetRTINoForwarding(null, billType);
    return AppGlobals.JobNoList;
  }

  // ─── Fetch Specific Forwarding Data ────────────────────────────────────────
  Future<Map<String, dynamic>?> fetchForwardingData(int saleOrderId) async {
    // In legacy code, comid defaults to 6 if 0
    final activeComId = comid == 0 ? 6 : comid;

    final body = {
      'Comid': activeComId,
      'RTIMasterRefId': saleOrderId,
    };

    final result = await ApiClient.postRequest(AppGlobals.apiSelectForwarding, body);

    if (result != null && result is Map<String, dynamic> && result['IsSuccess'] == true) {
      if (result['Data1'] != null && (result['Data1'] as List).isNotEmpty) {
        return result['Data1'][0] as Map<String, dynamic>;
      }
    }
    return null;
  }

  // ─── Save Forwarding Salary ────────────────────────────────────────────────
  Future<bool> saveForwardingSalary(Map<String, dynamic> masterPayload) async {
    final result = await ApiClient.postRequest(AppGlobals.apiInsertForwarding, [masterPayload]);

    if (result != null && result is Map<String, dynamic>) {
      return result['Result'] == 1 || result['IsSuccess'] == true;
    }
    return false;
  }
}