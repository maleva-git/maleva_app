import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:maleva/core/network/api_services/auth_api.dart';
import 'package:maleva/core/utils/app_preferences.dart';
import 'package:maleva/features/auth/data/repositories/auth_repository.dart';
import 'package:maleva/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:maleva/features/dashboard/admin_dashboard/bloc/admin_tab_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/billorder/bloc/billorder_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/invoice/data/invoice_repository.dart';
import 'package:maleva/features/dashboard/common_tabs/invoice/bloc/invoice_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/salesorder/bloc/salesorder_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/driverlicense/bloc/driverlicense_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/drivermaintenance/bloc/drivermaintenance_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/driversalary/bloc/driversalary_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/receiptview/bloc/receiptview_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/airfreightsales/bloc/airfreightsales_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/stockinentry/bloc/stock_in_entry_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/stocktransfer/bloc/stock_transfer_bloc.dart';
import 'package:maleva/features/dashboard/common_tabs/stockupdate/bloc/stock_update_bloc.dart';
import '../../features/dashboard/common_tabs/airfreightsales/data/airfreight_repository.dart';
import '../../features/dashboard/common_tabs/billorder/data/billorder_repository.dart';
import '../../features/dashboard/common_tabs/bocheck/bloc/bocheck_bloc.dart';
import '../../features/dashboard/common_tabs/bocheck/data/bocheck_repository.dart';
import '../../features/dashboard/common_tabs/driver/bloc/driverdetails_bloc.dart';
import '../../features/dashboard/common_tabs/driver/data/driver_repository.dart';
import '../../features/dashboard/common_tabs/driverlicense/data/driverlicense_repository.dart';
import '../../features/dashboard/common_tabs/drivermaintenance/data/drivermaintenance_repository.dart';
import '../../features/dashboard/common_tabs/driversalary/data/driversalary_repository.dart';
import '../../features/dashboard/common_tabs/emailinbox/bloc/emailinbox_bloc.dart';
import '../../features/dashboard/common_tabs/emailinbox/data/emailinbox_repository.dart';
import '../../features/dashboard/common_tabs/employeemaster/bloc/employeemaster_bloc.dart';
import '../../features/dashboard/common_tabs/employeemaster/data/employee_repository.dart';
import '../../features/dashboard/common_tabs/enginehours/bloc/enginehours_bloc.dart';
import '../../features/dashboard/common_tabs/enginehours/data/enginehours_repository.dart';
import '../../features/dashboard/common_tabs/enquiry/view/bloc/enquiry_bloc.dart';
import '../../features/dashboard/common_tabs/enquiry/view/data/enquiry_repository.dart';
import '../../features/dashboard/common_tabs/expensereport/bloc/expensereport_bloc.dart';
import '../../features/dashboard/common_tabs/expensereport/data/expensereport_repository.dart';
import '../../features/dashboard/common_tabs/forwardingreport/bloc/forwardingreport_bloc.dart';
import '../../features/dashboard/common_tabs/forwardingreport/data/forwardingreport_repository.dart';
import '../../features/dashboard/common_tabs/fuel/bloc/fuelreport_bloc.dart';
import '../../features/dashboard/common_tabs/fuel/data/fuel_repository.dart';
import '../../features/dashboard/common_tabs/fuelfillings/bloc/fuelfillings_bloc.dart';
import '../../features/dashboard/common_tabs/fuelfillings/data/fuelfillings_repository.dart';
import '../../features/dashboard/common_tabs/fwbreakseal/bloc/fwbreakseal_bloc.dart';
import '../../features/dashboard/common_tabs/fwbreakseal/data/fwbreakseal_repository.dart';
import '../../features/dashboard/common_tabs/googlereview/bloc/googlereview_bloc.dart';
import '../../features/dashboard/common_tabs/googlereview/data/googlereview_repository.dart';
import '../../features/dashboard/common_tabs/inventoryreport/bloc/inventoryreport_bloc.dart';
import '../../features/dashboard/common_tabs/inventoryreport/data/inventoryreport_repository.dart';
import '../../features/dashboard/common_tabs/license/bloc/license_bloc.dart';
import '../../features/dashboard/common_tabs/license/data/license_repository.dart';
import '../../features/dashboard/common_tabs/maintenance/bloc/maintenance_bloc.dart';
import '../../features/dashboard/common_tabs/maintenance/data/maintenance_repository.dart';
import '../../features/dashboard/common_tabs/paymentview/bloc/paymentview_bloc.dart';
import '../../features/dashboard/common_tabs/paymentview/data/paymentview_repository.dart';
import '../../features/dashboard/common_tabs/pdo/data/pdo_repository.dart';
import '../../features/dashboard/common_tabs/pettycash/bloc/pettycash_bloc.dart';
import '../../features/dashboard/common_tabs/pettycash/data/pettycash_repository.dart';
import '../../features/dashboard/common_tabs/planningdetailsview/bloc/planningdetails_bloc.dart';
import '../../features/dashboard/common_tabs/planningdetailsview/data/planning_details_repository.dart';
import '../../features/dashboard/common_tabs/receiptview/data/receipt_repository.dart';
import '../../features/dashboard/common_tabs/rtistatus/bloc/rtistatus_bloc.dart';
import '../../features/dashboard/common_tabs/rtistatus/data/rti_status_repository.dart';
import '../../features/dashboard/common_tabs/rtiview/bloc/rtiview_bloc.dart';
import '../../features/dashboard/common_tabs/rtiview/data/rtiview_repository.dart';
import '../../features/dashboard/common_tabs/salary/bloc/salary_bloc.dart';
import '../../features/dashboard/common_tabs/salary/data/salary_repository.dart';
import '../../features/dashboard/common_tabs/saleorderdetails/bloc/saleorderdetails_bloc.dart';
import '../../features/dashboard/common_tabs/saleorderdetails/data/sale_order_details_repository.dart';
import '../../features/dashboard/common_tabs/saleorderview/bloc/saleorderview_bloc.dart';
import '../../features/dashboard/common_tabs/saleorderview/data/saleorderrepository.dart';
import '../../features/dashboard/common_tabs/salesorder/data/salesorder_repository.dart';
import '../../features/dashboard/common_tabs/spareparts/bloc/spareparts_bloc.dart';
import '../../features/dashboard/common_tabs/spareparts/data/spareparts_repository.dart';
import '../../features/dashboard/common_tabs/speedingreport/bloc/speeding_bloc.dart';
import '../../features/dashboard/common_tabs/speedingreport/data/speeding_repository.dart';
import '../../features/dashboard/common_tabs/spotsaleorder/bloc/spotsaleorder_bloc.dart';
import '../../features/dashboard/common_tabs/spotsaleorder/data/spotsale_repository.dart';
import '../../features/dashboard/common_tabs/stockinentry/data/stock_in_entry_repository.dart';
import '../../features/dashboard/common_tabs/stocktransfer/data/stock_transfer_repository.dart';
import '../../features/dashboard/common_tabs/stockupdate/data/stock_update_repository.dart';
import '../../features/dashboard/common_tabs/subadminsale/bloc/sales_report_bloc.dart';
import '../../features/dashboard/common_tabs/subadminsale/data/salesreport_repository.dart';
import '../../features/dashboard/common_tabs/summonentry/bloc/summonentry_bloc.dart';
import '../../features/dashboard/common_tabs/summonentry/data/summonentry_repository.dart';
import '../../features/dashboard/common_tabs/transport/bloc/transport_bloc.dart';
import '../../features/dashboard/common_tabs/transport/data/transport_repository.dart';
import '../../features/dashboard/common_tabs/transportDB/bloc/transportdb_bloc.dart';
import '../../features/dashboard/common_tabs/transportDB/data/transportdb_repository.dart';
import '../../features/dashboard/common_tabs/transportsales/bloc/transport_sales_bloc.dart';
import '../../features/dashboard/common_tabs/transportsales/data/transport_sales_repository.dart';
import '../../features/dashboard/common_tabs/truck/bloc/truck_bloc.dart';
import '../../features/dashboard/common_tabs/truck/data/truck_repository.dart';
import '../../features/dashboard/common_tabs/unrelease/bloc/unrelease_bloc.dart';
import '../../features/dashboard/common_tabs/unrelease/data/unrelease_repository.dart';
import '../../features/dashboard/common_tabs/unreleasesmk/bloc/unreleasesmk_bloc.dart';
import '../../features/dashboard/common_tabs/unreleasesmk/data/unreleasesmk_repository.dart';
import '../../features/dashboard/common_tabs/vesselplanningdetails/bloc/vesselplanningdetails_bloc.dart';
import '../../features/dashboard/common_tabs/vesselplanningdetails/data/vesselplanningdetails_repository.dart';
import '../../features/dashboard/common_tabs/vesselreport/bloc/vesselreport_bloc.dart';
import '../../features/dashboard/common_tabs/vesselreport/data/vessel_report_repository.dart';
import '../../features/operations/forwarding/bloc/forwarding_bloc.dart';
import '../../features/operations/forwarding/data/fwupdate_repository.dart';
import '../../features/operations/forwardingsalary/bloc/forwardingsalary_bloc.dart';
import '../../features/operations/forwardingsalary/data/forwardingsalary_repository.dart';


import 'package:shared_preferences/shared_preferences.dart';
import 'package:maleva/core/utils/local_storage_service.dart';
import 'package:maleva/core/utils/session_manager.dart';
import 'package:maleva/core/network/dio_client.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/data/leave_repository.dart';
import 'package:maleva/features/dashboard/common_tabs/driverleave/bloc/leave_bloc.dart';
import 'package:maleva/features/transaction/enquirytrmaster/data/enquiry_repository.dart';
import 'package:maleva/features/transaction/enquirytrmaster/add/bloc/enquirytradd_bloc.dart';
import 'package:maleva/features/transaction/planning/data/planning_repository.dart';
import 'package:maleva/features/transaction/planning/bloc/planning_bloc.dart';
import 'package:maleva/features/transaction/vesselplanning/data/vesselplanning_repository.dart';
import 'package:maleva/features/transaction/vesselplanning/bloc/vesselplanning_bloc.dart';
import 'package:maleva/features/transaction/enquirytrmaster/view/bloc/enquirytrview_bloc.dart';
import 'package:maleva/features/transaction/salesorder/add/data/salesorderadd_repository.dart';
import 'package:maleva/features/transaction/salesorder/view/data/salesorderview_repository.dart';

import 'package:maleva/features/transaction/salesorder/add/bloc/salesorderadd_bloc.dart';
import 'package:maleva/features/transaction/viewsaleorder/data/viewsaleorder_repository.dart';
import 'package:maleva/features/transaction/viewsaleorder/bloc/viewsaleorder_bloc.dart';
import 'package:maleva/core/models/shared/review.dart';
final sl = GetIt.instance;

Future<void> setupDependencies() async {
  if (sl.isRegistered<AuthApi>()) return;

  await AppPreferences.init();
  
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<LocalStorageService>(() => LocalStorageService(sl<SharedPreferences>()));
  sl.registerLazySingleton<SessionManager>(() => SessionManager(sl<LocalStorageService>()));
  
  sl.registerLazySingleton<DioClient>(() => DioClient(sl<SessionManager>()));

  // Repositories
  sl.registerLazySingleton<LeaveRepository>(
    () => LeaveRepository(sl(), sl()),
  );
  sl.registerLazySingleton<EnquiryTrRepository>(
    () => EnquiryTrRepository(sl(), sl()),

  );

  sl.registerLazySingleton<SalesOrderAddRepository>(
    () => SalesOrderAddRepository(sl(), sl()),
  );

  sl.registerLazySingleton<ViewSaleOrderRepository>(
    () => ViewSaleOrderRepository(),
  );

  // BLoCs
  sl.registerFactory<LeaveBloc>(
    () => LeaveBloc(sl()),
  );
  sl.registerFactory<EnquiryAddBloc>(
    () => EnquiryAddBloc(sl(), sl()),
  );
  sl.registerFactory<EnquiryViewBloc>(
    () => EnquiryViewBloc(sl()),
  );
  sl.registerFactory<GetJobNoBloc>(
    () => GetJobNoBloc(sl()),
  );

  sl.registerLazySingleton<VesselPlanningRepository>(() => VesselPlanningRepository());
  sl.registerFactory<VesselPlanningBloc>(() => VesselPlanningBloc(sl()));

  sl.registerLazySingleton<PlanningRepository>(() => PlanningRepository());
  sl.registerFactoryParam<PlanningBloc, BuildContext, dynamic>(
    (context, _) => PlanningBloc(context, sl()),
  );

  sl.registerFactoryParam<SalesOrderAddBloc, BuildContext, dynamic>(
    (context, _) => SalesOrderAddBloc(context, sl()),
  );


  sl.registerLazySingleton<AuthApi>(() => AuthApi.instance);

  sl.registerLazySingleton<AuthRepository>(
        () => AuthRepository(authApi: sl<AuthApi>()),
  );
  sl.registerFactory<LoginBloc>(
        () => LoginBloc(authRepository: sl<AuthRepository>()),
  );

  sl.registerFactory<AdminTabBloc>(() => AdminTabBloc());

  sl.registerLazySingleton<InvoiceRepository>(() => InvoiceRepositoryImpl());
  sl.registerFactory<InvoiceBloc>(
        () => InvoiceBloc(invoiceRepo: sl<InvoiceRepository>()),
  );

  sl.registerLazySingleton<ReceiptRepository>(() => ReceiptRepositoryImpl());
  sl.registerFactory<ReceiptBloc>(
        () => ReceiptBloc(receiptRepo: sl<ReceiptRepository>()),
  );

  sl.registerLazySingleton<ExpenseReportRepository>(
        () => ExpenseReportRepository(),
  );
  sl.registerFactory<ExpenseReportBloc>(
        () => ExpenseReportBloc(repository: sl<ExpenseReportRepository>()),
  );

  
  sl.registerLazySingleton<SalesOrderViewRepository>(() => SalesOrderViewRepository(sl(), sl()));
  sl.registerLazySingleton<SalesOrderRepository>(() => SalesOrderRepository());
  sl.registerFactory<SalesOrderBloc>(
        () => SalesOrderBloc(repository: sl<SalesOrderRepository>()),
  );

  sl.registerLazySingleton<SaleOrderRepository>(() => SaleOrderRepository());
  sl.registerFactory<SaleOrderBloc>(
        () => SaleOrderBloc(repository: sl<SaleOrderRepository>()),
  );

  sl.registerLazySingleton<SaleOrderDetailsRepository>(
        () => SaleOrderDetailsRepository(),
  );
  sl.registerFactory<SaleOrderDetailsBloc>(
        () => SaleOrderDetailsBloc(repository: sl<SaleOrderDetailsRepository>()),
  );

  sl.registerLazySingleton<VesselReportRepository>(
        () => VesselReportRepository(),
  );
  sl.registerFactory<VesselBloc>(
        () => VesselBloc(repository: sl<VesselReportRepository>()),
  );

  sl.registerLazySingleton<VesselPlanningDetailsRepository>(
        () => VesselPlanningDetailsRepository(),
  );
  sl.registerFactory<VesselPlanningDetailsBloc>(
        () => VesselPlanningDetailsBloc(
      repository: sl<VesselPlanningDetailsRepository>(),
    ),
  );

  sl.registerLazySingleton<TransportRepository>(() => TransportRepository());
  sl.registerFactory<TransportBloc>(
        () => TransportBloc(repository: sl<TransportRepository>()),
  );

  sl.registerLazySingleton<TransportDashboardRepository>(
        () => TransportDashboardRepository(),
  );
  sl.registerFactory<TransportDashboardBloc>(
        () => TransportDashboardBloc(
      repository: sl<TransportDashboardRepository>(),
    ),
  );

  sl.registerLazySingleton<TransportSalesRepository>(
        () => TransportSalesRepository(),
  );
  sl.registerFactory<TransportSalesBloc>(
        () => TransportSalesBloc(repository: sl<TransportSalesRepository>()),
  );

  sl.registerLazySingleton<TruckRepository>(() => TruckRepository());
  sl.registerFactory<TruckDetailsBloc>(
        () => TruckDetailsBloc(repository: sl<TruckRepository>()),
  );

  sl.registerLazySingleton<TruckMaintenanceRepository>(
        () => TruckMaintenanceRepository(),
  );
  sl.registerFactory<TruckMaintDashBloc>(
        () => TruckMaintDashBloc(repository: sl<TruckMaintenanceRepository>()),
  );

  // ── Driver ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<DriverRepository>(() => DriverRepository());
  sl.registerFactory<DriverBloc>(
        () => DriverBloc(repository: sl<DriverRepository>()),
  );

  // ── Driver License ────────────────────────────────────────────────────────
  sl.registerLazySingleton<DriverLicenseRepository>(
        () => DriverLicenseRepository(),
  );
  sl.registerFactory<DriverLicenseExpiryBloc>(
        () => DriverLicenseExpiryBloc(repository: sl<DriverLicenseRepository>()),
  );

  sl.registerLazySingleton<DriverSalaryRepository>(
        () => DriverSalaryRepository(),
  );
  sl.registerFactory<DriverSalaryBloc>(
        () => DriverSalaryBloc(repository: sl<DriverSalaryRepository>()),
  );

  // ── Speeding Report ───────────────────────────────────────────────────────
  sl.registerLazySingleton<SpeedingRepository>(() => SpeedingRepository());
  sl.registerFactory<SpeedingBloc>(
        () => SpeedingBloc(repository: sl<SpeedingRepository>()),
  );

  // ── Fuel Fillings ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<FuelFillingsRepository>(
        () => FuelFillingsRepository(),
  );
  sl.registerFactory<FuelFillingBloc>(
        () => FuelFillingBloc(repository: sl<FuelFillingsRepository>()),
  );

  // ── Fuel Report ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<FuelRepository>(() => FuelRepository());
  sl.registerFactory<FuelDiffBloc>(
        () => FuelDiffBloc(repository: sl<FuelRepository>()),
  );

  // ── Engine Hours ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<EngineHoursRepository>(
        () => EngineHoursRepository(),
  );
  sl.registerFactory<EngineHoursBloc>(
        () => EngineHoursBloc(repository: sl<EngineHoursRepository>()),
  );

  // ── BO Check ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<BoCheckRepository>(() => BoCheckRepository());
  sl.registerFactory<BocBloc>(
        () => BocBloc(repository: sl<BoCheckRepository>()),
  );

  // ── Email Inbox ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<EmailInboxRepository>(
        () => EmailInboxRepository(),
  );
  sl.registerFactory<EmailBloc>(
        () => EmailBloc(repository: sl<EmailInboxRepository>()),
  );

  // ── Google Review ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<GoogleReviewRepository>(
        () => GoogleReviewRepository(),
  );
  sl.registerFactory<ReviewBloc>(
        () => ReviewBloc(repository: sl<GoogleReviewRepository>()),
  );

  // ── Employee Master ───────────────────────────────────────────────────────
  sl.registerLazySingleton<EmployeeRepository>(() => EmployeeRepository());
  sl.registerFactory<EmployeeMasterBloc>(
        () => EmployeeMasterBloc.list(repository: sl<EmployeeRepository>()),
  );

  // ── Petty Cash ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PettyCashRepository>(() => PettyCashRepository());
  sl.registerFactory<PettyCashBloc>(
        () => PettyCashBloc(repository: sl<PettyCashRepository>()),
  );

  // ── Summon Entry ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<SummonRepository>(() => SummonRepository());
  sl.registerFactory<SummonBloc>(
        () => SummonBloc.view(repository: sl<SummonRepository>()),
  );

  // ── Spare Parts ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<SparePartsRepository>(() => SparePartsRepository());
  sl.registerFactory<SparePartsBloc>(
        () => SparePartsBloc.view(repository: sl<SparePartsRepository>()),
  );

  // ── Payment View ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<PaymentViewRepository>(
        () => PaymentViewRepository(),
  );
  sl.registerFactory<PaymentPendingBloc>(
        () => PaymentPendingBloc(repository: sl<PaymentViewRepository>()),
  );

  // ── Spot Sale Order ───────────────────────────────────────────────────────
  sl.registerLazySingleton<SpotSaleRepository>(() => SpotSaleRepository());
  sl.registerFactory<SpotSaleBloc>(
        () => SpotSaleBloc.view(repository: sl<SpotSaleRepository>()),
  );

  // ── Inventory Report ──────────────────────────────────────────────────────
  sl.registerLazySingleton<InventoryReportRepository>(
        () => InventoryReportRepository(),
  );
  sl.registerFactory<InventoryBloc>(
        () => InventoryBloc(repository: sl<InventoryReportRepository>()),
  );

  // ── PDO ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PDORepository>(() => PDORepository());

  // ── RTI View ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<RTIViewRepository>(() => RTIViewRepository());
  sl.registerFactory<RTIDetailsBloc>(
        () => RTIDetailsBloc(repository: sl<RTIViewRepository>()),
  );

  // ── RTI Status ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<RTIStatusRepository>(() => RTIStatusRepository());
  sl.registerFactory<RTIStatusBloc>(
        () => RTIStatusBloc(repository: sl<RTIStatusRepository>()),
  );

  // ── Enquiry ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<EnquiryRepository>(() => EnquiryRepository());
  sl.registerFactory<EnquiryBloc>(
        () => EnquiryBloc(repository: sl<EnquiryRepository>()),
  );

  // ── Sales Report (sub-admin) ──────────────────────────────────────────────
  sl.registerLazySingleton<SalesReportRepository>(
        () => SalesReportRepository(),
  );
  sl.registerFactory<SalesReportBloc>(
        () => SalesReportBloc(repository: sl<SalesReportRepository>()),
  );

  // ── Airfreight ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AirfreightRepository>(() => AirfreightRepository());
  sl.registerFactory<AirfreightBloc>(
        () => AirfreightBloc(repository: sl<AirfreightRepository>()),
  );

  // ── Bill Order ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<BillOrderRepository>(() => BillOrderRepository());
  sl.registerFactory<BillOrderBloc>(
        () => BillOrderBloc(repository: sl<BillOrderRepository>()),
  );

  // ── FW Break Seal ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<FWBreakSealRepository>(
        () => FWBreakSealRepository(),
  );
  sl.registerFactory<FWBreakSealBloc>(
        () => FWBreakSealBloc(repository: sl<FWBreakSealRepository>()),
  );

  // ── License ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<LicenseRepository>(() => LicenseRepository());
  sl.registerFactory<LicenseBloc>(
        () => LicenseBloc(repository: sl<LicenseRepository>()),
  );

  // ── Planning Details ──────────────────────────────────────────────────────
  sl.registerLazySingleton<PlanningDetailsRepository>(
        () => PlanningDetailsRepository(),
  );
  // sl.registerFactory<PlanningDetailsBloc>(
  //       () => PlanningDetailsBloc(repository: sl<PlanningDetailsRepository>()),
  // );
  sl.registerFactory(() => PlanningDetailsBloc());
  // ── Salary ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<SalaryRepository>(() => SalaryRepository());
  sl.registerFactory<SalaryBloc>(
        () => SalaryBloc(repository: sl<SalaryRepository>()),
  );

  // ── Stock In Entry ────────────────────────────────────────────────────────
  sl.registerLazySingleton<StockInEntryRepository>(
        () => StockInEntryRepository(sl(), sl()),
  );
  sl.registerFactory<StockInEntryBloc>(
        () => StockInEntryBloc(repository: sl<StockInEntryRepository>()),
  );

  // ── Stock Transfer ────────────────────────────────────────────────────────
  sl.registerLazySingleton<StockTransferRepository>(
        () => StockTransferRepository(),
  );
  sl.registerFactory<StockTransferBloc>(
        () => StockTransferBloc(repository: sl<StockTransferRepository>()),
  );

  // ── Stock Update ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<StockUpdateRepository>(
        () => StockUpdateRepository(),
  );
  sl.registerFactory<StockUpdateBloc>(
        () => StockUpdateBloc(repository: sl<StockUpdateRepository>()),
  );

  // ── UnRelease ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<UnReleaseRepository>(() => UnReleaseRepository());
  sl.registerFactory<UnReleaseBloc>(
        () => UnReleaseBloc(repository: sl<UnReleaseRepository>()),
  );

  // ── UnRelease SMK ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<UnReleaseSMKRepository>(
        () => UnReleaseSMKRepository(),
  );
  sl.registerFactory<UnReleaseSMKBloc>(
        () => UnReleaseSMKBloc(repository: sl<UnReleaseSMKRepository>()),
  );

  // ── Forwarding Report ─────────────────────────────────────────────────────
  sl.registerLazySingleton<ForwardingReportRepository>(
        () => ForwardingReportRepository(),
  );
  sl.registerFactory<ForwardingReportBloc>(
        () => ForwardingReportBloc(repository: sl<ForwardingReportRepository>()),
  );

  sl.registerLazySingleton<FWUpdateRepository>(() => FWUpdateRepository());
  sl.registerFactory<FWUpdateBloc>(
        () => FWUpdateBloc(repository: sl<FWUpdateRepository>()),
  );

  sl.registerLazySingleton<ForwardingSalaryRepository>(
        () => ForwardingSalaryRepository(),
  );
  sl.registerFactory<ForwardingSalaryBloc>(
        () => ForwardingSalaryBloc(repository: sl<ForwardingSalaryRepository>()),
  );

  sl.registerFactory<MaintenanceBloc>(
        () => MaintenanceBloc(repository: sl()),
  );

// Register repository only if not already registered
  sl.registerLazySingleton<MaintenanceRepository>(
        () => MaintenanceRepository(), // pass any dependencies sl() needs here
  );
}