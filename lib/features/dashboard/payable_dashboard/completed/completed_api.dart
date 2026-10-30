import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import '../records/data/payable_record.dart';

/// One completed payment: a payment voucher or a supplier payment (pay bill).
class CompletedRow {
  const CompletedRow({
    required this.id,
    required this.date,
    required this.number,
    required this.paidTo,
    required this.ref,
    required this.amount,
    required this.head,
    required this.isSupplier,
    required this.status,
    this.qne = '',
  });

  factory CompletedRow.fromJava(Map<String, dynamic> m) => CompletedRow(
        id: JsonRead.integer(JsonRead.field(m, 'id')),
        date: readDate(pick(m, const ['sSaleDate'])),
        number: pick(m, const ['cNumberDisplay']),
        paidTo: pick(m, const ['expenseName']),
        ref: pick(m, const ['refNumber']),
        amount: pickNumber(m, const ['amount']),
        head: pick(m, const ['filePath']),
        isSupplier: JsonRead.integer(JsonRead.field(m, 'detailedId')) == 1,
        status: pick(m, const ['paymentStatus']),
        qne: pick(m, const ['remarks']),
      );

  final int id;
  final DateTime? date;
  final String number;
  final String paidTo;
  final String ref;
  final double amount;

  /// The expense head (`Description`; the server names it `filePath`).
  final String head;

  /// A supplier payment (pay bill); else a payment voucher.
  final bool isSupplier;

  /// Empty from an older server.
  final String status;
  final String qne;

  /// The record the Records detail page opens.
  PayableRecord get record => PayableRecord(
        kind: isSupplier ? RecordKind.payBill : RecordKind.voucher,
        id: id,
        number: number,
        date: date,
        party: paidTo,
        amount: amount,
        status: status,
        description: [head, ref].where((t) => t.isNotEmpty).join(' · '),
        head: head,
      );

  bool matches(String q) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return true;
    return [number, paidTo, ref, head].any((t) => t.toLowerCase().contains(s));
  }
}

/// A month of completed payments: rows, the server's total and count.
class CompletedMonth {
  const CompletedMonth({required this.rows, required this.total, required this.count});

  final List<CompletedRow> rows;
  final double total;
  final int count;

  /// Per expense head: count and amount, biggest first.
  List<({String head, int count, double amount})> get byHead {
    final m = <String, ({int count, double amount})>{};
    for (final r in rows) {
      final h = r.head.trim();
      final o = m[h] ?? (count: 0, amount: 0.0);
      m[h] = (count: o.count + 1, amount: o.amount + r.amount);
    }
    final out = [for (final e in m.entries) (head: e.key, count: e.value.count, amount: (e.value.amount * 100).roundToDouble() / 100)];
    out.sort((a, b) => b.amount.compareTo(a.amount));
    return out;
  }

  double get approved =>
      rows.where((r) => statusTone(r.status) == StatusTone.done).fold(0.0, (s, r) => s + r.amount);
}

/// The Completed list and its monthly report (change `payable-completed-list`), from the same shared
/// `POST /api/transaction-reports/payment-done` and `/payment-done/report` (PDF) as the web Payment Completed page.
/// REJECTED is left out by the server.
class CompletedApi {
  CompletedApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  Map<String, dynamic> _body(DateTime from, DateTime to) => {
        'comid': _companyId(),
        'fromDate': Fmt.ymd(from),
        'toDate': Fmt.ymd(to),
        'supplierId': 0,
        'payTo': '',
        'descriptions': <String>[],
      };

  Future<CompletedMonth> load(DateTime from, DateTime to) async {
    final dynamic res;
    try {
      res = (await _dio.post<dynamic>('/api/transaction-reports/payment-done',
              data: _body(from, to), queryParameters: {'companyId': _companyId()}))
          .data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    final view = JsonRead.map(_payload(res));
    final rows = [for (final m in JsonRead.listOfMaps(JsonRead.field(view, 'rows'))) CompletedRow.fromJava(m)];
    return CompletedMonth(
      rows: rows,
      total: pickNumber(view, const ['totalAmount']),
      count: JsonRead.intOrNull(JsonRead.field(view, 'count')) ?? rows.length,
    );
  }

  /// The printed report (PDF bytes) for the same days: the summary by category, then every payment.
  Future<List<int>> reportPdf(DateTime from, DateTime to) async {
    try {
      final r = await _dio.post<List<int>>('/api/transaction-reports/payment-done/report',
          data: _body(from, to),
          queryParameters: {'companyId': _companyId()},
          options: Options(responseType: ResponseType.bytes, headers: {'Accept': 'application/pdf, application/json'}));
      final bytes = r.data ?? const <int>[];
      if (bytes.length < 5 || String.fromCharCodes(bytes.take(4)) != '%PDF') {
        throw ApiFailure(_messageOf(bytes) ?? 'The report did not come back as a PDF');
      }
      return bytes;
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is List<int>) {
        final msg = _messageOf(body);
        if (msg != null) throw ApiFailure(msg, statusCode: e.response?.statusCode);
      }
      throw JavaResponse.fromDio(e);
    }
  }

  static String? _messageOf(List<int> bytes) {
    try {
      final j = jsonDecode(utf8.decode(bytes));
      if (j is Map) return JsonRead.stringOrNull(j['Message']) ?? JsonRead.stringOrNull(j['message']);
    } catch (_) {}
    return null;
  }

  static dynamic _payload(dynamic body) {
    if (body is! Map) throw const ApiFailure('Unexpected response from server');
    final okKey = ['IsSuccess', 'isSuccess', 'success', 'ok'].firstWhere(body.containsKey, orElse: () => '');
    if (okKey.isNotEmpty && !JsonRead.boolean(body[okKey])) {
      throw ApiFailure(JsonRead.stringOrNull(body['Message']) ?? JsonRead.stringOrNull(body['message']) ?? 'Request failed');
    }
    return body['Data1'] ?? body['data'] ?? body['Data'];
  }
}
