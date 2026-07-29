import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/app_globals.dart';

class ForwardingSalaryRepository {
  final int comid = AppPreferences.getComid();


  Future<Map<String, dynamic>> initializeData() async {

    await sl<LegacyApiRepository>().GetRTINoForwarding(null, 0);
    await sl<LegacyApiRepository>().SelectEmployee(null, '', 'Operation');
    await sl<LegacyApiRepository>().loadComboS1(null, 0);

    return {
      'jobNoList': AppGlobals.JobNoList,
      'employeeList': AppGlobals.EmployeeList,
    };
  }

  Future<List<dynamic>> fetchRTINoForwarding(int billType) async {
    await sl<LegacyApiRepository>().GetRTINoForwarding(null, billType);
    return AppGlobals.JobNoList;
  }


  Future<Map<String, dynamic>?> fetchForwardingData(int saleOrderId) async {

    final activeComId = comid == 0 ? 6 : comid;

    final body = {
      'Comid': activeComId,
      'RTIMasterRefId': saleOrderId,
    };

    final result = await ApiClient.postRequest(ApiConstants.apiSelectForwarding, body);

    if (result != null && result is Map<String, dynamic> && result['IsSuccess'] == true) {
      if (result['Data1'] != null && (result['Data1'] as List).isNotEmpty) {
        return result['Data1'][0] as Map<String, dynamic>;
      }
    }
    return null;
  }


  Future<bool> saveForwardingSalary(Map<String, dynamic> masterPayload) async {
    final result = await ApiClient.postRequest(ApiConstants.apiInsertForwarding, [masterPayload]);

    if (result != null && result is Map<String, dynamic>) {
      return result['Result'] == 1 || result['IsSuccess'] == true;
    }
    return false;
  }
}