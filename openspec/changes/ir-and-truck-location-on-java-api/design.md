# Design

## Contract mapping

IR (`IrController`):

| App call | Java | Notes |
|---|---|---|
| search(filter) | `GET /api/ir?companyRefId&fromDate&toDate&irStatusRefId&openOnly&search` | dates `yyyy-MM-dd`; status 0 and blank search are left out. `Data1 = {items, count, totalAmount}` |
| getById(id) | `GET /api/ir/{id}?companyRefId` | `Data1` = one report |
| save(draft) | `POST /api/ir` (body `IrSaveRequest`) | id 0 creates; ids 0 sent as null; author from the token |
| delete(id) | `DELETE /api/ir/{id}?companyRefId` | soft delete |
| statuses | `GET /api/ir/statuses?companyRefId` | `{id, statusCode, statusName, colorCode, finished}` |
| departments | `GET /api/ir/departments` | `{id, name}` |
| employees | `GET /api/employees/company/{id}/all` | bare list, `{id, employeeName}` |
| trucks, drivers | unchanged (`TruckApp/GetTruck`, `DriverApp/GetDriver`, served by Java) | `{Id, AccountName}` |

Truck Location (`TruckLocationBoardController`):

| App call | Java |
|---|---|
| week(date) | `GET /api/truck-locations/week?companyRefId&date` |
| saveWeek | `POST /api/truck-locations/week` `{companyRefId, weekStart, cells[{truckRefId, planDate, location}], doneTicks[{truckRefId, done}], dayDoneTicks: []}` |
| saveOrder | `POST /api/truck-locations/order` `{companyRefId, truckRefIds}` |

Rows: `{truckRefId, truckName, truckNumber, truckType, truckStatus, locations[7], lastKnownLocation, done}`.

## Errors

`ApiFailure(message, statusCode)` is the common error; `LegacyApiException` extends it.
`JavaResponse.data(body)` returns `Data1` of an `ApiResponse` (throws when `IsSuccess` is false);
`JavaResponse.fromDio(error)` takes `Message` (ApiResponse) or `message` plus `details`
(`ApiError`), else the timeout / no-connection / status texts the screens already use.

## Access

Both APIs accept employee tokens (web and mobile). A driver token is refused (403) outside
`/api/mobile/**`; drivers have no menu entry for these screens, so nothing is opened to them.

## Not done here

The Java employee list returns more fields than the picker needs (including `tokenId`); trimming
it is a backend security item (architecture Phase 0), not part of this change.
