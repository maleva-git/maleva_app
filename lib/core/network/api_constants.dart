// core/network/api_constants.dart
// OnlineApi.dart la irundha ELLA URL-um inga move pannanum
// String port = "https://maleva.my"; — live server

class ApiConstants {
  ApiConstants._(); // instantiate pannakoodadu

  static const String port = "https://maleva.my";
  // Demo servers:
  // static const String port = "http://103.215.139.121:9001/";
  // static const String port = "http://103.215.139.8:8001/";

  // ─── Image / File Upload ──────────────────────────────────────────────────
  static const String apiPostImage        = "$port/api/CommonApp/UploadFile/";
  static const String apiPostFile         = "$port/api/CommonApp/UploadFile2/";
  static const String apiUploadPdfFile    = "$port/api/CommonApp/UploadPdfFile/";
  static const String apiGetImage         = "$port/api/CommonApp/FetchFiles?ImageDirectory=";
  static const String apiDeleteImage      = "$port/api/CommonApp/DeleteFile";

  // ─── Auth / Login ─────────────────────────────────────────────────────────
  static const String apiLoginSuccess     = "$port/api/LoginApp/LoginAppSuccess?Userid=";
  static const String apiSelectUser       = "$port/api/LoginApp/SelectLoginUser?Comid=";
  static const String apiEditPassword     = "$port/api/LoginApp/EditPassword?password=";
  static const String apiGetSalesData     = "$port/api/LoginApp/GetSalesData?Comid=";
  static const String apiGetEmployeeSalesData = "$port/api/LoginApp/GetEmployeeSalesData?Comid=";
  static const String apiGetEmployeeInvData   = "$port/api/LoginApp/GetEmployeeInvData?Comid=";
  static const String apiGetFWData        = "$port/api/LoginApp/GetFWData?Comid=";
  static const String apiGetExpData       = "$port/api/LoginApp/GetExpData?Comid=";

  // ─── Master Data ──────────────────────────────────────────────────────────
  static const String apiSelectCustomer   = "$port/api/CustomerApp/GetCustomer?Comid=";
  static const String apiSelectLocation   = "$port/api/LocationApp/SelectLocation?Comid=";
  static const String apiSelectEmployee   = "$port/api/EmployeeApp/GetEmployee?Comid=";
  static const String apiSelectEmailData  = "$port/api/EmployeeApp/SelectEmailData";
  static const String apiInsertMailMaster = "$port/api/EmployeeApp/InsertMailMaster";
  static const String apiSelectJobStatus  = "$port/api/JobStatusApp/SelectJobStatus?Comid=";
  static const String apiSelectJobType    = "$port/api/JobTypeApp/SelectJobType?Comid=";
  static const String apiSelectAllJobStatus   = "$port/api/JobTypeApp/SelectJobAllData?Comid=";
  static const String apiSelectAgentCompany   = "$port/api/AgentCompanyApp/SelectAgentCompany?Comid=";
  static const String apiSelectAgentAll       = "$port/api/AgentApp/SelectAgentAll?Comid=";
  static const String apiGetProductList       = "$port/api/ItemApp/GetProductList?Comid=";
  static const String apiSelectAddressList    = "$port/api/AddressApp/SelectDistinctAddress?Comid=";
  static const String apiSelectAddressDetails = "$port/api/AddressApp/SelectAddress?Comid=";
  static const String apiWareHouseCombo       = "$port/api/StockApp/SelectPortList?Comid=";
  static const String apiSelectStockJob       = "$port/api/StockApp/SelectStockJob?Comid=";
  static const String apiGetTruckList         = "$port/api/TruckApp/GetTruck?Comid=";
  static const String apiGetDriverList        = "$port/api/DriverApp/GetDriver?Comid=";
  static const String apiSelectEmployeeDetails = "$port/api/EmployeeApp/SelectEmployee?Comid=";
  static const String apiInsertEmployeeDetails = "$port/api/EmployeeApp/InsertEmployee";
  static const String apiSelectEmployeeType   = "$port/api/EmployeeApp/SelectEmployeeType";
  static const String apiDeleteEmployeeType   = "$port/api/EmployeeApp/DeleteEmployee?Id=";
  static const String apiSelectGoogleReview   = "$port/api/EmployeeApp/SelectGoogleReview";
  static const String apiDeleteGoogleReview   = "$port/api/EmployeeApp/DeleteGoogleReview?Id=";
  static const String apiGoogleReviewInsert   = "$port/api/EmployeeApp/InsertGoogleReview";
  static const String apiSelectAllInventory   = "$port/api/CustomerApp/SelectAllInventoryt";

  // ─── Sales Order ──────────────────────────────────────────────────────────
  static const String apiSelectSalesOrder     = "$port/api/SaleOrderApp/SelectSaleOrder";
  static const String apiSelectTVSaleOrder    = "$port/api/SaleOrderApp/SelectTVSaleOrder";
  static const String apiEditSalesOrder       = "$port/api/SaleOrderApp/EditSaleOrder?Id=";
  static const String apiInsertSalesOrder     = "$port/api/SaleOrderApp/InsertSaleOrder";
  static const String apiDeleteSalesOrder     = "$port/api/SaleOrderApp/DeleteSaleOrder?Id=";
  static const String apiUpdateSaleOrderMaster = "$port/api/SaleOrderApp/UpdateSaleorderMaster";
  static const String apiMaxSaleOrderNo       = "$port/api/SaleOrderApp/MaxSaleOrderNo?Comid=";
  static const String apiGetJobNo             = "$port/api/SaleOrderApp/GetJobNo?Comid=";
  static const String apiUpdateForwarding     = "$port/api/SaleOrderApp/UpdateForwarding";
  static const String apiUpdateBoardingDetails = "$port/api/SaleOrderApp/UpdateBoardingDetails";
  static const String apiUpdateBoardingOfficer = "$port/api/SaleOrderApp/UpdateBoardingOfficier";
  static const String apiUpdateAirFrieghtDetails = "$port/api/SaleOrderApp/UpdateAirFrieght";
  static const String apiselectBillordercheck = "$port/api/SaleOrderApp/GetBillordercheck";
  static const String apiGetCurrencyValue     = "$port/api/SaleOrderApp/GetCurrencyValue?Comid=";
  static const String apiGetComboS1           = "$port/api/SaleOrderApp/SelectComboS1?Comid=";
  static const String apiBoardingMail         = "$port/api/SaleOrderApp/SendBoardingMail";
  static const String apiViewDOConvert        = "$port/api/SaleOrderApp/DoConvert?BillNo=";
  static const String apiViewInvoice          = "$port/api/SaleOrderApp/InvoiceConvert?BillNo=";
  static const String apiSelectBoardingSalary = "$port/api/SaleOrderApp/GetBoardingSalary";
  static const String apiSelectSaleorderinvoicecheck = "$port/api/MasterReportApp/SelectChecksalesinvoice";
  static const String SaleInvoiceCountDB      = "$port/api/DashBoardApp/CheckSaleInvoiceCount";
  static const String SelectSalesOrderStatus  = "$port/api/DashBoardApp/SelectSalesOrderStatus";

  // ─── Planning ─────────────────────────────────────────────────────────────
  static const String apiSelectPlanning       = "$port/api/PlanningApp/SelectPLANING";
  static const String apiEditPlanning         = "$port/api/PlanningApp/EditPLANING?Id=";
  static const String PLANINGSearch           = "$port/api/PlanningApp/PLANINGSearch";
  static const String apiViewPlanningPdf      = "$port/api/PlanningApp/PLANINGVIEW?PlanningNo=";
  static const String PLANINGSearchDB         = "$port/api/DashBoardApp/PLANINGSearchDB";
  static const String PLANINGDriverSearch     = "$port/api/DashBoardApp/PLANINGDriverSearch";

  // ─── Vessel Planning ──────────────────────────────────────────────────────
  static const String apiSelectVesselPlanning = "$port/api/VesselPlanningApp/SelectVESSELPLANING";
  static const String apiEditVesselPlanning   = "$port/api/VesselPlanningApp/EditVESSELPLANING?Id=";
  static const String apiViewVesselPlanningPdf = "$port/api/VesselPlanningApp/VESSELPLANINGVIEW?VesselPlanningNo=";
  static const String VESSELPLANINGDB         = "$port/api/DashBoardApp/VESSELPLANINGDB";

  // ─── RTI ──────────────────────────────────────────────────────────────────
  static const String apiGetRTINo             = "$port/api/RTIApp/SelectRTINo?Comid=";
  static const String apiSelectRTIView        = "$port/api/RTIApp/SelectRTI?Comid=";
  static const String apiSelectRTIDetailsView = "$port/api/RTIApp/SelectRTIView?Comid=";
  static const String apiViewRTIPdf           = "$port/api/RTIApp/RTIVIEW?RTINo=";
  static const String apiRTIMail              = "$port/api/RTIApp/SendStatusMail";
  static const String apiRTIDetailsInsert     = "$port/api/RTIApp/InsertRTIStatus?Comid=";

  // ─── Stock ────────────────────────────────────────────────────────────────
  static const String apiSelectStockDetails   = "$port/api/StockApp/SelectSaleStock?Comid=";
  static const String apiEditStockIn          = "$port/api/StockApp/EditStockIn?Id=";
  static const String apiUpdateStockIn        = "$port/api/StockApp/UpdateStockIn?Id=";
  static const String apiUpdateStockTransfer  = "$port/api/StockApp/UpdateStockTransfer?Id=";
  static const String apiInsertStockIn        = "$port/api/StockApp/InsertStockIn?Comid=";
  static const String apiMaxStockNo           = "$port/api/StockApp/MaxStockInNo?Comid=";
  static const String apiPrintStock           = "$port/api/StockApp/SelectStockPrint?Id=";

  // ─── Truck & Driver ───────────────────────────────────────────────────────
  static const String apiEditTruckDetails     = "$port/api/TruckApp/SelectTruck?Comid=";
  static const String apiUpdateTruckDetails   = "$port/api/TruckApp/InsertTruck?Comid=";
  static const String apiSelectTruckDetails   = "$port/api/MasterReportApp/TruckReportView";
  static const String apiSelectDriverDetails  = "$port/api/MasterReportApp/DriverReportView";
  static const String apiDriverViewRecords    = "$port/api/DriverApp/SelectDriver?Comid=";

  // ─── Fuel Entry ───────────────────────────────────────────────────────────
  static const String apiInsertFuelEntry      = "$port/api/FuelEntryApp/InsertFuelEntry";
  static const String apiMaxFuelEntryNo       = "$port/api/FuelEntryApp/MaxFuelEntryNo?Comid=";
  static const String apiDeleteFuelEntry      = "$port/api/FuelEntryApp/DeleteFuelEntry?Id=";
  static const String apiEditFuelEntry        = "$port/api/FuelEntryApp/EditFuelEntry?Id=";
  static const String apiSelectFuelEntry      = "$port/api/FuelEntryApp/SelectFuelEntry";

  // ─── Forwarding Salary ────────────────────────────────────────────────────
  static const String apiInsertForwarding     = "$port/api/ForwardingSalaryApp/InsertForwardingSalary";
  static const String apiSelectForwarding     = "$port/api/ForwardingSalaryApp/SelectForwardingSalary";

  // ─── Receipt / Transaction ────────────────────────────────────────────────
  static const String apiGetReceipt           = "$port/api/ReceiptApp/SelectReceipt?Comid=";
  static const String apiSelectReceipt        = "$port/api/TransactionReportApp/SelectCustomerBalance";
  static const String apiSelectPaymentPending = "$port/api/DashBoardApp/SelectPendingPayment";
  static const String apiGetReceiptView       = "$port/api/ReceiptApp/SelectTruck?Comid=";

  // ─── Enquiry ──────────────────────────────────────────────────────────────
  static const String apiInsertEnquiry        = "$port/api/EnquiryMasterApp/InsertEnquiryMaster";
  static const String apiSelectEnquiryMaster  = "$port/api/EnquiryMasterApp/SelectEnquiryMaster";
  static const String apiUpdateEnquiryMaster  = "$port/api/EnquiryMasterApp/UpdateEnquiryMaster?Id=";

  // ─── Bill Order / Petty Cash ──────────────────────────────────────────────
  static const String apiBillorderview        = "$port/api/BIllorderApp/SelectBillsOrderApp?Comid=";
  static const String apiGetpettycash         = "$port/api/BIllorderApp/SelectpetticashApp?Comid=";
  static const String apiPettyCashview        = "$port/api/PettyCashApp/SelectPettyCashMaster?Comid=";

  // ─── Spare Parts ──────────────────────────────────────────────────────────
  static const String apiInsertSpareParts     = "$port/api/TruckSparePartsApp/InsertSpareParts";
  static const String apiGetSpareParts        = "$port/api/TruckSparePartsApp/SelectSpareParts?Comid=";
  static const String apiInsertSpotSaleEntry  = "$port/api/TruckSparePartsApp/InsertSpotSaleEntry";
  static const String apiGetSpotSaleEntry     = "$port/api/TruckSparePartsApp/SelectSpotSaleEntry?Comid=";
  static const String apiInsertSummonParts    = "$port/api/TruckSparePartsApp/InsertSummon";
  static const String apiGetSummonParts       = "$port/api/TruckSparePartsApp/SelectSummon?Comid=";

  // ─── License ──────────────────────────────────────────────────────────────
  static const String apiLicenseViewRecords   = "$port/api/LicenseApp/SelectLicense";

  // ─── Dashboard ────────────────────────────────────────────────────────────
  static const String apiGetMaintenance       = "$port/api/DashboardApp/LoadSupplierExpenseData?Comid=";
  static const String apiGetMaintenance1      = "$port/api/DashboardApp/LoadExpenseData?Comid=";
  static const String apiGetMaintenance2      = "$port/api/DashboardApp/SelectStatusBO?Comid=";
  static const String apiSelectExpenseDetails = "$port/api/DashboardApp/SelectExpenseName";
  static const String LoadRulesType           = "$port/api/DashBoardApp/LoadRulesType";
  static const String LoadUnReleaseNo         = "$port/api/DashBoardApp/LoadUnReleaseNo";
  static const String LoadK8UnReleaseNo       = "$port/api/DashBoardApp/LoadK8UnReleaseNo";
  static const String AirFrieghtDB            = "$port/api/DashBoardApp/AirFrieghtDB";

  // ─── Reports ──────────────────────────────────────────────────────────────
  static const String apiPreAlertReport       = "$port/api/TransactionReportApp/PreAlertReport?PreAlertName=";
  static const String apiSelectSpeedingReport = "$port/api/MasterReportApp/SpeedingReportView";
  static const String apiSelectFuelFillingReport = "$port/api/MasterReportApp/SelectFuelFillings";
  static const String apiSelectEngineHoursReport = "$port/api/MasterReportApp/SelectEngineHours";
  static const String apiSelectDriverSalary   = "$port/api/TransactionReportApp/DriverRTIDetailedReport";
}