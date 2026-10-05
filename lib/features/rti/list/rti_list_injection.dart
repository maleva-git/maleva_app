import 'package:get_it/get_it.dart';
import 'package:maleva/core/fleet/driver_api.dart';
import 'package:maleva/core/fleet/truck_api.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/rti/rti_api.dart';
import 'package:maleva/core/rti/rti_entry_api.dart';
import 'package:maleva/core/rti/rti_list_api.dart';
import 'package:maleva/core/session/app_session.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/system_helpers.dart';
import 'package:maleva/features/rti/list/bloc/rti_list_bloc.dart';
import 'package:maleva/features/rti/list/data/rti_list_repository.dart';

/// Registers the RTI list. Needs [JavaApiClient], [RtiApi], [RtiEntryApi], [DriverApi] and
/// [TruckApi], which the app registers at start-up. The bloc is a factory.
void registerRtiListFeature(GetIt sl) {
  if (sl.isRegistered<RtiListRepository>()) return;
  if (!sl.isRegistered<AppSession>()) {
    sl.registerLazySingleton<AppSession>(() => const PreferencesAppSession());
  }
  if (!sl.isRegistered<RtiListApi>()) {
    sl.registerLazySingleton<RtiListApi>(() => RtiListApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  }
  sl
    ..registerLazySingleton<RtiListRepository>(() => RtiListRepository(
          list: sl<RtiListApi>(),
          rti: sl<RtiApi>(),
          entry: sl<RtiEntryApi>(),
          drivers: sl<DriverApi>(),
          trucks: sl<TruckApi>(),
          session: sl<AppSession>(),
        ))
    ..registerFactory<RtiListBloc>(
      () => RtiListBloc(repository: sl<RtiListRepository>(), openUrl: (url) async => SystemHelpers.launchInBrowser(url)),
    );
}
