# Proposal

## Why

The Inventory report called .NET `CustomerApp/SelectAllInventoryt`. Backend change
`share-cargo-inventory-api` ports it.

## What Changes

| Before (.NET) | Now (shared Java) |
|---|---|
| `POST SelectAllInventoryt {Comid, Fromdate, Todate, PortType, CustomerId, Status}` | `GET /api/sale-orders/inventory?companyId&portType&customerId&pending&fromDate&toDate` |

- **New** `CargoInventoryApi` (`lib/core/sale_order`), registered in `auth_injection.dart`.
- **`InventoryModel.fromJava` reads the Java line** (`cargoQty`, `jobStatus`, `cNumberDisplay`, ...). The .NET `fromJson` is removed.
- **The port chips and the "pending" tick are unchanged.** The tick sends `pending=true`, as `Status 1` did.
- **A refusal shows the server's message.**
- **Removed:** `ApiConstants.apiSelectAllInventory`. The network tests now use `apiDriverViewRecords` as their example of a call still on .NET.

## Behaviour changes

- **Deleted jobs no longer show as stock.**
- **The period includes the whole to-date.**

## Capabilities

### Modified Capabilities
- `api-integration`: the Inventory report uses the shared Java cargo inventory API.

## Impact

`lib/core/sale_order/cargo_inventory_api.dart` (new), `inventory_model.dart`,
`dashboard/common_tabs/inventoryreport/{data,bloc}`, `api_constants.dart`, `auth_injection.dart` and the
network tests. Ships with backend change `share-cargo-inventory-api`.
