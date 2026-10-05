import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/reports/transaction_report_api.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The driver's RTI job lines and their total (shared Java Driver RTI detailed
/// report rows, was .NET TransactionReportApp/DriverRTIDetailedReport). The
/// server keeps a driver token to the driver's own RTIs.
class DriverSalaryRepository {
  Future<Map<String, dynamic>> fetchSalaryData({
    required String fromDate,
    required String toDate,
  }) async {
    final salaryList = await sl<TransactionReportApi>().driverJobs(fromDate: fromDate, toDate: toDate);
    double salaryAmount = 0.0;
    for (final item in salaryList) {
      salaryAmount += JsonRead.number(item['amount']);
    }
    return {
      'salaryList': salaryList,
      'salaryAmount': salaryAmount,
    };
  }
}
