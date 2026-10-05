## 1. Client

- [x] 1.1 `LocationApi`, DI and `LocationModel.fromJava`; the Location picker on Java; the unused helper, .NET reader and constant removed. Verify: `test/core/lookups/location_api_test.dart`, network tests; analyzer 0 errors, no new warnings.
- [x] 1.2 Full suite. Verify: 306 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).

## 2. Open

- [ ] 2.1 On a test environment: Add Enquiry TR, pick an origin and a destination (list and search).
- [ ] 2.2 Backend: `LocationMasterController` is `@PermitAll` and its other endpoints are not company-scoped (separate change).
