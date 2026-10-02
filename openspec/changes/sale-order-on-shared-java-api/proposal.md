# Proposal

## Why

The sale order screens still called the .NET `SaleOrderApp` API, through five copies of the
EditSaleOrder load, two Add screens with different keys, and globals (`SaleEditMasterList`,
`JobNoList`, `ComboS1List`, ...) that one screen filled and another read. The owner's rule
(2026-10-02): the app uses the same Java API as React and reads its response as it is. Java and
React sale orders work; the calls Java lacked were ported from .NET in backend change
`port-sale-order-field-updates`.

## What Changes

- **New** `SaleOrderApi` (`lib/core/sale_order`): search, TV search, job numbers, the edit read,
  save (POST `/save` or PUT `/{id}`), the forwarding / boarding / boarding mail / air freight / trip
  updates, the vessel planning update (one job and several), the planning update, next job number,
  currency, invoice link and the DO / invoice report paths. A refusal is an `ApiFailure` with the
  server's message.
- **One Sale Order form**: `SalesOrdersAdd(saleOrderId:, saleOrderNo:, enquiry:)` reads the order
  with `edit()` (Java field names) and saves the Java `SaleOrderDTO` built by `saleOrderSaveBody`
  from the loaded order plus the form's fields. The broken dashboard `SalesOrderAdd` is deleted and
  every caller opens the one form by id. The form loads its own invoice number.
- `SaleOrderDetails` (read only) takes `saleOrderId`/`saleOrderNo` and loads after its lookups (no
  race between two events).
- Job pickers (view sale order, stock in entry, air freight, boarding, job status, forwarding,
  forwarding SMK, break seal) each load `/job-numbers` into their own state and read `id`/`cNumber`
  and `forwardingSMKNo..3`.
- Screens moved: sale order list (search, DO and invoice reports), TV board (tv-search, ticked jobs
  update), air freight, boarding details, job status update, forwarding, forwarding SMK, break seal,
  stock update boarding officers, vessel report update, BO check, sale update (trips), planning
  update windows, enquiry currency.
- Dead code removed: the dashboard Add screen, `LegacyApiRepository` sale order helpers
  (EditSalesOrder, MaxSaleOrderNo, GetJobNoForwarding, loadCustomerCurrency, loadComboS1,
  DeleteSalesOrder), `ViewSaleOrderRepository`, the saleorderview `SaleOrderRepository`,
  `ForwardingModel`, the globals and the `SaleOrderApp` constants, `CustDashboardEditSalesOrder`.

## Capabilities

### Modified Capabilities
- `api-integration`: sale orders use the shared Java APIs.

## Impact

`lib/core/sale_order`, `auth_injection.dart`, `injection.dart`, `api_constants.dart`,
`app_globals.dart`, `legacy_api_repository.dart`, the transaction sale order, view sale order,
enquiry, planning, air freight, boarding, forwarding and dashboard features. Ships with backend
change `port-sale-order-field-updates`.

Not moved: vessel planning web (its list is still .NET and its sheet edits the general boarding
officers, which the Java vessel planning window does not; it moves with the vessel planning screen)
and the enquiry status confirm after a save (no Java enquiry status API yet).
