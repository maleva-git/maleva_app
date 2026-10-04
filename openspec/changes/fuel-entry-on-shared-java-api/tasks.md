## 1. Client

- [x] 1.1 `FuelEntryApi`, `JsonRead.field` and DI. Verify: `test/core/fuel/fuel_entry_api_test.dart`.
- [x] 1.2 Maintenance Fuel Entry tab, driver add/list, Fuel Difference report and customer dashboard fuel on the Java fields. Verify: analyzer 0 errors.
- [x] 1.3 Fuel mappings, `SharedLookups` fuel methods and the fuel constants removed; adapter tests moved to the truck lookups. Verify: `legacy_call_adapter_test.dart`, `shared_lookups_test.dart`.
- [x] 1.4 Full suite. Verify: 254 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).

## 2. Open

- [ ] 2.1 On a test environment: maintenance tab (list a month, add, edit, delete); driver (add with an assigned truck, list, delete own entry); Fuel Difference report; customer dashboard fuel.
