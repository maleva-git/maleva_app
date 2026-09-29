import 'package:get_it/get_it.dart';
import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/core/session/app_session.dart';

import 'data/datasources/ir_remote_data_source.dart';
import 'data/repositories/ir_repository_impl.dart';
import 'domain/repositories/ir_repository.dart';
import 'presentation/form/bloc/ir_form_bloc.dart';
import 'presentation/list/bloc/ir_list_bloc.dart';

/// Registers the IR feature. Blocs are factories, so every page gets a fresh one.
void registerIrReportModule(GetIt sl) {
  if (sl.isRegistered<IrRepository>()) return;

  if (!sl.isRegistered<AppSession>()) {
    sl.registerLazySingleton<AppSession>(() => const PreferencesAppSession());
  }

  sl
    ..registerLazySingleton<IrRemoteDataSource>(() => IrRemoteDataSource(sl<DioClient>().dio))
    ..registerLazySingleton<IrRepository>(
      () => IrRepositoryImpl(remote: sl<IrRemoteDataSource>(), session: sl<AppSession>()),
    )
    ..registerFactory<IrListBloc>(() => IrListBloc(repository: sl<IrRepository>()))
    ..registerFactory<IrFormBloc>(() => IrFormBloc(repository: sl<IrRepository>()));
}
