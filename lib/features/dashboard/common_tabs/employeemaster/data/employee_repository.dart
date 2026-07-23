import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/network/api_client.dart';

class EmployeeRepository {
  /// Fetches the list of all employees
  Future<dynamic> fetchEmployees({required int comId}) async {
    final url = "${ApiConstants.apiSelectEmployeeDetails}$comId&Startindex=0&PageCount=100&keyword=&Column=All&type=";
    return await ApiClient.postRequest(url, '');
  }

  /// Deletes a specific employee
  Future<dynamic> deleteEmployee({required int id, required int comId}) async {
    final url = "${ApiConstants.apiDeleteEmployeeType}$id&Comid=$comId";
    return await ApiClient.postRequest(url, '');
  }

  /// Inserts or updates an employee
  Future<dynamic> saveEmployee({
    required List<Map<String, dynamic>> body,
    required int comId,
  }) async {
    final headers = {
      'Comid': comId.toString(),
    };
    return await ApiClient.postRequest(
        ApiConstants.apiInsertEmployeeDetails,
        body,
        headers: headers
    );
  }
}