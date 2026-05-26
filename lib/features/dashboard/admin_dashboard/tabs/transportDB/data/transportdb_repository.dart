import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun;

class TransportDashboardRepository {
  final int comid = AppPreferences.getComid();
  final int empRefId = AppPreferences.getEmpRefId();

  // ─── Sales ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchSalesData(int empId) async {
    final now = DateTime.now();
    final toDate = DateFormat('yyyy-MM-dd').format(now);
    final fromDate = DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));

    // Notice we use ApiClient for everything now
    final r1 = await ApiClient.postRequest(objfun.SaleInvoiceCountDB, {
      'Comid': comid, 'Fromdate': '2024-10-01', 'Todate': toDate, 'Statusid': 0,
      'Employeeid': empId, 'Remarks': 2, 'Search': '0', 'completestatusnotshow': false, 'Invoice': false,
    });
    final r2 = await ApiClient.postRequest(objfun.SaleInvoiceCountDB, {
      'Comid': comid, 'Fromdate': fromDate, 'Todate': toDate, 'Statusid': 0,
      'Employeeid': empId, 'Remarks': 0, 'Search': '0', 'completestatusnotshow': false, 'Invoice': false,
    });
    final r3 = await ApiClient.postRequest(objfun.SaleInvoiceCountDB, {
      'Comid': comid, 'Fromdate': fromDate, 'Todate': toDate, 'Statusid': 0,
      'Employeeid': empId, 'Remarks': 1, 'Search': '0', 'completestatusnotshow': false, 'Invoice': false,
    });
    final r4 = await ApiClient.postRequest(objfun.SaleInvoiceCountDB, {
      'Comid': comid, 'Fromdate': fromDate, 'Todate': toDate, 'Statusid': 0,
      'Employeeid': empId, 'Remarks': 2, 'Search': '0', 'completestatusnotshow': false, 'Invoice': false,
    });
    final r5 = await ApiClient.postRequest(objfun.SelectSalesOrderStatus, {
      'Comid': comid, 'Employeeid': empId
    });

    return {
      'withoutInvoiceCount': (r1 is List) ? r1.length : 0,
      'totalCount': (r2 is List) ? r2.length : 0,
      'totalBilledCount': (r3 is List) ? r3.length : 0,
      'totalUnBilledCount': (r4 is List) ? r4.length : 0,
      'salesReport': (r5 is List) ? r5 : [],
    };
  }

  Future<List<Map<String, dynamic>>> fetchRulesType() async {
    final result = await ApiClient.postRequest(objfun.LoadRulesType, {'Comid': comid, 'Employeeid': empRefId});
    return result is List ? result.cast<Map<String, dynamic>>() : [];
  }

  // ─── Transport/Planning ────────────────────────────────────────────────────
  Future<List<dynamic>> fetchPlanningData(int type) async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now().add(Duration(days: type)));
    final url = type == 0 ? objfun.PLANINGSearchDB : objfun.PLANINGSearch;
    final result = await ApiClient.postRequest(url, {
      'Comid': comid, 'Fromdate': date, 'Todate': date, 'Search': '', 'Employeeid': null, 'ETAType': 0,
    });
    return result is List ? result : [];
  }

  // ─── Enquiry ───────────────────────────────────────────────────────────────
  Future<List<dynamic>> fetchEnquiryData() async {
    final result = await ApiClient.postRequest(objfun.apiSelectEnquiryMaster, {
      'Comid': comid, 'Fromdate': null, 'Todate': null, 'Employeeid': empRefId,
      'Invoice': false, 'Id': 0, 'JId': 0, 'DashboardStatus': 2,
    });

    List<dynamic> list = result is List ? List.from(result) : [];
    for (var i = 0; i < list.length; i++) {
      list[i]['SForwardingDate'] = list[i]['ForwardingDate'] == null
          ? ''
          : DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(list[i]['ForwardingDate']));
    }

    objfun.EnquiryMasterList = list; // Keep legacy global sync
    return list;
  }

  Future<void> cancelEnquiry(int id) async {
    await ApiClient.postRequest('${objfun.apiUpdateEnquiryMaster}$id&Comid=$comid&StatusName=CANCEL', null);
  }

  // ─── Emails ────────────────────────────────────────────────────────────────
  Future<List<EmployeeModel>> fetchEmployees() async {
    final result = await ApiClient.postRequest('${objfun.apiSelectEmployee}$comid&type=&type1=', null);
    return result is List ? result.map((e) => EmployeeModel.fromJson(e)).toList() : [];
  }

  Future<List<EmailModel>> fetchEmailsForEmployee(int employeeId) async {
    final result = await ApiClient.postRequest(objfun.apiSelectEmailData, [{'Id': employeeId}], headers: {'Comid': comid.toString()});
    if (result is Map<String, dynamic> && result['unread_unreplied_emails'] is List) {
      return (result['unread_unreplied_emails'] as List).map((e) => EmailModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> saveEmails(List<Map<String, dynamic>> payload) async {
    await ApiClient.postRequest(objfun.apiInsertMailMaster, payload, headers: {'Comid': comid.toString()});
  }

  // ─── Google Reviews ────────────────────────────────────────────────────────
  Future<void> saveGoogleReview(Map<String, dynamic> payload) async {
    await ApiClient.postRequest(objfun.apiGoogleReviewInsert, [payload]);
  }

  // ─── RTI / PDO ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchRTIData(String fromDate, String toDate, int driverId, int truckId, String search) async {
    final url = '${objfun.apiSelectRTIView}$comid&Fromdate=$fromDate&Todate=$toDate&DId=$driverId&TId=$truckId&Employeeid=0&Search=$search';
    final result = await ApiClient.postRequest(url, null);

    List<RTIMasterViewModel> masterList = [];
    List<RTIDetailsViewModel> detailList = [];

    if (result is List && result.isNotEmpty) {
      masterList = (result[0]['salemaster'] as List).map((e) => RTIMasterViewModel.fromJson(e)).toList();
      detailList = (result[0]['saledetails'] as List).map((e) => RTIDetailsViewModel.fromJson(e)).toList();

      objfun.RTIViewMasterList = masterList; // Keep legacy global sync
      objfun.RTIViewDetailList = detailList; // Keep legacy global sync
    }

    return {'masterList': masterList, 'detailList': detailList};
  }

  Future<void> saveRTIData(List<Map<String, dynamic>> selectedDetails, List<RTIDetailsViewModel> rawDetailsToUpload, int masterId) async {
    final uri = Uri.parse('${objfun.apiRTIDetailsInsert}$comid');
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