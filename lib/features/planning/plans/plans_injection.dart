import 'package:get_it/get_it.dart';
import 'package:maleva/core/employee/employee_api.dart';
import 'package:maleva/core/planning/planning_api.dart';
import 'package:maleva/core/session/app_session.dart';
import 'package:maleva/core/utils/system_helpers.dart';
import 'package:maleva/features/planning/plans/bloc/plans_bloc.dart';
import 'package:maleva/features/planning/plans/data/plans_repository.dart';

/// Registers Planning View (the saved plans). Needs [PlanningApi] and [EmployeeApi], which the
/// app registers at start-up. The bloc is a factory: each page gets a fresh one.
void registerPlansFeature(GetIt sl) {
  if (sl.isRegistered<PlansRepository>()) return;
  if (!sl.isRegistered<AppSession>()) {
    sl.registerLazySingleton<AppSession>(() => const PreferencesAppSession());
  }
  sl
    ..registerLazySingleton<PlansRepository>(
      () => PlansRepository(planning: sl<PlanningApi>(), employees: sl<EmployeeApi>(), session: sl<AppSession>()),
    )
    ..registerFactory<PlansBloc>(
      () => PlansBloc(repository: sl<PlansRepository>(), openUrl: (url) async => SystemHelpers.launchInBrowser(url)),
    );
}
