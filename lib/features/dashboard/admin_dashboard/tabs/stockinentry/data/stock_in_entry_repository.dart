import 'package:dio/dio.dart';
import 'package:maleva/core/models/model.dart';
import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/network/api_constants.dart';
import 'package:maleva/core/utils/session_manager.dart';

class StockInEntryRepository {
  final DioClient _dioClient;
  final SessionManager _sessionManager;

  StockInEntryRepository(this._dioClient, this._sessionManager);

  int get _comid => _sessionManager.companyId;

  // ─── Initial Startup Data ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchInitialData(int billType) async {
    final maxStockRes = await _dioClient.dio.post("${ApiConstants.apiMaxStockNo}$_comid", data: {});
    final stockJobRes = await _dioClient.dio.post("${ApiConstants.apiSelectStockJob}$_comid", data: {});
    final jobNoRes = await _dioClient.dio.post("${ApiConstants.apiGetJobNo}$_comid&JobType=$billType", data: {});

    String maxNum = '';
    if (maxStockRes.data != null && maxStockRes.data is List && maxStockRes.data.isNotEmpty) {
      maxNum = maxStockRes.data[0]['MaxNo']?.toString() ?? '';
    }

    return {
      'maxStockNo': maxNum,
      'stockJobList': (stockJobRes.data is List) ? stockJobRes.data : [],
      'jobNoList': (jobNoRes.data is List) ? jobNoRes.data : [],
    };
  }

  // ─── Fetch Job List by Bill Type ───────────────────────────────────────────
  Future<List<dynamic>> fetchJobNoList(int billType) async {
    final jobNoRes = await _dioClient.dio.post("${ApiConstants.apiGetJobNo}$_comid&Type=$billType", data: {});
    return (jobNoRes.data != null && jobNoRes.data is List) ? jobNoRes.data : [];
  }

  // ─── Fetch Job Details ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchJobDetails(int saleOrderId) async {
    final result = await _dioClient.dio.post("${ApiConstants.apiSelectStockDetails}$_comid&Id=$saleOrderId", data: {});

    String shipName = '';
    String customerName = '';
    String jobDate = '';
    int jobMasterId = 0;
    int weightPkg = 0;
    List<dynamic> jobStatuses = [];

    if (result.data != null) {
      final value = ResponseViewModel.fromJson(result.data);
      if (value.IsSuccess == true && value.data1 != null && value.data1.isNotEmpty) {
        final data = value.data1[0];
        customerName = data['CustomerName'] ?? '';
        shipName = customerName.isNotEmpty ? (data['LoadingVesselName'] ?? '') : (data['OffVesselName'] ?? '');
        jobDate = data['SSaleDate'] ?? '';
        jobMasterId = data['JobMasterRefId'] ?? 0;

        final qty = data['Quantity']?.toString() ?? '0';
        final match = RegExp(r'\d+').stringMatch(qty);
        weightPkg = int.tryParse(match ?? '0') ?? 0;

        try {
          final statusRes = await _dioClient.dio.post("${ApiConstants.apiSelectAllJobStatus}$_comid&Jobid=$jobMasterId", data: {});

          if (statusRes.data != null && statusRes.data is List && statusRes.data.isNotEmpty) {
            var firstItem = statusRes.data[0];
            if (firstItem != null && firstItem['JobStatusDetails'] != null) {
              jobStatuses = firstItem['JobStatusDetails'];
            }
          }
        } catch (e) {
          // ignore
        }
      }
    }

    return {
      'shipName': shipName,
      'customerName': customerName,
      'jobDate': jobDate,
      'jobMasterId': jobMasterId,
      'weightPkg': weightPkg,
      'jobStatuses': jobStatuses,
    };
  }

  // ─── Fetch Sales Order For Edit ────────────────────────────────────────────
  Future<Map<String, dynamic>> fetchSalesOrderForEdit(int id, int saleNo) async {
    try {
      final endpoint = "${ApiConstants.apiEditSalesOrder}$id&SaleorderNo=$saleNo&Comid=$_comid";
      final response = await _dioClient.dio.post(endpoint, data: {});
      if (response.data != null && response.data.isNotEmpty) {
         final item = response.data[0];
         return {
            'masterList': item['EditMasterDetails'] ?? [],
            'detailsList': item['EditItemDetails'] ?? [],
         };
      }
    } catch (e) {
      // ignore
    }
    return {
      'masterList': [],
      'detailsList': [],
    };
  }

  // ─── Delete Image ──────────────────────────────────────────────────────────
  Future<ResponseViewModel?> deleteImage(int saleOrderId, String folder, String imageName) async {
    final filePath = '/Upload/$_comid/SalesOrder/$saleOrderId/$folder/$imageName';
    final options = Options(headers: {
      'Comid': _comid.toString(),
      'Id': saleOrderId.toString(),
      'FolderName': 'SalesOrder',
      'FileName': filePath,
      'SubFolderName': folder,
    });

    try {
      final result = await _dioClient.dio.post(ApiConstants.apiDeleteImage, options: options, data: {});
      if (result.data != null) {
        return ResponseViewModel.fromJson(result.data);
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  // ─── Save Stock In ─────────────────────────────────────────────────────────
  Future<ResponseViewModel?> saveStockIn(List<Map<String, dynamic>> master) async {
    try {
      final result = await _dioClient.dio.post('${ApiConstants.apiInsertStockIn}$_comid', data: master);
      if (result.data != null) {
        return ResponseViewModel.fromJson(result.data);
      }
    } catch (e) {
      // ignore
    }
    return null;
  }
}
