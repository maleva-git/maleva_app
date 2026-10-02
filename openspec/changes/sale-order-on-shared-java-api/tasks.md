## 1. Client

- [x] 1.1 `SaleOrderApi` and DI. Verify: `test/core/sale_order/sale_order_api_test.dart`.
- [x] 1.2 One Sale Order form on `edit()` / `save()` with `saleOrderSaveBody`; dashboard Add deleted; callers open by id. Verify: `test/features/transaction/sale_order_save_body_test.dart`.
- [x] 1.3 `SaleOrderDetails` by id; job pickers on `/job-numbers`.
- [x] 1.4 List, TV board, air freight, boarding, job status, forwarding, SMK, break seal, stock update, vessel report, BO check, sale update, planning windows, enquiry currency on Java.
- [x] 1.5 Dead helpers, globals and constants removed. Verify: analyzer 0 errors.
- [x] 1.6 Full suite. Verify: only the inherited Bluetooth failure.

## 2. Open

- [ ] 2.1 On a test environment with backend `port-sale-order-field-updates`: create, edit and enquiry-push a sale order; DO and invoice print; TV board ETA update; air freight, boarding (with photos and mail), forwarding, SMK and break seal updates; stock update at status 7 and 5; vessel report update; planning window saves; sale update trips.
- [ ] 2.2 Vessel planning web: move with the vessel planning screen (list and window as React's).
- [ ] 2.3 Enquiry status confirm: move when Java has the enquiry status API.
