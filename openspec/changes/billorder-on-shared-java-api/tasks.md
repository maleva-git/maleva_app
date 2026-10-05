## 1. Client

- [x] 1.1 `BillsOrderApi`, `PettyCashApi`, DI and the models' `fromJava`; Bill Order, Petty Cash and Change Status on Java; .NET readers, wrapper and constants removed. Verify: `test/core/finance/billorder_pettycash_api_test.dart`, `test/features/finance/change_status_test.dart`; analyzer 0 errors, no new warnings.
- [x] 1.2 Full suite. Verify: 293 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).

## 2. Open

- [ ] 2.1 On a test environment: Bill Order list for a period (only pending bills), Petty Cash list and its lines, compared with .NET for the same dates.
