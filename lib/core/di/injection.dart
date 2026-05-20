// lib/core/di/injection.dart

import 'package:flutter/Material.dart';
import 'package:get_it/get_it.dart';

// Core
import 'package:maleva/core/network/api_services/auth_api.dart';
import 'package:maleva/core/utils/app_preferences.dart';

// ── Auth ──────────────────────────────────────────────────────────────────────
import 'package:maleva/features/auth/data/repositories/auth_repository.dart';
import 'package:maleva/features/auth/presentation/bloc/auth_bloc.dart';

// ── Admin tab ─────────────────────────────────────────────────────────────────
import 'package:maleva/features/dashboard/admin_dashboard/bloc/admin_tab_bloc.dart';

// ── Invoice tab ───────────────────────────────────────────────────────────────
import 'package:maleva/features/dashboard/admin_dashboard/tabs/invoice/data/invoice_repository.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/invoice/bloc/invoice_bloc.dart';

// ── AI Invoice forecast ───────────────────────────────────────────────────────
import 'package:maleva/features/dashboard/admin_dashboard/tabs/adinvoice/data/repositories/sales_forecast_repository.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/adinvoice/bloc/forecast/forecast_bloc.dart';

// ── AI Engine hours / maintenance ─────────────────────────────────────────────
import 'package:maleva/features/dashboard/admin_dashboard/tabs/aienginehours/data/repositories/maintenance_ai_repository.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/aienginehours/bloc/ai_maintenance_bloc.dart';

// ── No-dep dashboard tabs ─────────────────────────────────────────────────────
import 'package:maleva/features/dashboard/admin_dashboard/tabs/salesorder/bloc/salesorder_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/maintenance/bloc/maintenance_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/driverlicense/bloc/driverlicense_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/drivermaintenance/bloc/drivermaintenance_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/driversalary/bloc/driversalary_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/receiptview/bloc/receiptview_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/airfreightsales/bloc/airfreightsales_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/stockinentry/bloc/stock_in_entry_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/stocktransfer/bloc/stock_transfer_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/stockupdate/bloc/stock_update_bloc.dart';

import '../../features/dashboard/admin_dashboard/tabs/airfreightsales/data/airfreight_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/bocheck/bloc/bocheck_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/bocheck/data/bocheck_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/driver/bloc/driverdetails_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/driver/data/driver_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/emailinbox/bloc/emailinbox_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/emailinbox/data/emailinbox_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/employeemaster/bloc/employeemaster_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/employeemaster/data/employee_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/enginehours/bloc/enginehours_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/enginehours/tab/enginehours_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/enquiry/view/bloc/enquiry_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/enquiry/view/data/enquiry_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/expensereport/bloc/expensereport_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/expensereport/data/expensereport_repository.dart';

import '../../features/dashboard/admin_dashboard/tabs/forwardingreport/bloc/forwardingreport_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/forwardingreport/data/forwardingreport_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/fuel/bloc/fuelreport_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/fuel/data/fuel_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/fuelfillings/bloc/fuelfillings_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/fuelfillings/data/fuelfillings_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/googlereview/bloc/googlereview_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/googlereview/data/googlereview_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/gpstruckmap/bloc/gpstruckmap_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/inventoryreport/bloc/inventoryreport_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/inventoryreport/data/inventoryreport_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/paymentview/bloc/paymentview_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/paymentview/data/paymentview_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/pdo/data/pdo_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/pettycash/bloc/pettycash_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/pettycash/data/pettycash_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/receiptview/data/receipt_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/rtiview/bloc/rtiview_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/rtiview/data/rtiview_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/saleorderview/bloc/saleorderview_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/saleorderview/data/saleorderrepository.dart';
import '../../features/dashboard/admin_dashboard/tabs/salesorder/data/salesorder_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/spareparts/bloc/spareparts_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/spareparts/data/spareparts_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/speedingreport/bloc/speeding_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/speedingreport/data/speeding_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/spotsaleorder/bloc/spotsaleorder_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/spotsaleorder/data/spotsale_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/subadminsale/bloc/salesreport bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/subadminsale/data/salesreport_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/summonentry/bloc/summonentry_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/summonentry/data/summonentry_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/transport/bloc/transport_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/transport/data/transport_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/transportsales/bloc/transport_sales_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/transportsales/data/transport_sales_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/truck/bloc/truck_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/truck/data/truck_repository.dart';
import '../../features/dashboard/admin_dashboard/tabs/vesselreport/bloc/vesselreport_bloc.dart';
import '../../features/dashboard/admin_dashboard/tabs/vesselreport/data/vessel_report_repository.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ════════════════════════════════════════════════════════════════
  // 0. FOUNDATION
  // ════════════════════════════════════════════════════════════════

  // AppPreferences is all-static — just init() is enough, no registration needed
  await AppPreferences.init();

  // ════════════════════════════════════════════════════════════════
  // 1. API SERVICES  —  lazySingleton
  //    App life-la oru thadava create, everywhere reuse
  // ════════════════════════════════════════════════════════════════

  sl.registerLazySingleton<AuthApi>(() => AuthApi.instance);

  // ════════════════════════════════════════════════════════════════
  // 2. REPOSITORIES  —  lazySingleton
  //    API inject panni create, cache pannivom
  // ════════════════════════════════════════════════════════════════

  // Auth
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepository(authApi: sl<AuthApi>()),
  );

  // Invoice  ← NEW (our refactored repo)
  sl.registerLazySingleton<InvoiceRepository>(
        () => InvoiceRepositoryImpl(),
  );

  // AI Invoice forecast
  sl.registerLazySingleton<SalesForecastRepository>(
        () => SalesForecastRepository(),
  );

  // AI Maintenance
  sl.registerLazySingleton<MaintenanceAIRepository>(
        () => MaintenanceAIRepository(),
  );
// ── REPOSITORIES ──────────────────────────────────────────────────────────

  // Existing Repositories...
  sl.registerLazySingleton<ForwardingReportRepository>(
        () => ForwardingReportRepository(),
  );

  // ── BLOCS ─────────────────────────────────────────────────────────────────

  // Existing Blocs...
  sl.registerFactory<ForwardingReportBloc>(
        () => ForwardingReportBloc(repository: sl<ForwardingReportRepository>()),
  );
  // ════════════════════════════════════════════════════════════════
  // 3. BLOCS  —  registerFactory
  //    Every BlocProvider.create() call-ku fresh instance
  // ════════════════════════════════════════════════════════════════

  // ── Auth ────────────────────────────────────────────────────────
  sl.registerFactory<LoginBloc>(
        () => LoginBloc(authRepository: sl<AuthRepository>()),
  );

  // ── Admin tab (pure UI state, no deps) ──────────────────────────
  sl.registerFactory<AdminTabBloc>(() => AdminTabBloc());

  // ── Invoice (refactored — repo injected) ────────────────────────
  sl.registerFactory<InvoiceBloc>(
        () => InvoiceBloc(invoiceRepo: sl<InvoiceRepository>()),
  );

  // ── AI Invoice forecast ─────────────────────────────────────────
  sl.registerFactory<ForecastBloc>(
        () => ForecastBloc(repository: sl<SalesForecastRepository>()),
  );

  // ── AI Maintenance ──────────────────────────────────────────────
  sl.registerFactory<AIMaintenanceBloc>(
        () => AIMaintenanceBloc(repository: sl<MaintenanceAIRepository>()),
  );
  sl.registerLazySingleton<ReceiptRepository>(
        () => ReceiptRepositoryImpl(),
  );
  sl.registerFactory<ReceiptBloc>(
        () => ReceiptBloc(receiptRepo: sl<ReceiptRepository>()),
  );
  // ── REPOSITORIES ──────────────────────────────────────────────────────────

  // Add this near your other repositories
  sl.registerLazySingleton<ExpenseReportRepository>(
        () => ExpenseReportRepository(),
  );
  sl.registerLazySingleton<SalesOrderRepository>(
        () => SalesOrderRepository(),
  );
  // ── BLOCS ─────────────────────────────────────────────────────────────────

  // Add this near your other blocs
  sl.registerFactory<ExpenseReportBloc>(
        () => ExpenseReportBloc(repository: sl<ExpenseReportRepository>()),
  );
  sl.registerFactory<SalesOrderBloc>(
        () => SalesOrderBloc(repository: sl<SalesOrderRepository>()),
  );
  // ── No-dep dashboard tabs (no-arg constructors) ─────────────────
// Inside your DI setup function
  sl.registerLazySingleton<VesselReportRepository>(
        () => VesselReportRepository(),
  );

// ✅ Standard factory, no context needed!
  sl.registerFactory<VesselBloc>(
        () => VesselBloc(repository: sl<VesselReportRepository>()),
  );

  sl.registerLazySingleton<TransportRepository>(
        () => TransportRepository(),
  );

  // 2. Register BLoC (No context needed!)
  sl.registerFactory<TransportBloc>(
        () => TransportBloc(repository: sl<TransportRepository>()),
  );
  sl.registerLazySingleton<TruckRepository>(
        () => TruckRepository(),
  );

  // 2. Register the BLoC (No context needed!)
  sl.registerFactory<TruckDetailsBloc>(
        () => TruckDetailsBloc(repository: sl<TruckRepository>()),
  );
  sl.registerLazySingleton<DriverRepository>(
        () => DriverRepository(),
  );

  // 2. Register the BLoC (No context needed!)
  sl.registerFactory<DriverBloc>(
        () => DriverBloc(repository: sl<DriverRepository>()),
  );
  sl.registerLazySingleton<SpeedingRepository>(
        () => SpeedingRepository(),
  );

  // 2. Register the BLoC (No context needed!)
  sl.registerFactory<SpeedingBloc>(
        () => SpeedingBloc(repository: sl<SpeedingRepository>()),
  );

  sl.registerLazySingleton<FuelFillingsRepository>(
        () => FuelFillingsRepository(),
  );

  // 2. Register the BLoC (No context needed!)
  sl.registerFactory<FuelFillingBloc>(
        () => FuelFillingBloc(repository: sl<FuelFillingsRepository>()),
  );
  sl.registerLazySingleton<EngineHoursRepository>(
        () => EngineHoursRepository(),
  );

  // 2. Register the BLoC (No context needed!)
  sl.registerFactory<EngineHoursBloc>(
        () => EngineHoursBloc(repository: sl<EngineHoursRepository>()),
  );
  sl.registerLazySingleton<BoCheckRepository>(
        () => BoCheckRepository(),
  );

  // 2. Register the BLoC (No context needed!)
  sl.registerFactory<BocBloc>(
        () => BocBloc(repository: sl<BoCheckRepository>()),
  );
  sl.registerLazySingleton<EmailInboxRepository>(
        () => EmailInboxRepository(),
  );

  // 2. Register the BLoC (No context needed!)
  sl.registerFactory<EmailBloc>(
        () => EmailBloc(repository: sl<EmailInboxRepository>()),
  );
  sl.registerLazySingleton<GoogleReviewRepository>(
        () => GoogleReviewRepository(),
  );

  // 2. Register the BLoC (No context needed!)
  sl.registerFactory<ReviewBloc>(
        () => ReviewBloc(repository: sl<GoogleReviewRepository>()),
  );
  sl.registerLazySingleton<FuelRepository>(
        () => FuelRepository(),
  );

  // 2. Register the BLoC (No context needed!)
  sl.registerFactory<FuelDiffBloc>(
        () => FuelDiffBloc(repository: sl<FuelRepository>()),
  );
  sl.registerLazySingleton<EmployeeRepository>(
        () => EmployeeRepository(),
  );

  // 2. Register the List BLoC as the default factory
  sl.registerFactory<EmployeeMasterBloc>(
        () => EmployeeMasterBloc.list(repository: sl<EmployeeRepository>()),
  );

  sl.registerLazySingleton<PettyCashRepository>(
        () => PettyCashRepository(),
  );

  // 2. Register the BLoC (No context needed!)
  sl.registerFactory<PettyCashBloc>(
        () => PettyCashBloc(repository: sl<PettyCashRepository>()),
  );
  sl.registerLazySingleton<SummonRepository>(
        () => SummonRepository(),
  );

  // 2. Register the View BLoC as the default factory
  sl.registerFactory<SummonBloc>(
        () => SummonBloc.view(repository: sl<SummonRepository>()),
  );
  sl.registerLazySingleton<SparePartsRepository>(
        () => SparePartsRepository(),
  );

  // 2. Register the View BLoC as the default factory
  sl.registerFactory<SparePartsBloc>(
        () => SparePartsBloc.view(repository: sl<SparePartsRepository>()),
  );

  sl.registerLazySingleton<PaymentViewRepository>(
        () => PaymentViewRepository(),
  );

  // 2. Register the BLoC as a factory
  sl.registerFactory<PaymentPendingBloc>(
        () => PaymentPendingBloc(repository: sl<PaymentViewRepository>()),
  );
  sl.registerLazySingleton<SpotSaleRepository>(
        () => SpotSaleRepository(),
  );

  // 2. Register the View BLoC as the default factory
  sl.registerFactory<SpotSaleBloc>(
        () => SpotSaleBloc.view(repository: sl<SpotSaleRepository>()),
  );
  sl.registerLazySingleton<InventoryReportRepository>(
        () => InventoryReportRepository(),
  );

  // 2. Register the BLoC
  sl.registerFactory<InventoryBloc>(
        () => InventoryBloc(repository: sl<InventoryReportRepository>()),
  );
  sl.registerLazySingleton<PDORepository>(
        () => PDORepository(),
  );
  sl.registerLazySingleton<RTIViewRepository>(
        () => RTIViewRepository(),
  );

  sl.registerFactory<RTIDetailsBloc>(
        () => RTIDetailsBloc(repository: sl<RTIViewRepository>()),
  );

  sl.registerFactory<GpsTruckMapBloc>(
        () => GpsTruckMapBloc(),
  );
  sl.registerLazySingleton<TransportSalesRepository>(
        () => TransportSalesRepository(),
  );

  sl.registerFactory<TransportSalesBloc>(
        () => TransportSalesBloc(repository: sl<TransportSalesRepository>()),
  );
  sl.registerLazySingleton<EnquiryRepository>(
        () => EnquiryRepository(),
  );

  sl.registerFactory<EnquiryBloc>(
        () => EnquiryBloc(repository: sl<EnquiryRepository>()),
  );
  sl.registerLazySingleton<SalesReportRepository>(
        () => SalesReportRepository(),
  );

  sl.registerFactory<SalesReportBloc>(
        () => SalesReportBloc(repository: sl<SalesReportRepository>()),
  );
  sl.registerLazySingleton<AirfreightRepository>(
        () => AirfreightRepository(),
  );

  sl.registerFactory<AirfreightBloc>(
        () => AirfreightBloc(repository: sl<AirfreightRepository>()),
  );
  sl.registerFactory<SaleOrderBloc>(
        () => SaleOrderBloc(
      // sl() automatically finds the registered SaleOrderRepository
      repository: sl<SaleOrderRepository>(),
    ),
  );
  sl.registerLazySingleton<SaleOrderRepository>(
        () => SaleOrderRepository(),
  );
  sl.registerFactory<MaintenanceBloc>(() => MaintenanceBloc());
  sl.registerFactory<DriverLicenseExpiryBloc>(() => DriverLicenseExpiryBloc());
  sl.registerFactory<TruckMaintDashBloc>(() => TruckMaintDashBloc());
  sl.registerFactory<DriverSalaryBloc>(() => DriverSalaryBloc());
  // sl.registerFactory<ReceiptBloc>(() => ReceiptBloc());
  // sl.registerFactory<CustomerDashboardBloc>(() => CustomerDashboardBloc());
  sl.registerFactory<StockInEntryBloc>(() => StockInEntryBloc());
  sl.registerFactory<StockTransferBloc>(() => StockTransferBloc());
  sl.registerFactory<StockUpdateBloc>(() => StockUpdateBloc());



  // ════════════════════════════════════════════════════════════════
  // 4. CONTEXT-DEP BLOCS  —  NOT registered here
  //    These still take BuildContext in constructor.
  //    Refactor pannும்போது inga add pannuvom.
  //
  //    BillOrderBloc(context)        — billorder tab
  //    BocBloc(context)              — bocheck tab
  //    DriverBloc(context)           — driver tab
  //    EmailBloc(context)            — emailinbox tab
  //    EngineHoursBloc(context)      — enginehours tab
  //    ExpenseReportBloc(context)    — expenseReport tab
  //    ForwardingReportBloc(context) — forwardingreport tab
  //    FuelDiffBloc(context)         — fuel tab
  //    FuelFillingBloc(context)      — fuelfillings tab
  //    ReviewBloc(context)           — googlereview tab
  //    InventoryBloc(context)        — inventoryreport tab
  //    PaymentPendingBloc(context)   — paymentview tab
  //    PettyCashBloc(context)        — pettycash tab
  //    RTIDetailsBloc(context)       — rtiview tab
  //    SpeedingBloc(context)         — speedingreport tab
  //    TransportBloc(context)        — transport tab
  //    TruckDetailsBloc(context)     — truck tab
  //    VesselBloc(context)           — vesselreport tab
  //    PDOBloc(context, ...)         — pdo tab
  // ════════════════════════════════════════════════════════════════
}