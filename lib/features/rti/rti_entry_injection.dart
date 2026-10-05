import 'package:get_it/get_it.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/fleet/driver_api.dart';
import 'package:maleva/core/fleet/truck_api.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/rti/levi_api.dart';
import 'package:maleva/core/rti/rti_entry_api.dart';
import 'package:maleva/core/rti/rti_job_lookup_api.dart';
import 'package:maleva/core/session/app_session.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/rti/bloc/levi_bloc.dart';
import 'package:maleva/features/rti/bloc/rti_entry_bloc.dart';
import 'package:maleva/features/rti/data/rti_entry_repository.dart';
import 'package:maleva/features/rti/data/rti_from_planning.dart';
import 'package:maleva/features/rti/data/rti_from_planning_service.dart';

/// Registers the RTI entry (change `planning-rti-phone-tablet`): its APIs, repository,
/// [RtiFromPlanning] for Planning's Create RTI, and the bloc factories. Uses the shared
/// [RtiEntryApi], [DriverApi], [TruckApi] and [AttachmentsApi] registered at sign-in.
void registerRtiEntryFeature(GetIt sl) {
  if (sl.isRegistered<RtiEntryRepository>()) return;
  if (!sl.isRegistered<AppSession>()) {
    sl.registerLazySingleton<AppSession>(() => const PreferencesAppSession());
  }
  sl
    ..registerLazySingleton<RtiJobLookupApi>(() => RtiJobLookupApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid))
    ..registerLazySingleton<LeviApi>(() => LeviApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid))
    ..registerLazySingleton<RtiEntryRepository>(() => RtiEntryRepository(
          api: sl<RtiEntryApi>(),
          lookup: sl<RtiJobLookupApi>(),
          drivers: sl<DriverApi>(),
          trucks: sl<TruckApi>(),
          session: sl<AppSession>(),
        ))
    ..registerLazySingleton<RtiFromPlanning>(() => RtiFromPlanningService(
          repository: sl<RtiEntryRepository>(),
          drivers: sl<DriverApi>(),
          trucks: sl<TruckApi>(),
        ))
    ..registerFactory<RtiEntryBloc>(() => RtiEntryBloc(repository: sl<RtiEntryRepository>()))
    ..registerFactoryParam<LeviBloc, LeviContext, void>(
        (context, _) => LeviBloc(api: sl<LeviApi>(), attachments: sl<AttachmentsApi>(), context: context));
}
