## 1. Routing

- [x] 1.1 `JavaRoute` (moved controllers and actions, URL rewrite) and Java routing in `ApiClient`, `LegacyApiRepository` and the legacy `DioClient` (an interceptor, so its direct callers follow too). Verify: `test/core/network/java_route_test.dart` (rewrite, not moved, token, caller headers, 500 message, string answer, legacy client untouched).

## 2. Controllers (each after its Java port, backend change add-mobile-app-api)

- [x] 2.1 FuelEntryApp. Later moved to the shared `/api/fuel-entries` (change `use-shared-lookup-apis`).
- [x] 2.2 TruckApp (later: shared APIs, change `use-shared-lookup-apis`)
- [x] 2.3 AddressApp, JobTypeApp, JobStatusApp, AgentApp, AgentCompanyApp, ItemApp, CustomerApp/GetCustomer, DriverApp/GetDriver. Verify: the direct callers (IR, sales order repositories) use the legacy `DioClient`, routed by its interceptor; `java_route_test.dart`.
- [ ] 2.4 SaleOrderApp (moved actions), SaleOrder
- [ ] 2.5 RTIApp, PlanningApp, VesselPlanningApp, VesselPlaning (moved actions)
- [ ] 2.6 CommonApp, Common, LoginApp, EmployeeApp, MasterReportApp (moved actions)
- [ ] 2.7 The controllers whose .NET source is missing move straight to the Java REST API the web uses (hybrid plan): IRApp and TruckLocationApp done in change `ir-and-truck-location-on-java-api`; StockApp moved on the Java stock API built from `SP_StockIn` and the app's calls (backend change `add-stock-app-api`, assumptions to confirm on a test server); the rest follow one change per module.

## 3. Checks

- [ ] 3.1 Analyzer and full test suite after each controller. Verify: no new failures.
- [ ] 3.2 On a test environment, use each moved screen as an employee and as a driver against the Java backend. Keep open until a test environment is available.
