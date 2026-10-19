import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

import 'ceo_analytics_models.dart';

/// The CEO analytics dashboard, from the shared Java `/api/ceo-dashboard/analytics/*` endpoints the web
/// uses too (change `ceo-analytics-dashboard`, contract in
/// `maleva-backend/openspec/changes/ceo-analytics-dashboard/contract.md`). The company comes from the
/// token; the server answers 403 to anyone but role 100 with permission 1.
///
/// Answers are `ApiResponse` `{IsSuccess, StatusCode, Message, Data1}` (`ApiResponse.success` fills `Data1`
/// only); the payload is read from `Data1`, falling back to `Data` / `data`. A refusal is thrown as [ApiFailure] with its status code.
class CeoAnalyticsApi {
  CeoAnalyticsApi(this._dio);

  final Dio _dio;

  static const _base = '/api/ceo-dashboard/analytics';

  Future<CeoOverview> overview({required String fromDate, required String toDate}) async =>
      CeoOverview.fromJava(await _get('$_base/overview', {'fromDate': fromDate, 'toDate': toDate}));

  /// The list behind a number; [key] is left out for kinds that take none. [invoice] (`ALL` / `WITH` /
  /// `WITHOUT`) is read by the sale order lists, [customer] (a customer id) by `SALE_ORDERS` and
  /// `INVOICES`; both are left out when null.
  Future<CeoDetails> details({
    required String kind,
    String? key,
    required String fromDate,
    required String toDate,
    String? invoice,
    int? customer,
  }) async =>
      CeoDetails.fromJava(await _get('$_base/details', {
        'kind': kind,
        if (key != null && key.isNotEmpty) 'key': key,
        'fromDate': fromDate,
        'toDate': toDate,
        if (invoice != null && invoice.isNotEmpty) 'invoice': invoice,
        if (customer != null) 'customer': customer,
      }));

  /// Money received from customers in the days, against the same days of the month before.
  Future<CeoReceived> received({required String fromDate, required String toDate}) async =>
      CeoReceived.fromJava(await _get('$_base/received', {'fromDate': fromDate, 'toDate': toDate}));

  /// Fuel from the fuel entries in the period (the saved PAmount), against the period before.
  Future<CeoFuel> fuel({required String fromDate, required String toDate}) async =>
      CeoFuel.fromJava(await _get('$_base/fuel', {'fromDate': fromDate, 'toDate': toDate}));

  /// The spend flow of the period: Purchase Order → Bill → Paid out → Still owed, and the checks.
  Future<CeoSpendFlow> spend({required String fromDate, required String toDate}) async =>
      CeoSpendFlow.fromJava(await _get('$_base/spend', {'fromDate': fromDate, 'toDate': toDate}));

  Future<dynamic> _get(String path, Map<String, dynamic> query) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(path, queryParameters: query);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    return payload(response.data);
  }

  /// The payload of a successful answer: `Data1`, else `Data`, else `data`.
  static dynamic payload(dynamic body) {
    if (body is! Map) throw const ApiFailure('Unexpected response from server');
    final ok = body.containsKey('IsSuccess') ? body['IsSuccess'] : body['success'];
    if (!JsonRead.boolean(ok)) {
      throw ApiFailure(
        JsonRead.stringOrNull(body['Message']) ?? JsonRead.stringOrNull(body['message']) ?? 'Request failed',
        statusCode: JsonRead.intOrNull(body['StatusCode']) ?? JsonRead.intOrNull(body['statusCode']),
      );
    }
    return body['Data1'] ?? body['Data'] ?? body['data'];
  }
}
