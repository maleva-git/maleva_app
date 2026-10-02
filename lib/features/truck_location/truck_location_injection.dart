import 'package:get_it/get_it.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/session/app_session.dart';

import 'data/datasources/truck_location_remote_data_source.dart';
import 'data/repositories/truck_location_repository_impl.dart';
import 'domain/repositories/truck_location_repository.dart';
import 'presentation/bloc/truck_location_bloc.dart';

/// Registers the Truck Location feature. The bloc is a factory, so every
/// visit to the screen starts fresh.
void registerTruckLocationModule(GetIt sl) {
  if (sl.isRegistered<TruckLocationRepository>()) return;

  if (!sl.isRegistered<AppSession>()) {
    sl.registerLazySingleton<AppSession>(() => const PreferencesAppSession());
  }

  sl
    ..registerLazySingleton<TruckLocationRemoteDataSource>(
      () => TruckLocationRemoteDataSource(sl<JavaApiClient>().dio),
    )
    ..registerLazySingleton<TruckLocationRepository>(
      () => TruckLocationRepositoryImpl(
        remote: sl<TruckLocationRemoteDataSource>(),
        session: sl<AppSession>(),
      ),
    )
    ..registerFactory<TruckLocationBloc>(
      () => TruckLocationBloc(repository: sl<TruckLocationRepository>()),
    );
}
