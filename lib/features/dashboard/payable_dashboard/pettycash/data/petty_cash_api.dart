import 'dart:io';

import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import '../../po/data/po_draft.dart';
import '../../records/data/payable_record.dart';
import 'petty_cash_draft.dart';

/// The petty cash form's calls (change `payable-pettycash-form`): the same Java endpoints as the web form
/// (`pettyCashApi.ts`, `pettyCashBookApi.ts`, `employeeApi.ts`, payment voucher `getExpenseItems`). The petty cash
/// modules answer `ApiResponse` `{IsSuccess, Message, Data1}`; read as they are.
class PettyCashApi {
  PettyCashApi(this._dio, {required this.companyId});

  final Dio _dio;
  final int companyId;

  Options get _comid => Options(headers: {'Comid': companyId});

  /// Preview only: the real number is given when the sheet is saved.
  Future<String> nextNumber() async =>
      JsonRead.string(JavaResponse.data(await _get('/api/petty-cash-masters/next-number', {'companyId': companyId})));

  /// A saved sheet with its lines and balances (`GET /api/petty-cash-masters/edit?companyId&id`).
  Future<Map<String, dynamic>> load(int id) async {
    final m = JsonRead.map(JavaResponse.data(await _get('/api/petty-cash-masters/edit', {'companyId': companyId, 'id': id})));
    if (m.isEmpty || JsonRead.field(m, 'id') == null) throw const ApiFailure('Petty cash not found');
    return m;
  }

  /// Saves; answers the sheet id, number and the server's message.
  Future<({int id, String number, String message})> save(Map<String, dynamic> body) async {
    final dynamic res;
    try {
      res = (await _dio.post<dynamic>('/api/petty-cash-masters/save',
              data: body, queryParameters: {'companyId': companyId}, options: _comid))
          .data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    final d = JsonRead.map(JavaResponse.data(res));
    if (d.containsKey('success') && !JsonRead.boolean(d['success'])) {
      throw ApiFailure(JsonRead.stringOrNull(d['message']) ?? 'Could not save');
    }
    return (
      id: JsonRead.integer(JsonRead.field(d, 'id')),
      number: pick(d, const ['cNumberDisplay']),
      message: pick(d, const ['message']),
    );
  }

  /// The person's last sheet before [date] (REJECTED and deleted skipped by the server); [excludeId] = the opened one.
  Future<PettyCashLastBalance> lastBalance({required int employeeId, required DateTime date, int? excludeId}) async =>
      PettyCashLastBalance.fromJava(JsonRead.map(JavaResponse.data(await _get('/api/petty-cash-book/last-balance', {
        'companyId': companyId,
        'employeeId': employeeId,
        'date': Fmt.ymd(date),
        if ((excludeId ?? 0) > 0) 'excludeId': excludeId,
      }))));

  /// This sheet and the later ones take the balance of the sheet before.
  Future<PettyCashFollowResult> follow(int id) async {
    final dynamic res;
    try {
      res = (await _dio.post<dynamic>('/api/petty-cash-book/$id/follow',
              queryParameters: {'companyId': companyId}, options: _comid))
          .data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    return PettyCashFollowResult.fromJava(JsonRead.map(JavaResponse.data(res)));
  }

  /// Reads a petty cash sheet photo (`LlmGateway` task of `/api/ai/petty-cash/extract`); nothing is saved.
  Future<Map<String, dynamic>> extract(File file) async {
    final form = FormData()
      ..files.add(MapEntry('file', await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last)));
    final dynamic res;
    try {
      res = (await _dio.post<dynamic>('/api/ai/petty-cash/extract',
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

  /// "Requested by": every employee of the company (`/api/employees/company/{id}/all?type=ALL`, a bare list).
  Future<List<Option>> employees() async {
    final body = await _get('/api/employees/company/$companyId/all', const {'type': 'ALL'});
    return [
      for (final m in JsonRead.listOfMaps(body is Map ? JavaResponse.data(body) : body))
        if (JsonRead.integer(JsonRead.field(m, 'id')) > 0 && pick(m, const ['employeeName', 'name']).isNotEmpty)
          Option(JsonRead.integer(JsonRead.field(m, 'id')), pick(m, const ['employeeName', 'name'])),
    ];
  }

  /// "Employee type": `/api/employees/types?all=true` (`{id, customerName}`), as the web form asks.
  Future<List<String>> employeeTypes() async {
    final out = <String>[];
    for (final m in JsonRead.listOfMaps(JavaResponse.data(await _get('/api/employees/types', const {'all': true})))) {
      final t = pick(m, const ['customerName', 'employeeType', 'roleName', 'name']);
      if (t.isNotEmpty && !out.contains(t)) out.add(t);
    }
    return out.isEmpty ? pettyCashFallbackTypes : out;
  }

  /// The expense accounts (`/api/payment-vouchers/select-coa-expense`, `{ok, data}`), each with its classification.
  Future<List<PettyCashAccount>> accounts() async {
    final body = await _get('/api/payment-vouchers/select-coa-expense', {'comid': companyId, 'expenseId': 0, 'keyword': ''});
    final rows = _payload(body);
    return [
      for (final m in JsonRead.listOfMaps(rows))
        if (JsonRead.integer(JsonRead.field(m, 'Id')) > 0 &&
            pick(m, const ['AccountName', 'ProductName', 'AccountCode', 'Productcode']).isNotEmpty)
          _account(m),
    ];
  }

  static PettyCashAccount _account(Map<String, dynamic> m) {
    final code = pick(m, const ['AccountCode', 'Productcode', 'ProductCode']);
    final parent = pick(m, const ['ParentName', 'ParentAccountName']);
    return PettyCashAccount(
      JsonRead.integer(JsonRead.field(m, 'Id')),
      pick(m, const ['AccountName', 'ProductName']).isEmpty ? code : pick(m, const ['AccountName', 'ProductName']),
      sub: [code, parent].where((t) => t.isNotEmpty).join(' · '),
      code: code,
      extra: JsonRead.integer(JsonRead.field(m, 'Classification')),
      classificationName: pick(m, const ['ClassificationName', 'ClassificationName1']),
    );
  }

  /// `{ok, data}`, `{IsSuccess, Data1}` or a bare list; a refusal is an [ApiFailure].
  static dynamic _payload(dynamic body) {
    if (body is! Map) return body;
    final okKey = ['IsSuccess', 'isSuccess', 'ok', 'success'].firstWhere(body.containsKey, orElse: () => '');
    if (okKey.isNotEmpty && !JsonRead.boolean(body[okKey])) {
      throw ApiFailure(
          JsonRead.stringOrNull(body['Message']) ?? JsonRead.stringOrNull(body['message']) ?? 'Request failed');
    }
    for (final k in const ['Data1', 'data1', 'data', 'Data']) {
      if (body.containsKey(k)) return body[k];
    }
    return null;
  }

  Future<dynamic> _get(String path, Map<String, dynamic> query) async {
    try {
      return (await _dio.get<dynamic>(path, queryParameters: query, options: _comid)).data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
