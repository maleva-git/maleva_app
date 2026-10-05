import 'package:maleva/core/network/legacy_api_repository.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/employee/forwarding_salary_api.dart';
import 'package:maleva/core/utils/app_globals.dart';

class ForwardingSalaryRepository {

  Future<Map<String, dynamic>> initializeData() async {

    await sl<LegacyApiRepository>().GetRTINoForwarding(null, 0);
    await sl<LegacyApiRepository>().SelectEmployee(null, '', 'Operation');

    return {
      'jobNoList': AppGlobals.JobNoList,
      'employeeList': AppGlobals.EmployeeList,
    };
  }

  Future<List<dynamic>> fetchRTINoForwarding(int billType) async {
    await sl<LegacyApiRepository>().GetRTINoForwarding(null, billType);
    return AppGlobals.JobNoList;
  }


  /// The RTI's forwarding salary (shared Java `/api/forwarding-salaries/entries`,
  /// was .NET ForwardingSalaryApp/SelectForwardingSalary), or null.
  Future<Map<String, dynamic>?> fetchForwardingData(int rtiId) => sl<ForwardingSalaryApi>().forRti(rtiId);

  /// Adds or updates it (was .NET InsertForwardingSalary / SP_ForwardingSalary).
  /// A refusal throws an [ApiFailure] with the server's reason.
  Future<int> saveForwardingSalary({
    required int id,
    required int rtiId,
    required int sealEmployeeId,
    required int breakSealEmployeeId,
    required double salary1,
    required double salary2,
  }) =>
      sl<ForwardingSalaryApi>().save(
        id: id,
        rtiId: rtiId,
        sealEmployeeId: sealEmployeeId,
        breakSealEmployeeId: breakSealEmployeeId,
        salary1: salary1,
        salary2: salary2,
      );
}
