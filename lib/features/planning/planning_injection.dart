import 'package:get_it/get_it.dart';
import 'package:maleva/core/access/screen_access_api.dart';
import 'package:maleva/core/fleet/driver_api.dart';
import 'package:maleva/core/fleet/truck_api.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/planning/planning_api.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/planning/bloc/plan_cubit.dart';
import 'package:maleva/features/planning/data/planning_repository.dart';
import 'package:maleva/features/rti/data/rti_from_planning.dart';

/// The Planning feature's registrations. Needs the Java client and the core APIs
/// (`registerAuthModule`) and an [RtiFromPlanning] (the RTI feature) when a plan opens.
void registerPlanningFeature(GetIt sl) {
  if (!sl.isRegistered<PlanningRepository>()) {
    sl.registerLazySingleton<PlanningRepository>(() => JavaPlanningRepository(
          dio: sl<JavaApiClient>().dio,
          planning: sl<PlanningApi>(),
          screenAccess: sl<ScreenAccessApi>(),
          truckApi: sl<TruckApi>(),
          driverApi: sl<DriverApi>(),
          saleOrders: sl<SaleOrderApi>(),
          companyId: AppPreferences.getComid,
          userId: AppPreferences.getEmpRefId,
        ));
  }
  if (!sl.isRegistered<PlanCubit>()) {
    sl.registerFactory<PlanCubit>(() => PlanCubit(repo: sl<PlanningRepository>(), rtiFromPlanning: sl<RtiFromPlanning>()));
  }
}
