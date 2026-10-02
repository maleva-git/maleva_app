import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/models/shared/payment_pending_model.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/features/dashboard/common_tabs/paymentview/bloc/paymentview_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/paymentview/bloc/paymentview_event.dart';
import 'package:maleva/features/dashboard/common_tabs/paymentview/bloc/paymentview_state.dart';
import 'package:maleva/features/dashboard/common_tabs/paymentview/data/paymentview_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The Payment Pending tab on the shared Java board: the bloc asks once per
/// filter, with the company, and keeps the selected filters on an error.
class RecordingPayments extends PaymentViewRepository {
  final calls = <Map<String, int>>[];
  PaymentPendingLists response = const PaymentPendingLists([], []);
  bool fail = false;
  @override
  Future<PaymentPendingLists> fetchPaymentPending({
    required int comid,
    required int expenseFilter,
    required int paidFilter,
    DateTime? month,
  }) async {
    calls.add({'comid': comid, 'expense': expenseFilter, 'paid': paidFilter});
    if (fail) throw StateError('fixture failure');
    return response;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({'Comid': 17});
    AppGlobals.storagenew = await SharedPreferences.getInstance();
  });

  test('initial load asks once for the company with no filters', () async {
    final repo = RecordingPayments();
    final bloc = PaymentPendingBloc(repository: repo);
    await bloc.stream.firstWhere((s) => s is PaymentPendingLoaded);
    expect(repo.calls, [{'comid': 17, 'expense': 0, 'paid': 0}]);
    expect((bloc.state as PaymentPendingLoaded).masterList, isEmpty);
    await bloc.close();
  });

  test('the lists are shown as the repository gives them', () async {
    final bill = PaymentPendingModel(id: 1, SubExpenseName: 'TNB', Amount: 10, Paiddamount: '0', InnerAmount: 0);
    final repo = RecordingPayments()..response = PaymentPendingLists([bill], [bill]);
    final bloc = PaymentPendingBloc(repository: repo);
    final loaded = await bloc.stream.firstWhere((s) => s is PaymentPendingLoaded) as PaymentPendingLoaded;
    expect(loaded.masterList.single.SubExpenseName, 'TNB');
    expect(loaded.detailsList, hasLength(1));
    await bloc.close();
  });

  test('filters load once and errors preserve selected filters', () async {
    final repo = RecordingPayments();
    final bloc = PaymentPendingBloc(repository: repo);
    await bloc.stream.firstWhere((s) => s is PaymentPendingLoaded);
    repo.fail = true;
    final error = bloc.stream.firstWhere((s) => s is PaymentPendingError);
    bloc.add(const SelectExpenseFilterEvent('Utility'));
    final state = await error as PaymentPendingError;
    expect(repo.calls.length, 2);
    expect(repo.calls.last['expense'], 3);
    expect(state.selectedFilter, 'Utility');
    expect(state.message, contains('fixture failure'));
    await bloc.close();
  });
}
