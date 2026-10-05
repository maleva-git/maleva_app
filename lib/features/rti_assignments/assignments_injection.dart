import 'package:get_it/get_it.dart';
import 'package:maleva/core/employee/employee_api.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/rti/employee_assignments_api.dart';
import 'package:maleva/core/rti/rti_list_api.dart';
import 'package:maleva/core/session/app_session.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/utils/system_helpers.dart';
import 'package:maleva/features/rti_assignments/bloc/assignments_bloc.dart';
import 'package:maleva/features/rti_assignments/data/assignments_repository.dart';

/// Registers Employee Assignments. Needs [JavaApiClient] and [EmployeeApi], which the app
/// registers at start-up. The bloc is a factory.
void registerAssignmentsFeature(GetIt sl) {
  if (sl.isRegistered<AssignmentsRepository>()) return;
  if (!sl.isRegistered<AppSession>()) {
    sl.registerLazySingleton<AppSession>(() => const PreferencesAppSession());
  }
  if (!sl.isRegistered<RtiListApi>()) {
    sl.registerLazySingleton<RtiListApi>(() => RtiListApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  }
  if (!sl.isRegistered<EmployeeAssignmentsApi>()) {
    sl.registerLazySingleton<EmployeeAssignmentsApi>(
        () => EmployeeAssignmentsApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  }
  sl
    ..registerLazySingleton<AssignmentsRepository>(() => AssignmentsRepository(
          assignments: sl<EmployeeAssignmentsApi>(),
          rti: sl<RtiListApi>(),
          employees: sl<EmployeeApi>(),
          session: sl<AppSession>(),
          userName: AppPreferences.getUsername,
        ))
    ..registerFactory<AssignmentsBloc>(
      () => AssignmentsBloc(repository: sl<AssignmentsRepository>(), openUrl: (url) async => SystemHelpers.launchInBrowser(url)),
    );
}
