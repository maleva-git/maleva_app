import 'dart:io';

import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

import '../../records/data/payable_record.dart';
import 'po_draft.dart';

/// The purchase order form's calls (change `payable-po-create`): the same shared Java endpoints as the web PO form.
/// Lookups answer in three envelopes (`{IsSuccess, Data1}`, `{isSuccess, data1}`, `{ok, data}`); [_payload] reads all.
class PoApi {
  PoApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get companyId => _companyId();

  // ── lookups ───────────────────────────────────────────────────────────────────

  Future<List<Option>> suppliers() async => [
        for (final m in JsonRead.listOfMaps(await _get('/api/suppliers/combo', {'comid': companyId, 'type': ''})))
          if (JsonRead.integer(JsonRead.field(m, 'Id')) > 0)
            Option(JsonRead.integer(JsonRead.field(m, 'Id')), pick(m, const ['AccountName', 'SupplierName']),
                extra: JsonRead.integer(JsonRead.field(m, 'PaymentTermsRefid'))),
      ];

  /// The supplier's own default term (the combo may not carry it), as the web asks.
  Future<int?> supplierTerm(int supplierId) async {
    final rows = JsonRead.listOfMaps(await _post('/api/suppliers/select', null, {
      'comid': companyId,
      'keyword': supplierId,
      'column': 'Id',
      'startindex': 0,
      'pageCount': 0,
      'type': '',
    }));
    if (rows.isEmpty) return null;
    final t = JsonRead.integer(JsonRead.field(rows.first, 'PaymentTermsRefid'));
    return t > 0 ? t : null;
  }

  Future<List<Option>> paymentTerms() async {
    final rows = JsonRead.listOfMaps(await _get('/api/payment-terms-master', const {}));
    return [
      for (final m in rows)
        if (JsonRead.integer(JsonRead.field(m, 'companyRefId')) == companyId ||
            JsonRead.field(m, 'companyRefId') == null)
          Option(JsonRead.integer(JsonRead.field(m, 'Id')), pick(m, const ['TermsName', 'termsName'])),
    ];
  }

  /// Days to pay for a payment term (the param is named supplierId but takes the term id, as on the web).
  Future<int> dueDays(int termId) async =>
      JsonRead.integer(await _get('/api/payment-terms/supplier-due', {'comid': companyId, 'supplierId': termId}));

  Future<List<String>> descriptions() async =>
      _texts(await _get('/api/bills-order/select-description/$companyId', const {}));

  Future<List<String>> payTos() async => _texts(await _get('/api/bills-order/select-payment-to/$companyId', const {}));

  /// GL expense accounts (the web's line "product").
  Future<List<Option>> accounts() async => [
        for (final m in JsonRead.listOfMaps(await _get(
            '/api/payment-vouchers/select-coa-expense', {'comid': companyId, 'expenseId': 0, 'keyword': ''})))
          if (JsonRead.integer(JsonRead.field(m, 'Id')) > 0)
            Option(JsonRead.integer(JsonRead.field(m, 'Id')), pick(m, const ['AccountName']),
                // The account's classification id: a voucher line saves it, as the web does.
                extra: JsonRead.integer(JsonRead.field(m, 'Classification')),
                sub: [
                  pick(m, const ['AccountCode']),
                  pick(m, const ['ParentName', 'ClassificationName'])
                ].where((t) => t.isNotEmpty).join(' · ')),
      ];

  Future<List<Option>> trucks() async => _combo('/api/truck-combo');

  Future<List<Option>> drivers() async => _combo('/api/driver-combo');

  Future<List<Option>> _combo(String path) async => [
        for (final m in JsonRead.listOfMaps(await _get(path, {'companyId': companyId})))
          if (JsonRead.integer(JsonRead.field(m, 'Id')) > 0)
            Option(JsonRead.integer(JsonRead.field(m, 'Id')), pick(m, const ['AccountName', 'Name'])),
      ];

  Future<String> nextNumber() async =>
      JsonRead.string(await _get('/api/bills-order/max-bills-order-no/$companyId', const {}));

  /// Every invoice number already on a PO of the company, trimmed and in upper case.
  Future<Set<String>> usedInvoiceNumbers() async => {
        for (final m in JsonRead.listOfMaps(await _get('/api/bills-order/check-invoice-no/$companyId', const {})))
          if (pick(m, const ['InvoiceNo']).isNotEmpty) pick(m, const ['InvoiceNo']).toUpperCase(),
      };

  // ── load and save ─────────────────────────────────────────────────────────────

  /// The saved PO `data[0]` of `edit-bills-order`.
  Future<Map<String, dynamic>> load(int id) async {
    final data =
        await _get('/api/bills-order/edit-bills-order', {'id': id, 'billsOrderMasterNo': 0, 'comid': companyId});
    if (data is List && data.isNotEmpty) return JsonRead.map(data.first);
    final m = JsonRead.map(data);
    if (m.isEmpty) throw const ApiFailure('Purchase order not found');
    return m;
  }

  /// Saves (id 0 = new) and answers the PO id and number.
  Future<({int id, String number})> save(Map<String, dynamic> body) async {
    final dynamic res;
    try {
      res = (await _dio.post<dynamic>('/api/bills-order/insert',
              data: body, options: Options(headers: {'Comid': companyId})))
          .data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    if (res is! Map || !JsonRead.boolean(res['ok'])) {
      throw ApiFailure(res is Map ? (JsonRead.stringOrNull(res['message']) ?? 'Could not save') : 'Could not save');
    }
    return (id: JsonRead.integer(res['id']), number: JsonRead.string(res['billNo']));
  }

  // ── AI read ───────────────────────────────────────────────────────────────────

  /// Reads a PO / invoice photo through the shared AI endpoint (`LlmGateway` task `purchase-order-extraction`).
  Future<Map<String, dynamic>> extract(File file) async {
    final form = FormData()
      ..files.add(MapEntry('file', await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last)));
    final dynamic res;
    try {
      res = (await _dio.post<dynamic>('/api/ai/purchase-orders/extract',
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
    return JsonRead.map(_payload(res));
  }

  // ── transport ─────────────────────────────────────────────────────────────────

  Future<dynamic> _get(String path, Map<String, dynamic> query) async {
    try {
      return _payload((await _dio.get<dynamic>(path, queryParameters: query)).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  Future<dynamic> _post(String path, Object? body, Map<String, dynamic> query) async {
    try {
      return _payload((await _dio.post<dynamic>(path, data: body, queryParameters: query)).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// The payload of any of the three envelopes; a refusal is an [ApiFailure]. A bare list or value is returned as is.
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
    return okKey.isEmpty ? body : null;
  }

  /// A list of names: plain strings, or rows whose first text value is the name.
  static List<String> _texts(dynamic data) {
    final out = <String>{};
    if (data is List) {
      for (final v in data) {
        final t = v is Map
            ? (v.values.firstWhere((x) => x is String && x.trim().isNotEmpty, orElse: () => '') as String)
            : '$v';
        if (t.trim().isNotEmpty) out.add(t.trim());
      }
    }
    return out.toList();
  }
}
