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
import 'package:maleva/core/rti/rti_entry_api.dart';
import 'package:maleva/core/employee/leave_api.dart';
import 'package:maleva/core/lookups/customer_api.dart';
import 'package:maleva/core/lookups/job_type_api.dart';
import 'package:maleva/core/lookups/job_status_api.dart';
import 'package:maleva/core/lookups/agent_api.dart';
import 'package:maleva/core/lookups/product_api.dart';
import 'package:maleva/core/lookups/address_api.dart';
import 'package:maleva/core/fleet/truck_api.dart';
import 'package:maleva/core/reports/transaction_report_api.dart';
import 'package:maleva/core/finance/bills_order_api.dart';
import 'package:maleva/core/employee/forwarding_salary_api.dart';
import 'package:maleva/core/employee/boarding_salary_api.dart';
import 'package:maleva/core/sale_order/cargo_inventory_api.dart';
import 'package:maleva/core/fleet/driver_api.dart';
import 'package:maleva/core/lookups/location_api.dart';
import 'package:maleva/core/finance/petty_cash_api.dart';
import 'package:maleva/core/sale_order/sale_order_api.dart';
import 'package:maleva/core/utils/app_preferences.dart';
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
  // bills orders and petty cash (was .NET BIllorderApp)
  sl.registerLazySingleton<BillsOrderApi>(
      () => BillsOrderApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  sl.registerLazySingleton<PettyCashApi>(
      () => PettyCashApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // forwarding salaries (the shared /api/forwarding-salaries/entries)
  sl.registerLazySingleton<ForwardingSalaryApi>(
      () => ForwardingSalaryApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // boarding officers' salary (the shared /api/boarding-settlement/monthly-salary)
  sl.registerLazySingleton<BoardingSalaryApi>(
      () => BoardingSalaryApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // the cargo inventory by port (the shared /api/sale-orders/inventory)
  sl.registerLazySingleton<CargoInventoryApi>(
      () => CargoInventoryApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // drivers (the shared /api/driver-masters/search)
  sl.registerLazySingleton<DriverApi>(
      () => DriverApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // locations (the shared /api/location-master)
  sl.registerLazySingleton<LocationApi>(
      () => LocationApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // the RTI entry form (the shared /api/rti-masters create / update / revise / delete)
  sl.registerLazySingleton<RtiEntryApi>(
      () => RtiEntryApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // leave requests (the shared /api/leave)
  sl.registerLazySingleton<LeaveApi>(
      () => LeaveApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // customer and job type pickers (the shared /api/customers/options, /api/job-type-master/jobtypes)
  sl.registerLazySingleton<CustomerApi>(
      () => CustomerApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  sl.registerLazySingleton<JobTypeApi>(
      () => JobTypeApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // job statuses and job-type steps (the shared job status / job type masters)
  sl.registerLazySingleton<JobStatusApi>(
      () => JobStatusApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // agent and agent company pickers (the shared /api/agents, /api/agent-companies)
  sl.registerLazySingleton<AgentApi>(
      () => AgentApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // the product picker (the shared /api/item-masters/company/{id}/products)
  sl.registerLazySingleton<ProductApi>(
      () => ProductApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // address pickers (the shared /api/addresses)
  sl.registerLazySingleton<AddressApi>(
      () => AddressApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
  // trucks: the picker list, one truck and its save (the shared /api/truck-combo, /api/truck-masters)
  sl.registerLazySingleton<TruckApi>(
      () => TruckApi(sl<JavaApiClient>().dio, companyId: AppPreferences.getComid));
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
