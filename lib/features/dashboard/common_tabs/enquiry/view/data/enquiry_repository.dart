import 'package:get_it/get_it.dart';
import 'package:maleva/core/enquiry/enquiry_api.dart';

/// The Enquiry tab, on the shared Java enquiry API (change `enquiry-on-shared-java-api`).
class EnquiryRepository {
  /// The open enquiries of the employee and their team (Java rows).
  Future<List<Map<String, dynamic>>> fetchEnquiries({required int employeeId}) =>
      GetIt.instance<EnquiryApi>().search(employeeId: employeeId, team: true);

  Future<void> cancelEnquiry(int id) => GetIt.instance<EnquiryApi>().setStatus(id, 'CANCEL');
}
