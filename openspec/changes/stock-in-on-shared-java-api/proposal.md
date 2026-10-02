# Proposal

## Why

Stock In Entry, Stock Update and Stock Transfer used the Java bridge (`/api/mobile/app/StockApp`,
.NET-shaped). The owner's rule (2026-10-02) allows no bridges: the app uses the shared Java API.
Backend change `share-stock-in-api` ported .NET `StockServices` to `/api/stock-ins` and removed the
bridge.

## What Changes

- **New** `StockInApi` (`lib/core/stock`): the `/api/stock-ins` endpoints, read as they answer
  (common `{IsSuccess, Message, Data1}`, camelCase rows); a refusal or unknown label is an
  `ApiFailure` with the server's message.
- The three screens' repositories and blocs read the Java fields (`id`, `numberOfPackages`,
  `barcodeLabelDisplay`, `saleOrderMasterRefId`, `portMasterRefId`, `jobMasterRefId`, `jStatus`,
  ...); the save sends the Java row; label printing reads `/entries/{id}/label`.
- The warehouse picker (`mastersearch/WareHouseList`) and the vessel planning port filter read
  `/api/stock-ins/warehouses` (`WareHouseModel.fromJava`).
- A refused save, arrival or transfer, or an unknown label, now shows the server's reason (before,
  a refused save went back to the form silently).
- `JavaRoute.moved` is empty: nothing is bridged.
- Dead code removed: `OperationsApi`, `MasterApi.getStockJobs`, `LegacyApiRepository.SelectStockJob`
  and `MaxStockNo`, the StockApp constants.

## Capabilities

### Modified Capabilities
- `api-integration`: stock-in entry uses the shared Java `/api/stock-ins`.

## Impact

`lib/core/stock`, `lib/features/auth/auth_injection.dart`, the stock-in entry, stock update and
stock transfer features, `mastersearch/WareHouseList` (through `LegacyApiRepository`),
`MasterApi.getWarehouses`, `JavaRoute`. Ships with backend change `share-stock-in-api` (the bridge
is gone there).
