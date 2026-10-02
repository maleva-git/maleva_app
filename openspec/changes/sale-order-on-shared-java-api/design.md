# Design

| Screen call (.NET) | Now (shared Java) |
|---|---|
| SelectSaleOrder | POST /api/sale-orders/search (`{salemaster, saledetails}`, .NET row names) |
| SelectTVSaleOrder | POST /api/sale-orders/tv-search?westport= |
| EditSaleOrder | GET /api/sale-orders/edit?id&saleOrderNo&companyId (`saleOrderMaster`, camelCase) |
| InsertSaleOrder | POST /api/sale-orders/save, PUT /api/sale-orders/{id} |
| MaxSaleOrderNo | GET /api/sequence-masters/company/{c}/max-sequence?billType |
| GetCurrencyValue | GET /api/currency-value/get |
| GetJobNo | GET /api/sale-orders/job-numbers?jobType (0 MY, 1 TR, 3 all) |
| UpdateForwarding | PUT /api/sale-orders/{id}/forwarding (only the fields sent) |
| UpdateBoardingDetails, SendBoardingMail | PUT /{id}/boarding, POST /{id}/boarding-mail |
| UpdateAirFrieght | PUT /{id}/air-freight |
| SearchSaleOrderForUpdate, UpdateSaleOrderFields | GET /trips, PUT /{id}/trip |
| UpdateSaleorderMaster (ticked ETA/ETB) | POST /api/vessel-plannings/sale-order-update-many |
| SaleOrder/UpdateSaleorder (vessel report), UpdateBoardingOfficier | POST /api/vessel-plannings/sale-order-update |
| SaleOrder/UpdateSaleorder (planning) | POST /api/planing/update-dates |
| DoConvert, InvoiceConvert, SelectInvoiceNumber | POST /{id}/do-convert/print-ticket, GET /{id}/invoice-link, GET /api/v1/sale-invoices/{id}/print-ticket |
| GetBillordercheck | POST /api/bills-order/select-bills-order-view (same .NET SelectBillsOrderView) |
| SelectComboS1 | none: the result was never read |

## Rules the app follows because of how the Java APIs write

- **Sale order update** (PUT `/{id}`): MapStruct skips null fields but clears the boarding officers
  and the ETA/ETB/ETD/OETA/OETB/OETD/pickup/delivery dates when null. `saleOrderSaveBody` therefore
  starts from the loaded master and puts the form's fields on top; an unticked date is null (cleared,
  as the web form). `forwardingDetails` is not sent, so the web's forwarding rows stay.
- **Vessel planning update**: the server compares all six officer slots with the job and treats a
  missing one as removed. `vesselUpdate` requires both sides; callers that change one side send the
  job's current other side (`SaleOrderApi.officers`). Amounts are the server's (50, 30, 20 each).
- **Planning update**: always writes origin, destination, quantity and weight, so `planningUpdate`
  reads the job first and sends them back. Stops are deleted only by the ids the window removed. The
  window's per-section SAVE buttons now save the whole window (the .NET `Type` saved one field).
- **Ticked jobs ETA/ETB** (TV board): `sale-order-update-many` keeps what is not sent; a job the
  rules refuse is shown by job number.

## .NET defects not carried over

- Stock update's boarding officer save (UpdateBoardingOfficier) wrote all twelve officer and amount
  columns from a body carrying one, wiping the off-vessel officers. Now only the loading side
  changes.
- The vessel report update (Type 100) wrote OETB/OETD from WareHouseExitDate (now when null) and
  cleared ETA/OETA it did not show; the Java update keeps a date that is not sent.
- Stock in entry asked GetJobNo with `Type=` instead of `JobType=`, so the bill type radio never
  changed the list.
- Job status update read an unregistered `sl<JobStatusUpdateBloc>()` and did not open.
- A job picked in one screen stayed in the shared globals for the next screen (e.g. the invoice
  number shown on the next order opened).

## Known gaps (Java side, not changed: React/Java are the reference)

- The edit read has no `Original` column, so Forwarding SMK's "Original" tick opens unticked (a
  save never clears it: Java writes it only when ticked).
- `select-bills-order-view` concatenates the search text into its SQL (quotes doubled).
