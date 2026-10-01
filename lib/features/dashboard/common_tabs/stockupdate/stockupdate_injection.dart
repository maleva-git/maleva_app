import 'package:get_it/get_it.dart';
import 'data/stock_update_repository.dart';
import 'bloc/stock_update_bloc.dart';

void registerStockUpdateModule(GetIt sl) {
  // ── Stock Update ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<StockUpdateRepository>(
        () => StockUpdateRepository(),
  );
  sl.registerFactory<StockUpdateBloc>(
        () => StockUpdateBloc(repository: sl<StockUpdateRepository>()),
  );

}
