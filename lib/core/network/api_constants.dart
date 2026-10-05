
import '../config/app_config.dart';

class ApiConstants {
  ApiConstants._();

  static const String port = AppConfig.baseUrl;

//static const String port = "https://maleva.my";
  // Demo servers:
  // static const String port = "http://103.215.139.121:9001/";
  //static const String port = "http://103.215.139.8:8001/";

  // ─── Image / File Upload ──────────────────────────────────────────────────

  // ─── Auth / Login ─────────────────────────────────────────────────────────

  // ─── Master Data ──────────────────────────────────────────────────────────
  static const String apiSelectCustomer   = "$port/api/CustomerApp/GetCustomer?Comid=";
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

  // ─── Sales Order ──────────────────────────────────────────────────────────

  // ─── RTI ──────────────────────────────────────────────────────────────────

  // ─── Stock ────────────────────────────────────────────────────────────────

  // ─── Truck & Driver ───────────────────────────────────────────────────────
  static const String apiEditTruckDetails     = "$port/api/TruckApp/SelectTruck?Comid=";
  static const String apiUpdateTruckDetails   = "$port/api/TruckApp/InsertTruck?Comid=";

  // ─── Fuel Entry ───────────────────────────────────────────────────────────

  // ─── Forwarding Salary ────────────────────────────────────────────────────

  // ─── Receipt / Transaction ────────────────────────────────────────────────

  // ─── Enquiry ──────────────────────────────────────────────────────────────

  // ─── Bill Order / Petty Cash ──────────────────────────────────────────────

  // ─── Spare Parts ──────────────────────────────────────────────────────────

  // ─── License ──────────────────────────────────────────────────────────────

  // ─── Dashboard ────────────────────────────────────────────────────────────

  // ─── Reports ──────────────────────────────────────────────────────────────

  // ─── App Troubleshoot / Support Log ────────────────────────────────────────
}