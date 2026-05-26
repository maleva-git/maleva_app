import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class SalaryRepository {
  Future<Map<String, dynamic>> fetchSalaryData(String fromDate, String toDate) async {
    try {
      final master = {
        'Comid': AppPreferences.getComid(),
        'Employeeid': AppPreferences.getEmpRefId(),
        'FromDate': fromDate,
        'ToDate': toDate,
      };

      // Assuming ApiClient.postRequest handles the headers internally
      final response = await ApiClient.postRequest(
        objfun.apiSelectBoardingSalary,
        master,
      );

      List<Map<String, dynamic>> salaryList = [];
      double salaryAmount = 0.0;

      if (response != null) {
        final value = ResponseViewModel.fromJson(response);

        if (value.IsSuccess == true && value.data1 != null) {
          final rawList = value.data1 as List;

          if (rawList.isNotEmpty) {
            salaryList = rawList.cast<Map<String, dynamic>>();

            // Calculate total inside the data layer
            salaryAmount = salaryList.fold(
              0.0,
                  (sum, item) => sum + ((item["NetAmt"] as num?)?.toDouble() ?? 0.0),
            );
          }
        }
      }

      return {
        'salaryList': salaryList,
        'salaryAmount': salaryAmount,
      };
    } catch (e) {
      throw Exception('Failed to load salary data: $e');
    }
  }
}