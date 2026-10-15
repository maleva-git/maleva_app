## Why

A customer often gives us a job on behalf of their own customer: CIVA (a forwarder) sends a job for
Daikin. The owner added an **End Customer** to the sale order on 2026-10-15 (backend and web change
`sale-order-end-customer`) and asked for it on the mobile app too.

## What Changes

- Sales order form: an **End Customer** field under Customer Name. It opens a sheet listing that
  customer's end customers (`GET /api/end-customers/customer/{id}`) with an "Add new" box
  (`POST /api/end-customers/customer/{id}/quick-add`). Changing or clearing the customer clears it.
- Save body: `endCustomerRefId` (the chosen id, 0 for none). The Java rule is null keeps, 0 clears.
- Sales order list: the end customer name under the customer name when the job has one
  (`EndCustomerName` from `/api/sale-orders/search`).

Shared Java API only (owner's rule 1); no backend change for the app. Not migrated from .NET: the
feature is new and `MalevaWeb-develop` has nothing for it.

## Capabilities

### Modified Capabilities

- `sales-enquiries`: the sales order form and list carry the end customer.

## Impact

- New `lib/core/end_customer/end_customer_api.dart`, registered in `auth_injection.dart`.
- `salesorder/add`: state, event, bloc, save body, tab, new `end_customer_sheet.dart`.
- `salesorder/models/sale_order_master_model.dart` and the list tab.
