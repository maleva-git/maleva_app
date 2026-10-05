import 'package:maleva/core/employee/google_review_api.dart';
import 'package:maleva/core/models/shared/review.dart';
import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/employee/employee_api.dart';

class GoogleReviewRepository {
  /// The employees, from the shared Java employee list
  Future<List<EmployeeModel>> fetchEmployees({required int comId}) =>
      GetIt.instance<EmployeeApi>().dropdown();


  /// Adds (id 0) or updates a review on the shared Java API; answers the id.
  Future<int> saveReview({
    int id = 0,
    required String refDate,
    required int employeeId,
    required int googleReview,
    required String googleMsg,
    required String shopName,
    required String mobileNo,
  }) =>
      GetIt.instance<GoogleReviewApi>().save(
        id: id,
        refDate: refDate,
        employeeId: employeeId,
        googleReview: googleReview,
        googleMsg: googleMsg,
        shopName: shopName,
        mobileNo: mobileNo,
      );

  /// Reviews dated in the days, one employee's when [empId] is not 0.
  Future<List<Review>> fetchReviews({
    required String fromDate,
    required String toDate,
    required int empId,
  }) async =>
      (await GetIt.instance<GoogleReviewApi>().list(fromDate: fromDate, toDate: toDate, employeeId: empId))
          .map(Review.fromJava)
          .toList();

  /// Deletes a review of the company.
  Future<void> deleteReview({required int id}) => GetIt.instance<GoogleReviewApi>().delete(id);
}
