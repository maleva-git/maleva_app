import 'package:get_it/get_it.dart';
import 'data/stock_transfer_repository.dart';
import 'bloc/stock_transfer_bloc.dart';

void registerStockTransferModule(GetIt sl) {
  // ── Stock Transfer ────────────────────────────────────────────────────────
  sl.registerLazySingleton<StockTransferRepository>(
        () => StockTransferRepository(),
  );
  sl.registerFactory<StockTransferBloc>(
        () => StockTransferBloc(repository: sl<StockTransferRepository>()),
  );

}
