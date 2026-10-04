# Proposal

## Why

The Job Orders tab (admin dashboard and maintenance dashboard) still called the old .NET
`JobOrderMasterApp` directly. The owner's rule (2026-10-02) says the app uses the same shared Java
API as the web, and reads the Java response as it is.

## What Changes

| Screen action | Before (.NET) | Now (shared Java) |
|---|---|---|
| Job order list + detail lines (by status, by truck) | `JobOrderMasterApp/SelectJoborder` | `POST /api/job-orders/list` (existing) |
| Status chips and the status picker | `JobOrderMasterApp/SelectJoborderType` | `GET /api/job-orders/statuses` (existing) |
| Long-press → change status | `JobOrderMasterApp/Updatejoborderstatus` | `PUT /api/job-orders/{id}/status` (new, backend change `share-job-order-status-update`) |
| Product name of a detail line | joined by .NET (`ProductMaster.PName`) | `GET /api/product-masters/company/{id}` (existing) |

- **New** `JobOrderApi` (`lib/core/job_order`), registered in `auth_injection.dart`, sends calls with
  the Java session token.
- `JobOrder`, `JobOrderDetail` and `JobOrderType` read the Java camelCase fields (`fromJava`). The
  .NET `fromJson` readers are removed.
- The detail lines come with each job order (`details`). The app shows only active lines
  (`active == 1`), as .NET did. The product name is looked up by `productRefId`.
- Dates (`jobDate`, `expectedCompletionDate`) are shown as `dd/MM/yyyy`, as before.
- The truck picker is unchanged. It already reads the shared Java trucks through `MasterApi.getTrucks`.

## Not changed

- The look of the screen, the filters, the default filter (status 1, all trucks), and refetching
  after a status change.
- A failed status change is still only logged and the list is not refetched, as before.

## Capabilities

### Modified Capabilities
- `api-integration`: the Job Orders tab uses the shared Java `/api/job-orders`.

## Impact

`lib/core/job_order/job_order_api.dart` (new), `lib/features/auth/auth_injection.dart`, and the
`dashboard/common_tabs/job_orders` bloc and models. Ships with backend change
`share-job-order-status-update`.
