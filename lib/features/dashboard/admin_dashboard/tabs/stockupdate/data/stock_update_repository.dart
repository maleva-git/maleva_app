import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/api_client.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/clsfunction.dart' as objfun; // Only for image path parsing

class StockUpdateRepository {
  final int comid = AppPreferences.getComid();
  final int empRefId = AppPreferences.getEmpRefId();
  final int driverLogin = AppPreferences.getDriverLogin(); // Assuming this is saved in prefs

  // ─── Initialize ────────────────────────────────────────────────────────────
  Future<void> prefetchJobData() async {
    // Replaces OnlineApi.GetJobNoForwarding(null, 0)
    await ApiClient.postRequest("${objfun.apiGetJobNo}$comid&Type=0", null);
  }

  // ─── Scan Barcode ──────────────────────────────────────────────────────────
  Future<String?> scanBarcode() async {
    await objfun.barcodeScanning();
    if (objfun.barcodeerror == true) return null;
    return objfun.barcodestring as String;
  }

  // ─── Load Stock Data (First Scan) ──────────────────────────────────────────
  Future<Map<String, dynamic>?> loadStockData(String barcodeLabel) async {
    final response = await ApiClient.postRequest(
        "${objfun.apiEditStockIn}0&barcodeLabel=$barcodeLabel&Comid=$comid", null);

    if (response != null) {
      final value = ResponseViewModel.fromJson(response);
      if (value.IsSuccess == true && value.data1 != null && value.data1.isNotEmpty) {
        return value.data1[0] as Map<String, dynamic>;
      }
    }
    return null;
  }

  // ─── Load Job Details & Calculate Status & Boarding Officers ─────────────
  Future<Map<String, dynamic>?> loadJobDetails(int saleOrderId) async {
    final response = await ApiClient.postRequest(
        "${objfun.apiSaleOrderDetailsLoad}$comid&Id=$saleOrderId", null);

    if (response == null) return null;
    final value = ResponseViewModel.fromJson(response);
    if (value.IsSuccess != true || value.data1 == null || value.data1.isEmpty) return null;

    final data = value.data1[0];
    final soId = data['Id'] as int;
    final jobMId = data['JobMasterRefId'] as int;
    final jStatus = data['JStatus'] as int;

    // Fetch Job Statuses
    final statusListRes = await ApiClient.postRequest(
        "${objfun.apiSelectAllJobStatus}$comid&JobMasterRefId=$jobMId", null);

    int statusId = 0;
    String statusName = '';

    // Status Transition Logic
    if (driverLogin == 1) {
      if (jStatus == 3) statusId = 11;
      else if (jStatus == 11) statusId = 19;
      else return null; // Invalid state
    } else {
      if (jStatus == 19) statusId = 4;
      else if (jStatus == 4) statusId = 7;
      else if (jStatus == 7) statusId = 5;
      else return null; // Invalid state
    }

    if (statusListRes is List) {
      final match = statusListRes.firstWhere((s) => s['Status'] == statusId, orElse: () => null);
      if (match != null) statusName = match['StatusName'];
    }

    // Boarding Officer Logic
    int boardId1 = 0;
    int boardId2 = 0;
    double boardAmt1 = 0.0;
    double boardAmt2 = 0.0;

    if (statusId == 7) {
      boardId1 = empRefId;
      boardAmt1 = 50;
    } else if (statusId == 5) {
      final editRes = await ApiClient.postRequest("${objfun.apiEditSalesOrder}$soId&CNumber=0", null);
      if (editRes != null && editRes is List && editRes.isNotEmpty) {
        boardId1 = editRes[0]['LBoardingOfficerRefid'] ?? 0;
        if (boardId1 != empRefId) {
          boardId2 = empRefId;
          boardAmt1 = 30;
          boardAmt2 = 30;
        }
      }
    }

    return {
      'saleOrderId': soId,
      'jobId': jobMId,
      'statusId': statusId,
      'statusName': statusName,
      'boardOfficerId1': boardId1,
      'boardOfficerId2': boardId2,
      'boardOfficerAmt1': boardAmt1,
      'boardOfficerAmt2': boardAmt2,
    };
  }

  // ─── Delete Image ──────────────────────────────────────────────────────────
  Future<ResponseViewModel?> deleteImage(int saleOrderId, String folder, String imageName) async {
    final filePath = '/Upload/$comid/SalesOrder/$saleOrderId/$folder/$imageName';
    final header = {
      'Comid': comid.toString(),
      'Id': saleOrderId.toString(),
      'FolderName': 'SalesOrder',
      'FileName': filePath,
      'SubFolderName': folder,
    };

    final result = await ApiClient.postRequest(objfun.apiDeleteimage, null, headers: header);
    return result != null ? ResponseViewModel.fromJson(result) : null;
  }

  // ─── Save Stock Update ───────────────────────────────────────────────────
  Future<ResponseViewModel?> saveStockUpdate(int stockId, int statusId, int warehouseId, List<String> imageUrls) async {
    final url = '${objfun.apiUpdateStockIn}$stockId&StatusId=$statusId&Comid=$comid&PortRefid=$warehouseId&ImageURL';
    final result = await ApiClient.postRequest(url, imageUrls);
    return result != null ? ResponseViewModel.fromJson(result) : null;
  }

  // ─── Update Boarding Officer ─────────────────────────────────────────────
  Future<void> updateBoardingOfficer(int saleOrderId, int statusType, int boardOfficerId1, int boardOfficerId2, double boardOfficerAmt1, double boardOfficerAmt2) async {
    if (statusType != 7 && statusType != 5) return;
    if (statusType == 5 && boardOfficerId1 == empRefId) return;

    Map<String, dynamic> master;
    if (statusType == 7) {
      master = {
        'Id': saleOrderId,
        'CompanyRefId': comid,
        'EmployeeRefId': empRefId == 0 ? null : empRefId,
        'LBoardingOfficerRefid': boardOfficerId1,
        'LBoardingAmount': boardOfficerAmt1,
      };
    } else {
      master = {
        'Id': saleOrderId,
        'CompanyRefId': comid,
        'EmployeeRefId': empRefId == 0 ? null : empRefId,
        'LBoardingOfficerRefid': boardOfficerId1,
        'LBoardingOfficer1Refid': boardOfficerId2,
        'LBoardingAmount': boardOfficerAmt1,
        'LBoardingAmount1': boardOfficerAmt2,
      };
    }

    await ApiClient.postRequest(objfun.apiUpdateBoardingOfficer, master);
  }
}