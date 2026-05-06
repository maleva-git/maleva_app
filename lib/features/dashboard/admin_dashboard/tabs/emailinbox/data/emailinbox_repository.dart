import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class EmailInboxRepository {
  /// Fetches the list of employees
  Future<dynamic> fetchEmployees({required int comId}) async {
    // We send a POST request with a null body as per the original logic
    return await ApiClient.postRequest(
      "${objfun.apiSelectEmployee}$comId&type=&type1=",
      null,
    );
  }

  /// Fetches the emails for a specific employee
  Future<dynamic> fetchEmails({required List<Map<String, dynamic>> body}) async {
    final headers = {
      'Comid': (objfun.storagenew.getInt('Comid') ?? 0).toString(),
    };
    return await ApiClient.postRequest(
      objfun.apiSelectEmailData,
      body,
      headers: headers,
    );
  }

  /// Saves the modified emails back to the server
  Future<dynamic> saveEmails({required List<Map<String, dynamic>> body}) async {
    final headers = {
      'Comid': (objfun.storagenew.getInt('Comid') ?? 0).toString(),
    };
    return await ApiClient.postRequest(
      objfun.apiInsertMailMaster,
      body,
      headers: headers,
    );
  }
}