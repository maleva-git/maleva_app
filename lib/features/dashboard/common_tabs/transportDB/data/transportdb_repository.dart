import 'package:maleva/core/enquiry/enquiry_api.dart';
import 'package:maleva/core/employee/email_inbox_api.dart';
import 'dart:io';
import 'package:maleva/core/employee/google_review_api.dart';
import 'package:maleva/core/employee/employee_api.dart';
import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/models/shared/email_model.dart';
import 'package:maleva/core/models/shared/r_t_i_details_view_model.dart';
import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/rti/rti_api.dart';

class TransportDashboardRepository {
  final int comid = AppPreferences.getComid();
  final int empRefId = AppPreferences.getEmpRefId();

  // ─── Sales (shared Java /api/dashboard) ────────────────────────────────────
  Future<Map<String, dynamic>> fetchSalesData(int empId) async {
    final desk = await sl<DashboardApi>().salesDesk(comid, empId);
    return {
      'withoutInvoiceCount': desk.withoutInvoice,
      'totalCount': desk.total,
      'totalBilledCount': desk.billed,
      'totalUnBilledCount': desk.unbilled,
      'salesReport': desk.statuses,
    };
  }

  /// `[{Id, AccountName}]`: the employees this user may look at.
  Future<List<Map<String, dynamic>>> fetchRulesType() => sl<DashboardApi>().employeeRules(comid, empRefId);

  // ─── Transport/Planning ────────────────────────────────────────────────────
  Future<List<dynamic>> fetchPlanningData(int type) => sl<DashboardApi>().transportList(comid, type);

  // ─── Enquiry ───────────────────────────────────────────────────────────────
  /// The open enquiries of the employee and their team (shared Java enquiry API).
  Future<List<dynamic>> fetchEnquiryData() async {
    final rows = await GetIt.instance<EnquiryApi>().search(employeeId: empRefId, team: true);
    AppGlobals.EnquiryMasterList = rows; // Keep legacy global sync
    return rows;
  }

  Future<void> cancelEnquiry(int id) => GetIt.instance<EnquiryApi>().setStatus(id, 'CANCEL');

  // ─── Emails ────────────────────────────────────────────────────────────────
  Future<List<EmployeeModel>> fetchEmployees() async {
    // the shared Java employee list
    return GetIt.instance<EmployeeApi>().dropdown();
  }

  /// The employee's unanswered mail of the last day (shared Java inbox).
  Future<List<EmailModel>> fetchEmailsForEmployee(int employeeId) =>
      GetIt.instance<EmailInboxApi>().unanswered(employeeId);

  /// Keeps the ticked mails as the employee's inbox entries.
  Future<void> saveEmails(int employeeId, List<EmailModel> emails) async {
    await GetIt.instance<EmailInboxApi>().keep(employeeId, emails);
  }

  // ─── Google Reviews ────────────────────────────────────────────────────────
  /// A new staff Google review on the shared Java API.
  Future<void> saveGoogleReview({
    required String refDate,
    required int employeeId,
    required int googleReview,
    required String googleMsg,
    required String shopName,
    required String mobileNo,
  }) async {
    await GetIt.instance<GoogleReviewApi>().save(
      refDate: refDate,
      employeeId: employeeId,
      googleReview: googleReview,
      googleMsg: googleMsg,
      shopName: shopName,
      mobileNo: mobileNo,
    );
  }


  // ─── RTI / PDO ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchRTIData(String fromDate, String toDate, int driverId, int truckId, String search) async {
    // the shared Java RTI list (a driver token gets its own RTIs only)
    final list = await GetIt.instance<RtiApi>().withJobs(
        fromDate: fromDate, toDate: toDate, driverId: driverId, truckId: truckId, search: search);
    final masterList = list.masters;
    final detailList = list.details;
    AppGlobals.RTIViewMasterList = masterList; // Keep legacy global sync
    AppGlobals.RTIViewDetailList = detailList; // Keep legacy global sync

    return {'masterList': masterList, 'detailList': detailList};
  }

  /// Saves the checked lines' RTI status with their photos (Java port of
  /// InsertRTIStatus / SP_RTIStatus).
  Future<void> saveRTIData(List<Map<String, dynamic>> selectedDetails, List<RTIDetailsViewModel> rawDetailsToUpload, int masterId) async {
    final photos = <int, File>{
      for (final d in rawDetailsToUpload)
        if (d.RTIMasterRefId == masterId && d.isChecked && d.imageFile != null) d.Id: File(d.imageFile!.path),
    };
    await GetIt.instance<RtiApi>().saveStatuses(selectedDetails, photos: photos);
  }

}