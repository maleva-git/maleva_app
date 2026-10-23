## Why

Boarding officers and other employees enter fuel from the app for the company vehicles the office
gives them (Employee Master → Fuel vehicles). Full change:
`maleva-backend/openspec/changes/employee-fuel-vehicles`.

## What Changes

- `FuelEntryApi.myVehicles()` reads `GET /api/fuel-vehicles/mine` as Java answers it (`FuelVehicle`).
- Fuel Entry screen: a driver works as before (truck from their record). An employee sees their
  vehicles; with one it is picked automatically, with more a Vehicle picker is shown. Save sends the
  picked `truckRefId`, no driver, `fStatus` 1; litres and amount rules are unchanged.
- The menu row comes from the server session (no app menu change).
