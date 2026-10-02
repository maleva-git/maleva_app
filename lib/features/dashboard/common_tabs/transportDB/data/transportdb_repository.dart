import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/di/injection.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/core/models/shared/email_model.dart';
import 'package:maleva/core/models/shared/r_t_i_details_view_model.dart';
import 'package:maleva/core/models/shared/employee_model.dart';
import 'package:maleva/core/models/shared/r_t_i_master_view_model.dart';

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
  Future<List<dynamic>> fetchPlanningData(int type) async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: type)));
    final url = type == 0 ? ApiConstants.PLANINGSearchDB : ApiConstants.PLANINGSearch;
    final result = await ApiClient.postRequest(url, {
      'Comid': comid, 'Fromdate': date, 'Todate': date, 'Search': '', 'Employeeid': 0, 'ETAType': 0,
    });
    return result is List ? result : [];
  }

  // ─── Enquiry ───────────────────────────────────────────────────────────────
  Future<List<dynamic>> fetchEnquiryData() async {
    final result = await ApiClient.postRequest(ApiConstants.apiSelectEnquiryMaster, {
      'Comid': comid, 'Fromdate': null, 'Todate': null, 'Employeeid': empRefId,
      'Invoice': false, 'Id': 0, 'JId': 0, 'DashboardStatus': 2,
    });

    List<dynamic> list = result is List ? List.from(result) : [];
    for (var i = 0; i < list.length; i++) {
      list[i]['SForwardingDate'] = list[i]['ForwardingDate'] == null
          ? ''
          : DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(list[i]['ForwardingDate']));
    }

    AppGlobals.EnquiryMasterList = list; // Keep legacy global sync
    return list;
  }

  Future<void> cancelEnquiry(int id) async {
    await ApiClient.postRequest('${ApiConstants.apiUpdateEnquiryMaster}$id&Comid=$comid&StatusName=CANCEL', null);
  }

  // ─── Emails ────────────────────────────────────────────────────────────────
  Future<List<EmployeeModel>> fetchEmployees() async {
    final result = await ApiClient.postRequest('${ApiConstants.apiSelectEmployee}$comid&type=&type1=', null);
    return result is List ? result.map((e) => EmployeeModel.fromJson(e)).toList() : [];
  }

  Future<List<EmailModel>> fetchEmailsForEmployee(int employeeId) async {
    final result = await ApiClient.postRequest(ApiConstants.apiSelectEmailData, [{'Id': employeeId}], headers: {'Comid': comid.toString()});
    if (result is Map<String, dynamic> && result['unread_unreplied_emails'] is List) {
      return (result['unread_unreplied_emails'] as List).map((e) => EmailModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> saveEmails(List<Map<String, dynamic>> payload) async {
    await ApiClient.postRequest(ApiConstants.apiInsertMailMaster, payload, headers: {'Comid': comid.toString()});
  }

  // ─── Google Reviews ────────────────────────────────────────────────────────
  Future<void> saveGoogleReview(Map<String, dynamic> payload) async {
    await ApiClient.postRequest(ApiConstants.apiGoogleReviewInsert, [payload]);
  }

  // ─── RTI / PDO ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchRTIData(String fromDate, String toDate, int driverId, int truckId, String search) async {
    final url = '${ApiConstants.apiSelectRTIView}$comid&Fromdate=$fromDate&Todate=$toDate&DId=$driverId&TId=$truckId&Employeeid=0&Search=$search';
    final result = await ApiClient.postRequest(url, null);

    List<RTIMasterViewModel> masterList = [];
    List<RTIDetailsViewModel> detailList = [];

    if (result is List && result.isNotEmpty) {
      masterList = (result[0]['salemaster'] as List).map((e) => RTIMasterViewModel.fromJson(e)).toList();
      detailList = (result[0]['saledetails'] as List).map((e) => RTIDetailsViewModel.fromJson(e)).toList();

      AppGlobals.RTIViewMasterList = masterList; // Keep legacy global sync
      AppGlobals.RTIViewDetailList = detailList; // Keep legacy global sync
    }

    return {'masterList': masterList, 'detailList': detailList};
  }

  Future<void> saveRTIData(List<Map<String, dynamic>> selectedDetails, List<RTIDetailsViewModel> rawDetailsToUpload, int masterId) async {
    final uri = Uri.parse('${ApiConstants.apiRTIDetailsInsert}$comid');
    final request = http.MultipartRequest('POST', uri);
    request.fields['objReceipt'] = jsonEncode(selectedDetails);
    request.fields['Comid'] = comid.toString();

    for (var d in rawDetailsToUpload) {
      if (d.RTIMasterRefId == masterId && d.isChecked && d.imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('Files_${d.Id}', d.imagePath!, filename: d.imageFile!.name));
      }
    }
    await request.send();
  }
}