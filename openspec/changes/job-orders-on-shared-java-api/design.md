# Design

## JobOrderApi

`JobOrderApi(Dio, {companyId})`, the same pattern as `SaleOrderApi`. All calls answer the Java data as
it comes, and a failure throws `ApiFailure` with the server's message (`JavaResponse`).

| Method | Call | Answer |
|---|---|---|
| `list(statusId, truckId)` | `POST /api/job-orders/list` `{companyRefId, statusRefId, truckMasterRefId}` (0 = any) | `Data1`: job orders, each with `details` |
| `statuses()` | `GET /api/job-orders/statuses` | `Data1`: `[{id, name}]` |
| `updateStatus(id, statusId)` | `PUT /api/job-orders/{id}/status?companyRefId&statusRefId` | `Data1`: the job order |
| `productNames()` | `GET /api/product-masters/company/{id}` | a bare list of `{id, pname}`, turned into an id → name map |

## Field mapping (Java → model)

| Model | Java |
|---|---|
| `cNumberDisplay` | `cNumberDisplay` (Jackson may write it as `cnumberDisplay`; the reader checks both) |
| `sJobDate` / `targetDate` | `jobDate` / `expectedCompletionDate` (`yyyy-MM-dd`, shown as `dd/MM/yyyy`) |
| detail `productName` | `productNames[productRefId]` |
| other fields | the same names in camelCase (`statusRefId`, `truckName`, `driverName`, ...) |

## Bloc

`JobOrdersBloc({JobOrderApi? api})` defaults to `GetIt.I<JobOrderApi>()`, so the two dashboards
construct it unchanged and tests can pass a fake API. Statuses, trucks and product names are loaded
once and cached, as before. The detail lines of all listed job orders are flattened into
`jobDetails`, which keeps the view's per-job filter (`jobOrderMasterRefId`) unchanged.
