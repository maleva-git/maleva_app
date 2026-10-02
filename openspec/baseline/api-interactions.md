# API interactions

Verified from client source on 2026-10-01. The configured base URL is
`https://mydriverszone.com` in [AppConfig](../../lib/core/config/app_config.dart).
The setup did not contact it. This is a client integration description, not a
server/OpenAPI contract or a claim about deployed API availability.

## Transport conventions

| Path | Verified request/response convention |
| --- | --- |
| `ApiClient.postRequest` | JSON POST; optional body; 30-second timeout. Default Content-Type plus Bearer/Userid/Profile when Tokenkey is nonempty, then caller headers override defaults. `skipAuth` uses supplied headers directly. HTTP 200 decodes JSON or returns `[]` for an empty body. 401/406/404/500 have configured error handling. |
| `ApiClient.getString` | Despite the method name, uses HTTP POST, without the shared auth-header builder. |
| `DioClient` | 15-second connect/receive timeouts; JSON content type; adds `Token` from SessionManager if nonempty. Logs request/response data and passes errors onward. |
| `LegacyApiRepository` | Uses Dio; generic helpers normalize maps/lists differently; `apiGetString` catches errors and returns an empty string. Specialized login/master helpers also update globals. |
| IR / Truck Location data sources | Dio POST plus `LegacyResponse.envelope`; Dio errors become `LegacyApiException`. Model mappers preserve endpoint-specific PascalCase keys. |
| Direct multipart | Upload helpers, RTI/PDO, and support uploads construct their own requests; do not assume shared JSON auth headers or timeouts apply. |

Evidence: [HTTP client](../../lib/core/network/api_client.dart),
[Dio client](../../lib/core/network/dio_client.dart),
[legacy repository](../../lib/core/network/legacy_api_repository.dart),
[envelope errors](../../lib/core/network/legacy_api_exception.dart).

## Reviewed workflow contracts

All methods in this table are POST as implemented in the reviewed call paths.
Names such as Get, Select, Edit, and Delete do not imply HTTP GET/PUT/DELETE.

| Workflow / source | Endpoint or family | Request and response observations |
| --- | --- | --- |
| [Mobile auth](../../lib/features/auth/data/mobile_auth_api.dart) (since 2026-10-01, change `move-mobile-login-to-java`) | Java `POST /api/mobile/auth/login`, `/refresh`, `/logout` on `AppConfig.javaBaseUrl` | userName, password, driver, deviceToken in a JSON body (never the URL). Responses use IsSuccess/Data1; Data1 holds the token, its expiries, the session fields and the menu rows (legacy keys). Only `JavaApiClient` sends the bearer token, and only to the Java host; 401 at sign-in = invalid credentials, at refresh = session ended. Replaces the .NET `/api/LoginApp/LoginAppSuccess`, which sent Userid/Pwd in the URL. |
| [Master lookups](../../lib/core/network/api_services/master_api.dart) | CustomerApp, EmployeeApp, LocationApp, AgentApp, JobTypeApp, TruckApp, DriverApp, StockApp | Company and type/reference filters vary by endpoint; most wrappers expect row lists. |
| [Sales entry](../../lib/features/transaction/salesorder/add/bloc/salesorderadd_bloc.dart) | SaleOrderApp/InsertSaleOrder; EnquiryMasterApp/UpdateEnquiryMaster | Order master/details are submitted with company context. A linked enquiry gets a separate CONFIRMED update after order success. |
| [Sales list](../../lib/features/transaction/salesorder/view/bloc/salesorderview_bloc.dart) | SaleOrderApp/SelectSaleOrder | Filter body includes date and selected customer/employee/status/text values. List/detail envelope handling is local to the feature. |
| [Transport planning](../../lib/features/transaction/planning/data/planning_repository.dart) | PlanningApp/SelectPLANING, PLANINGSearch, EditPLANING, PLANINGVIEW; `/api/PLANING/InsertPLANING` | Search uses company/date/employee/text; save sends a list of masters with SaleDetails and a Comid header. Save currently considers a nonempty result successful. |
| [Vessel planning](../../lib/features/dashboard/common_tabs/vesselplanningweb/data/vesselplanningweb_repository.dart) | VesselPlanningApp; `/VESSELPLANING/MaxVESSELPLANINGNo`; `/SaleOrder/UpdateSaleorder` | Search uses ETAType, Search, DeliveryDone, dates and employee. Parsing accepts several list/envelope forms. Some exceptions become empty lists or Success strings (Q07). |
| [Stock entry](../../lib/features/dashboard/common_tabs/stockinentry/data/stock_in_entry_repository.dart) | StockApp/InsertStockIn, SelectStockJob, MaxStockInNo; SaleOrderApp/EditSaleOrder | Entry assembles a stock master list with job/package/status and image URLs; returned Data2 provides the stock ID in the BLoC. |
| [Stock transfer](../../lib/features/dashboard/common_tabs/stocktransfer/data/stock_transfer_repository.dart) | StockApp/EditStockIn, UpdateStockTransfer, SelectPortList | Reads the scanned stock and warehouses, then updates selected stock/destination; success uses IsSuccess. |
| [Stock status](../../lib/features/dashboard/common_tabs/stockupdate/data/stock_update_repository.dart) | StockApp/UpdateStockIn; SaleOrderApp/UpdateBoardingOfficier | Status/warehouse/evidence update followed by a separate boarding-officer update. Preserve the endpoint spelling `Officier`. |
| [Forwarding](../../lib/features/operations/forwarding/bloc/forwarding_bloc.dart) | SaleOrderApp/UpdateForwarding | Three sections of seal/break employees, entry/exit refs, and SMK numbers plus sale-order/company/employee context. |
| [Boarding](../../lib/features/boarding/updateboardingdetails/bloc/updateboardingdetails_bloc.dart) | SaleOrderApp/UpdateBoardingDetails, SendBoardingMail | Update status and optional timestamps first; mail carries job/status/image URLs when images exist. |
| [Air freight](../../lib/features/airfreight/updateairfreight/bloc/airfreight_bloc.dart) | SaleOrderApp/UpdateAirFrieght | Id, Comid, Jobid, EmployeeRefId, StatusRefId, AWBNO; success uses IsSuccess. |
| [Fuel](../../lib/features/dashboard/common_tabs/fuelentry/data/fuelentry_repository.dart) | FuelEntryApp/SelectFuelEntry, InsertFuelEntry, DeleteFuelEntry | Date/company search; one-element model list for save; delete uses Id/Comid/Mobile=0. Save/delete treat nonnull results as successful. |
| [RTI/PDO](../../lib/features/dashboard/common_tabs/pdo/data/pdo_repository.dart) | RTIApp/SelectRTI, InsertRTIStatus | Filter query for selection; multipart fields objReceipt and Comid; optional files keyed Files_<detail ID>; HTTP 200 interpreted as success. |
| [Leave](../../lib/features/dashboard/common_tabs/driverleave/data/leave_repository.dart) | LeaveRequestApp/SaveLeaveRequest, GetLeaveRequests, UpdateLeaveStatus, GetLeaveTypes | Applicant/type/dates/reason/status and company for save; review payload has Id, StatusRefId, ReviewedBy, ReviewRemark; IsSuccess result. Caught errors return false or empty lists. A separate static helper also defines GetLeaveStatus. |
| [IR](../../lib/features/ir_report/data/datasources/ir_remote_data_source.dart) | Java `GET/POST /api/ir`, `GET/DELETE /api/ir/{id}`, `/api/ir/statuses`, `/api/ir/departments`, `/api/employees/company/{id}/all`; trucks/drivers via TruckApp/GetTruck and DriverApp/GetDriver (served by Java) | Moved by change `ir-and-truck-location-on-java-api`: camelCase JSON, `companyRefId` query, ApiResponse `Data1` (list = `{items, count, totalAmount}`); the author comes from the session token. |
| [Truck Location](../../lib/features/truck_location/data/models/truck_location_json.dart) | Java `GET/POST /api/truck-locations/week`, `POST /api/truck-locations/order` | Moved by change `ir-and-truck-location-on-java-api`: `companyRefId` + `date` query; save body `{companyRefId, weekStart, cells, doneTicks, dayDoneTicks}`; order `{companyRefId, truckRefIds}`. |
| [Customer balance](../../lib/features/dashboard/common_tabs/receiptview/data/receipt_repository.dart) | TransactionReportApp/SelectCustomerBalance | fromdate, tilldate, CompanyRefId; master list from Data1 and detail list from Data2. |
| [Email rows](../../lib/features/dashboard/common_tabs/emailinbox/data/emailinbox_repository.dart) | EmployeeApp/SelectEmailData, InsertMailMaster | Supplied row lists plus a Comid header. This does not independently establish external email sending. |
| [Common uploads](../../lib/core/network/api_client.dart) | CommonApp/UploadFile, UploadFile2, UploadPdfFile, FetchFiles, DeleteFile | Shared image helper uses MyImages0; shared file/PDF helper uses MyFiles0. Headers include Comid, Id, FolderName, FileName, SubFolderName. Call sites can use different helpers. |
| [Support log](../../lib/features/troubleshoot/data/applog_api.dart) | CommonApp/UploadFile2 | MyImages0 multipart part containing a temporary text file, image/jpeg content type, and Troubleshoot folder metadata. It does not call the separately declared InsertAppLog constant. |

The [endpoint inventory](endpoint-inventory.md) covers additional constants and
inline paths, and the [module inventory](module-inventory.md) lists report/utility
repositories. A declaration or reference count is not evidence of a successful
request or a reachable production screen.

## Boundary conventions to preserve in future plans

- Field names and route spelling vary, including `Comid` versus `CompanyRefId`,
  `PLANING`, `VESSELPLANING`, `Frieght`, and `Officier`.
- IR uses `yyyy-MM-dd` search dates and local formatted date-times without a zone
  suffix on save. Truck Location uses date-only strings. Do not assume UTC
  timestamp semantics across all modules.
- Newer `AppSession` returns employee ID 0 for a driver login. Legacy call paths
  can use raw stored IDs or globals instead.
- Empty results, transport failures, non-success envelopes, and successful empty
  bodies are not handled consistently. Baseline docs do not harmonize them.
- Common upload metadata, credentials in query parameters, certificate behavior,
  and logging are observed facts; changes require an explicit scoped plan.

See Q02–Q04, Q07, Q11, and Q12 in the [clarification register](clarifications.md).
