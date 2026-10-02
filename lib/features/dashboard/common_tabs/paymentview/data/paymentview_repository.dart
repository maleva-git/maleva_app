import 'package:dio/dio.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/models/shared/payment_pending_model.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/network/java_response.dart';
import 'package:maleva/core/utils/json_read.dart';

/// The lists the Payment Pending tab shows.
class PaymentPendingLists {
  const PaymentPendingLists(this.masters, this.details);

  /// The month's bills (filtered) and the suppliers owed, one line each.
  final List<PaymentPendingModel> masters;

  /// What is still unpaid: bills with no payment voucher yet, and each
  /// supplier's unpaid credit bills.
  final List<PaymentPendingModel> details;
}

/// Payment Pending, from the shared Java board the web's Pending Payments screen
/// uses (`GET /api/pending-payments/board`, ported from .NET SelectPendingPayment).
/// As in .NET, the board is the current month.
class PaymentViewRepository {
  PaymentViewRepository({Dio? dio}) : _dio = dio;

  final Dio? _dio;

  /// The .NET expense filter: 1 HIRE PURCHASE, 2 VENDOR, 3 UTILITY, 4 TENANCY, 5 MONTHLY PURPOSE.
  static const _heads = {1: 'HIRE PURCHASE', 2: 'VENDOR', 3: 'UTILITY', 4: 'TENANCY', 5: 'MONTHLY PURPOSE'};

  /// [expenseFilter] as above (0 all); [paidFilter] 1 paid, 2 not paid, 0 all
  /// (it applies to the bills, as in .NET; the supplier lines stay).
  Future<PaymentPendingLists> fetchPaymentPending({
    required int comid,
    required int expenseFilter,
    required int paidFilter,
    DateTime? month,
  }) async {
    final m = month ?? DateTime.now();
    final Response<dynamic> response;
    try {
      response = await (_dio ?? sl<JavaApiClient>().dio).get<dynamic>('/api/pending-payments/board', queryParameters: {
        'companyId': comid,
        'month': '${m.year.toString().padLeft(4, '0')}-${m.month.toString().padLeft(2, '0')}',
      });
    } on DioException catch (e) {
      throw JavaResponse.fromDio(e);
    }
    final board = JsonRead.map(JavaResponse.data(response.data));
    final bills = JsonRead.listOfMaps(board['bills']);
    final vendors = JsonRead.listOfMaps(board['vendors']);

    final head = _heads[expenseFilter];
    bool keepHead(String? name) => head == null || (name ?? '').toUpperCase() == head;

    final masters = <PaymentPendingModel>[
      for (final b in bills)
        if (keepHead(b['expenseName']?.toString()) &&
            (paidFilter == 0 || (paidFilter == 1) == (b['paid'] == true)))
          PaymentPendingModel.fromBoardBill(b),
      if (keepHead('VENDOR'))
        for (final v in vendors) PaymentPendingModel.fromBoardVendor(v),
    ]..sort((a, b) => (a.SubExpenseName ?? '').compareTo(b.SubExpenseName ?? ''));

    final details = <PaymentPendingModel>[
      for (final b in bills)
        if (b['paid'] != true && ((b['voucherAmount'] as num?) ?? 0) == 0 && ((b['amount'] as num?) ?? 0) != 0)
          PaymentPendingModel.fromBoardBill(b),
      for (final v in vendors)
        for (final vb in JsonRead.listOfMaps(v['bills']))
          if (((vb['outstanding'] as num?) ?? 0) != 0) PaymentPendingModel.fromBoardVendorBill(v['supplierName']?.toString(), vb),
    ]..sort((a, b) => (a.ExpenseName ?? '').compareTo(b.ExpenseName ?? ''));

    return PaymentPendingLists(masters, details);
  }
}
