import 'package:flutter_test/flutter_test.dart';
import 'package:maleva/core/di/injection.dart';
import 'package:maleva/core/session/app_session.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/session_manager.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/features/dashboard/common_tabs/stocktransfer/data/stock_transfer_repository.dart';
import 'package:maleva/features/dashboard/common_tabs/stockupdate/data/stock_update_repository.dart';
import 'package:maleva/features/ir_report/domain/repositories/ir_repository.dart';
import 'package:maleva/features/ir_report/presentation/list/bloc/ir_list_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({'Comid': 10, 'EmpRefId': 42, 'DriverId': 1});
    await setupDependencies();
  });
  tearDown(() async {
    sl<JavaApiClient>().dio.close();
    await sl.reset();
  });
  test('repositories are shared and route BLoCs are fresh', () async {
    expect(identical(sl<IrRepository>(), sl<IrRepository>()), isTrue);
    final first = sl<IrListBloc>();
    final second = sl<IrListBloc>();
    expect(identical(first, second), isFalse);
    await first.close();
    await second.close();
  });
  test('stock captures company at construction; session reads stay live', () async {
    final transfer = StockTransferRepository();
    final update = StockUpdateRepository();
    await AppPreferences.setComid(20);
    expect(transfer.comid, 10);
    expect(update.comid, 10);
    expect(StockTransferRepository().comid, 20);
    expect(sl<SessionManager>().companyId, 20);
    expect(sl<AppSession>().companyId, 20);
  });
  test('driver identity differs deliberately between session contracts', () {
    expect(sl<SessionManager>().empRefId, 42);
    expect(sl<AppSession>().employeeId, 0);
    expect(StockUpdateRepository().empRefId, 42);
  });
}
