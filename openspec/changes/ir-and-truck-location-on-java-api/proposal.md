# Proposal

## Why

The hybrid plan (change `move-mobile-api-to-java`): where the .NET source is missing, the app
moves straight to the Java REST API the React web app already uses, instead of a .NET copy. The IR
Report and Truck Location Board are the first two: their .NET endpoints (`IRApp`,
`TruckLocationApp`) are not in the local .NET copy, while Java's `/api/ir` and
`/api/truck-locations` serve the same screens on the web, with the company scoping, validation and
author stamping the .NET endpoints lacked.

## What Changes

- The IR data source calls `/api/ir` (list, one report, save, delete, statuses, departments)
  through `JavaApiClient`, with Java's camelCase JSON. The employee picker reads
  `/api/employees/company/{id}/all`; the truck and driver pickers keep their calls, which are
  already served by Java (`TruckApp/GetTruck`, `DriverApp/GetDriver`).
- The Truck Location data source calls `/api/truck-locations/week` (GET and POST) and
  `/api/truck-locations/order`.
- The report author and "modified by" come from the session token on the server; the app no
  longer sends a user id.
- Java's error bodies (`message`, validation `details`) reach the screen as the error text.
- Screens, blocs, entities and repositories' interfaces are unchanged.

## Capabilities

### Modified Capabilities
- `api-integration`: IR and Truck Location use the shared Java REST API.

## Impact

`lib/features/ir_report/data`, `lib/features/truck_location/data`, their injection, and a shared
`ApiFailure` error type. No backend change: both APIs accept mobile employee tokens; drivers have
no menu entry for either and stay refused, as on the web.
