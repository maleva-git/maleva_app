# Design

- **One generic model** (`PayableRecord`, `RecordDetail`, `RecordLine`, `RecordFile`) and one API class
  (`records/data/payable_records_api.dart`) mapping each Java answer to it, so the screens are the same for all six
  types. Field names come from the web mappers; every field is read without case (`JsonRead.field`) because Jackson
  writes some Lombok names both ways (`cNumberDisplay` / `cnumberDisplay`).
- **Envelopes:** `ApiResponse` `{IsSuccess, Data1}` via `JavaResponse.data`; the PO endpoints answer `{ok, data}`
  (detail `data` is a list → first item).
- **PO status:** `PStatus` 0 = Pending (the web's Pending filter), else Done; `BillStatus` (MAINTENANCE / SPARE PARTS…)
  is shown as the type chip. **Levy:** Completed when a payment voucher carries it.
- **Pay bill detail:** the edit answer lists the supplier's whole outstanding; only rows with an amount are this
  payment's bills.
- **Search and status filter on the phone** over the loaded period (the PO search on the server drops the dates).
- **Files:** `/api/attachments` list + `/summary` counts; the Upload tree is public (`/uploads/**`), so photos load with
  `cached_network_image` and other files open with `url_launcher`; Share sends the link. No new package.
- **Phone width:** period chips scroll sideways and the summary wraps (found by the 390 px widget test).
- Read only; create / edit / Push to Bill / PV / AI read are steps S3–S4 (`docs/payable/payable-app-plan.md`).

## Risks
- The endpoints are `@PermitAll` with the company from the request (existing gap, noted in the plan).
- Older PO status meaning (PStatus) is taken from the web's filter; owner to confirm on the phone.
