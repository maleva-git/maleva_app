# Design

## RtiApi

`RtiApi(Dio, {companyId, javaBaseUrl})`, the same pattern as `JobOrderApi` and `FuelEntryApi`. Calls
carry the Java session token, and a failure throws `ApiFailure` with the server's message.

| Method | Call | Answer |
|---|---|---|
| `withJobs(fromDate, toDate, driverId, truckId, employeeId, search)` | `GET /api/rti-masters/with-jobs` (0 and blank not sent) | `RtiList` |
| `reportUrl(rtiId)` | `GET /api/rti-masters/{id}/report-ticket` | `javaBaseUrl` + `Url` |
| `numbers()` | `GET /api/rti-masters/company/{id}` (a bare list) | `[{CNumber, Id}]`, as `AppGlobals.JobNoList` holds them |
| `updateJobStatus(saleOrderId, statusName, imageUrls)` | `POST /api/rti-masters/jobs/{id}/status` | — |
| `routeActivities(fromDate, toDate, employeeId)` | `GET /api/rti-route-activities` | rows |
| `setRouteActivityStatus(id, status)` | `PUT /api/rti-route-activities/{id}/status` | — |

`numbers()` reads `cNumberDisplay` through `JsonRead.field`, because Jackson writes the Lombok name
as `cnumberDisplay`.

## Screens

- RTI View, PDO and TransportDB repositories return `RtiList`, and their blocs take
  `masters` / `details` from it. TransportDB and Update RTI still fill `AppGlobals.RTIViewMasterList`
  / `RTIViewDetailList`, which other code reads.
- The RTI Status bloc sends the same status text (`'<driverStatus> Done'`) and photo URLs as
  before. Success is a normal return; a refusal is the caught `ApiFailure`.
- The route activities bloc takes an optional `RtiApi` (default from GetIt). It sends the signed-in
  employee as `employeeRefId`, as before, and still updates the list optimistically after a status
  change.
