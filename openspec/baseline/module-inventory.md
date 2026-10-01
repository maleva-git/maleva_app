# Module inventory

Snapshot date: 2026-10-01. Every immediate feature family, dashboard folder, and common-tab folder below was enumerated from the repository. This is exhaustive at those folder boundaries, not a line-by-line behavioral audit of every widget. Reviewed capability contracts live in the linked specs.

## Capability index

| Capability | Requirements | Spec |
| --- | ---: | --- |
| App startup and session restoration | 2 | [app-startup](../specs/app-startup/spec.md) |
| Authentication and local session | 4 | [authentication](../specs/authentication/spec.md) |
| Navigation and client permissions | 4 | [navigation-permissions](../specs/navigation-permissions/spec.md) |
| Master data and selection | 2 | [master-data](../specs/master-data/spec.md) |
| Sales orders and enquiries | 5 | [sales-enquiries](../specs/sales-enquiries/spec.md) |
| Transport planning | 3 | [transport-planning](../specs/transport-planning/spec.md) |
| Vessel planning | 3 | [vessel-planning](../specs/vessel-planning/spec.md) |
| Stock entry, update, and transfer | 4 | [stock-management](../specs/stock-management/spec.md) |
| Forwarding operations | 4 | [forwarding](../specs/forwarding/spec.md) |
| Boarding status and evidence | 3 | [boarding](../specs/boarding/spec.md) |
| Air freight job updates | 2 | [airfreight](../specs/airfreight/spec.md) |
| Fleet operations and reports | 6 | [fleet-operations](../specs/fleet-operations/spec.md) |
| RTI records and PDO verification | 3 | [rti-pdo](../specs/rti-pdo/spec.md) |
| Leave requests and staff reporting | 4 | [people-leave](../specs/people-leave/spec.md) |
| Financial and customer reports | 4 | [finance-reports](../specs/finance-reports/spec.md) |
| Incident reports | 6 | [incident-reports](../specs/incident-reports/spec.md) |
| Truck location planning board | 5 | [truck-location](../specs/truck-location/spec.md) |
| Bluetooth device selection and printing | 4 | [bluetooth-printing](../specs/bluetooth-printing/spec.md) |
| Employee records and communication settings | 3 | [employee-communications](../specs/employee-communications/spec.md) |
| Notifications and support diagnostics | 3 | [notifications-support](../specs/notifications-support/spec.md) |
| API transport and response handling | 4 | [api-integration](../specs/api-integration/spec.md) |

## Feature families

| Source family | Dart files | Baseline owner / scope |
| --- | ---: | --- |
| [lib/features/airfreight](../../lib/features/airfreight) | 2 | [airfreight](../specs/airfreight/spec.md); submodules listed below or in that spec |
| [lib/features/auth](../../lib/features/auth) | 4 | [authentication](../specs/authentication/spec.md); submodules listed below or in that spec |
| [lib/features/boarding](../../lib/features/boarding) | 3 | [boarding](../specs/boarding/spec.md); submodules listed below or in that spec |
| [lib/features/dashboard](../../lib/features/dashboard) | 4 | [navigation-permissions](../specs/navigation-permissions/spec.md); submodules listed below or in that spec |
| [lib/features/home](../../lib/features/home) | 4 | [navigation-permissions](../specs/navigation-permissions/spec.md); submodules listed below or in that spec |
| [lib/features/ir_report](../../lib/features/ir_report) | 6 | [incident-reports](../specs/incident-reports/spec.md); submodules listed below or in that spec |
| [lib/features/mastersearch](../../lib/features/mastersearch) | 2 | [master-data](../specs/master-data/spec.md); submodules listed below or in that spec |
| [lib/features/operations](../../lib/features/operations) | 4 | [forwarding](../specs/forwarding/spec.md); submodules listed below or in that spec |
| [lib/features/transaction](../../lib/features/transaction) | 5 | [sales-enquiries](../specs/sales-enquiries/spec.md); submodules listed below or in that spec |
| [lib/features/transport](../../lib/features/transport) | 6 | [fleet-operations](../specs/fleet-operations/spec.md); submodules listed below or in that spec |
| [lib/features/troubleshoot](../../lib/features/troubleshoot) | 3 | [notifications-support](../specs/notifications-support/spec.md); submodules listed below or in that spec |
| [lib/features/truck_location](../../lib/features/truck_location) | 5 | [truck-location](../specs/truck-location/spec.md); submodules listed below or in that spec |

`operations` covers forwarding, SMK, and forwarding salary. `transaction` also contains transport/vessel planning, pre-alert, alternate sales view, and transport enquiries. `transport` also contains RTI and alternate fuel, license, and maintenance paths; consult their capability specs rather than assuming the family owner covers every detail.

## Dashboard folders

Folder presence does not establish a configured route or production role assignment. See [permissions](permissions.md) for verified login routing.

| Folder | Views present |
| --- | --- |
| [lib/features/dashboard/admin_dashboard](../../lib/features/dashboard/admin_dashboard) | [admin_dashboard.dart](../../lib/features/dashboard/admin_dashboard/view/admin_dashboard.dart), [admin_dashboard_ui.dart](../../lib/features/dashboard/admin_dashboard/view/admin_dashboard_ui.dart) |
| [lib/features/dashboard/airfreight_dashboard](../../lib/features/dashboard/airfreight_dashboard) | [airfreight_dashboard.dart](../../lib/features/dashboard/airfreight_dashboard/view/airfreight_dashboard.dart), [airfreight_dashboard_ui.dart](../../lib/features/dashboard/airfreight_dashboard/view/airfreight_dashboard_ui.dart) |
| [lib/features/dashboard/boarding_dashboard](../../lib/features/dashboard/boarding_dashboard) | [boarding_dashboard.dart](../../lib/features/dashboard/boarding_dashboard/view/boarding_dashboard.dart), [boarding_dashboard_ui.dart](../../lib/features/dashboard/boarding_dashboard/view/boarding_dashboard_ui.dart) |
| [lib/features/dashboard/driver_dashboard](../../lib/features/dashboard/driver_dashboard) | [driver_dashboard.dart](../../lib/features/dashboard/driver_dashboard/view/driver_dashboard.dart), [driver_dashboard_ui.dart](../../lib/features/dashboard/driver_dashboard/view/driver_dashboard_ui.dart) |
| [lib/features/dashboard/forwarding_agent_dashboard](../../lib/features/dashboard/forwarding_agent_dashboard) | [forwarding_agent_dashboard.dart](../../lib/features/dashboard/forwarding_agent_dashboard/view/forwarding_agent_dashboard.dart), [forwarding_agent_dashboard_ui.dart](../../lib/features/dashboard/forwarding_agent_dashboard/view/forwarding_agent_dashboard_ui.dart), [rti_route_activities_tab.dart](../../lib/features/dashboard/forwarding_agent_dashboard/view/rti_route_activities_tab.dart) |
| [lib/features/dashboard/forwarding_dashboard](../../lib/features/dashboard/forwarding_dashboard) | [forwarding_dashboard.dart](../../lib/features/dashboard/forwarding_dashboard/view/forwarding_dashboard.dart), [forwarding_dashboard_ui.dart](../../lib/features/dashboard/forwarding_dashboard/view/forwarding_dashboard_ui.dart) |
| [lib/features/dashboard/hr_dashboard](../../lib/features/dashboard/hr_dashboard) | [hr_dashboard.dart](../../lib/features/dashboard/hr_dashboard/view/hr_dashboard.dart), [hr_dashboard_ui.dart](../../lib/features/dashboard/hr_dashboard/view/hr_dashboard_ui.dart) |
| [lib/features/dashboard/hradmin_dashboard](../../lib/features/dashboard/hradmin_dashboard) | [hradmin_dashboard.dart](../../lib/features/dashboard/hradmin_dashboard/view/hradmin_dashboard.dart), [hradmin_dashboard_ui.dart](../../lib/features/dashboard/hradmin_dashboard/view/hradmin_dashboard_ui.dart) |
| [lib/features/dashboard/maintenance_dashboard](../../lib/features/dashboard/maintenance_dashboard) | [maintenance_dashboard.dart](../../lib/features/dashboard/maintenance_dashboard/view/maintenance_dashboard.dart), [maintenance_dashboard_ui.dart](../../lib/features/dashboard/maintenance_dashboard/view/maintenance_dashboard_ui.dart) |
| [lib/features/dashboard/models](../../lib/features/dashboard/models) | Shared models / inspect folder |
| [lib/features/dashboard/operation_dashboard](../../lib/features/dashboard/operation_dashboard) | [operation_dashboard.dart](../../lib/features/dashboard/operation_dashboard/view/operation_dashboard.dart), [operation_dashboard_ui.dart](../../lib/features/dashboard/operation_dashboard/view/operation_dashboard_ui.dart) |
| [lib/features/dashboard/operationadmin_dashboard](../../lib/features/dashboard/operationadmin_dashboard) | [operationadmin_dashboard.dart](../../lib/features/dashboard/operationadmin_dashboard/view/operationadmin_dashboard.dart), [operationadmin_dashboard_ui.dart](../../lib/features/dashboard/operationadmin_dashboard/view/operationadmin_dashboard_ui.dart) |
| [lib/features/dashboard/payable_dashboard](../../lib/features/dashboard/payable_dashboard) | [payable_dashboard.dart](../../lib/features/dashboard/payable_dashboard/view/payable_dashboard.dart), [payable_dashboard_ui.dart](../../lib/features/dashboard/payable_dashboard/view/payable_dashboard_ui.dart) |
| [lib/features/dashboard/receivable_dashboard](../../lib/features/dashboard/receivable_dashboard) | [receivable_dashboard.dart](../../lib/features/dashboard/receivable_dashboard/view/receivable_dashboard.dart), [receivable_dashboard_ui.dart](../../lib/features/dashboard/receivable_dashboard/view/receivable_dashboard_ui.dart) |
| [lib/features/dashboard/sales_dashboard](../../lib/features/dashboard/sales_dashboard) | [salesdashboard_dashboard.dart](../../lib/features/dashboard/sales_dashboard/view/salesdashboard_dashboard.dart), [salesdashboard_dashboard_ui.dart](../../lib/features/dashboard/sales_dashboard/view/salesdashboard_dashboard_ui.dart) |
| [lib/features/dashboard/subadmin_dashboard](../../lib/features/dashboard/subadmin_dashboard) | [subadmin_dashboard.dart](../../lib/features/dashboard/subadmin_dashboard/view/subadmin_dashboard.dart), [subadmin_dashboard_ui.dart](../../lib/features/dashboard/subadmin_dashboard/view/subadmin_dashboard_ui.dart) |
| [lib/features/dashboard/transport_dashboard](../../lib/features/dashboard/transport_dashboard) | [transport_dashboard.dart](../../lib/features/dashboard/transport_dashboard/view/transport_dashboard.dart), [transport_dashboard_ui.dart](../../lib/features/dashboard/transport_dashboard/view/transport_dashboard_ui.dart) |
| [lib/features/dashboard/unauthorized](../../lib/features/dashboard/unauthorized) | Shared models / inspect folder |
| [lib/features/dashboard/warehouse_dashboard](../../lib/features/dashboard/warehouse_dashboard) | [warehouse_dashboard.dart](../../lib/features/dashboard/warehouse_dashboard/view/warehouse_dashboard.dart), [warehouse_dashboard_ui.dart](../../lib/features/dashboard/warehouse_dashboard/view/warehouse_dashboard_ui.dart) |

## Common tabs and their integration surface

The methods column is a source inventory of repository/API method declarations. It is not a guarantee that every method is wired into a visible button. API names in these files can be resolved through the endpoint inventory. Shared dashboard summary tabs are grouped with their reporting capability even where they expose links to other workflows.

| Tab folder | Baseline owner | Repository/API methods found |
| --- | --- | --- |
| [airfreightsales](../../lib/features/dashboard/common_tabs/airfreightsales) | [finance-reports](../specs/finance-reports/spec.md) | [airfreight_repository.dart](../../lib/features/dashboard/common_tabs/airfreightsales/data/airfreight_repository.dart): `fetchRules`, `fetchInvoiceCount`, `fetchOrderStatus` |
| [airfreightvessel](../../lib/features/dashboard/common_tabs/airfreightvessel) | [vessel-planning](../specs/vessel-planning/spec.md) | [air_frieghtvessel_dashboard_bloc.dart](../../lib/features/dashboard/common_tabs/airfreightvessel/bloc/air_frieghtvessel_dashboard_bloc.dart) |
| [billorder](../../lib/features/dashboard/common_tabs/billorder) | [finance-reports](../specs/finance-reports/spec.md) | [billorder_repository.dart](../../lib/features/dashboard/common_tabs/billorder/data/billorder_repository.dart): `fetchBillOrders` |
| [bocheck](../../lib/features/dashboard/common_tabs/bocheck) | [finance-reports](../specs/finance-reports/spec.md) | [bocheck_repository.dart](../../lib/features/dashboard/common_tabs/bocheck/data/bocheck_repository.dart): `fetchBocData` |
| [custdashboard](../../lib/features/dashboard/common_tabs/custdashboard) | [finance-reports](../specs/finance-reports/spec.md) | [custdashboard_bloc.dart](../../lib/features/dashboard/common_tabs/custdashboard/bloc/custdashboard_bloc.dart) |
| [driver](../../lib/features/dashboard/common_tabs/driver) | [fleet-operations](../specs/fleet-operations/spec.md) | [driver_repository.dart](../../lib/features/dashboard/common_tabs/driver/data/driver_repository.dart): `fetchDriverDetails` |
| [driverleave](../../lib/features/dashboard/common_tabs/driverleave) | [people-leave](../specs/people-leave/spec.md) | [leave_repository.dart](../../lib/features/dashboard/common_tabs/driverleave/data/leave_repository.dart): `addLeaveRequest`, `getLeaveRequests`, `updateLeaveStatus`, `getLeaveTypes`<br>[leave_request_api.dart](../../lib/features/dashboard/common_tabs/driverleave/data/leave_request_api.dart): `addLeaveRequest`, `getLeaveRequests`, `updateLeaveStatus`, `getLeaveTypes`, `getLeaveStatus` |
| [driverlicense](../../lib/features/dashboard/common_tabs/driverlicense) | [fleet-operations](../specs/fleet-operations/spec.md) | [driverlicense_repository.dart](../../lib/features/dashboard/common_tabs/driverlicense/data/driverlicense_repository.dart): `fetchLicenseData` |
| [drivermaintenance](../../lib/features/dashboard/common_tabs/drivermaintenance) | [fleet-operations](../specs/fleet-operations/spec.md) | [drivermaintenance_repository.dart](../../lib/features/dashboard/common_tabs/drivermaintenance/data/drivermaintenance_repository.dart): `fetchTruckData` |
| [driversalary](../../lib/features/dashboard/common_tabs/driversalary) | [people-leave](../specs/people-leave/spec.md) | [driversalary_repository.dart](../../lib/features/dashboard/common_tabs/driversalary/data/driversalary_repository.dart): `fetchSalaryData` |
| [emailinbox](../../lib/features/dashboard/common_tabs/emailinbox) | [employee-communications](../specs/employee-communications/spec.md) | [emailinbox_repository.dart](../../lib/features/dashboard/common_tabs/emailinbox/data/emailinbox_repository.dart): `fetchEmployees`, `fetchEmails`, `saveEmails` |
| [employeemaster](../../lib/features/dashboard/common_tabs/employeemaster) | [employee-communications](../specs/employee-communications/spec.md) | [employee_repository.dart](../../lib/features/dashboard/common_tabs/employeemaster/data/employee_repository.dart): `fetchEmployees`, `deleteEmployee`, `saveEmployee` |
| [enginehours](../../lib/features/dashboard/common_tabs/enginehours) | [fleet-operations](../specs/fleet-operations/spec.md) | [enginehours_repository.dart](../../lib/features/dashboard/common_tabs/enginehours/data/enginehours_repository.dart): `fetchEngineHoursReport` |
| [enquiry](../../lib/features/dashboard/common_tabs/enquiry) | [sales-enquiries](../specs/sales-enquiries/spec.md) | [enquiry_repository.dart](../../lib/features/dashboard/common_tabs/enquiry/view/data/enquiry_repository.dart): `fetchEnquiries`, `cancelEnquiry` |
| [expensereport](../../lib/features/dashboard/common_tabs/expensereport) | [finance-reports](../specs/finance-reports/spec.md) | [expensereport_repository.dart](../../lib/features/dashboard/common_tabs/expensereport/data/expensereport_repository.dart): `getExpenseReport` |
| [forwardingreport](../../lib/features/dashboard/common_tabs/forwardingreport) | [finance-reports](../specs/finance-reports/spec.md) | [forwardingreport_repository.dart](../../lib/features/dashboard/common_tabs/forwardingreport/data/forwardingreport_repository.dart): `getForwardingReport` |
| [fuel](../../lib/features/dashboard/common_tabs/fuel) | [fleet-operations](../specs/fleet-operations/spec.md) | [fuel_repository.dart](../../lib/features/dashboard/common_tabs/fuel/data/fuel_repository.dart): `fetchFuelDifference` |
| [fuelentry](../../lib/features/dashboard/common_tabs/fuelentry) | [fleet-operations](../specs/fleet-operations/spec.md) | [fuelentry_repository.dart](../../lib/features/dashboard/common_tabs/fuelentry/data/fuelentry_repository.dart): `getFuelEntries`, `saveFuelEntry`, `deleteFuelEntry` |
| [fuelfillings](../../lib/features/dashboard/common_tabs/fuelfillings) | [fleet-operations](../specs/fleet-operations/spec.md) | [fuelfillings_repository.dart](../../lib/features/dashboard/common_tabs/fuelfillings/data/fuelfillings_repository.dart): `fetchFuelFillingReport` |
| [fwbreakseal](../../lib/features/dashboard/common_tabs/fwbreakseal) | [forwarding](../specs/forwarding/spec.md) | [fwbreakseal_repository.dart](../../lib/features/dashboard/common_tabs/fwbreakseal/data/fwbreakseal_repository.dart): `fetchJobs`, `fetchSalesOrderDetails`, `fetchEmployees`, `updateForwarding` |
| [googlereview](../../lib/features/dashboard/common_tabs/googlereview) | [employee-communications](../specs/employee-communications/spec.md) | [googlereview_repository.dart](../../lib/features/dashboard/common_tabs/googlereview/data/googlereview_repository.dart): `fetchEmployees`, `saveReview`, `fetchReviews`, `deleteReview` |
| [inventoryreport](../../lib/features/dashboard/common_tabs/inventoryreport) | [finance-reports](../specs/finance-reports/spec.md) | [inventoryreport_repository.dart](../../lib/features/dashboard/common_tabs/inventoryreport/data/inventoryreport_repository.dart): `fetchCustomers`, `fetchInventoryReport` |
| [invoice](../../lib/features/dashboard/common_tabs/invoice) | [finance-reports](../specs/finance-reports/spec.md) | [invoice_repository.dart](../../lib/features/dashboard/common_tabs/invoice/data/invoice_repository.dart): `loadDashboard`, `getWaitingBills`, `getEmployeeInvData` |
| [job_orders](../../lib/features/dashboard/common_tabs/job_orders) | [sales-enquiries](../specs/sales-enquiries/spec.md) | [job_orders_bloc.dart](../../lib/features/dashboard/common_tabs/job_orders/bloc/job_orders_bloc.dart) |
| [jobstatusupdate](../../lib/features/dashboard/common_tabs/jobstatusupdate) | [boarding](../specs/boarding/spec.md) | [job_status_update_repository.dart](../../lib/features/dashboard/common_tabs/jobstatusupdate/data/job_status_update_repository.dart): `fetchJobs`, `fetchJobData`, `deleteImage`, `updateBoardingDetails`, `sendBoardingMail` |
| [license](../../lib/features/dashboard/common_tabs/license) | [fleet-operations](../specs/fleet-operations/spec.md) | [license_repository.dart](../../lib/features/dashboard/common_tabs/license/data/license_repository.dart): `fetchLicenseRecords` |
| [maintenance](../../lib/features/dashboard/common_tabs/maintenance) | [fleet-operations](../specs/fleet-operations/spec.md) | [maintenance_repository.dart](../../lib/features/dashboard/common_tabs/maintenance/data/maintenance_repository.dart): `fetchCurrentMonthStats`, `fetchPendingMaintenance`, `fetchSummaryMaintenance` |
| [paymentview](../../lib/features/dashboard/common_tabs/paymentview) | [finance-reports](../specs/finance-reports/spec.md) | [paymentview_repository.dart](../../lib/features/dashboard/common_tabs/paymentview/data/paymentview_repository.dart): `fetchPaymentPendingData` |
| [pdo](../../lib/features/dashboard/common_tabs/pdo) | [rti-pdo](../specs/rti-pdo/spec.md) | [pdo_repository.dart](../../lib/features/dashboard/common_tabs/pdo/data/pdo_repository.dart): `fetchPDORecords`, `submitPDOVerification` |
| [pettycash](../../lib/features/dashboard/common_tabs/pettycash) | [finance-reports](../specs/finance-reports/spec.md) | [pettycash_repository.dart](../../lib/features/dashboard/common_tabs/pettycash/data/pettycash_repository.dart): `fetchPettyCashData` |
| [planningdetailsview](../../lib/features/dashboard/common_tabs/planningdetailsview) | [transport-planning](../specs/transport-planning/spec.md) | [planning_details_repository.dart](../../lib/features/dashboard/common_tabs/planningdetailsview/data/planning_details_repository.dart): `fetchPlanningDetails` |
| [receiptview](../../lib/features/dashboard/common_tabs/receiptview) | [finance-reports](../specs/finance-reports/spec.md) | [receipt_repository.dart](../../lib/features/dashboard/common_tabs/receiptview/data/receipt_repository.dart): `getReceipts` |
| [rtistatus](../../lib/features/dashboard/common_tabs/rtistatus) | [rti-pdo](../specs/rti-pdo/spec.md) | [rti_status_repository.dart](../../lib/features/dashboard/common_tabs/rtistatus/data/rti_status_repository.dart): `fetchImages`, `uploadImage`, `deleteImage`, `sendRtiMail` |
| [rtiview](../../lib/features/dashboard/common_tabs/rtiview) | [rti-pdo](../specs/rti-pdo/spec.md) | [rtiview_repository.dart](../../lib/features/dashboard/common_tabs/rtiview/data/rtiview_repository.dart): `fetchRTIRecords`, `fetchRTIPdfUrl` |
| [salary](../../lib/features/dashboard/common_tabs/salary) | [people-leave](../specs/people-leave/spec.md) | [salary_repository.dart](../../lib/features/dashboard/common_tabs/salary/data/salary_repository.dart): `fetchSalaryData` |
| [sale_update](../../lib/features/dashboard/common_tabs/sale_update) | [sales-enquiries](../specs/sales-enquiries/spec.md) | [sale_update_repository.dart](../../lib/features/dashboard/common_tabs/sale_update/data/sale_update_repository.dart): `searchSaleOrders`, `updateSaleOrderFields` |
| [saleorderadd](../../lib/features/dashboard/common_tabs/saleorderadd) | [sales-enquiries](../specs/sales-enquiries/spec.md) | [sales_order_repository.dart](../../lib/features/dashboard/common_tabs/saleorderadd/data/sales_order_repository.dart): `fetchInitialData`, `fetchMasterData`, `fetchJobTypeDependencies`, `saveSalesOrder`, `confirmEnquiry` |
| [saleorderdetails](../../lib/features/dashboard/common_tabs/saleorderdetails) | [sales-enquiries](../specs/sales-enquiries/spec.md) | [sale_order_details_repository.dart](../../lib/features/dashboard/common_tabs/saleorderdetails/data/sale_order_details_repository.dart): `fetchInitialData`, `fetchMasterDependencies`, `fetchMaxOrderNo` |
| [saleorderview](../../lib/features/dashboard/common_tabs/saleorderview) | [sales-enquiries](../specs/sales-enquiries/spec.md) | [saleorderrepository.dart](../../lib/features/dashboard/common_tabs/saleorderview/data/saleorderrepository.dart): `updateSaleOrderMaster` |
| [salesorder](../../lib/features/dashboard/common_tabs/salesorder) | [sales-enquiries](../specs/sales-enquiries/spec.md) | [salesorder_repository.dart](../../lib/features/dashboard/common_tabs/salesorder/data/salesorder_repository.dart): `fetchSalesData`, `fetchSalesInvoiceCheck`, `fetchEmployeeSalesData`, `fetchWaitingBills`, `fetchEmployeeInvData` |
| [spareparts](../../lib/features/dashboard/common_tabs/spareparts) | [fleet-operations](../specs/fleet-operations/spec.md) | [spareparts_repository.dart](../../lib/features/dashboard/common_tabs/spareparts/data/spareparts_repository.dart): `fetchTrucks`, `fetchSparePartsRecords`, `submitSpareParts` |
| [speedingreport](../../lib/features/dashboard/common_tabs/speedingreport) | [fleet-operations](../specs/fleet-operations/spec.md) | [speeding_repository.dart](../../lib/features/dashboard/common_tabs/speedingreport/data/speeding_repository.dart): `fetchSpeedingReport` |
| [spotsaleorder](../../lib/features/dashboard/common_tabs/spotsaleorder) | [sales-enquiries](../specs/sales-enquiries/spec.md) | [spotsale_repository.dart](../../lib/features/dashboard/common_tabs/spotsaleorder/data/spotsale_repository.dart): `fetchJobTypes`, `fetchJobStatus`, `fetchSpotSaleRecords`, `submitSpotSaleEntry` |
| [stockinentry](../../lib/features/dashboard/common_tabs/stockinentry) | [stock-management](../specs/stock-management/spec.md) | [stock_in_entry_repository.dart](../../lib/features/dashboard/common_tabs/stockinentry/data/stock_in_entry_repository.dart): `fetchInitialData`, `fetchJobNoList`, `fetchJobDetails`, `fetchSalesOrderForEdit`, `deleteImage`, `saveStockIn` |
| [stocktransfer](../../lib/features/dashboard/common_tabs/stocktransfer) | [stock-management](../specs/stock-management/spec.md) | [stock_transfer_repository.dart](../../lib/features/dashboard/common_tabs/stocktransfer/data/stock_transfer_repository.dart): `fetchWarehouses`, `fetchStockData`, `updateStockTransfer`, `scanBarcode` |
| [stockupdate](../../lib/features/dashboard/common_tabs/stockupdate) | [stock-management](../specs/stock-management/spec.md) | [stock_update_repository.dart](../../lib/features/dashboard/common_tabs/stockupdate/data/stock_update_repository.dart): `scanBarcode`, `loadStockData`, `loadJobDetails`, `deleteImage`, `saveStockUpdate`, `updateBoardingOfficer` |
| [subadminsale](../../lib/features/dashboard/common_tabs/subadminsale) | [finance-reports](../specs/finance-reports/spec.md) | [salesreport_repository.dart](../../lib/features/dashboard/common_tabs/subadminsale/data/salesreport_repository.dart): `fetchRules`, `fetchInvoiceCount`, `fetchOrderStatus`, `fetchEmployeeInvData` |
| [summonentry](../../lib/features/dashboard/common_tabs/summonentry) | [fleet-operations](../specs/fleet-operations/spec.md) | [summonentry_repository.dart](../../lib/features/dashboard/common_tabs/summonentry/data/summonentry_repository.dart): `fetchTrucks`, `fetchSummonRecords`, `submitSummon` |
| [top_customers](../../lib/features/dashboard/common_tabs/top_customers) | [finance-reports](../specs/finance-reports/spec.md) | [top_customers_bloc.dart](../../lib/features/dashboard/common_tabs/top_customers/bloc/top_customers_bloc.dart) |
| [transport](../../lib/features/dashboard/common_tabs/transport) | [transport-planning](../specs/transport-planning/spec.md) | [transport_repository.dart](../../lib/features/dashboard/common_tabs/transport/data/transport_repository.dart): `fetchTransportData` |
| [transportDB](../../lib/features/dashboard/common_tabs/transportDB) | [transport-planning](../specs/transport-planning/spec.md) | [transportdb_repository.dart](../../lib/features/dashboard/common_tabs/transportDB/data/transportdb_repository.dart): `fetchSalesData`, `fetchRulesType`, `fetchPlanningData`, `fetchEnquiryData`, `cancelEnquiry`, `fetchEmployees`, `fetchEmailsForEmployee`, `saveEmails`, `saveGoogleReview`, `fetchRTIData`, `saveRTIData` |
| [transportsales](../../lib/features/dashboard/common_tabs/transportsales) | [finance-reports](../specs/finance-reports/spec.md) | [transport_sales_repository.dart](../../lib/features/dashboard/common_tabs/transportsales/data/transport_sales_repository.dart): `fetchRules`, `fetchInvoiceCount`, `fetchOrderStatus` |
| [truck](../../lib/features/dashboard/common_tabs/truck) | [fleet-operations](../specs/fleet-operations/spec.md) | [truck_repository.dart](../../lib/features/dashboard/common_tabs/truck/data/truck_repository.dart): `fetchTruckDetails` |
| [unrelease](../../lib/features/dashboard/common_tabs/unrelease) | [forwarding](../specs/forwarding/spec.md) | [unrelease_repository.dart](../../lib/features/dashboard/common_tabs/unrelease/data/unrelease_repository.dart): `fetchUnReleaseData` |
| [unreleasesmk](../../lib/features/dashboard/common_tabs/unreleasesmk) | [forwarding](../specs/forwarding/spec.md) | [unreleasesmk_repository.dart](../../lib/features/dashboard/common_tabs/unreleasesmk/data/unreleasesmk_repository.dart): `fetchUnReleaseSMKData` |
| [vesselplanningdetails](../../lib/features/dashboard/common_tabs/vesselplanningdetails) | [vessel-planning](../specs/vessel-planning/spec.md) | [vesselplanningdetails_repository.dart](../../lib/features/dashboard/common_tabs/vesselplanningdetails/data/vesselplanningdetails_repository.dart): `fetchVesselPlanningData` |
| [vesselplanningweb](../../lib/features/dashboard/common_tabs/vesselplanningweb) | [vessel-planning](../specs/vessel-planning/spec.md) | [vesselplanningweb_repository.dart](../../lib/features/dashboard/common_tabs/vesselplanningweb/data/vesselplanningweb_repository.dart): `getVesselPlanningSearch`, `updateSpecificJob`, `saveVesselPlanning`, `deleteVesselPlanning`, `getSavedPlannings`, `getPlanningById`, `getMaxVesselPlanningNo`, `fetchVesselPlanningPdfUrl` |
| [vesselreport](../../lib/features/dashboard/common_tabs/vesselreport) | [vessel-planning](../specs/vessel-planning/spec.md) | [vessel_report_repository.dart](../../lib/features/dashboard/common_tabs/vesselreport/data/vessel_report_repository.dart): `fetchVesselPlanningData`, `updateVesselPlanningDates` |

## Other shared entry points

| Source | Coverage |
| --- | --- |
| [lib/main.dart](../../lib/main.dart) and [lib/splash/splashscreen.dart](../../lib/splash/splashscreen.dart) | Startup, restoration, notifications |
| [lib/menu/menulist.dart](../../lib/menu/menulist.dart) and [lib/core/router/app_router.dart](../../lib/core/router/app_router.dart) | Menu dispatch and dashboard routes |
| [lib/change_status_page.dart](../../lib/change_status_page.dart) | Additional status-change page; reachability and specific deployed use require Q06 clarification |
| [lib/core/bluetooth](../../lib/core/bluetooth) and [lib/core/utils/printer_helper.dart](../../lib/core/utils/printer_helper.dart) | Device discovery/connection and printer helper |
| [lib/core/network](../../lib/core/network) | Shared HTTP/Dio, endpoint constants, legacy API, service wrappers |
| [lib/core/session](../../lib/core/session) and [lib/core/utils](../../lib/core/utils) | Session, preferences, globals, uploads, platform helpers |
| [lib/core/theme](../../lib/core/theme), [lib/core/colors](../../lib/core/colors), [lib/core/widgets](../../lib/core/widgets) | Shared presentation assets and controls; no design-system migration proposed |
| [android](../../android), [ios](../../ios), [web](../../web), [linux](../../linux), [macos](../../macos), [windows](../../windows) | Platform configuration/scaffolds, not verified platform support |

## Existing tests

These files were inventoried/read; application tests were not executed for this documentation-only setup.
- [test/features/ir_report/ir_draft_test.dart](../../test/features/ir_report/ir_draft_test.dart)
- [test/features/ir_report/ir_form_bloc_test.dart](../../test/features/ir_report/ir_form_bloc_test.dart)
- [test/features/ir_report/ir_json_test.dart](../../test/features/ir_report/ir_json_test.dart)
- [test/features/ir_report/ir_list_bloc_test.dart](../../test/features/ir_report/ir_list_bloc_test.dart)
- [test/features/ir_report/ir_permissions_test.dart](../../test/features/ir_report/ir_permissions_test.dart)
- [test/features/truck_location/truck_location_bloc_test.dart](../../test/features/truck_location/truck_location_bloc_test.dart)
- [test/features/truck_location/truck_location_rules_test.dart](../../test/features/truck_location/truck_location_rules_test.dart)
- [test/stock_transfer_bloc_test.dart](../../test/stock_transfer_bloc_test.dart)
- [test/stock_update_bloc_test.dart](../../test/stock_update_bloc_test.dart)
- [test/widget_test.dart](../../test/widget_test.dart)

Inventory totals: 12 feature families, 58 common-tab folders, 677 Dart files under lib, 10 test files.
