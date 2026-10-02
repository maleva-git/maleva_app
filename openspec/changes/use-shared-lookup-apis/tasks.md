## 1. Shared lookups

- [x] 1.1 `SharedLookups` for every lookup, License Update's truck read and save, and fuel entries. Verify: `test/core/lookups/shared_lookups_test.dart` (each wrapper, 404/204, mapping, truck merge, fuel filter and save).
- [x] 1.2 `LegacyCallAdapter` in `ApiClient`, `LegacyApiRepository` and `DioClient`; IR pickers on `SharedLookups`; `JavaRoute.moved` = StockApp. Verify: `legacy_call_adapter_test.dart`, `java_route_test.dart`, IR data-source tests.

## 2. Fixes and clean-up

- [x] 2.1 Driver fuel number loads; job steps read in their shape (four screens); RTI driver filter; License Update admin = not a driver; driver long-press does nothing. Verify: `job_steps_test.dart`, `transport_long_press_test.dart`, adapter test for the fuel number.
- [x] 2.2 Remove the dead lookup and fuel helpers. Verify: analyzer shows no new warnings.
- [x] 2.3 Analyzer and full test suite. Verify: no new failures.
- [ ] 2.4 On a test environment, as an employee and as a driver: every picker, License Update, Add RTI, Summon, Fuel Entry (save, list, delete), the maintenance fuel tab and the fuel report. Keep open until a test environment and the backend change are deployed.
