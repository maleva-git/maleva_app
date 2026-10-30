import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';
import 'package:maleva/core/widgets/ui/formats.dart';

import 'payable_record.dart';

/// The payable records, read only, from the same shared Java endpoints the web screens use (change
/// `payable-records`; field names from the web mappers, read without case because Jackson writes some Lombok names
/// both ways). Every answer is `ApiResponse` `{IsSuccess, Data1}` except the purchase order one (`{ok, data}`).
class PayableRecordsApi {
  PayableRecordsApi(this._dio, {required int Function() companyId}) : _companyId = companyId;

  final Dio _dio;
  final int Function() _companyId;

  int get _comid => _companyId();

  // ── lists ─────────────────────────────────────────────────────────────────────

  /// The records of [kind] dated [from]..[to] (whole days), newest first.
  Future<List<PayableRecord>> list(RecordKind kind, DateTime from, DateTime to) async {
    final f = Fmt.ymd(from), t = Fmt.ymd(to);
    final rows = switch (kind) {
      RecordKind.po => _poList(f, t),
      RecordKind.bill => _post('/api/bills/search', {'fromdate': f, 'todate': t, 'id': 0, 'employeeid': 0, 'search': '', 'invoicecheck': 0})
          .then((d) => _records(kind, d, 'billMaster', 'billDetails')),
      RecordKind.payBill => _post('/api/payments/search', {
          'comid': _comid, 'fromDate': f, 'toDate': t, 'supplierId': 0, 'employeeId': 0, 'search': '', 'paymentStatus': '',
        }).then((d) => _records(kind, d, 'paymentMaster', 'paymentDetails')),
      RecordKind.voucher => _post('/api/payment-voucher-masters/search', {
          'comid': _comid, 'fromDate': f, 'toDate': t, 'employeeId': 0, 'search': '', 'paymentStatus': '',
        }).then((d) => _records(kind, d, 'paymentVoucherMaster', 'paymentVoucherDetails')),
      RecordKind.pettyCash => _post('/api/petty-cash-masters/search', {
          'comid': _comid, 'fromDate': f, 'toDate': t, 'employeeId': 0, 'search': '', 'paymentStatus': '',
        }).then((d) => _records(kind, d, 'pettyCashMaster', 'pettyCashDetails')),
      RecordKind.levy => _get('/api/levi-entries', {'companyRefId': _comid, 'fromDate': f, 'toDate': t})
          .then((d) => _records(kind, d, 'items', null)),
    };
    final list = await rows;
    list.sort((a, b) {
      final ad = a.date, bd = b.date;
      if (ad == null || bd == null) return ad == null ? (bd == null ? b.id.compareTo(a.id) : 1) : -1;
      final c = bd.compareTo(ad);
      return c != 0 ? c : b.id.compareTo(a.id);
    });
    return list;
  }

  Future<List<PayableRecord>> _poList(String f, String t) async {
    final body = await _call(() => _dio.get<dynamic>('/api/bills-order/select-bills-order',
        queryParameters: {'comid': _comid, 'fromdate': f, 'todate': t}));
    return _records(RecordKind.po, _legacy(body), 'billsOrderMaster', 'billsOrderDetails');
  }

  /// Rows of `data[masterKey]`, with the number of lines per record from `data[linesKey]` (by `saleRefId` or the
  /// master id field).
  static List<PayableRecord> _records(RecordKind kind, dynamic data, String masterKey, String? linesKey) {
    final m = JsonRead.map(data);
    final lines = <int, int>{};
    if (linesKey != null) {
      for (final l in JsonRead.listOfMaps(JsonRead.field(m, linesKey))) {
        final owner = JsonRead.integer(pick(l, const [
          'saleRefId', 'paymentVoucherMasterRefId', 'pettyCashMasterRefId', 'paymentMasterRefId', 'billMasterRefId',
        ]));
        lines[owner] = (lines[owner] ?? 0) + 1;
      }
    }
    return [
      for (final r in JsonRead.listOfMaps(JsonRead.field(m, masterKey)))
        rowOf(kind, r, lineCount: lines[JsonRead.integer(JsonRead.field(r, 'id'))] ?? 0),
    ];
  }

  /// One list row in the shape the screen reads.
  static PayableRecord rowOf(RecordKind kind, Map<String, dynamic> r, {int lineCount = 0}) {
    final id = JsonRead.integer(JsonRead.field(r, 'id'));
    return switch (kind) {
      RecordKind.po => PayableRecord(
          kind: kind,
          id: id,
          number: pick(r, const ['billNoDisplay', 'cNumberDisplay']),
          date: readDate(pick(r, const ['billDate', 'saleDate'])),
          party: pick(r, const ['supplierName', 'payTo']),
          amount: pickNumber(r, const ['netAmt', 'amount']),
          // the web's "Pending" filter is PStatus 0; a PO with PStatus 1 has been taken further (billed / paid)
          status: JsonRead.integer(JsonRead.field(r, 'pStatus')) == 0 ? 'PENDING' : 'DONE',
          tag: pick(r, const ['billStatus']),
          description: [pick(r, const ['description']), pick(r, const ['truckName'])].where((t) => t.isNotEmpty).join(' · '),
          lineCount: lineCount),
      RecordKind.bill => PayableRecord(
          kind: kind,
          id: id,
          number: pick(r, const ['billNoDisplay', 'cNumberDisplay']),
          date: readDate(pick(r, const ['billDate', 'saleDate'])),
          party: pick(r, const ['supplierName']),
          amount: pickNumber(r, const ['netAmt', 'amount']),
          status: pick(r, const ['billStatus']),
          tag: pick(r, const ['saleType']),
          description: [pick(r, const ['invoiceNo']).isEmpty ? '' : 'Inv ${pick(r, const ['invoiceNo'])}', pick(r, const ['remarks'])]
              .where((t) => t.isNotEmpty)
              .join(' · '),
          lineCount: lineCount),
      RecordKind.payBill => PayableRecord(
          kind: kind,
          id: id,
          number: pick(r, const ['billNoDisplay', 'cNumberDisplay']),
          date: readDate(pick(r, const ['billDate', 'paymentDate'])),
          party: pick(r, const ['supplierName', 'payTo']),
          amount: pickNumber(r, const ['amount']),
          status: pick(r, const ['paymentStatus']),
          tag: pick(r, const ['bankName']),
          description: [pick(r, const ['description']), pick(r, const ['refNumber'])].where((t) => t.isNotEmpty).join(' · '),
          head: pick(r, const ['description']),
          lineCount: lineCount),
      RecordKind.voucher => PayableRecord(
          kind: kind,
          id: id,
          number: pick(r, const ['cNumberDisplay', 'cnumberDisplay']),
          date: readDate(pick(r, const ['sPaymentVoucherDate', 'paymentVoucherDate'])),
          party: pick(r, const ['payTo']),
          amount: pickNumber(r, const ['amount']),
          status: pick(r, const ['paymentStatus']),
          tag: pick(r, const ['paymentByIdName']),
          description: [pick(r, const ['description']), pick(r, const ['refNo'])].where((t) => t.isNotEmpty).join(' · '),
          head: pick(r, const ['description']),
          lineCount: lineCount),
      RecordKind.pettyCash => PayableRecord(
          kind: kind,
          id: id,
          number: pick(r, const ['cNumberDisplay', 'cnumberDisplay']),
          date: readDate(pick(r, const ['sPettyCashDate', 'pettyCashDate'])),
          party: pick(r, const ['employeeName']),
          amount: pickNumber(r, const ['amount']),
          status: pick(r, const ['paymentStatus']),
          tag: pick(r, const ['department']),
          description: pick(r, const ['remark']),
          lineCount: lineCount),
      RecordKind.levy => PayableRecord(
          kind: kind,
          id: id,
          number: pick(r, const ['cNumberDisplay', 'cnumberDisplay']),
          date: readDate(pick(r, const ['saleDate'])),
          party: [pick(r, const ['truckName']), pick(r, const ['driverName'])].where((t) => t.isNotEmpty).join(' · '),
          amount: pickNumber(r, const ['amount']),
          // a levy is settled once a payment voucher carries it
          status: pick(r, const ['paymentVoucherNo']).isEmpty ? '' : 'COMPLETED',
          tag: pick(r, const ['enterLink']),
          description: [
            pick(r, const ['rtiNumber']).isEmpty ? '' : 'RTI ${pick(r, const ['rtiNumber'])}',
            pick(r, const ['paymentVoucherNo']).isEmpty ? '' : 'PV ${pick(r, const ['paymentVoucherNo'])}',
            pick(r, const ['remarks']),
          ].where((t) => t.isNotEmpty).join(' · ')),
    };
  }

  // ── detail ────────────────────────────────────────────────────────────────────

  /// One record's facts and lines. [row] is its list row (the detail answers carry ids, not names, for the supplier).
  Future<RecordDetail> detail(PayableRecord row) async {
    final id = row.id;
    switch (row.kind) {
      case RecordKind.po:
        final body = await _call(() => _dio.get<dynamic>('/api/bills-order/edit-bills-order',
            queryParameters: {'id': id, 'billsOrderMasterNo': 0, 'comid': _comid}));
        final data = _legacy(body);
        final m = data is List && data.isNotEmpty ? JsonRead.map(data.first) : JsonRead.map(data);
        return poDetail(m, row);
      case RecordKind.bill:
        return billDetail(JsonRead.map(await _get('/api/bills/edit', {'companyId': _comid, 'id': id, 'billNumber': 0})), row);
      case RecordKind.payBill:
        return payBillDetail(JsonRead.map(await _get('/api/payments/edit', {'companyId': _comid, 'id': id})), row);
      case RecordKind.voucher:
        return voucherDetail(JsonRead.map(await _get('/api/payment-voucher-masters/edit', {'companyId': _comid, 'id': id})), row);
      case RecordKind.pettyCash:
        return pettyDetail(JsonRead.map(await _get('/api/petty-cash-masters/edit', {'companyId': _comid, 'id': id})), row);
      case RecordKind.levy:
        return levyDetail(JsonRead.map(await _get('/api/levi-entries/$id', {'companyRefId': _comid})), row);
    }
  }

  static String _date(Map<String, dynamic> m, List<String> keys) {
    final d = readDate(pick(m, keys));
    return d == null ? '' : Fmt.ddMMyyyy(d);
  }

  static String _rm(double v) => v == 0 ? '' : Fmt.rm(v);

  static RecordDetail poDetail(Map<String, dynamic> m, PayableRecord row) {
    final lines = [
      for (final l in JsonRead.listOfMaps(JsonRead.field(m, 'billsOrderDetails')))
        RecordLine(
          title: pick(l, const ['productName', 'productCode']).isEmpty ? 'Item' : pick(l, const ['productName', 'productCode']),
          subtitle: pick(l, const ['remarksD', 'serialNo']),
          quantity: pickNumber(l, const ['itemQty']),
          rate: pickNumber(l, const ['salesRate', 'saleRate']),
          amount: pickNumber(l, const ['amount', 'sAmount']),
        ),
    ];
    final total = pickNumber(m, const ['amount']);
    return RecordDetail(lineTitle: 'Items', lines: lines, total: total != 0 ? total : row.amount, facts: [
      ('PO date', _date(m, const ['saleDate', 'sSaleDate'])),
      ('Supplier', row.party),
      ('Pay to', pick(m, const ['payTo'])),
      ('Type', pick(m, const ['billStatus'])),
      ('Cash / credit', pick(m, const ['saleType'])),
      ('Invoice no.', pick(m, const ['invoiceNo'])),
      ('Invoice date', _date(m, const ['invoiceDate', 'sInvoiceDate'])),
      ('Due date', _date(m, const ['dueDate', 'sDueDate'])),
      ('Job', pick(m, const ['jobNo', 'jobOrderNo'])),
      ('Gross', _rm(pickNumber(m, const ['grossAmount']))),
      ('Tax', _rm(pickNumber(m, const ['taxAmount']))),
      ('Discount', _rm(pickNumber(m, const ['discountAmount']))),
      ('Description', pick(m, const ['description'])),
      ('Remarks', pick(m, const ['remarks'])),
    ]);
  }

  static RecordDetail billDetail(Map<String, dynamic> m, PayableRecord row) {
    final lines = [
      for (final l in JsonRead.listOfMaps(JsonRead.field(m, 'billDetails')))
        RecordLine(
          title: pick(l, const ['productName', 'productCode']).isEmpty ? 'Item' : pick(l, const ['productName', 'productCode']),
          subtitle: pick(l, const ['remarksD']),
          quantity: pickNumber(l, const ['itemQty']),
          rate: pickNumber(l, const ['salesRate', 'saleRate']),
          amount: pickNumber(l, const ['amount', 'sAmount']),
        ),
    ];
    final total = pickNumber(m, const ['amount']);
    final po = JsonRead.integer(JsonRead.field(m, 'billsOrderMasterRefId'));
    return RecordDetail(lineTitle: 'Items', lines: lines, total: total != 0 ? total : row.amount, facts: [
      ('Bill date', _date(m, const ['saleDate', 'sSaleDate'])),
      ('Supplier', row.party),
      ('Invoice no.', pick(m, const ['invoiceNo'])),
      ('Invoice date', _date(m, const ['invoiceDate', 'sInvoiceDate'])),
      ('Due date', _date(m, const ['dueDate', 'sDueDate'])),
      ('Status', statusLabel(pick(m, const ['billStatus']))),
      ('From PO', po > 0 ? 'Yes (PO id $po)' : ''),
      ('Gross', _rm(pickNumber(m, const ['grossAmount']))),
      ('Tax', _rm(pickNumber(m, const ['taxAmount']))),
      ('Description', pick(m, const ['description'])),
      ('Remarks', pick(m, const ['remarks'])),
      ('QNE', pick(m, const ['qneCode'])),
    ]);
  }

  static RecordDetail payBillDetail(Map<String, dynamic> m, PayableRecord row) {
    // the edit answer lists the supplier's whole outstanding; this payment's bills are the ones with an amount
    final lines = [
      for (final l in JsonRead.listOfMaps(JsonRead.field(m, 'paymentDetails')))
        if (pickNumber(l, const ['amount']) > 0)
          RecordLine(
            title: [
              pick(l, const ['billNo']).isEmpty ? 'Bill' : 'Bill ${pick(l, const ['billNo'])}',
              if (pick(l, const ['invoiceNo']).isNotEmpty) 'Inv ${pick(l, const ['invoiceNo'])}',
            ].join(' · '),
            subtitle: [
              _date(l, const ['sBillDate', 'billDate']),
              if (pickNumber(l, const ['billAmount']) != 0) 'bill ${Fmt.rm(pickNumber(l, const ['billAmount']))}',
            ].where((t) => t.isNotEmpty).join(' · '),
            amount: pickNumber(l, const ['amount']),
          ),
    ];
    final total = pickNumber(m, const ['amount']);
    return RecordDetail(lineTitle: 'Bills paid', lines: lines, total: total != 0 ? total : row.amount, facts: [
      ('Payment date', _date(m, const ['paymentDate', 'sPaymentDate'])),
      ('Supplier', row.party),
      ('Pay to', pick(m, const ['payTo'])),
      ('Bank', pick(m, const ['bankName'])),
      ('Account no.', pick(m, const ['accountNo'])),
      ('Reference', pick(m, const ['refNumber'])),
      ('Bank charges', _rm(pickNumber(m, const ['bankCharges']))),
      ('Status', statusLabel(pick(m, const ['paymentStatus']))),
      ('Description', pick(m, const ['description'])),
      ('Remarks', pick(m, const ['remarks'])),
    ]);
  }

  static RecordDetail voucherDetail(Map<String, dynamic> m, PayableRecord row) {
    final lines = [
      for (final l in JsonRead.listOfMaps(JsonRead.field(m, 'paymentVoucherDetails')))
        RecordLine(
          title: pick(l, const ['accountName', 'classificationName', 'accountCode']).isEmpty
              ? 'Line'
              : pick(l, const ['accountName', 'classificationName', 'accountCode']),
          subtitle: pick(l, const ['description']),
          amount: pickNumber(l, const ['amount']),
        ),
    ];
    final total = pickNumber(m, const ['amount']);
    final po = JsonRead.integer(JsonRead.field(m, 'billsOrderMasterRefId'));
    return RecordDetail(lineTitle: 'Accounts', lines: lines, total: total != 0 ? total : row.amount, facts: [
      ('Voucher date', _date(m, const ['paymentVoucherDate', 'sPaymentVoucherDate'])),
      ('Pay to', pick(m, const ['payTo']).isEmpty ? row.party : pick(m, const ['payTo'])),
      ('Paid from', pick(m, const ['payFrom']).isEmpty ? row.tag : pick(m, const ['payFrom'])),
      ('Reference', pick(m, const ['refNo'])),
      ('Bank charges', _rm(pickNumber(m, const ['bankCharges']))),
      ('Status', statusLabel(pick(m, const ['paymentStatus']))),
      ('For a PO', po > 0 ? 'Yes (PO id $po)' : ''),
      ('Expense', pick(m, const ['description'])),
      ('QNE', pick(m, const ['qneCode'])),
    ]);
  }

  static RecordDetail pettyDetail(Map<String, dynamic> m, PayableRecord row) {
    final lines = [
      for (final l in JsonRead.listOfMaps(JsonRead.field(m, 'pettyCashDetails')))
        RecordLine(
          title: pick(l, const ['items', 'accountName']).isEmpty ? 'Item' : pick(l, const ['items', 'accountName']),
          subtitle: [pick(l, const ['accountName']), pick(l, const ['notes'])]
              .where((t) => t.isNotEmpty && t != pick(l, const ['items']))
              .join(' · '),
          amount: pickNumber(l, const ['amount']),
        ),
    ];
    final total = pickNumber(m, const ['amount']); // a String on this answer; read as a number
    final sum = lines.fold<double>(0, (s, l) => s + l.amount);
    return RecordDetail(lineTitle: 'Items', lines: lines, total: total != 0 ? total : (sum != 0 ? sum : row.amount), facts: [
      ('Date', _date(m, const ['pettyCashDate', 'sPettyCashDate'])),
      ('Employee', row.party),
      ('Department', pick(m, const ['department'])),
      ('Status', statusLabel(pick(m, const ['paymentStatus']))),
      ('Remark', pick(m, const ['remark'])),
    ]);
  }

  static RecordDetail levyDetail(Map<String, dynamic> m, PayableRecord row) {
    final amount = pickNumber(m, const ['amount']);
    return RecordDetail(lineTitle: 'Lines', lines: const [], total: amount != 0 ? amount : row.amount, facts: [
      ('Date', _date(m, const ['saleDate'])),
      ('Truck', pick(m, const ['truckName'])),
      ('Driver', pick(m, const ['driverName'])),
      ('RTI', pick(m, const ['rtiNumber'])),
      ('In / out', pick(m, const ['enterLink'])),
      ('Payment voucher', row.description.contains('PV ') ? row.description.split('PV ').last.split(' · ').first : ''),
      ('Remarks', pick(m, const ['remarks'])),
    ]);
  }

  // ── files ─────────────────────────────────────────────────────────────────────

  /// How many files each record of [kind] has (records with none are absent).
  Future<Map<int, int>> fileCounts(RecordKind kind) async {
    final data = JsonRead.map(await _get('/api/attachments/summary', {'companyRefId': _comid, 'folderName': kind.folder}));
    return {
      for (final e in data.entries)
        if (int.tryParse(e.key) != null) int.parse(e.key): JsonRead.integer(e.value),
    };
  }

  /// The files of one record.
  Future<List<RecordFile>> files(PayableRecord row) async => [
        for (final m in JsonRead.listOfMaps(await _get('/api/attachments',
            {'companyRefId': _comid, 'recordId': row.id, 'folderName': row.kind.folder})))
          RecordFile.fromJava(m),
      ];

  // ── transport ─────────────────────────────────────────────────────────────────

  Future<dynamic> _get(String path, Map<String, dynamic> query) async =>
      JavaResponse.data(await _call(() => _dio.get<dynamic>(path, queryParameters: query)));

  Future<dynamic> _post(String path, Map<String, dynamic> body) async => JavaResponse.data(await _call(() =>
      _dio.post<dynamic>(path, queryParameters: {'companyId': _comid}, data: body, options: Options(headers: {'Comid': _comid}))));

  Future<dynamic> _call(Future<Response<dynamic>> Function() call) async {
    try {
      return (await call()).data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }

  /// The purchase order answers `{ok, message, data}`.
  static dynamic _legacy(dynamic body) {
    if (body is! Map) throw const ApiFailure('Unexpected response from server');
    if (!JsonRead.boolean(body['ok'])) throw ApiFailure(JsonRead.stringOrNull(body['message']) ?? 'Request failed');
    return body['data'];
  }
}
