import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;
import 'package:maleva/core/models/model.dart';

class DriverSalaryRepository {
  Future<Map<String, dynamic>> fetchSalaryData({
    required String fromDate,
    required String toDate,
  }) async {
    final master = {
      'Comid':      AppPreferences.getComid(),
      'DriverId':   AppPreferences.getEmpRefId(),
      'TruckId':    0,
      'FromDate':   fromDate,
      'ToDate':     toDate,
      'DriverName': '',
      'TruckName':  '',
    };

    // Use ApiClient.postRequest (assuming it handles the headers internally as discussed)
    final resultData = await ApiClient.postRequest(
      objfun.apiSelectDriverSalary,
      master,
    );

    List<dynamic> salaryList = [];
    double salaryAmount = 0.0;

    if (resultData != null) {
      final value = ResponseViewModel.fromJson(resultData);
      if (value.IsSuccess == true && value.data1 != null) {
        salaryList = List<dynamic>.from(value.data1 as List);
        for (final item in salaryList) {
          salaryAmount += (item['Amount'] as num?)?.toDouble() ?? 0.0;
        }
      }
    }

    return {
      'salaryList': salaryList,
      'salaryAmount': salaryAmount,
    };
  }
}