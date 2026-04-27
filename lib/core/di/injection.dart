// lib/core/di/injection.dart

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

import '../../features/dashboard/admin_dashboard/tabs/receiptview/data/receipt_repository.dart';

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
  sl.registerFactory<ReceiptBloc>(
        () => ReceiptBloc(receiptRepo: sl<ReceiptRepository>()),
  );
  // ── No-dep dashboard tabs (no-arg constructors) ─────────────────
  sl.registerFactory<SalesOrderBloc>(() => SalesOrderBloc());
  sl.registerFactory<MaintenanceBloc>(() => MaintenanceBloc());
  sl.registerFactory<DriverLicenseExpiryBloc>(() => DriverLicenseExpiryBloc());
  sl.registerFactory<TruckMaintDashBloc>(() => TruckMaintDashBloc());
  sl.registerFactory<DriverSalaryBloc>(() => DriverSalaryBloc());
  // sl.registerFactory<ReceiptBloc>(() => ReceiptBloc());
  sl.registerFactory<CustomerDashboardBloc>(() => CustomerDashboardBloc());
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