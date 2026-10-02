
import '../config/app_config.dart';

class ApiConstants {
  ApiConstants._();

  static const String port = AppConfig.baseUrl;

//static const String port = "https://maleva.my";
  // Demo servers:
  // static const String port = "http://103.215.139.121:9001/";
  //static const String port = "http://103.215.139.8:8001/";

  // ─── Image / File Upload ──────────────────────────────────────────────────
  static const String apiPostFile         = "$port/api/CommonApp/UploadFile2/";
  static const String apiUploadPdfFile    = "$port/api/CommonApp/UploadPdfFile/";

  // ─── Auth / Login ─────────────────────────────────────────────────────────
  static const String apiSelectUser       = "$port/api/LoginApp/SelectLoginUser?Comid=";
  static const String apiEditPassword     = "$port/api/LoginApp/EditPassword?password=";

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
  static const String apiSelectBoardingSalaryNew = "$port/api/BoardingSalaryApp/SelectBoardingSalary";
  static const String apiSelectBoardingSalaryByEmpId = "$port/api/BoardingSalaryApp/SelectBoardingSalaryByEmpId";

  // ─── Planning ─────────────────────────────────────────────────────────────
  static const String apiSelectPlanning       = "$port/api/PlanningApp/SelectPLANING";
  static const String apiEditPlanning         = "$port/api/PlanningApp/EditPLANING?Id=";
  static String PLANINGSearch           = "$port/api/PlanningApp/PLANINGSearch";
  static String VESSELPLANINGDB         = "$port/api/DashBoardApp/VESSELPLANINGDB"; // vesselplanningdetails only (its read never matched this answer)
  static const String apiViewPlanningPdf      = "$port/api/PlanningApp/PLANINGVIEW?PlanningNo=";

  // ─── Vessel Planning ──────────────────────────────────────────────────────
  static const String apiSelectVesselPlanning = "$port/api/VesselPlanningApp/SelectVESSELPLANING";
  static const String apiEditVesselPlanning   = "$port/api/VesselPlanningApp/EditVESSELPLANING?Id=";
  static const String apiViewVesselPlanningPdf = "$port/api/VesselPlanningApp/VESSELPLANINGVIEW?VesselPlanningNo=";
  static const String apiVesselPlanningSearch = "$port/api/VesselPlanningApp/VESSELPLANINGSearch";
  static const String apiMaxVesselPlanningNo  = "$port/VESSELPLANING/MaxVESSELPLANINGNo";
  static const String apiInsertVesselPlanning = "$port/api/VesselPlanningApp/InsertVESSELPLANING";
  static const String apiDeleteVesselPlanning = "$port/api/VesselPlanningApp/DeleteVESSELPLANING?Id=";
  static const String apiUpdateSaleOrderSpecific = "$port/SaleOrder/UpdateSaleorder";

  // ─── RTI ──────────────────────────────────────────────────────────────────
  static const String apiGetRTINo             = "$port/api/RTIApp/SelectRTINo?Comid=";
  static const String apiSelectRTIView        = "$port/api/RTIApp/SelectRTI?Comid=";
  static const String apiSelectRTIDetailsView = "$port/api/RTIApp/SelectRTIView?Comid=";
  static const String apiViewRTIPdf           = "$port/api/RTIApp/RTIVIEW?RTINo=";
  static const String apiRTIMail              = "$port/api/RTIApp/SendStatusMail";
  static const String apiRTIDetailsInsert     = "$port/api/RTIApp/InsertRTIStatus?Comid=";

  // ─── Stock ────────────────────────────────────────────────────────────────

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
  static const String apiSelectFuelEntry      = "$port/api/FuelEntryApp/SelectFuelEntry";

  // ─── Forwarding Salary ────────────────────────────────────────────────────
  static const String apiInsertForwarding     = "$port/api/ForwardingSalaryApp/InsertForwardingSalary";
  static const String apiSelectForwarding     = "$port/api/ForwardingSalaryApp/SelectForwardingSalary";

  // ─── Receipt / Transaction ────────────────────────────────────────────────
  static const String apiGetReceipt           = "$port/api/ReceiptApp/SelectReceipt?Comid=";
  static const String apiSelectReceipt        = "$port/api/TransactionReportApp/SelectCustomerBalance";
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

  // ─── Reports ──────────────────────────────────────────────────────────────
  static const String apiPreAlertReport       = "$port/api/TransactionReportApp/PreAlertReport?PreAlertName=";
  static const String apiSelectSpeedingReport = "$port/api/MasterReportApp/SpeedingReportView";
  static const String apiSelectFuelFillingReport = "$port/api/MasterReportApp/SelectFuelFillings";
  static const String apiSelectEngineHoursReport = "$port/api/MasterReportApp/SelectEngineHours";
  static const String apiSelectDriverSalary   = "$port/api/TransactionReportApp/DriverRTIDetailedReport";

  // ─── App Troubleshoot / Support Log ────────────────────────────────────────
  static const String apiInsertAppLog         = "$port/api/AppLogApp/InsertAppLog";
}