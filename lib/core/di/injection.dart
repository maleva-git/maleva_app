// lib/core/di/injection.dart
//
// SINGLE place where everything is wired.
// Inga register pannitu, everywhere sl<T>() call pannuvom.
//
// Usage:
//   await setupDependencies();   ← main.dart-la oru thadava
//   sl<LoginBloc>()              ← anywhere instantiate

import 'package:get_it/get_it.dart';
import 'package:maleva/core/network/api_services/auth_api.dart';
import 'package:maleva/core/network/api_services/master_api.dart';
import 'package:maleva/core/network/api_services/sales_api.dart';
import 'package:maleva/core/network/api_services/operations_api.dart';
import 'package:maleva/core/network/api_services/reports_api.dart';
import 'package:maleva/core/utils/app_preferences.dart';

// Features
import 'package:maleva/features/auth/data/repositories/auth_repository.dart';
import 'package:maleva/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:maleva/features/transaction/planning/bloc/planning_bloc.dart';
import 'package:maleva/features/transaction/salesorder/add/bloc/salesorderadd_bloc.dart';
import 'package:maleva/features/transaction/salesorder/view/bloc/salesorderview_bloc.dart';
import 'package:maleva/features/transaction/vesselplanning/bloc/vesselplanning_bloc.dart';
import 'package:maleva/features/transaction/prealertview/bloc/prealertview_bloc.dart';

import 'package:maleva/features/transport/fuelentry/add/bloc/fuelentry_bloc.dart';
import 'package:maleva/features/transport/fuelentry/view/bloc/fuelentryview_bloc.dart';
import 'package:maleva/features/transport/maintenance/bloc/maintenance_bloc.dart';
import 'package:maleva/features/transport/licenseupdate/bloc/licenseupdate_bloc.dart';
import 'package:maleva/features/transport/updatertidetails/bloc/updatertidetails_bloc.dart';

import 'package:maleva/features/operations/forwarding/bloc/forwarding_bloc.dart';
import 'package:maleva/features/operations/forwardingsalary/bloc/forwardingsalary_bloc.dart';

import 'package:maleva/features/stock/stockinentry/bloc/stockinentry_bloc.dart';
import 'package:maleva/features/stock/stocktransfer/bloc/stocktransfer_bloc.dart';
import 'package:maleva/features/stock/stockupdate/bloc/stockupdate_bloc.dart';

import 'package:maleva/features/dashboard/admin_dashboard/tabs/salesorder/bloc/salesorder_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/maintenance/bloc/maintenance_bloc.dart'
as dash_maint;
import 'package:maleva/features/dashboard/admin_dashboard/tabs/fuel/bloc/fuelreport_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/truck/bloc/truck_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/tabs/driver/bloc/driverdetails_bloc.dart';

// sl = service locator (short alias)
final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ─────────────────────────────────────────────────────────
  // 0.  Foundation — AppPreferences (init pannitu register)
  // ─────────────────────────────────────────────────────────
  await AppPreferences.init();
  // sl.registerSingleton<AppPreferences>(AppPreferences.instance);

  // ─────────────────────────────────────────────────────────
  // 1.  API Services  →  registerLazySingleton
  //     App life-la oru thadava create, cache pannitu use pannuvom
  // ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthApi>(() => AuthApi.instance);
  // sl.registerLazySingleton<MasterApi>(() => MasterApi());
  // sl.registerLazySingleton<SalesApi>(() => SalesApi());
  // sl.registerLazySingleton<OperationsApi>(() => OperationsApi());
  // sl.registerLazySingleton<ReportsApi>(() => ReportsApi());

  // ─────────────────────────────────────────────────────────
  // 2.  Repositories  →  registerLazySingleton
  //     API service inject pannuvom — manual new panna vendaam
  // ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepository(authApi: sl<AuthApi>()),
  );

  // (Future: SalesRepository, TransportRepository, etc.)

  // ─────────────────────────────────────────────────────────
  // 3.  BLoCs  →  registerFactory
  //     Every BlocProvider.create() call-ku fresh instance vennum
  //     Factory = new instance every time sl<XBloc>() call
  // ─────────────────────────────────────────────────────────

  // Auth
  sl.registerFactory<LoginBloc>(
        () => LoginBloc(authRepository: sl<AuthRepository>()),
  );

  // Transaction
  // sl.registerFactory<PlanningBloc>(
  //       () => PlanningBloc(),  // context dep removed — see planning_bloc.dart fix below
  // );
  // sl.registerFactory<SalesOrderAddBloc>(
  //       () => SalesOrderAddBloc(salesApi: sl<SalesApi>(), masterApi: sl<MasterApi>()),
  // );
  // sl.registerFactory<SalesOrderViewBloc>(
  //       () => SalesOrderViewBloc(salesApi: sl<SalesApi>()),
  // );
  sl.registerFactory<VesselPlanningBloc>(
        () => VesselPlanningBloc(),
  );
  // sl.registerFactory<PreAlertViewBloc>(
  //       () => PreAlertViewBloc(reportsApi: sl<ReportsApi>()),
  // );

  // Transport
  // sl.registerFactory<FuelEntryBloc>(
  //       () => FuelEntryBloc(operationsApi: sl<OperationsApi>()),
  // );
  // sl.registerFactory<FuelEntryViewBloc>(
  //       () => FuelEntryViewBloc(operationsApi: sl<OperationsApi>()),
  // );
  // sl.registerFactory<MaintenanceBloc>(
  //       () => MaintenanceBloc(masterApi: sl<MasterApi>()),
  // );
  sl.registerFactory<LicenseUpdateBloc>(
        () => LicenseUpdateBloc(),
  );
  // sl.registerFactory<UpdateRtiDetailsBloc>(
  //       () => UpdateRtiDetailsBloc(masterApi: sl<MasterApi>()),
  // );

  // Operations
  // sl.registerFactory<ForwardingBloc>(
  //       () => ForwardingBloc(operationsApi: sl<OperationsApi>()),
  // );
  // sl.registerFactory<ForwardingSalaryBloc>(
  //       () => ForwardingSalaryBloc(operationsApi: sl<OperationsApi>()),
  // );

  // Stock
  // sl.registerFactory<StockInEntryBloc>(
  //       () => StockInEntryBloc(masterApi: sl<MasterApi>()),
  // );
  // sl.registerFactory<StockTransferBloc>(
  //       () => StockTransferBloc(masterApi: sl<MasterApi>()),
  // );
  // sl.registerFactory<StockUpdateBloc>(
  //       () => StockUpdateBloc(masterApi: sl<MasterApi>()),
  // );

  // Dashboard tabs
  sl.registerFactory<SalesOrderBloc>(() => SalesOrderBloc());
  // sl.registerFactory<dash_maint.MaintenanceBloc>(
  //       () => dash_maint.MaintenanceBloc(masterApi: sl<MasterApi>()),
  // );
  // sl.registerFactory<FuelReportBloc>(
  //       () => FuelReportBloc(reportsApi: sl<ReportsApi>()),
  // );
  // sl.registerFactory<TruckBloc>(
  //       () => TruckBloc(masterApi: sl<MasterApi>()),
  // );
  // sl.registerFactory<DriverDetailsBloc>(
  //       () => DriverDetailsBloc(masterApi: sl<MasterApi>()),
  // );
}