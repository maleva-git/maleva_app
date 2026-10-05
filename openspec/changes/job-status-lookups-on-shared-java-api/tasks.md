## 1. Client

- [x] 1.1 `JobStatusApi` and typed `JobSteps`; the three models' `fromJava`; every job status / steps caller moved; adapter entries, mappers, the old helper and constants removed. Verify: `test/core/lookups/job_status_api_test.dart`, lookup and adapter tests; analyzer 0 errors, warnings equal to the baseline.
- [x] 1.2 Full suite. Verify: 320 pass; only the inherited Bluetooth failure (`bluetooth_page_test`).

## 2. Open

- [ ] 2.1 On a test environment: job status pickers (Sales Order view, Spot Sale, Vessel report), a Sales Order add for each job type (fields shown per its steps), Enquiry TR, Job Status Update, Stock-in and Stock update status names, Sale Order details.
- [ ] 2.2 Next lookup groups: agents / agent companies, products, addresses, trucks, drivers.
