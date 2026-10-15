## Context

The Java API is already live in the backend change `sale-order-end-customer`. The app reads it
as is: `EndCustomerDto` is `{id, endCustomerName, remarks, active}` inside the usual `Data1`
wrapper; the sale order edit read adds `endCustomerRefId` / `endCustomerName` to
`saleOrderMaster`; the list adds `EndCustomerName` to each `salemaster` row.

## Decisions

- **Save sends the field always.** The form shows it, so the body carries `endCustomerRefId` (id or
  0). Loaded orders also carry it through `...loadedMaster`, which the form value overrides.
- **Customer change clears it** (0 / ''), as the web does: the list belongs to the customer.
- **A bottom sheet, not a new search page.** The list per customer is short; the sheet loads it,
  filters as you type, and offers "Add" for a typed name that is not in it. The server makes
  quick-add find-or-create, so a second spelling is never created.
- **The list shows "for <end customer>"** under the customer name only when there is one.

## Risks

- Until the owner runs `db/end-customer.sql` and deploys the backend, the end customer calls
  fail; the sheet shows the server's error and the rest of the form keeps working.
