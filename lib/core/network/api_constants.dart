
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
  static const String apiSelectAllInventory   = "$port/api/CustomerApp/SelectAllInventoryt";

  // ─── Sales Order ──────────────────────────────────────────────────────────
  static const String apiSelectBoardingSalaryNew = "$port/api/BoardingSalaryApp/SelectBoardingSalary";
  static const String apiSelectBoardingSalaryByEmpId = "$port/api/BoardingSalaryApp/SelectBoardingSalaryByEmpId";

  // ─── RTI ──────────────────────────────────────────────────────────────────

  // ─── Stock ────────────────────────────────────────────────────────────────

  // ─── Truck & Driver ───────────────────────────────────────────────────────
  static const String apiEditTruckDetails     = "$port/api/TruckApp/SelectTruck?Comid=";
  static const String apiUpdateTruckDetails   = "$port/api/TruckApp/InsertTruck?Comid=";
  static const String apiDriverViewRecords    = "$port/api/DriverApp/SelectDriver?Comid=";

  // ─── Fuel Entry ───────────────────────────────────────────────────────────

  // ─── Forwarding Salary ────────────────────────────────────────────────────
  static const String apiInsertForwarding     = "$port/api/ForwardingSalaryApp/InsertForwardingSalary";
  static const String apiSelectForwarding     = "$port/api/ForwardingSalaryApp/SelectForwardingSalary";

  // ─── Receipt / Transaction ────────────────────────────────────────────────
  static const String apiGetReceipt           = "$port/api/ReceiptApp/SelectReceipt?Comid=";
  static const String apiGetReceiptView       = "$port/api/ReceiptApp/SelectTruck?Comid=";

  // ─── Enquiry ──────────────────────────────────────────────────────────────

  // ─── Bill Order / Petty Cash ──────────────────────────────────────────────
  static const String apiBillorderview        = "$port/api/BIllorderApp/SelectBillsOrderApp?Comid=";
  static const String apiGetpettycash         = "$port/api/BIllorderApp/SelectpetticashApp?Comid=";
  static const String apiPettyCashview        = "$port/api/PettyCashApp/SelectPettyCashMaster?Comid=";

  // ─── Spare Parts ──────────────────────────────────────────────────────────

  // ─── License ──────────────────────────────────────────────────────────────
  static const String apiLicenseViewRecords   = "$port/api/LicenseApp/SelectLicense";

  // ─── Dashboard ────────────────────────────────────────────────────────────

  // ─── Reports ──────────────────────────────────────────────────────────────

  // ─── App Troubleshoot / Support Log ────────────────────────────────────────
  static const String apiInsertAppLog         = "$port/api/AppLogApp/InsertAppLog";
}