## 1. Client

- [x] 1.1 `CustomerApi`, `JobTypeApi`, `MasterResponse`, the models' `fromJava`; every customer / job type caller moved; adapter entries, mappers and constants removed. Verify: `test/core/lookups/customer_job_type_api_test.dart`, lookup and adapter tests; analyzer 0 errors, no new warnings.
- [x] 1.2 Full suite. Verify: 321 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).

## 2. Open

- [ ] 2.1 On a test environment: the customer and job type pickers (Add Enquiry, Sales Order, Pre Alert, Spot Sale, Inventory) and Sale Order details names.
- [ ] 2.2 Next lookup groups: job statuses, agents / agent companies, products, addresses, trucks, drivers.
