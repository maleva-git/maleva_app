import 'package:get_it/get_it.dart';
import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/planning/planning_api.dart';
import 'package:maleva/core/planning/vessel_planning_api.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/core/lookups/shared_lookups.dart';
import 'package:maleva/core/stock/stock_in_api.dart';
import 'package:maleva/core/network/java_api_client.dart';
import 'package:maleva/core/router/app_router.dart';
import 'package:maleva/core/session/session_token_store.dart';
import 'package:maleva/features/auth/data/mobile_auth_api.dart';
import 'package:maleva/features/auth/data/session_service.dart';
import 'package:maleva/features/auth/data/session_writer.dart';

/// The Java session: encrypted token store, the Java client, sign-in /
/// restore / sign-out. Additive - no existing registration changes.
void registerAuthModule(GetIt sl) {
  sl.registerLazySingleton<SessionTokenStore>(() => SessionTokenStore(const PlatformSecureKeyValueStore()));
  sl.registerLazySingleton<JavaApiClient>(() => JavaApiClient(sl<SessionTokenStore>()));
  sl.registerLazySingleton<MobileAuthApi>(() => MobileAuthApi(sl<JavaApiClient>()));
  // the shared Java lookups and fuel entries (the web's APIs), for LegacyCallAdapter
  sl.registerLazySingleton<SharedLookups>(() => SharedLookups(sl<JavaApiClient>().dio));
  // the dashboard numbers (the web's /api/dashboard)
  sl.registerLazySingleton<DashboardApi>(() => DashboardApi(sl<JavaApiClient>().dio));
  // stock-in entry (the shared /api/stock-ins)
  sl.registerLazySingleton<StockInApi>(() => StockInApi(sl<JavaApiClient>().dio));
  // sale orders (the shared /api/sale-orders and friends)
  sl.registerLazySingleton<SaleOrderApi>(
      () => SaleOrderApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // transport and vessel planning (the shared /api/planing and /api/vessel-plannings)
  sl.registerLazySingleton<PlanningApi>(
      () => PlanningApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  sl.registerLazySingleton<VesselPlanningApi>(
      () => VesselPlanningApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // record attachments (the shared /api/attachments)
  sl.registerLazySingleton<AttachmentsApi>(
      () => AttachmentsApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  sl.registerLazySingleton<SessionWriter>(() => SessionWriter(sl<SessionTokenStore>()));
  sl.registerLazySingleton<SessionService>(() {
    final service = SessionService(
      api: sl<MobileAuthApi>(),
      tokens: sl<SessionTokenStore>(),
      writer: sl<SessionWriter>(),
    );
    // a Java call whose session cannot be refreshed any more ends at the login page
    service.attachTo(sl<JavaApiClient>(), onSessionEnded: () => appRouter.go('/login'));
    return service;
  });
}
