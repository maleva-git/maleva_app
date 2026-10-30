import 'dart:io';

import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

import '../../po/data/po_api.dart';

/// The bill form's own calls (change `payable-bill-form`); the shared lookups (suppliers, terms, accounts, trucks,
/// drivers, expense types) and the PO read are [po]'s. All `ApiResponse` `{IsSuccess, Data1}` with header `Comid`.
class BillApi {
  BillApi(this._dio, this.po);

  final Dio _dio;
  final PoApi po;

  int get companyId => po.companyId;

  Future<String> nextNumber() async => JsonRead.string(await _get('/api/bills/next-number', {'companyId': companyId}));

  /// The supplier's currency rate (0 when none).
  Future<double> supplierCurrency(int supplierId) async =>
      JsonRead.number(await _get('/api/bills/supplier-currency', {'companyId': companyId, 'supplierId': supplierId}));

  Future<bool> invoiceExists(String invoiceNo) async => JsonRead.boolean(await _get(
      '/api/bills/invoice-no-exists', {'companyId': companyId, 'invoiceNo': invoiceNo.trim(), 'excludeBillId': 0}));

  /// What is already paid on a bill.
  Future<double> paidAmount(int id) async =>
      JsonRead.number(await _get('/api/bills/$id/paid-amount', {'companyId': companyId}));

  Future<Map<String, dynamic>> load(int id) async {
    final m = JsonRead.map(await _get('/api/bills/edit', {'companyId': companyId, 'id': id, 'billNumber': 0}));
    if (m.isEmpty) throw const ApiFailure('Bill not found');
    return m;
  }

  /// Saves; answers the bill id, number, and whether the server found the same bill already saved (then it answers
  /// that bill and saves nothing new).
  Future<({int id, String number, bool duplicate})> save(Map<String, dynamic> body) async {
    final dynamic res;
    try {
      res = (await _dio.post<dynamic>('/api/bills/save',
              data: body, queryParameters: {'companyId': companyId}, options: Options(headers: {'Comid': companyId})))
          .data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    final d = JsonRead.map(JavaResponse.data(res));
    if (d.containsKey('success') && !JsonRead.boolean(d['success'])) {
      throw ApiFailure(JsonRead.stringOrNull(d['message']) ?? 'Could not save');
    }
    return (
      id: JsonRead.integer(d['id']),
      number: JsonRead.string(d['billNoDisplay']),
      duplicate: JsonRead.boolean(d['duplicate']),
    );
  }

  /// Reads a bill photo through the shared AI endpoint (`LlmGateway` task `bill-extraction`).
  Future<Map<String, dynamic>> extract(File file) async {
    final form = FormData()
      ..files.add(MapEntry('file', await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last)));
    final dynamic res;
    try {
      res = (await _dio.post<dynamic>('/api/ai/bills/extract',
              data: form,
              queryParameters: {'companyId': companyId},
              options: Options(
                  headers: {'Comid': companyId},
                  sendTimeout: const Duration(seconds: 60),
                  receiveTimeout: const Duration(seconds: 180))))
          .data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    return JsonRead.map(JavaResponse.data(res));
  }

  Future<dynamic> _get(String path, Map<String, dynamic> query) async {
    try {
      return JavaResponse.data(
          (await _dio.get<dynamic>(path, queryParameters: query, options: Options(headers: {'Comid': companyId})))
              .data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
