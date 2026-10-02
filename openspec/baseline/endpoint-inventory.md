# Endpoint source inventory

Snapshot date: 2026-10-01. This catalog was extracted from non-comment Dart source. It records declarations and lexical references, not live API availability, invocation counts, or complete backend contracts. Methods and schemas must be checked at the call site; see [API interactions](api-interactions.md).

## Declared endpoint constants

Paths preserve casing and spelling from the code. `{base}` is AppConfig.baseUrl; unfinished query values are filled by callers. A reference count includes wrappers, not just reachable UI calls.

| Constant | Declared path / prefix | Other source files referencing it | Example reference |
| --- | --- | ---: | --- |
| `apiPostImage` | `{base}/api/CommonApp/UploadFile/` | 7 | [airfreight_tab.dart](../../lib/features/airfreight/updateairfreight/view/airfreight_tab.dart) |
| `apiPostFile` | `{base}/api/CommonApp/UploadFile2/` | 1 | [applog_api.dart](../../lib/features/troubleshoot/data/applog_api.dart) |
| `apiUploadPdfFile` | `{base}/api/CommonApp/UploadPdfFile/` | 0 | No lexical reference found |
| `apiGetImage` | `{base}/api/CommonApp/FetchFiles?ImageDirectory=` | 6 | [airfreight_bloc.dart](../../lib/features/airfreight/updateairfreight/bloc/airfreight_bloc.dart) |
| `apiDeleteImage` | `{base}/api/CommonApp/DeleteFile` | 7 | [airfreight_bloc.dart](../../lib/features/airfreight/updateairfreight/bloc/airfreight_bloc.dart) |
| ~~`apiLoginSuccess`~~ | ~~`{base}/api/LoginApp/LoginAppSuccess?Userid=`~~ | 0 | Removed 2026-10-01 (change `move-mobile-login-to-java`): sign-in, restore and sign-out use the Java `/api/mobile/auth/login`, `/refresh`, `/logout` through [mobile_auth_api.dart](../../lib/features/auth/data/mobile_auth_api.dart) |
| `apiSelectUser` | `{base}/api/LoginApp/SelectLoginUser?Comid=` | 2 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiEditPassword` | `{base}/api/LoginApp/EditPassword?password=` | 0 | No lexical reference found |
| `apiGetSalesData` | `{base}/api/LoginApp/GetSalesData?Comid=` | 1 | [auth_api.dart](../../lib/core/network/api_services/auth_api.dart) |
| `apiGetEmployeeSalesData` | `{base}/api/LoginApp/GetEmployeeSalesData?Comid=` | 1 | [auth_api.dart](../../lib/core/network/api_services/auth_api.dart) |
| `apiGetEmployeeInvData` | `{base}/api/LoginApp/GetEmployeeInvData?Comid=` | 3 | [auth_api.dart](../../lib/core/network/api_services/auth_api.dart) |
| `apiGetFWData` | `{base}/api/LoginApp/GetFWData?Comid=` | 1 | [forwardingreport_repository.dart](../../lib/features/dashboard/common_tabs/forwardingreport/data/forwardingreport_repository.dart) |
| `apiGetExpData` | `{base}/api/LoginApp/GetExpData?Comid=` | 2 | [auth_api.dart](../../lib/core/network/api_services/auth_api.dart) |
| `apiSelectCustomer` | `{base}/api/CustomerApp/GetCustomer?Comid=` | 7 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiSelectLocation` | `{base}/api/LocationApp/SelectLocation?Comid=` | 2 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiSelectEmployee` | `{base}/api/EmployeeApp/GetEmployee?Comid=` | 14 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiSelectEmailData` | `{base}/api/EmployeeApp/SelectEmailData` | 2 | [emailinbox_repository.dart](../../lib/features/dashboard/common_tabs/emailinbox/data/emailinbox_repository.dart) |
| `apiInsertMailMaster` | `{base}/api/EmployeeApp/InsertMailMaster` | 2 | [emailinbox_repository.dart](../../lib/features/dashboard/common_tabs/emailinbox/data/emailinbox_repository.dart) |
| `apiSelectJobStatus` | `{base}/api/JobStatusApp/SelectJobStatus?Comid=` | 4 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiSelectJobType` | `{base}/api/JobTypeApp/SelectJobType?Comid=` | 6 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiSelectAllJobStatus` | `{base}/api/JobTypeApp/SelectJobAllData?Comid=` | 9 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiSelectAgentCompany` | `{base}/api/AgentCompanyApp/SelectAgentCompany?Comid=` | 5 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiSelectAgentAll` | `{base}/api/AgentApp/SelectAgentAll?Comid=` | 5 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiGetProductList` | `{base}/api/ItemApp/GetProductList?Comid=` | 2 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiSelectAddressList` | `{base}/api/AddressApp/SelectDistinctAddress?Comid=` | 4 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiSelectAddressDetails` | `{base}/api/AddressApp/SelectAddress?Comid=` | 4 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiWareHouseCombo` | `{base}/api/StockApp/SelectPortList?Comid=` | 3 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiSelectStockJob` | `{base}/api/StockApp/SelectStockJob?Comid=` | 3 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiGetTruckList` | `{base}/api/TruckApp/GetTruck?Comid=` | 3 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiGetDriverList` | `{base}/api/DriverApp/GetDriver?Comid=` | 3 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiSelectEmployeeDetails` | `{base}/api/EmployeeApp/SelectEmployee?Comid=` | 1 | [employee_repository.dart](../../lib/features/dashboard/common_tabs/employeemaster/data/employee_repository.dart) |
| `apiInsertEmployeeDetails` | `{base}/api/EmployeeApp/InsertEmployee` | 1 | [employee_repository.dart](../../lib/features/dashboard/common_tabs/employeemaster/data/employee_repository.dart) |
| `apiSelectEmployeeType` | `{base}/api/EmployeeApp/SelectEmployeeType` | 0 | No lexical reference found |
| `apiDeleteEmployeeType` | `{base}/api/EmployeeApp/DeleteEmployee?Id=` | 1 | [employee_repository.dart](../../lib/features/dashboard/common_tabs/employeemaster/data/employee_repository.dart) |
| `apiSelectGoogleReview` | `{base}/api/EmployeeApp/SelectGoogleReview` | 1 | [googlereview_repository.dart](../../lib/features/dashboard/common_tabs/googlereview/data/googlereview_repository.dart) |
| `apiDeleteGoogleReview` | `{base}/api/EmployeeApp/DeleteGoogleReview?Id=` | 1 | [googlereview_repository.dart](../../lib/features/dashboard/common_tabs/googlereview/data/googlereview_repository.dart) |
| `apiGoogleReviewInsert` | `{base}/api/EmployeeApp/InsertGoogleReview` | 2 | [transportdb_repository.dart](../../lib/features/dashboard/common_tabs/transportDB/data/transportdb_repository.dart) |
| `apiSelectAllInventory` | `{base}/api/CustomerApp/SelectAllInventoryt` | 1 | [inventoryreport_repository.dart](../../lib/features/dashboard/common_tabs/inventoryreport/data/inventoryreport_repository.dart) |
| `apiSelectInvoiceNumber` | `{base}/SaleOrder/SelectInvoiceNumber` | 1 | [salesorderview_repository.dart](../../lib/features/transaction/salesorder/view/data/salesorderview_repository.dart) |
| `apiSelectSalesOrder` | `{base}/api/SaleOrderApp/SelectSaleOrder` | 1 | [salesorderview_bloc.dart](../../lib/features/transaction/salesorder/view/bloc/salesorderview_bloc.dart) |
| `apiSelectTVSaleOrder` | `{base}/api/SaleOrderApp/SelectTVSaleOrder` | 1 | [saleorderview_bloc.dart](../../lib/features/dashboard/common_tabs/saleorderview/bloc/saleorderview_bloc.dart) |
| `apiEditSalesOrder` | `{base}/api/SaleOrderApp/EditSaleOrder?Id=` | 10 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiInsertSalesOrder` | `{base}/api/SaleOrderApp/InsertSaleOrder` | 2 | [salesorderadd_bloc.dart](../../lib/features/transaction/salesorder/add/bloc/salesorderadd_bloc.dart) |
| `apiDeleteSalesOrder` | `{base}/api/SaleOrderApp/DeleteSaleOrder?Id=` | 2 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiUpdateSaleOrderMaster` | `{base}/api/SaleOrderApp/UpdateSaleorderMaster` | 1 | [saleorderrepository.dart](../../lib/features/dashboard/common_tabs/saleorderview/data/saleorderrepository.dart) |
| `apiMaxSaleOrderNo` | `{base}/api/SaleOrderApp/MaxSaleOrderNo?Comid=` | 5 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiGetJobNo` | `{base}/api/SaleOrderApp/GetJobNo?Comid=` | 7 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiUpdateForwarding` | `{base}/api/SaleOrderApp/UpdateForwarding` | 4 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiUpdateBoardingDetails` | `{base}/api/SaleOrderApp/UpdateBoardingDetails` | 3 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiUpdateBoardingOfficer` | `{base}/api/SaleOrderApp/UpdateBoardingOfficier` | 2 | [vessel_report_repository.dart](../../lib/features/dashboard/common_tabs/vesselreport/data/vessel_report_repository.dart) |
| `apiUpdateAirFrieghtDetails` | `{base}/api/SaleOrderApp/UpdateAirFrieght` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiselectBillordercheck` | `{base}/api/SaleOrderApp/GetBillordercheck` | 1 | [bocheck_repository.dart](../../lib/features/dashboard/common_tabs/bocheck/data/bocheck_repository.dart) |
| `apiGetCurrencyValue` | `{base}/api/SaleOrderApp/GetCurrencyValue?Comid=` | 5 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiGetComboS1` | `{base}/api/SaleOrderApp/SelectComboS1?Comid=` | 4 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiBoardingMail` | `{base}/api/SaleOrderApp/SendBoardingMail` | 2 | [job_status_update_repository.dart](../../lib/features/dashboard/common_tabs/jobstatusupdate/data/job_status_update_repository.dart) |
| `apiViewDOConvert` | `{base}/api/SaleOrderApp/DoConvert?BillNo=` | 1 | [salesorderview_bloc.dart](../../lib/features/transaction/salesorder/view/bloc/salesorderview_bloc.dart) |
| `apiViewInvoice` | `{base}/api/SaleOrderApp/InvoiceConvert?BillNo=` | 1 | [salesorderview_bloc.dart](../../lib/features/transaction/salesorder/view/bloc/salesorderview_bloc.dart) |
| `apiSelectBoardingSalary` | `{base}/api/SaleOrderApp/GetBoardingSalary` | 0 | No lexical reference found |
| `apiSelectBoardingSalaryNew` | `{base}/api/BoardingSalaryApp/SelectBoardingSalary` | 0 | No lexical reference found |
| `apiSelectBoardingSalaryByEmpId` | `{base}/api/BoardingSalaryApp/SelectBoardingSalaryByEmpId` | 1 | [salary_repository.dart](../../lib/features/dashboard/common_tabs/salary/data/salary_repository.dart) |
| `apiSelectSaleorderinvoicecheck` | `{base}/api/MasterReportApp/SelectChecksalesinvoice` | 2 | [auth_api.dart](../../lib/core/network/api_services/auth_api.dart) |
| `SaleInvoiceCountDB` | `{base}/api/DashBoardApp/CheckSaleInvoiceCount` | 6 | [sales_api.dart](../../lib/core/network/api_services/sales_api.dart) |
| `SelectSalesOrderStatus` | `{base}/api/DashBoardApp/SelectSalesOrderStatus` | 6 | [sales_api.dart](../../lib/core/network/api_services/sales_api.dart) |
| `apiSelectPlanning` | `{base}/api/PlanningApp/SelectPLANING` | 1 | [planning_repository.dart](../../lib/features/transaction/planning/data/planning_repository.dart) |
| `apiEditPlanning` | `{base}/api/PlanningApp/EditPLANING?Id=` | 3 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `PLANINGSearch` | `{base}/api/PlanningApp/PLANINGSearch` | 5 | [planning_repository.dart](../../lib/features/transaction/planning/data/planning_repository.dart) |
| `apiViewPlanningPdf` | `{base}/api/PlanningApp/PLANINGVIEW?PlanningNo=` | 2 | [enquiry_repository.dart](../../lib/features/transaction/enquirytrmaster/data/enquiry_repository.dart) |
| `PLANINGSearchDB` | `{base}/api/DashBoardApp/PLANINGSearchDB` | 4 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `PLANINGDriverSearch` | `{base}/api/DashBoardApp/PLANINGDriverSearch` | 1 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `apiSelectVesselPlanning` | `{base}/api/VesselPlanningApp/SelectVESSELPLANING` | 2 | [vesselplanning_repository.dart](../../lib/features/transaction/vesselplanning/data/vesselplanning_repository.dart) |
| `apiEditVesselPlanning` | `{base}/api/VesselPlanningApp/EditVESSELPLANING?Id=` | 4 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiViewVesselPlanningPdf` | `{base}/api/VesselPlanningApp/VESSELPLANINGVIEW?VesselPlanningNo=` | 2 | [vesselplanning_repository.dart](../../lib/features/transaction/vesselplanning/data/vesselplanning_repository.dart) |
| `VESSELPLANINGDB` | `{base}/api/DashBoardApp/VESSELPLANINGDB` | 4 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `apiVesselPlanningSearch` | `{base}/api/VesselPlanningApp/VESSELPLANINGSearch` | 1 | [vesselplanningweb_repository.dart](../../lib/features/dashboard/common_tabs/vesselplanningweb/data/vesselplanningweb_repository.dart) |
| `apiMaxVesselPlanningNo` | `{base}/VESSELPLANING/MaxVESSELPLANINGNo` | 1 | [vesselplanningweb_repository.dart](../../lib/features/dashboard/common_tabs/vesselplanningweb/data/vesselplanningweb_repository.dart) |
| `apiInsertVesselPlanning` | `{base}/api/VesselPlanningApp/InsertVESSELPLANING` | 1 | [vesselplanningweb_repository.dart](../../lib/features/dashboard/common_tabs/vesselplanningweb/data/vesselplanningweb_repository.dart) |
| `apiDeleteVesselPlanning` | `{base}/api/VesselPlanningApp/DeleteVESSELPLANING?Id=` | 1 | [vesselplanningweb_repository.dart](../../lib/features/dashboard/common_tabs/vesselplanningweb/data/vesselplanningweb_repository.dart) |
| `apiUpdateSaleOrderSpecific` | `{base}/SaleOrder/UpdateSaleorder` | 2 | [vesselplanningweb_repository.dart](../../lib/features/dashboard/common_tabs/vesselplanningweb/data/vesselplanningweb_repository.dart) |
| `apiGetRTINo` | `{base}/api/RTIApp/SelectRTINo?Comid=` | 2 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiSelectRTIView` | `{base}/api/RTIApp/SelectRTI?Comid=` | 5 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiSelectRTIDetailsView` | `{base}/api/RTIApp/SelectRTIView?Comid=` | 1 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiViewRTIPdf` | `{base}/api/RTIApp/RTIVIEW?RTINo=` | 2 | [updatertidetails_bloc.dart](../../lib/features/transport/updatertidetails/bloc/updatertidetails_bloc.dart) |
| `apiRTIMail` | `{base}/api/RTIApp/SendStatusMail` | 1 | [rti_status_repository.dart](../../lib/features/dashboard/common_tabs/rtistatus/data/rti_status_repository.dart) |
| `apiRTIDetailsInsert` | `{base}/api/RTIApp/InsertRTIStatus?Comid=` | 3 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiSelectStockDetails` | `{base}/api/StockApp/SelectSaleStock?Comid=` | 3 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiEditStockIn` | `{base}/api/StockApp/EditStockIn?Id=` | 3 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiUpdateStockIn` | `{base}/api/StockApp/UpdateStockIn?Id=` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiUpdateStockTransfer` | `{base}/api/StockApp/UpdateStockTransfer?Id=` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiInsertStockIn` | `{base}/api/StockApp/InsertStockIn?Comid=` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiMaxStockNo` | `{base}/api/StockApp/MaxStockInNo?Comid=` | 3 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiPrintStock` | `{base}/api/StockApp/SelectStockPrint?Id=` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiEditTruckDetails` | `{base}/api/TruckApp/SelectTruck?Comid=` | 2 | [legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `apiUpdateTruckDetails` | `{base}/api/TruckApp/InsertTruck?Comid=` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiSelectTruckDetails` | `{base}/api/MasterReportApp/TruckReportView` | 4 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `apiSelectDriverDetails` | `{base}/api/MasterReportApp/DriverReportView` | 3 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `apiDriverViewRecords` | `{base}/api/DriverApp/SelectDriver?Comid=` | 1 | [license_repository.dart](../../lib/features/dashboard/common_tabs/license/data/license_repository.dart) |
| `apiInsertFuelEntry` | `{base}/api/FuelEntryApp/InsertFuelEntry` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiMaxFuelEntryNo` | `{base}/api/FuelEntryApp/MaxFuelEntryNo?Comid=` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiDeleteFuelEntry` | `{base}/api/FuelEntryApp/DeleteFuelEntry?Id=` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiEditFuelEntry` | `{base}/api/FuelEntryApp/EditFuelEntry?Id=` | 1 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiSelectFuelEntry` | `{base}/api/FuelEntryApp/SelectFuelEntry` | 4 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiInsertForwarding` | `{base}/api/ForwardingSalaryApp/InsertForwardingSalary` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiSelectForwarding` | `{base}/api/ForwardingSalaryApp/SelectForwardingSalary` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiGetReceipt` | `{base}/api/ReceiptApp/SelectReceipt?Comid=` | 0 | No lexical reference found |
| `apiSelectReceipt` | `{base}/api/TransactionReportApp/SelectCustomerBalance` | 1 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `apiSelectPaymentPending` | `{base}/api/DashBoardApp/SelectPendingPayment` | 3 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `apiGetReceiptView` | `{base}/api/ReceiptApp/SelectTruck?Comid=` | 0 | No lexical reference found |
| `apiInsertEnquiry` | `{base}/api/EnquiryMasterApp/InsertEnquiryMaster` | 3 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiSelectEnquiryMaster` | `{base}/api/EnquiryMasterApp/SelectEnquiryMaster` | 5 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiUpdateEnquiryMaster` | `{base}/api/EnquiryMasterApp/UpdateEnquiryMaster?Id=` | 7 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiBillorderview` | `{base}/api/BIllorderApp/SelectBillsOrderApp?Comid=` | 1 | [billorder_repository.dart](../../lib/features/dashboard/common_tabs/billorder/data/billorder_repository.dart) |
| `apiGetpettycash` | `{base}/api/BIllorderApp/SelectpetticashApp?Comid=` | 2 | [change_status_page.dart](../../lib/change_status_page.dart) |
| `apiPettyCashview` | `{base}/api/PettyCashApp/SelectPettyCashMaster?Comid=` | 0 | No lexical reference found |
| `apiInsertSpareParts` | `{base}/api/TruckSparePartsApp/InsertSpareParts` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiGetSpareParts` | `{base}/api/TruckSparePartsApp/SelectSpareParts?Comid=` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiInsertSpotSaleEntry` | `{base}/api/TruckSparePartsApp/InsertSpotSaleEntry` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiGetSpotSaleEntry` | `{base}/api/TruckSparePartsApp/SelectSpotSaleEntry?Comid=` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiInsertSummonParts` | `{base}/api/TruckSparePartsApp/InsertSummon` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiGetSummonParts` | `{base}/api/TruckSparePartsApp/SelectSummon?Comid=` | 2 | [operations_api.dart](../../lib/core/network/api_services/operations_api.dart) |
| `apiLicenseViewRecords` | `{base}/api/LicenseApp/SelectLicense` | 0 | No lexical reference found |
| `apiGetMaintenance` | `{base}/api/DashboardApp/LoadSupplierExpenseData?Comid=` | 2 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `apiGetMaintenance1` | `{base}/api/DashboardApp/LoadExpenseData?Comid=` | 2 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `apiGetMaintenance2` | `{base}/api/DashboardApp/SelectStatusBO?Comid=` | 2 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `apiSelectExpenseDetails` | `{base}/api/DashboardApp/SelectExpenseName` | 0 | No lexical reference found |
| `LoadRulesType` | `{base}/api/DashBoardApp/LoadRulesType` | 6 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `LoadUnReleaseNo` | `{base}/api/DashBoardApp/LoadUnReleaseNo` | 2 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `LoadK8UnReleaseNo` | `{base}/api/DashBoardApp/LoadK8UnReleaseNo` | 3 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `AirFrieghtDB` | `{base}/api/DashBoardApp/AirFrieghtDB` | 2 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `apiPreAlertReport` | `{base}/api/TransactionReportApp/PreAlertReport?PreAlertName=` | 2 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `apiSelectSpeedingReport` | `{base}/api/MasterReportApp/SpeedingReportView` | 2 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `apiSelectFuelFillingReport` | `{base}/api/MasterReportApp/SelectFuelFillings` | 2 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `apiSelectEngineHoursReport` | `{base}/api/MasterReportApp/SelectEngineHours` | 2 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `apiSelectDriverSalary` | `{base}/api/TransactionReportApp/DriverRTIDetailedReport` | 2 | [reports_api.dart](../../lib/core/network/api_services/reports_api.dart) |
| `apiInsertAppLog` | `{base}/api/AppLogApp/InsertAppLog` | 0 | No lexical reference found |

## Inline API path literals outside the constants file

This supplemental inventory lists unique `/api/...` path fragments and all source files where they occur outside ApiConstants. It does not resolve every dynamically constructed URL; for example LeaveRequestApp appends action names to a stored base. Comments are excluded, but a reference can still be in inactive code.

| Literal path fragment | Sources |
| --- | --- |
| `/api/DashBoardApp/SelectTopCustomers` | [features/dashboard/common_tabs/top_customers/bloc/top_customers_bloc.dart](../../lib/features/dashboard/common_tabs/top_customers/bloc/top_customers_bloc.dart) |
| `/api/EmployeeApp/GetEmployeeport` | [core/network/legacy_api_repository.dart](../../lib/core/network/legacy_api_repository.dart) |
| `/api/FuelEntryApp/DeleteFuelEntry` | [features/dashboard/common_tabs/fuelentry/data/fuelentry_repository.dart](../../lib/features/dashboard/common_tabs/fuelentry/data/fuelentry_repository.dart) |
| `/api/FuelEntryApp/InsertFuelEntry` | [features/dashboard/common_tabs/fuelentry/data/fuelentry_repository.dart](../../lib/features/dashboard/common_tabs/fuelentry/data/fuelentry_repository.dart) |
| `/api/FuelEntryApp/SelectFuelEntry` | [features/dashboard/common_tabs/fuelentry/data/fuelentry_repository.dart](../../lib/features/dashboard/common_tabs/fuelentry/data/fuelentry_repository.dart) |
| `/api/JobOrderMasterApp/SelectJoborder` | [features/dashboard/common_tabs/job_orders/bloc/job_orders_bloc.dart](../../lib/features/dashboard/common_tabs/job_orders/bloc/job_orders_bloc.dart) |
| `/api/JobOrderMasterApp/SelectJoborderType` | [features/dashboard/common_tabs/job_orders/bloc/job_orders_bloc.dart](../../lib/features/dashboard/common_tabs/job_orders/bloc/job_orders_bloc.dart) |
| `/api/JobOrderMasterApp/Updatejoborderstatus` | [features/dashboard/common_tabs/job_orders/bloc/job_orders_bloc.dart](../../lib/features/dashboard/common_tabs/job_orders/bloc/job_orders_bloc.dart) |
| `/api/LeaveRequestApp` | [features/dashboard/common_tabs/driverleave/data/leave_request_api.dart](../../lib/features/dashboard/common_tabs/driverleave/data/leave_request_api.dart), [features/dashboard/common_tabs/driverleave/data/leave_repository.dart](../../lib/features/dashboard/common_tabs/driverleave/data/leave_repository.dart) |
| `/api/PLANING/InsertPLANING` | [features/transaction/planning/data/planning_repository.dart](../../lib/features/transaction/planning/data/planning_repository.dart) |
| `/api/PlanningApp/InsertPLANING` | [features/transaction/planning/view/add_planning_page.dart](../../lib/features/transaction/planning/view/add_planning_page.dart) |
| `/api/RTIApp/SelectRTIRouteActivities` | [features/dashboard/forwarding_agent_dashboard/bloc/rti_activities/rti_activities_bloc.dart](../../lib/features/dashboard/forwarding_agent_dashboard/bloc/rti_activities/rti_activities_bloc.dart) |
| `/api/RTIApp/UpdateRootactivity` | [features/dashboard/forwarding_agent_dashboard/bloc/rti_activities/rti_activities_bloc.dart](../../lib/features/dashboard/forwarding_agent_dashboard/bloc/rti_activities/rti_activities_bloc.dart) |
| `/api/SaleOrderApp/SearchSaleOrderForUpdate` | [features/dashboard/common_tabs/sale_update/data/sale_update_repository.dart](../../lib/features/dashboard/common_tabs/sale_update/data/sale_update_repository.dart) |
| `/api/SaleOrderApp/UpdateSaleOrderFields` | [features/dashboard/common_tabs/sale_update/data/sale_update_repository.dart](../../lib/features/dashboard/common_tabs/sale_update/data/sale_update_repository.dart) |

Known composed actions: LeaveRequestApp defines SaveLeaveRequest, GetLeaveRequests, UpdateLeaveStatus, GetLeaveTypes, and (in the static helper) GetLeaveStatus. Non-`/api` routes are also declared in the constants table. External map/document/image URLs and Firebase SDK traffic are outside this endpoint catalog.

Totals: 143 declared endpoint constants and 15 unique inline API path fragments.
