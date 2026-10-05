## 1. Client

- [x] 1.1 `DriverApi.combo`; the driver list callers moved; `LegacyCallAdapter`, `SharedLookups`, their hooks and DI, `GetTruckModel.fromJson` and the last .NET address removed. Verify: `test/core/fleet/driver_api_test.dart`, `java_route_test.dart`; analyzer 0 errors, warnings equal to the baseline.
- [x] 1.2 Full suite. Verify: 324 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).

## 2. Open

- [ ] 2.1 On a test environment: the Driver picker, Fuel entry drivers, IR report drivers.
- [ ] 2.2 End-to-end check: run the app against a server with the .NET API switched off and open each screen once.
- [ ] 2.3 Decide where `/Upload/...` file links should point once .NET is retired (Java serves the same Upload tree).
