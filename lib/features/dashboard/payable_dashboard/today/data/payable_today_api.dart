import 'package:dio/dio.dart';
import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import 'payable_today_models.dart';

/// The Payable Today tab's data, from the shared Java endpoints the web payable desk calls
/// (`maleva-front-end/src/features/payable-dashboard/api/payableDashboardApi.ts`; change `payable-desk-today`).
/// No endpoint of its own.
class PayableTodayApi {
  PayableTodayApi(this._dio, this._dashboard);

  final Dio _dio;
  final DashboardApi _dashboard;

  /// How many days ahead the sub-expense arm looks (the web desk's `EXPENSE_DUE_DAYS`).
  static const dueDays = 5;

  /// Everything still owed: sub-expenses due up to today + [dueDays] and unpaid supplier bills up to today.
  Future<List<PendingPayment>> pending(int comid, DateTime today) async {
    final body = await _call(() => _dio.get<dynamic>('/api/dashboard/pending-payment/$comid', queryParameters: {
          'dueDate': Fmt.ymd(today.add(const Duration(days: dueDays))),
          'toDate': Fmt.ymd(today),
        }));
    return [for (final m in JsonRead.listOfMaps(_payload(body))) PendingPayment.fromJava(m)];
  }

  /// Payments settled from the 1st of the month to today.
  Future<List<CompletedPayment>> completed(int comid, DateTime today) async {
    final body = await _call(() => _dio.get<dynamic>('/api/dashboard/completed-payment/$comid', queryParameters: {
          'fromDate': Fmt.ymd(DateTime(today.year, today.month, 1)),
          'toDate': Fmt.ymd(today),
        }));
    return [for (final m in JsonRead.listOfMaps(_payload(body))) CompletedPayment.fromJava(m)];
  }

  /// Which payments have a document filed: one `checkFiles` call per folder, as the web desk does.
  Future<DocumentIndex> documents(int comid) async {
    final r = await Future.wait([_folderIds(comid, 'PayBills'), _folderIds(comid, 'PaymentVoucher')]);
    return DocumentIndex(payBills: r[0], paymentVoucher: r[1]);
  }

  /// Expense totals and the breakdown of the month so far.
  Future<ExpenseSummary> expenses(int comid, DateTime today) async => ExpenseSummary.fromJava(await _dashboard
      .expenses(comid, Fmt.ymd(DateTime(today.year, today.month, 1)), Fmt.ymd(today)));

  /// `checkFiles` answers the legacy `{ok, message, data: [ids]}`; an empty list when the folder does not exist.
  Future<Set<int>> _folderIds(int comid, String folder) async {
    final body = await _call(
        () => _dio.post<dynamic>('/api/common/checkFiles', queryParameters: {'imageDirectory': '/$comid/$folder'}));
    if (body is! Map) throw const ApiFailure('Unexpected response from server');
    if (body.containsKey('ok') && !JsonRead.boolean(body['ok'])) {
      throw ApiFailure(JsonRead.stringOrNull(body['message']) ?? 'Request failed');
    }
    final data = body['data'];
    return {
      if (data is List)
        for (final v in data)
          if (JsonRead.intOrNull(v) != null) JsonRead.intOrNull(v)!,
    };
  }

  Future<dynamic> _call(Future<Response<dynamic>> Function() call) async {
    try {
      return (await call()).data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// The payload of an `ApiResponse` (`{success, data}`), also accepting the legacy `Data1` / `Data`.
  static dynamic _payload(dynamic body) {
    if (body is! Map) throw const ApiFailure('Unexpected response from server');
    final ok = body.containsKey('success') ? body['success'] : body['IsSuccess'];
    if (ok != null && !JsonRead.boolean(ok)) {
      throw ApiFailure(
        JsonRead.stringOrNull(body['message']) ?? JsonRead.stringOrNull(body['Message']) ?? 'Request failed',
        statusCode: JsonRead.intOrNull(body['statusCode']) ?? JsonRead.intOrNull(body['StatusCode']),
      );
    }
    return body['data'] ?? body['Data1'] ?? body['Data'];
  }
}
