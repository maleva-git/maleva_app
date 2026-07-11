import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_globals.dart';

class GoogleReviewRepository {
  /// Fetches the list of employees
  Future<dynamic> fetchEmployees({required int comId}) async {
    return await ApiClient.postRequest(
      "${AppGlobals.apiSelectEmployee}$comId&type=&type1=",
      null,
    );
  }

  /// Inserts or updates a Google Review entry
  Future<dynamic> saveReview({required List<Map<String, dynamic>> body}) async {
    return await ApiClient.postRequest(
      AppGlobals.apiGoogleReviewInsert,
      body,
    );
  }

  /// Fetches the list of Google Reviews based on date range and employee ID
  Future<dynamic> fetchReviews({
    required int comId,
    required String fromDate,
    required String toDate,
    required int empId,
  }) async {
    final url = Uri.parse(AppGlobals.apiSelectGoogleReview).replace(
      queryParameters: {
        'Comid': comId.toString(),
        'fromdate': fromDate,
        'todate': toDate,
        'Empid': empId.toString(),
      },
    ).toString();

    return await ApiClient.postRequest(url, null);
  }

  /// Deletes a specific Google Review by ID
  Future<dynamic> deleteReview({required int id}) async {
    final url = Uri.parse(AppGlobals.apiDeleteGoogleReview).replace(
      queryParameters: {'Id': id.toString()},
    ).toString();

    return await ApiClient.postRequest(url, null);
  }
}