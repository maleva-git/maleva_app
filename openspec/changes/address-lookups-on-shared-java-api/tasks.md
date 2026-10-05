## 1. Client

- [x] 1.1 `AddressApi`, `AddressDetailsModel.fromJava`; the address picker and Sales Order add moved; the unread Sale Order details request dropped; adapter entries, mappers and constants removed. Verify: `test/core/lookups/address_api_test.dart`, lookup and adapter tests; analyzer 0 errors, warnings equal to the baseline.
- [x] 1.2 Full suite. Verify: 326 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).

## 2. Open

- [ ] 2.1 On a test environment: the Address picker (list and search), and on Sales Order add the pickup / delivery / warehouse address fills.
- [ ] 2.2 Next lookup groups: trucks, drivers.
