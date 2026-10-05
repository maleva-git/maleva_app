import 'package:get_it/get_it.dart';
import 'package:maleva/core/dashboard/dashboard_api.dart';
import 'package:maleva/core/employee/email_inbox_api.dart';
import 'package:maleva/core/enquiry/enquiry_api.dart';
import 'package:maleva/core/employee/employee_api.dart';
import 'package:maleva/core/employee/google_review_api.dart';
import 'package:maleva/core/files/attachments_api.dart';
import 'package:maleva/core/fleet/expiry_api.dart';
import 'package:maleva/core/fleet/gps_api.dart';
import 'package:maleva/core/fleet/truck_entries_api.dart';
import 'package:maleva/core/fuel/fuel_entry_api.dart';
import 'package:maleva/core/job_order/job_order_api.dart';
import 'package:maleva/core/planning/planning_api.dart';
import 'package:maleva/core/planning/vessel_planning_api.dart';
import 'package:maleva/core/rti/rti_api.dart';
import 'package:maleva/core/reports/transaction_report_api.dart';
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
  // the shared Java lookups (the web's APIs), for LegacyCallAdapter
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
  // truck spare parts, summon and spot sale entries (TruckSparePartsApp ported)
  sl.registerLazySingleton<TruckEntriesApi>(
      () => TruckEntriesApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // GPS lists and truck / driver expiry lists (MasterReportApp ported)
  sl.registerLazySingleton<GpsApi>(
      () => GpsApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  sl.registerLazySingleton<ExpiryApi>(
      () => ExpiryApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // fuel entries (the shared /api/fuel-entries)
  sl.registerLazySingleton<FuelEntryApi>(
      () => FuelEntryApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // employee pickers (the shared /api/employees and /api/employee-ports)
  sl.registerLazySingleton<EmployeeApi>(
      () => EmployeeApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // enquiries (the shared /api/enquiry-masters list and status)
  sl.registerLazySingleton<EnquiryApi>(
      () => EnquiryApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // the staff email inbox (the shared /api/email-inboxes)
  sl.registerLazySingleton<EmailInboxApi>(
      () => EmailInboxApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // staff Google reviews (the shared /api/google-reviews)
  sl.registerLazySingleton<GoogleReviewApi>(
      () => GoogleReviewApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // RTIs (the shared /api/rti-masters and /api/rti-route-activities)
  sl.registerLazySingleton<RtiApi>(
      () => RtiApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // driver salary, receipt balances and the pre-alert PDF (was .NET TransactionReportApp)
  sl.registerLazySingleton<TransactionReportApi>(
      () => TransactionReportApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // job orders (the shared /api/job-orders)
  sl.registerLazySingleton<JobOrderApi>(
      () => JobOrderApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
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
