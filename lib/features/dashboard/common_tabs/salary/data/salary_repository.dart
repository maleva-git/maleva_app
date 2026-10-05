import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/employee/boarding_salary_api.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The boarding salary rows and their total (shared Java
/// `/api/boarding-settlement/monthly-salary`, the React page's rate rule; was
/// .NET BoardingSalaryApp/SelectBoardingSalaryByEmpId). An admin sees every
/// officer of the company, anyone else their own.
class SalaryRepository {
  Future<Map<String, dynamic>> fetchSalaryData(String fromDate, String toDate) async {
    final isAdmin = AppPreferences.getRulesType().toUpperCase() == 'ADMIN' || AppPreferences.getRoleId() == 1;
    final salaryList = await sl<BoardingSalaryApi>().monthly(
      fromDate: fromDate,
      toDate: toDate,
      employeeId: isAdmin ? 0 : AppPreferences.getEmpRefId(),
    );
    final salaryAmount = salaryList.fold<double>(0.0, (sum, item) => sum + JsonRead.number(item['calculatedRate']));
    return {
      'salaryList': salaryList,
      'salaryAmount': salaryAmount,
    };
  }
}
