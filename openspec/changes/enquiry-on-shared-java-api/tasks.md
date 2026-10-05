## 1. Client (phase 1)

- [x] 1.1 `EnquiryApi` and DI; the six places on the Java list and status; converter and constants removed. Verify: `test/core/enquiry/enquiry_api_test.dart`, `sale_order_save_body_test.dart`, network tests, analyzer 0 errors.
- [x] 1.2 Full suite. Verify: 285 pass; only the inherited Bluetooth failure.

## 2. Open

- [x] 2.1 Enquiry save (Add Enquiry, Add Enquiry TR) on `EnquiryApi.save`. Verify: `enquiry_api_test.dart`, network tests; analyzer no new warnings; full suite 287 pass (only the inherited Bluetooth failure).
- [ ] 2.2 On a test environment: each list, cancel, edit prefill, an enquiry turned into a sale order (check it is CONFIRMED), and adding and editing an MY and a TR enquiry.
