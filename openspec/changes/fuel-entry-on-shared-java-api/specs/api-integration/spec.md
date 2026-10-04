## ADDED Requirements

### Requirement: Fuel screens on the shared fuel entry API

The maintenance Fuel Entry tab, the driver Fuel Entry screens, the Fuel Difference report and the
customer dashboard's fuel section SHALL use the shared Java `/api/fuel-entries` with the session
token, and SHALL read its fields. The app SHALL NOT send `FuelEntryApp` URLs, and `LegacyCallAdapter`
SHALL NOT answer them.

#### Scenario: Driver adds fuel
- **WHEN** a driver with an assigned truck saves litres and an amount
- **THEN** the app posts to `/api/fuel-entries` with `fStatus` 1 and shows the next number from `/api/fuel-entries/next-no`

#### Scenario: Driver deletes an entry
- **WHEN** a driver deletes an entry from their fuel list
- **THEN** the app calls `DELETE /api/fuel-entries/{id}` with `mobile=true` and lists again

#### Scenario: Refused save
- **WHEN** the server refuses a fuel save
- **THEN** the screen shows the server's message

#### Scenario: Maintenance list
- **WHEN** the maintenance Fuel Entry tab lists a month
- **THEN** each row shows the Java number, date, truck, litres and amounts, with the patron-minus-actual and patron-minus-GPS differences
