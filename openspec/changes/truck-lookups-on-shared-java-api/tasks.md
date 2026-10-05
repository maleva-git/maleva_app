## 1. Client

- [x] 1.1 `TruckApi` (list, one truck, save), `GetTruckModel.fromJava`; License Update load and save on the Java truck; every truck list caller moved (including the IR report); adapter entries, mappers, helpers, readers and constants removed. Verify: `test/core/fleet/truck_api_test.dart`, lookup, adapter and route tests; analyzer 0 errors, warnings equal to the baseline.
- [x] 1.2 Full suite. Verify: 329 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).

## 2. Open

- [ ] 2.1 On a test environment: License Update (load a truck, change a date, untick one, save; check the web shows the same), the truck pickers (Job Orders, Fuel entry, Planning, Spare Parts, Summons, IR report).
- [ ] 2.2 Last lookup: drivers; then delete `LegacyCallAdapter`, `SharedLookups` and the last `ApiConstants`.
