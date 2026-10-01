import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/utils/app_globals.dart';
import 'package:maleva/features/dashboard/common_tabs/paymentview/bloc/paymentview_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/paymentview/bloc/paymentview_event.dart';
import 'package:maleva/features/dashboard/common_tabs/paymentview/bloc/paymentview_state.dart';
import 'package:maleva/features/dashboard/common_tabs/paymentview/data/paymentview_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordingPayments extends PaymentViewRepository {
  final calls = <Map<String, dynamic>>[];
  dynamic response = <dynamic>[];
  bool fail = false;
  @override
  Future<dynamic> fetchPaymentPendingData(Map<String, dynamic> body) async {
    calls.add(body);
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
  for (final response in [null, [], [{'ExpenseReportModel': [], 'ExpenseReportDetailsModel': []}], [[], []]]) {
    test('initial load preserves response shape $response', () async {
      final repo = RecordingPayments()..response = response;
      final bloc = PaymentPendingBloc(repository: repo);
      await bloc.stream.firstWhere((s) => s is PaymentPendingLoaded);
      expect(repo.calls.length, 1);
      expect(repo.calls.single['Comid'], 17);
      expect(repo.calls.single['Fromdate'], repo.calls.single['Todate']);
      expect((bloc.state as PaymentPendingLoaded).masterList, isEmpty);
      await bloc.close();
    });
  }
  test('filters load once and errors preserve selected filters', () async {
    final repo = RecordingPayments();
    final bloc = PaymentPendingBloc(repository: repo);
    await bloc.stream.firstWhere((s) => s is PaymentPendingLoaded);
    repo.fail = true;
    final error = bloc.stream.firstWhere((s) => s is PaymentPendingError);
    bloc.add(const SelectExpenseFilterEvent('All'));
    final state = await error as PaymentPendingError;
    expect(repo.calls.length, 2);
    expect(state.selectedFilter, 'All');
    expect(state.message, contains('fixture failure'));
    await bloc.close();
  });
}
