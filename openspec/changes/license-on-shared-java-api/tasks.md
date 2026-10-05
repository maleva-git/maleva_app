## 1. Client

- [x] 1.1 `DriverApi`, DI and `LicenseViewModel.fromJava`; the License tab on Java; expiry warnings read `yyyy-MM-dd`; the .NET reader and constant removed. Verify: `test/core/fleet/driver_api_test.dart`, network tests; analyzer 0 errors, no new warnings.
- [x] 1.2 Full suite. Verify: 304 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).

## 2. Open

- [ ] 2.1 On a test environment: the HR Admin License tab lists the drivers, and a licence expiring within 30 days / expired shows its warning.
