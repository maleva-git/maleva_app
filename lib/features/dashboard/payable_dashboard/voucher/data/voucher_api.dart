import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

import '../../po/data/po_api.dart';
import '../../po/data/po_draft.dart';
import '../../records/data/payable_record.dart';
import 'voucher_draft.dart';

/// The payment voucher form's calls (change `payable-voucher-form`); accounts and the PO read are [po]'s.
class VoucherApi {
  VoucherApi(this._dio, this.po);

  final Dio _dio;
  final PoApi po;

  int get companyId => po.companyId;

  Future<String> nextNumber() async =>
      JsonRead.string(JavaResponse.data(await _get('/api/payment-voucher-masters/next-number', {'companyId': companyId})));

  /// "Payment by": the company's banks (`/api/banks/company/{id}`; any envelope).
  Future<List<Option>> banks() async => [
        for (final m in JsonRead.listOfMaps(_rows(await _get('/api/banks/company/$companyId', const {}))))
          if (JsonRead.integer(pick(m, const ['Id'])) > 0 && pick(m, const ['AccountName', 'BankName']).isNotEmpty)
            Option(JsonRead.integer(pick(m, const ['Id'])), pick(m, const ['AccountName', 'BankName'])),
      ];

  Future<List<String>> payTos() async => _names(await _get('/api/payment-voucher-masters/select-payment-to', {'comid': companyId}));

  Future<List<String>> payFroms() async =>
      _names(await _get('/api/payment-voucher-masters/select-payment-from', {'comid': companyId}));

  /// The company's expense heads merged with the web's fixed list, sorted.
  Future<List<String>> heads() async {
    final data = _rows(await _get('/api/payment-voucher-masters/descriptions', {'companyId': companyId}));
    final out = <String>{};
    if (data is List) {
      for (final v in data) {
        final t = (v is Map ? pick(Map<String, dynamic>.from(v), const ['description', 'Description']) : '$v').trim();
        if (t.isNotEmpty) out.add(t);
      }
    }
    return {...out, ...voucherDefaultHeads}.toList()..sort();
  }

  Future<Map<String, dynamic>> load(int id) async {
    final m = JsonRead.map(JavaResponse.data(await _get('/api/payment-voucher-masters/edit', {'companyId': companyId, 'id': id})));
    if (m.isEmpty) throw const ApiFailure('Payment voucher not found');
    return m;
  }

  /// Saves; answers the voucher id, number and whether the server found the same voucher already saved.
  Future<({int id, String number, bool duplicate})> save(Map<String, dynamic> body) async {
    final dynamic res;
    try {
      res = (await _dio.post<dynamic>('/api/payment-voucher-masters/save',
              data: body, queryParameters: {'companyId': companyId}, options: Options(headers: {'Comid': companyId})))
          .data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    final d = JsonRead.map(JavaResponse.data(res));
    if (d.containsKey('success') && !JsonRead.boolean(d['success'])) {
      throw ApiFailure(JsonRead.stringOrNull(d['message']) ?? 'Could not save');
    }
    return (id: JsonRead.integer(d['id']), number: JsonRead.string(d['voucherNoDisplay']), duplicate: JsonRead.boolean(d['duplicate']));
  }

  Future<dynamic> _get(String path, Map<String, dynamic> query) async {
    try {
      return (await _dio.get<dynamic>(path, queryParameters: query, options: Options(headers: {'Comid': companyId}))).data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// The rows of any envelope (`Data1`, `data1`, `data`, `Data`) or a bare list; a refusal is an [ApiFailure].
  static dynamic _rows(dynamic body) {
    if (body is! Map) return body;
    final okKey = ['IsSuccess', 'isSuccess', 'ok', 'success'].firstWhere(body.containsKey, orElse: () => '');
    if (okKey.isNotEmpty && !JsonRead.boolean(body[okKey])) {
      throw ApiFailure(JsonRead.stringOrNull(body['Message']) ?? JsonRead.stringOrNull(body['message']) ?? 'Request failed');
    }
    for (final k in const ['Data1', 'data1', 'data', 'Data']) {
      if (body.containsKey(k)) return body[k];
    }
    return null;
  }

  static List<String> _names(dynamic body) {
    final out = <String>{};
    final rows = _rows(body);
    if (rows is List) {
      for (final v in rows) {
        final t = (v is Map ? pick(Map<String, dynamic>.from(v), const ['accountName', 'AccountName']) : '$v').trim();
        if (t.isNotEmpty) out.add(t);
      }
    }
    return out.toList()..sort();
  }
}
