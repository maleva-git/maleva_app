# Proposal

## Why

Eight app screens called .NET `MasterReportAppController`. The owner's rule (2026-10-02) says the
app uses the shared Java APIs React uses, and reads their fields.

## What Changes

| Screen | Before (.NET) | Now (shared Java) |
|---|---|---|
| Engine Hours | `SelectEngineHours` | `GET /api/gps/engine-hours` (React's GPS screen) |
| Fuel Fillings | `SelectFuelFillings` | `GET /api/gps/fuel-fillings` |
| Speeding report | `SpeedingReportView` | `GET /api/gps/speed-reports` |
| Truck Details (due in 5 days) | `TruckReportView` | `GET /api/master-reports/trucks/rows?until=` (new, backend `share-expiry-report-rows`) |
| Transport Maintenance (one truck) | `TruckReportView` | `GET /api/master-reports/trucks/rows?truckId=` |
| Driver dashboard: truck maintenance | `TruckReportView` | the same, limited to the driver's truck by the server |
| Driver Details | `DriverReportView` | `GET /api/master-reports/drivers/rows` |
| Driver dashboard: licence expiry | `DriverReportView` | the same, limited to the driver's own record by the server |

- **New** `GpsApi` and `ExpiryApi` (`lib/core/fleet`), registered in DI.
- **GPS model readers.** `EngineHoursdata`, `FuelFilling` and `SpeedingView` gain `fromJava`. Their
  times are shown as .NET showed them (`dd/MM/yyyy HH:mm:ss`), and the raw value is kept.
- **Truck reader.** `TruckDetailsModel.fromJavaExpiry` writes the dates as .NET did (`yyyy/MM/dd`).
  The views stay unchanged, and `fromJson` stays for the truck lookup.
- **Driver readers.** `DriverDetailsModel.fromJava` is added, and the licence tab reads the Java
  fields (`driverName`, `gdlExp`, `kuantanPort`, …).
- **Removed**: the five `MasterReportApp` URLs.

## Behaviour changes

- Fuel Fillings and Speeding now show the truck name and raw time. The app read them in lowercase
  and .NET sent them capitalised, so they were blank.
- The GPS lists include the whole to-date; .NET cut it at midnight.
- The driver dashboard's truck-maintenance tab now shows the truck. It expected a list and .NET sent
  a wrapper, so it was always empty.
- An empty truck or driver list is an empty list, not an error.
- The licence tab shows dates as `yyyy-MM-dd`.

## Capabilities

### Modified Capabilities
- `api-integration`: the GPS lists and the truck and driver expiry lists use the shared Java APIs.

## Impact

`lib/core/fleet/{gps_api,expiry_api}.dart`, the GPS, truck and driver models, the `enginehours`,
`fuelfillings`, `speedingreport`, `truck`, `driver`, `drivermaintenance` and `driverlicense`
features, `transport/maintenance`, `api_constants.dart` and `auth_injection.dart`. Ships with backend
change `share-expiry-report-rows`.
