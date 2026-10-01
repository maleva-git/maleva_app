import 'package:get_it/get_it.dart';
import 'data/paymentview_repository.dart';
import 'bloc/paymentview_bloc.dart';

void registerPaymentViewModule(GetIt sl) {
  // ── Payment View ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<PaymentViewRepository>(
        () => PaymentViewRepository(),
  );
  sl.registerFactory<PaymentPendingBloc>(
        () => PaymentPendingBloc(repository: sl<PaymentViewRepository>()),
  );

}
