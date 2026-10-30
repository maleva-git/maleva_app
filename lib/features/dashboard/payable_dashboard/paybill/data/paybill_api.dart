import 'package:dio/dio.dart';
import 'package:maleva/core/network/api_failure.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

import '../../po/data/po_api.dart';
import '../../po/data/po_draft.dart';
import '../../records/data/payable_record.dart';
import '../../voucher/data/voucher_api.dart';
import 'paybill_draft.dart';

/// The supplier's bank and tax details the pay bill carries.
typedef SupplierBank = ({String bankName, String accountNo, String tinNo, String sstNo, String msicCode, String serviceTaxType});

/// The pay bill form's calls (change `payable-paybill-form`); suppliers are [po]'s, banks are [vouchers]'.
class PayBillApi {
  PayBillApi(this._dio, this.po, this.vouchers);

  final Dio _dio;
  final PoApi po;
  final VoucherApi vouchers;

  int get companyId => po.companyId;

  Future<String> nextNumber() async => JsonRead.string(await _get('/api/payments/next-number', {'companyId': companyId}));

  /// The supplier's open documents; [excludePaymentId] when editing, so this payment's bills still show as open.
  Future<List<PayRow>> supplierBills(int supplierId, {int excludePaymentId = 0}) async => [
        for (final m in JsonRead.listOfMaps(await _get('/api/payments/supplier-bills',
            {'companyId': companyId, 'supplierId': supplierId, 'excludePaymentId': excludePaymentId})))
          PayRow.fromJava(m),
      ];

  /// The supplier's bank and tax details (`/api/suppliers/select` by id), as the web fills them.
  Future<SupplierBank> supplierBank(int supplierId) async {
    final dynamic res;
    try {
      res = (await _dio.post<dynamic>('/api/suppliers/select', queryParameters: {
        'Comid': companyId,
        'Startindex': 0,
        'PageCount': 20,
        'Keyword': '$supplierId',
        'Column': 'Id',
      }))
          .data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    final raw = res is Map ? (res['data'] ?? res['Data'] ?? res['Data1'] ?? res['data1']) : res;
    final rows = JsonRead.listOfMaps(raw);
    final s = rows.isEmpty ? const <String, dynamic>{} : rows.first;
    return (
      bankName: pick(s, const ['BankName']),
      accountNo: pick(s, const ['AccountNo']),
      tinNo: pick(s, const ['TinNo']),
      sstNo: pick(s, const ['SSTNo']),
      msicCode: pick(s, const ['MsicCode']),
      serviceTaxType: pick(s, const ['ServiceTaxType']),
    );
  }

  Future<List<Option>> banks() => vouchers.banks();

  Future<Map<String, dynamic>> load(int id) async {
    final m = JsonRead.map(await _get('/api/payments/edit', {'companyId': companyId, 'id': id}));
    if (m.isEmpty) throw const ApiFailure('Pay bill not found');
    return m;
  }

  /// The supplier of a bill (for "Pay this bill").
  Future<int> supplierOfBill(int billId) async => JsonRead.integer(JsonRead.field(
      JsonRead.map(await _get('/api/bills/edit', {'companyId': companyId, 'id': billId, 'billNumber': 0})), 'supplierRefId'));

  Future<({int id, String number, bool duplicate})> save(Map<String, dynamic> body) async {
    final dynamic res;
    try {
      res = (await _dio.post<dynamic>('/api/payments/save',
              data: body, queryParameters: {'companyId': companyId}, options: Options(headers: {'Comid': '$companyId'})))
          .data;
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    final d = JsonRead.map(JavaResponse.data(res));
    if (d.containsKey('success') && !JsonRead.boolean(d['success'])) {
      throw ApiFailure(JsonRead.stringOrNull(d['message']) ?? 'Could not save');
    }
    return (id: JsonRead.integer(d['id']), number: JsonRead.string(d['paymentNoDisplay']), duplicate: JsonRead.boolean(d['duplicate']));
  }

  Future<dynamic> _get(String path, Map<String, dynamic> query) async {
    try {
      return JavaResponse.data((await _dio.get<dynamic>(path, queryParameters: query)).data);
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
  }
}
